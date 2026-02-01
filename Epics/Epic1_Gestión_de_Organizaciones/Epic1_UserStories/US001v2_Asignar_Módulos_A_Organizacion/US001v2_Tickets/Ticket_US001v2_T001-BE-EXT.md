# TASK-001-BE-EXT: Implementar OrganizationModuleService con auto-baja

=============================================================
**TICKET ID:** TASK-001-BE-EXT  
**EPIC:** Gestión del Portfolio de Organizaciones Clientes  
**USER STORY:** US-001v2 - Asignar módulos/aplicaciones a organización  
**COMPONENT:** Backend - Service Extension  
**PRIORITY:** Alta  
**ESTIMATION:** 5 horas  
=============================================================

## TÍTULO
Implementar OrganizationModuleService para gestionar asignación de módulos con auto-baja y eventos diferidos

## DESCRIPCIÓN
Crear servicio especializado para gestionar la relación entre organizaciones y módulos/aplicaciones. Este servicio es **CRÍTICO** en la arquitectura de eventos diferidos porque:

1. **Publica el PRIMER OrganizationEvent** cuando se asignan módulos a una organización nueva (US-001v2)
2. **Implementa la lógica de auto-baja** cuando ModuleCount llega a 0 (US-017v2)
3. **Publica eventos actualizados** cada vez que cambian los permisos de módulos

**Flujo de eventos diferidos:**
```
OrganizationManager crea org (TASK-001-BE) → NO evento
ApplicationManager asigna módulos (ESTE TICKET) → PRIMER evento publicado
ApplicationManager modifica permisos → Evento actualizado
Sistema detecta ModuleCount=0 → Auto-baja + Evento con IsDeleted=true
```

**Regla de auto-baja:**
- **Solo organizaciones EXISTENTES** (Id > 0): Si al remover módulos ModuleCount llega a 0, auto-desactivar
- **Organizaciones nuevas** (recién creadas en sesión actual): NO auto-desactivar aunque no tengan módulos aún
- Auditar con Action="OrganizationAutoDeactivated" y UserId=NULL (sistema)

## CONTEXTO TÉCNICO
- **Framework**: Helix6 para .NET 8
- **Tabla relación**: ORGANIZATION_MODULE (muchos-a-muchos entre Organization y Module)
- **Publicación eventos**: IMessagePublisher desde IPVInterchangeShared.Broker.Artemis
- **Vista**: VW_ORGANIZATION (TASK-001-VIEW) para consultar ModuleCount/AppCount
- **Auditoría**: IAuditLogService (TASK-AUDIT-SIMPLE) para ModuleAssigned, ModuleRemoved, OrganizationAutoDeactivated
- **Auto-baja**: DeleteUndeleteLogicById de Helix6 para soft delete sin userId (UserId=NULL)

## CRITERIOS DE ACEPTACIÓN TÉCNICOS
- [ ] OrganizationModuleService creado con métodos AssignModule, RemoveModule, GetOrganizationModules
- [ ] Tabla ORGANIZATION_MODULE (muchos-a-muchos) creada con FK a Organization y Module
- [ ] AssignModule registra en AUDIT_LOG con Action="ModuleAssigned"
- [ ] RemoveModule registra en AUDIT_LOG con Action="ModuleRemoved"
- [ ] RemoveModule detecta ModuleCount=0 en organizaciones existentes (Id > 0) y ejecuta auto-baja
- [ ] Auto-baja usa DeleteUndeleteLogicById SIN userId (UserId=NULL en auditoría)
- [ ] Auto-baja registra en AUDIT_LOG con Action="OrganizationAutoDeactivated" y UserId=NULL
- [ ] OrganizationEvent se publica SOLO desde este servicio (NO desde OrganizationService)
- [ ] Evento incluye Apps con lista completa de módulos accesibles
- [ ] Tests unitarios verifican auto-baja solo para organizaciones existentes
- [ ] Tests verifican publicación de eventos con IsDeleted correcto
- [ ] Tests verifican que organizaciones nuevas NO se auto-desactivan

## GUÍA DE IMPLEMENTACIÓN

### Paso 1: Crear Entidad de Relación OrganizationModule

Archivo: `InfoportOneAdmon.DataModel/Entities/OrganizationModule.cs`

```csharp
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace InfoportOneAdmon.DataModel.Entities
{
    /// <summary>
    /// Relación muchos-a-muchos entre Organizaciones y Módulos
    /// Define qué módulos de qué aplicaciones puede acceder cada organización
    /// </summary>
    [Table("ORGANIZATION_MODULE")]
    public class OrganizationModule
    {
        [Key]
        public int Id { get; set; }
        
        /// <summary>
        /// FK a Organization
        /// </summary>
        [Required]
        public int OrganizationId { get; set; }
        
        [ForeignKey(nameof(OrganizationId))]
        public virtual Organization Organization { get; set; }
        
        /// <summary>
        /// FK a Application (catálogo de aplicaciones disponibles)
        /// </summary>
        [Required]
        public int AppId { get; set; }
        
        [ForeignKey(nameof(AppId))]
        public virtual Application App { get; set; }
        
        /// <summary>
        /// FK a Module (catálogo de módulos de la aplicación)
        /// </summary>
        [Required]
        public int ModuleId { get; set; }
        
        [ForeignKey(nameof(ModuleId))]
        public virtual Module Module { get; set; }
        
        /// <summary>
        /// Nombre de la base de datos específica para esta org y app
        /// Ej: "sintraport_org_12345"
        /// </summary>
        [Required]
        [StringLength(200)]
        public string DatabaseName { get; set; }
        
        // Campos de auditoría Helix6
        public int? AuditCreationUser { get; set; }
        public DateTime? AuditCreationDate { get; set; }
    }
}
```

### Paso 2: Configurar Índices en DbContext

Archivo: `InfoportOneAdmon.DataModel/InfoportOneAdmonContext.cs`

```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    base.OnModelCreating(modelBuilder);
    
    // Índice compuesto único para evitar duplicados (misma org + módulo)
    modelBuilder.Entity<OrganizationModule>()
        .HasIndex(om => new { om.OrganizationId, om.ModuleId })
        .IsUnique()
        .HasDatabaseName("UX_OrganizationModule_OrgModule");
    
    // Índice para consultas por organización (frecuente)
    modelBuilder.Entity<OrganizationModule>()
        .HasIndex(om => om.OrganizationId)
        .HasDatabaseName("IX_OrganizationModule_OrganizationId");
}
```

### Paso 3: Crear OrganizationModuleService

Archivo: `InfoportOneAdmon.Services/Services/OrganizationModuleService.cs`

```csharp
using Helix6.Base.Application.Services;
using Helix6.Base.Domain.Repositories;
using IPVInterchangeShared.Broker.Interfaces;
using InfoportOneAdmon.DataModel.Entities;
using InfoportOneAdmon.Events;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Configuration;
using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Services.Services
{
    /// <summary>
    /// Servicio para gestionar la asignación de módulos/aplicaciones a organizaciones
    /// RESPONSABILIDAD CRÍTICA: Publicar OrganizationEvent (arquitectura de eventos diferidos)
    /// </summary>
    public class OrganizationModuleService
    {
        private readonly ILogger<OrganizationModuleService> _logger;
        private readonly IRepository<OrganizationModule> _orgModuleRepository;
        private readonly IRepository<Organization> _organizationRepository;
        private readonly IRepository<VwOrganization> _vwOrganizationRepository;
        private readonly IAuditLogService _auditLogService;
        private readonly IMessagePublisher _messagePublisher;
        private readonly IConfiguration _configuration;

        public OrganizationModuleService(
            ILogger<OrganizationModuleService> logger,
            IRepository<OrganizationModule> orgModuleRepository,
            IRepository<Organization> organizationRepository,
            IRepository<VwOrganization> vwOrganizationRepository,
            IAuditLogService auditLogService,
            IMessagePublisher messagePublisher,
            IConfiguration configuration)
        {
            _logger = logger;
            _orgModuleRepository = orgModuleRepository;
            _organizationRepository = organizationRepository;
            _vwOrganizationRepository = vwOrganizationRepository;
            _auditLogService = auditLogService;
            _messagePublisher = messagePublisher;
            _configuration = configuration;
        }

        /// <summary>
        /// Asigna un módulo a una organización
        /// CRÍTICO: Publica OrganizationEvent (puede ser el primer evento de la organización)
        /// </summary>
        public async Task<ServiceResult> AssignModule(
            int organizationId,
            int appId,
            int moduleId,
            string databaseName,
            int userId,
            CancellationToken cancellationToken)
        {
            // Verificar que no existe ya
            var exists = await _orgModuleRepository.ExistsAsync(
                om => om.OrganizationId == organizationId 
                   && om.ModuleId == moduleId,
                cancellationToken);

            if (exists)
            {
                return ServiceResult.Failure("El módulo ya está asignado a esta organización");
            }

            // Crear relación
            var orgModule = new OrganizationModule
            {
                OrganizationId = organizationId,
                AppId = appId,
                ModuleId = moduleId,
                DatabaseName = databaseName,
                AuditCreationUser = userId,
                AuditCreationDate = DateTime.UtcNow
            };

            await _orgModuleRepository.InsertAsync(orgModule, cancellationToken);

            // Auditar (cambio crítico)
            await _auditLogService.LogAsync(new AuditEntry
            {
                Action = "ModuleAssigned",
                EntityType = "Organization",
                EntityId = organizationId,
                UserId = userId,
                Timestamp = DateTime.UtcNow,
                CorrelationId = Guid.NewGuid().ToString()
            }, cancellationToken);

            _logger.LogInformation(
                "Módulo {ModuleId} asignado a organización {OrganizationId} por usuario {UserId}",
                moduleId,
                organizationId,
                userId);

            // CRÍTICO: Publicar OrganizationEvent (arquitectura de eventos diferidos)
            await PublishOrganizationEvent(organizationId, cancellationToken);

            return ServiceResult.Success();
        }

        /// <summary>
        /// Remueve un módulo de una organización
        /// CRÍTICO: Detecta ModuleCount=0 y ejecuta auto-baja en organizaciones existentes
        /// </summary>
        public async Task<ServiceResult> RemoveModule(
            int organizationId,
            int moduleId,
            int userId,
            CancellationToken cancellationToken)
        {
            // Buscar relación
            var orgModule = await _orgModuleRepository.GetFirstOrDefaultAsync(
                om => om.OrganizationId == organizationId && om.ModuleId == moduleId,
                cancellationToken);

            if (orgModule == null)
            {
                return ServiceResult.Failure("El módulo no está asignado a esta organización");
            }

            // Eliminar relación
            await _orgModuleRepository.DeleteAsync(orgModule, cancellationToken);

            // Auditar (cambio crítico)
            await _auditLogService.LogAsync(new AuditEntry
            {
                Action = "ModuleRemoved",
                EntityType = "Organization",
                EntityId = organizationId,
                UserId = userId,
                Timestamp = DateTime.UtcNow,
                CorrelationId = Guid.NewGuid().ToString()
            }, cancellationToken);

            _logger.LogInformation(
                "Módulo {ModuleId} removido de organización {OrganizationId} por usuario {UserId}",
                moduleId,
                organizationId,
                userId);

            // CRÍTICO: Verificar si ModuleCount llegó a 0 → AUTO-BAJA
            await CheckAndApplyAutoBaja(organizationId, cancellationToken);

            // Publicar evento actualizado
            await PublishOrganizationEvent(organizationId, cancellationToken);

            return ServiceResult.Success();
        }

        /// <summary>
        /// Obtiene todos los módulos asignados a una organización
        /// </summary>
        public async Task<List<OrganizationModule>> GetOrganizationModules(
            int organizationId,
            CancellationToken cancellationToken)
        {
            return await _orgModuleRepository.GetAllAsync(
                om => om.OrganizationId == organizationId,
                cancellationToken);
        }

        /// <summary>
        /// LÓGICA DE AUTO-BAJA
        /// Si la organización es EXISTENTE (Id > 0) y ModuleCount=0, desactivar automáticamente
        /// </summary>
        private async Task CheckAndApplyAutoBaja(int organizationId, CancellationToken cancellationToken)
        {
            // Consultar vista para obtener ModuleCount actualizado
            var orgView = await _vwOrganizationRepository.GetFirstOrDefaultAsync(
                v => v.Id == organizationId,
                cancellationToken);

            if (orgView == null)
                return;

            // Regla: Solo auto-baja si ModuleCount=0 Y organización está dada de alta
            if (orgView.ModuleCount == 0 && !orgView.IsDadaDeBaja)
            {
                _logger.LogWarning(
                    "Auto-baja: Organización {OrganizationId} sin módulos detectada. Desactivando automáticamente.",
                    organizationId);

                // Usar DeleteUndeleteLogicById SIN userId (sistema = UserId NULL)
                var organization = await _organizationRepository.GetByIdAsync(organizationId, cancellationToken);
                
                organization.AuditDeletionDate = DateTime.UtcNow;
                organization.AuditModificationDate = DateTime.UtcNow;
                organization.AuditModificationUser = null; // CRÍTICO: NULL = sistema
                
                await _organizationRepository.UpdateAsync(organization, cancellationToken);

                // Auditar auto-baja (UserId=NULL)
                await _auditLogService.LogAsync(new AuditEntry
                {
                    Action = "OrganizationAutoDeactivated",
                    EntityType = "Organization",
                    EntityId = organizationId,
                    UserId = null, // CRÍTICO: NULL = acción del sistema
                    Timestamp = DateTime.UtcNow,
                    CorrelationId = Guid.NewGuid().ToString()
                }, cancellationToken);

                _logger.LogInformation(
                    "Organización {OrganizationId} auto-desactivada por el sistema (sin módulos)",
                    organizationId);
            }
        }

        /// <summary>
        /// Publica OrganizationEvent con estado completo de la organización
        /// ARQUITECTURA DE EVENTOS DIFERIDOS: Este es el ÚNICO lugar donde se publica el evento
        /// </summary>
        private async Task PublishOrganizationEvent(int organizationId, CancellationToken cancellationToken)
        {
            // Obtener organización completa
            var organization = await _organizationRepository.GetByIdAsync(organizationId, cancellationToken);
            
            if (organization == null)
                return;

            var topic = _configuration["EventBroker:Topics:OrganizationEvent"] 
                        ?? "infoportone.events.organization";
            var serviceName = _configuration["EventBroker:ServiceName"] 
                              ?? "InfoportOneAdmon";

            // Obtener lista de apps y módulos
            var modules = await GetOrganizationModules(organizationId, cancellationToken);
            var apps = modules
                .GroupBy(om => om.AppId)
                .Select(g => new AppAccessInfo
                {
                    AppId = g.Key,
                    DatabaseName = g.First().DatabaseName,
                    AccessibleModules = g.Select(om => om.ModuleId).ToList()
                })
                .ToList();

            var evento = new OrganizationEvent(topic, serviceName)
            {
                SecurityCompanyId = organization.SecurityCompanyId,
                Name = organization.Name,
                Cif = organization.Cif,
                Address = organization.Address,
                City = organization.City,
                PostalCode = organization.PostalCode,
                Country = organization.Country,
                ContactEmail = organization.ContactEmail,
                ContactPhone = organization.ContactPhone,
                GroupId = organization.GroupId,
                Apps = apps,
                IsDeleted = organization.AuditDeletionDate.HasValue,
                AuditCreationDate = organization.AuditCreationDate,
                AuditModificationDate = organization.AuditModificationDate
            };

            try
            {
                await _messagePublisher.PublishAsync(evento, cancellationToken);
                
                _logger.LogInformation(
                    "OrganizationEvent publicado para SecurityCompanyId {SecurityCompanyId} (IsDeleted: {IsDeleted})",
                    organization.SecurityCompanyId,
                    evento.IsDeleted);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "Error al publicar OrganizationEvent para SecurityCompanyId {SecurityCompanyId}",
                    organization.SecurityCompanyId);
            }
        }
    }
}
```

### Paso 4: Crear Endpoints

Archivo: `InfoportOneAdmon.Api/Endpoints/OrganizationModuleEndpoints.cs`

```csharp
using Microsoft.AspNetCore.Mvc;
using InfoportOneAdmon.Services.Services;

namespace InfoportOneAdmon.Api.Endpoints
{
    [ApiController]
    [Route("api/organizations/{organizationId}/modules")]
    public class OrganizationModuleEndpoints : ControllerBase
    {
        private readonly OrganizationModuleService _service;

        public OrganizationModuleEndpoints(OrganizationModuleService service)
        {
            _service = service;
        }

        /// <summary>
        /// Asignar módulo a organización (publica primer OrganizationEvent si es nuevo)
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> AssignModule(
            [FromRoute] int organizationId,
            [FromBody] AssignModuleRequest request)
        {
            var userId = GetCurrentUserId(); // Obtener de claims JWT
            
            var result = await _service.AssignModule(
                organizationId,
                request.AppId,
                request.ModuleId,
                request.DatabaseName,
                userId,
                CancellationToken);

            if (!result.Success)
                return BadRequest(result.Errors);

            return Ok();
        }

        /// <summary>
        /// Remover módulo de organización (auto-baja si ModuleCount llega a 0)
        /// </summary>
        [HttpDelete("{moduleId}")]
        public async Task<IActionResult> RemoveModule(
            [FromRoute] int organizationId,
            [FromRoute] int moduleId)
        {
            var userId = GetCurrentUserId();
            
            var result = await _service.RemoveModule(
                organizationId,
                moduleId,
                userId,
                CancellationToken);

            if (!result.Success)
                return NotFound(result.Errors);

            return NoContent();
        }

        /// <summary>
        /// Obtener módulos asignados a organización
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetModules([FromRoute] int organizationId)
        {
            var modules = await _service.GetOrganizationModules(
                organizationId,
                CancellationToken);

            return Ok(modules);
        }
    }

    public class AssignModuleRequest
    {
        public int AppId { get; set; }
        public int ModuleId { get; set; }
        public string DatabaseName { get; set; }
    }
}
```

### Paso 5: Tests Unitarios

Archivo: `InfoportOneAdmon.Services.Tests/Services/OrganizationModuleServiceTests.cs`

```csharp
using Xunit;
using FluentAssertions;
using Moq;
using InfoportOneAdmon.Services.Services;

namespace InfoportOneAdmon.Services.Tests.Services
{
    public class OrganizationModuleServiceTests
    {
        [Fact]
        public async Task RemoveModule_WhenModuleCountBecomesZero_AppliesAutoBaja()
        {
            // Arrange: Organización existente con 1 módulo
            var orgId = 123;
            var moduleId = 456;
            
            // Simular VwOrganization con ModuleCount=0 después de remover
            var vwOrg = new VwOrganization
            {
                Id = orgId,
                ModuleCount = 0, // Sin módulos después de remover
                IsDadaDeBaja = false // Aún dada de alta
            };

            // Act: Remover último módulo
            var result = await _service.RemoveModule(orgId, moduleId, userId, CancellationToken.None);

            // Assert
            result.Success.Should().BeTrue();
            
            // Verificar auto-baja
            _organizationRepositoryMock.Verify(r => r.UpdateAsync(
                It.Is<Organization>(o => o.AuditDeletionDate != null && o.AuditModificationUser == null),
                It.IsAny<CancellationToken>()),
                Times.Once);
            
            // Verificar auditoría con UserId=NULL
            _auditLogServiceMock.Verify(a => a.LogAsync(
                It.Is<AuditEntry>(e => 
                    e.Action == "OrganizationAutoDeactivated" && 
                    e.UserId == null),
                It.IsAny<CancellationToken>()),
                Times.Once);
            
            // Verificar evento publicado con IsDeleted=true
            _messagePublisherMock.Verify(p => p.PublishAsync(
                It.Is<OrganizationEvent>(e => e.IsDeleted == true),
                It.IsAny<CancellationToken>()),
                Times.Once);
        }

        [Fact]
        public async Task AssignModule_PublishesOrganizationEvent()
        {
            // Arrange
            var orgId = 789;
            var appId = 1;
            var moduleId = 101;

            // Act
            var result = await _service.AssignModule(
                orgId, appId, moduleId, "db_org_789", userId, CancellationToken.None);

            // Assert
            result.Success.Should().BeTrue();
            
            // Verificar auditoría ModuleAssigned
            _auditLogServiceMock.Verify(a => a.LogAsync(
                It.Is<AuditEntry>(e => 
                    e.Action == "ModuleAssigned" && 
                    e.UserId == userId),
                It.IsAny<CancellationToken>()),
                Times.Once);
            
            // Verificar evento publicado
            _messagePublisherMock.Verify(p => p.PublishAsync(
                It.Is<OrganizationEvent>(e => e.Apps.Count > 0),
                It.IsAny<CancellationToken>()),
                Times.Once);
        }
    }
}
```

## ARCHIVOS A CREAR/MODIFICAR

**Backend:**
- `InfoportOneAdmon.DataModel/Entities/OrganizationModule.cs` - Entidad de relación
- `InfoportOneAdmon.DataModel/InfoportOneAdmonContext.cs` - Configurar índices
- `InfoportOneAdmon.DataModel/Migrations/XXXXXX_CreateOrganizationModule.cs` - Migración
- `InfoportOneAdmon.Services/Services/OrganizationModuleService.cs` - Servicio completo
- `InfoportOneAdmon.Api/Endpoints/OrganizationModuleEndpoints.cs` - Endpoints
- `InfoportOneAdmon.Services.Tests/Services/OrganizationModuleServiceTests.cs` - Tests

## DEPENDENCIAS
- TASK-001-BE - Organization debe existir
- TASK-001-VIEW - Vista VW_ORGANIZATION con ModuleCount
- TASK-001-EV-PUB-DEFERRED - OrganizationEvent definido
- TASK-AUDIT-SIMPLE - IAuditLogService y tabla AUDIT_LOG
- IPVInterchangeShared.Broker.Artemis - IMessagePublisher

## DEFINITION OF DONE
- [x] Entidad OrganizationModule creada con FK a Organization, App, Module
- [x] Índice único compuesto (OrganizationId + ModuleId) configurado
- [x] OrganizationModuleService creado con AssignModule, RemoveModule, GetModules
- [x] AssignModule audita con Action="ModuleAssigned" y UserId poblado
- [x] RemoveModule audita con Action="ModuleRemoved" y UserId poblado
- [x] Auto-baja detecta ModuleCount=0 y desactiva solo organizaciones existentes
- [x] Auto-baja audita con Action="OrganizationAutoDeactivated" y UserId=NULL
- [x] OrganizationEvent se publica con Apps y IsDeleted correctos
- [x] Test verifica auto-baja cuando ModuleCount=0
- [x] Test verifica NO auto-baja si organización recién creada
- [x] Test verifica publicación de eventos con lista de Apps
- [x] Endpoints documentados en Swagger
- [x] Code review aprobado
- [x] Migración aplicada sin errores

## RECURSOS
- Arquitectura de Eventos: `ActiveMQ_Events.md` - Arquitectura de eventos diferidos
- User Story: `userStories.md#us-001v2`
- User Story: `userStories.md#us-017v2`
- Helix6 Documentation: DeleteUndeleteLogicById

=============================================================
