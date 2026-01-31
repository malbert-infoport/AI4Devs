# Tickets Técnicos - Épica 3: Configuración de Módulos y Permisos de Acceso

**Generado desde:** User Stories (userStories.md)  
**Fecha de generación:** 31 de enero de 2026  
**Arquitecturas de referencia:**
- Backend: Helix6_Backend_Architecture.md
- Frontend: Helix6_Frontend_Architecture.md
- Eventos: ActiveMQ_Events.md

---

## Resumen de la Épica

Esta épica implementa el sistema de licenciamiento granular mediante módulos funcionales. Permite definir módulos dentro de cada aplicación siguiendo la nomenclatura `M{Prefix}_{NombreDescriptivo}`, asignarlos individualmente o masivamente a organizaciones, y visualizar matrices de permisos organización-módulo. El sistema soporta soft delete para revocación de accesos y publica eventos de estado para sincronización con aplicaciones satélite.

**Funcionalidades principales:**
- Definición de módulos con nomenclatura validada
- Asignación N:M entre organizaciones y módulos con soft delete
- Configuración masiva de accesos por lotes
- Matriz interactiva de permisos con exportación a Excel
- Sincronización mediante eventos OrganizationEvent y ApplicationEvent

**Tecnologías principales:**
- Backend: .NET 8 con Helix6 Framework, Entity Framework Core 9.0, PostgreSQL 16
- Frontend: Angular 20 Standalone Components, @cl/common-library (ClGrid, ClModal, ClAccordion, ClCheckbox)
- Eventos: ActiveMQ Artemis con IPVInterchangeShared (patrón State Transfer)
- Exportación: SheetJS para generación de Excel desde frontend

---

## Índice de Tickets - Épica 3

### US-016: Definir módulos funcionales de una aplicación
- [TASK-016-BE: Entidad Module con validaciones de nomenclatura](#task-016-be-entidad-module-con-validaciones-de-nomenclatura)
- [TASK-016-EV-PUB: Actualizar ApplicationEvent con lista de módulos](#task-016-ev-pub-actualizar-applicationevent-con-lista-de-módulos)
- [TASK-016-FE: Implementar grid de módulos con modal de creación/edición](#task-016-fe-implementar-grid-de-módulos-con-modal-de-creaciónedición)

### US-017: Asignar módulos de una aplicación a una organización
- [TASK-017-BE: Entidad ModuleAccess y publicación de OrganizationEvent](#task-017-be-entidad-moduleaccess-y-publicación-de-organizationevent)
- [TASK-017-FE: Implementar UI de asignación de módulos a organización](#task-017-fe-implementar-ui-de-asignación-de-módulos-a-organización)

### US-018: Configurar acceso masivo de módulos
- [TASK-018-BE: Endpoint de asignación masiva de módulos](#task-018-be-endpoint-de-asignación-masiva-de-módulos)
- [TASK-018-FE: UI de configuración masiva de módulos](#task-018-fe-ui-de-configuración-masiva-de-módulos)

### US-019: Revocar acceso a módulo de organización
- [TASK-019-NOTE: Funcionalidad de revocación ya implementada](#task-019-note-funcionalidad-de-revocación-ya-implementada)

### US-020: Visualizar matriz de permisos organización-módulo
- [TASK-020-FE: Implementar UI de matriz de permisos organización-módulo](#task-020-fe-implementar-ui-de-matriz-de-permisos-organización-módulo)

---

## Épica 3: Configuración de Módulos y Permisos de Acceso

### US-017: Asignar módulos de una aplicación a una organización

**Resumen de tickets generados:**
- TASK-017-BE: Entidad ModuleAccess (N:M soft delete) con publicación de OrganizationEvent
- TASK-017-FE: UI de asignación de módulos con checklist

---

#### TASK-017-BE: Entidad ModuleAccess y publicación de OrganizationEvent

=============================================================
**TICKET ID:** TASK-017-BE  
**EPIC:** Configuración de Módulos y Permisos de Acceso  
**USER STORY:** US-017 - Asignar módulos de una aplicación a una organización  
**COMPONENT:** Backend  
**PRIORITY:** Alta  
**ESTIMATION:** 5 horas  
=============================================================

**TÍTULO:**
Implementar entidad ModuleAccess (N:M) con publicación de OrganizationEvent

**DESCRIPCIÓN:**
Crear la tabla de relación `MODULE_ACCESS` que conecta organizaciones con módulos (N:M). Cuando se otorga/revoca acceso a un módulo, se debe republicar `OrganizationEvent` con el array actualizado de `Apps.AccessibleModules`.

**CONTEXTO TÉCNICO:**
- **Relación N:M**: Organization ↔ Module con soft delete
- **Estado local**: OrganizationEvent incluye `Apps[].AccessibleModules`
- **Sin round-trip**: Aplicaciones satélite validan permisos localmente con datos del evento
- **Soft delete**: Revocar acceso = AuditDeletionDate, NO eliminar físicamente

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] Entidad ModuleAccess con OrganizationId, ModuleId, soft delete
- [ ] Validación: organización y módulo existen y están activos
- [ ] Validación: no duplicados (OrganizationId + ModuleId único)
- [ ] PostActions: republicar OrganizationEvent con módulos accesibles
- [ ] OrganizationEvent.Apps incluye AccessibleModules por app
- [ ] Tests verifican publicación correcta

**GUÍA DE IMPLEMENTACIÓN:**

**Paso 1: Crear Entidad ModuleAccess**

Archivo: `InfoportOneAdmon.DataModel/Entities/ModuleAccess.cs`

```csharp
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;

namespace InfoportOneAdmon.DataModel.Entities
{
    /// <summary>
    /// Relación N:M entre Organization y Module (soft delete)
    /// Representa qué módulos tiene licenciados una organización
    /// </summary>
    [Table("MODULE_ACCESS")]
    public class ModuleAccess : IEntityBase
    {
        [Key]
        public int Id { get; set; }

        /// <summary>
        /// FK a la organización que tiene acceso al módulo
        /// </summary>
        [ForeignKey(nameof(Organization))]
        public int OrganizationId { get; set; }

        /// <summary>
        /// Navegación a la organización
        /// </summary>
        public virtual Organization? Organization { get; set; }

        /// <summary>
        /// FK al módulo al que se otorga acceso
        /// </summary>
        [ForeignKey(nameof(Module))]
        public int ModuleId { get; set; }

        /// <summary>
        /// Navegación al módulo
        /// </summary>
        public virtual Module? Module { get; set; }

        // Auditoría
        public int AuditCreationUser { get; set; }
        public DateTime AuditCreationDate { get; set; }
        public int AuditModificationUser { get; set; }
        public DateTime AuditModificationDate { get; set; }

        /// <summary>
        /// Soft delete: fecha de revocación del acceso
        /// </summary>
        public DateTime? AuditDeletionDate { get; set; }
    }
}
```

**Paso 2: Actualizar Relaciones**

Modificar: `InfoportOneAdmon.DataModel/Entities/Organization.cs`

```csharp
/// <summary>
/// Módulos a los que la organización tiene acceso
/// </summary>
[InverseProperty(nameof(ModuleAccess.Organization))]
public virtual ICollection<ModuleAccess>? ModuleAccesses { get; set; }
```

**Paso 3: Configurar Índice Único**

Modificar: `InfoportOneAdmon.DataModel/InfoportOneAdmonContext.cs`

```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    base.OnModelCreating(modelBuilder);

    // Índice único compuesto (OrganizationId, ModuleId)
    // Permitir múltiples soft-deletes del mismo par
    modelBuilder.Entity<ModuleAccess>()
        .HasIndex(ma => new { ma.OrganizationId, ma.ModuleId, ma.AuditDeletionDate })
        .IsUnique()
        .HasFilter("AuditDeletionDate IS NULL") // Solo activos son únicos
        .HasDatabaseName("IX_ModuleAccess_OrganizationId_ModuleId_Active");
}
```

**Paso 4: Crear View**

Archivo: `InfoportOneAdmon.Entities/Views/ModuleAccessView.cs`

```csharp
using Helix6.Base.Domain.BaseInterfaces;

namespace InfoportOneAdmon.Entities.Views
{
    public partial class ModuleAccessView : IViewBase
    {
        public int Id { get; set; }
        public int OrganizationId { get; set; }
        public int ModuleId { get; set; }

        // Auditoría
        public int AuditCreationUser { get; set; }
        public DateTime AuditCreationDate { get; set; }
        public int AuditModificationUser { get; set; }
        public DateTime AuditModificationDate { get; set; }
        public DateTime? AuditDeletionDate { get; set; }
    }
}
```

**Paso 5: Crear Servicio con Validaciones y PostActions**

Archivo: `InfoportOneAdmon.Services/Services/ModuleAccessService.cs`

```csharp
using Helix6.Base.Domain;
using Helix6.Base.Service;
using Helix6.Base.Domain.Repositories;
using InfoportOneAdmon.DataModel.Entities;
using InfoportOneAdmon.Entities.Views;
using InfoportOneAdmon.Entities.Events;

namespace InfoportOneAdmon.Services.Services
{
    public class ModuleAccessService : BaseService<ModuleAccessView, ModuleAccess, ModuleAccessViewMetadata>
    {
        private readonly IRepository<ModuleAccess> _moduleAccessRepository;
        private readonly IRepository<Organization> _organizationRepository;
        private readonly IRepository<Module> _moduleRepository;
        private readonly IRepository<Application> _applicationRepository;
        private readonly IMessagePublisher _messagePublisher;
        private readonly IConfiguration _configuration;

        public ModuleAccessService(
            IApplicationContext appCtx,
            IUserContext userCtx,
            IRepository<ModuleAccess> repo,
            IRepository<Organization> organizationRepository,
            IRepository<Module> moduleRepository,
            IRepository<Application> applicationRepository,
            IMessagePublisher messagePublisher,
            IConfiguration configuration)
            : base(appCtx, userCtx, repo)
        {
            _moduleAccessRepository = repo;
            _organizationRepository = organizationRepository;
            _moduleRepository = moduleRepository;
            _applicationRepository = applicationRepository;
            _messagePublisher = messagePublisher;
            _configuration = configuration;
        }

        protected override async Task ValidateView(
            HelixValidationProblem validations,
            ModuleAccessView? view,
            EnumActionType actionType,
            CancellationToken cancellationToken)
        {
            if (view != null)
            {
                // Validación: organización existe y está activa
                var organization = await _organizationRepository.GetByIdAsync(view.OrganizationId, cancellationToken);
                if (organization == null || organization.AuditDeletionDate.HasValue)
                {
                    validations.Add("OrganizationId", "La organización no existe o está inactiva");
                }

                // Validación: módulo existe y está activo
                var module = await _moduleRepository.GetByIdAsync(view.ModuleId, cancellationToken);
                if (module == null || module.AuditDeletionDate.HasValue)
                {
                    validations.Add("ModuleId", "El módulo no existe o está inactivo");
                }

                // Validación: no duplicados activos (OrganizationId + ModuleId)
                if (actionType == EnumActionType.Insert)
                {
                    var exists = await Repository.ExistsAsync(
                        ma => ma.OrganizationId == view.OrganizationId
                              && ma.ModuleId == view.ModuleId
                              && ma.AuditDeletionDate == null,
                        cancellationToken);

                    if (exists)
                    {
                        validations.Add("ModuleAccess",
                            "La organización ya tiene acceso a este módulo");
                    }
                }
            }

            await base.ValidateView(validations, view, actionType, cancellationToken);
        }

        protected override async Task PostActions(
            ModuleAccessView view,
            EnumActionType actionType,
            CancellationToken cancellationToken)
        {
            // Republicar OrganizationEvent con módulos actualizados
            var organization = await _organizationRepository.GetQuery()
                .Include(o => o.ModuleAccesses)
                    .ThenInclude(ma => ma.Module)
                        .ThenInclude(m => m.Application)
                .FirstOrDefaultAsync(o => o.Id == view.OrganizationId, cancellationToken);

            if (organization != null)
            {
                await PublishOrganizationEventAsync(organization, cancellationToken);
            }

            await base.PostActions(view, actionType, cancellationToken);
        }

        private async Task PublishOrganizationEventAsync(Organization organization, CancellationToken cancellationToken)
        {
            // Agrupar módulos por aplicación
            var appModulesDict = organization.ModuleAccesses?
                .Where(ma => ma.AuditDeletionDate == null && ma.Module?.AuditDeletionDate == null)
                .GroupBy(ma => ma.Module!.Application!)
                .ToDictionary(
                    g => g.Key,
                    g => g.Select(ma => ma.Module!).ToList()
                ) ?? new Dictionary<Application, List<Module>>();

            var organizationEvent = new OrganizationEvent
            {
                OrganizationId = organization.Id,
                SecurityCompanyId = organization.SecurityCompanyId,
                Name = organization.Name,
                FiscalId = organization.FiscalId,
                GroupId = organization.GroupId,
                IsDeleted = organization.AuditDeletionDate.HasValue,
                CreatedAt = organization.AuditCreationDate,
                ModifiedAt = DateTime.UtcNow,

                // Apps con módulos accesibles
                Apps = appModulesDict.Select(kvp => new AppAccessInfo
                {
                    ApplicationId = kvp.Key.Id,
                    RolePrefix = kvp.Key.RolePrefix,
                    DatabasePrefix = kvp.Key.DatabasePrefix,

                    AccessibleModules = kvp.Value
                        .OrderBy(m => m.DisplayOrder)
                        .Select(m => new ModuleInfo
                        {
                            ModuleId = m.Id,
                            ModuleName = m.ModuleName,
                            Description = m.Description,
                            DisplayOrder = m.DisplayOrder
                        }).ToList()
                }).ToList()
            };

            var topic = _configuration["EventBroker:Topics:OrganizationEvents"];
            await _messagePublisher.PublishAsync(topic, organizationEvent, cancellationToken);

            Logger.LogInformation(
                $"OrganizationEvent publicado para Organization ID {organization.Id} con {organizationEvent.Apps.Count} aplicaciones");
        }
    }
}
```

**Paso 6: Actualizar OrganizationEvent**

Modificar: `InfoportOneAdmon.Entities/Events/OrganizationEvent.cs`

```csharp
// Añadir al final de la clase OrganizationEvent:

/// <summary>
/// Aplicaciones y módulos a los que la organización tiene acceso
/// </summary>
public List<AppAccessInfo> Apps { get; set; } = new();
```

```csharp
// Añadir clase AppAccessInfo al mismo archivo:

public class AppAccessInfo
{
    public int ApplicationId { get; set; }
    public string RolePrefix { get; set; } = string.Empty;
    public string DatabasePrefix { get; set; } = string.Empty;

    /// <summary>
    /// Módulos a los que la organización tiene acceso en esta aplicación
    /// </summary>
    public List<ModuleInfo> AccessibleModules { get; set; } = new();
}
```

**Paso 7: Migración**

```bash
dotnet ef migrations add AddModuleAccessEntity -p InfoportOneAdmon.DataModel -s InfoportOneAdmon.Api
dotnet ef database update -p InfoportOneAdmon.DataModel -s InfoportOneAdmon.Api
```

**Paso 8: Tests**

Archivo: `InfoportOneAdmon.Services.Tests/Services/ModuleAccessServiceTests.cs`

```csharp
using Xunit;
using FluentAssertions;
using Moq;
using InfoportOneAdmon.Services.Services;
using InfoportOneAdmon.Entities.Views;
using InfoportOneAdmon.DataModel.Entities;
using Helix6.Base.Domain;

namespace InfoportOneAdmon.Services.Tests.Services
{
    public class ModuleAccessServiceTests
    {
        [Fact]
        public async Task ValidateView_ValidData_ReturnsTrue()
        {
            // Arrange
            var organizationRepoMock = new Mock<IRepository<Organization>>();
            var moduleRepoMock = new Mock<IRepository<Module>>();
            var repoMock = new Mock<IRepository<ModuleAccess>>();

            organizationRepoMock.Setup(r => r.GetByIdAsync(1, It.IsAny<CancellationToken>()))
                .ReturnsAsync(new Organization { Id = 1, AuditDeletionDate = null });

            moduleRepoMock.Setup(r => r.GetByIdAsync(1, It.IsAny<CancellationToken>()))
                .ReturnsAsync(new Module { Id = 1, AuditDeletionDate = null });

            repoMock.Setup(r => r.ExistsAsync(It.IsAny<Expression<Func<ModuleAccess, bool>>>(), It.IsAny<CancellationToken>()))
                .ReturnsAsync(false);

            var service = new ModuleAccessService(
                Mock.Of<IApplicationContext>(),
                Mock.Of<IUserContext>(),
                repoMock.Object,
                organizationRepoMock.Object,
                moduleRepoMock.Object,
                Mock.Of<IRepository<Application>>(),
                Mock.Of<IMessagePublisher>(),
                Mock.Of<IConfiguration>());

            var view = new ModuleAccessView
            {
                OrganizationId = 1,
                ModuleId = 1
            };

            var validations = new HelixValidationProblem();

            // Act
            await service.ValidateView(validations, view, EnumActionType.Insert, CancellationToken.None);

            // Assert
            validations.IsValid.Should().BeTrue();
        }

        [Fact]
        public async Task ValidateView_DuplicateAccess_ReturnsFalse()
        {
            // Arrange
            var organizationRepoMock = new Mock<IRepository<Organization>>();
            var moduleRepoMock = new Mock<IRepository<Module>>();
            var repoMock = new Mock<IRepository<ModuleAccess>>();

            organizationRepoMock.Setup(r => r.GetByIdAsync(1, It.IsAny<CancellationToken>()))
                .ReturnsAsync(new Organization { Id = 1 });

            moduleRepoMock.Setup(r => r.GetByIdAsync(1, It.IsAny<CancellationToken>()))
                .ReturnsAsync(new Module { Id = 1 });

            // Ya existe acceso activo
            repoMock.Setup(r => r.ExistsAsync(It.IsAny<Expression<Func<ModuleAccess, bool>>>(), It.IsAny<CancellationToken>()))
                .ReturnsAsync(true);

            var service = new ModuleAccessService(
                Mock.Of<IApplicationContext>(),
                Mock.Of<IUserContext>(),
                repoMock.Object,
                organizationRepoMock.Object,
                moduleRepoMock.Object,
                Mock.Of<IRepository<Application>>(),
                Mock.Of<IMessagePublisher>(),
                Mock.Of<IConfiguration>());

            var view = new ModuleAccessView
            {
                OrganizationId = 1,
                ModuleId = 1
            };

            var validations = new HelixValidationProblem();

            // Act
            await service.ValidateView(validations, view, EnumActionType.Insert, CancellationToken.None);

            // Assert
            validations.IsValid.Should().BeFalse();
            validations.Errors.Should().ContainKey("ModuleAccess");
        }

        [Fact]
        public async Task PostActions_Insert_PublishesOrganizationEvent()
        {
            // Arrange
            var messagePublisherMock = new Mock<IMessagePublisher>();
            var organizationRepoMock = new Mock<IRepository<Organization>>();

            var organization = new Organization
            {
                Id = 1,
                SecurityCompanyId = "SEC-001",
                ModuleAccesses = new List<ModuleAccess>
                {
                    new ModuleAccess
                    {
                        ModuleId = 1,
                        AuditDeletionDate = null,
                        Module = new Module
                        {
                            Id = 1,
                            ModuleName = "MCRM_Facturacion",
                            DisplayOrder = 1,
                            Application = new Application { Id = 1, RolePrefix = "CRM" }
                        }
                    }
                }
            };

            organizationRepoMock.Setup(r => r.GetQuery())
                .Returns(new List<Organization> { organization }.AsQueryable());

            var service = new ModuleAccessService(
                Mock.Of<IApplicationContext>(),
                Mock.Of<IUserContext>(),
                Mock.Of<IRepository<ModuleAccess>>(),
                organizationRepoMock.Object,
                Mock.Of<IRepository<Module>>(),
                Mock.Of<IRepository<Application>>(),
                messagePublisherMock.Object,
                Mock.Of<IConfiguration>());

            var view = new ModuleAccessView { OrganizationId = 1, ModuleId = 1 };

            // Act
            await service.PostActions(view, EnumActionType.Insert, CancellationToken.None);

            // Assert
            messagePublisherMock.Verify(m => m.PublishAsync(
                It.IsAny<string>(),
                It.Is<OrganizationEvent>(e =>
                    e.Apps.Count == 1 &&
                    e.Apps[0].AccessibleModules.Count == 1 &&
                    e.Apps[0].AccessibleModules[0].ModuleName == "MCRM_Facturacion"),
                It.IsAny<CancellationToken>()),
                Times.Once);
        }
    }
}
```

**ARCHIVOS A CREAR/MODIFICAR:**
- `InfoportOneAdmon.DataModel/Entities/ModuleAccess.cs` - Nueva entidad N:M
- `InfoportOneAdmon.DataModel/Entities/Organization.cs` - Relación ModuleAccesses
- `InfoportOneAdmon.DataModel/InfoportOneAdmonContext.cs` - Índice único
- `InfoportOneAdmon.Entities/Views/ModuleAccessView.cs` - ViewModel
- `InfoportOneAdmon.Entities/Events/OrganizationEvent.cs` - Añadir Apps y AppAccessInfo
- `InfoportOneAdmon.Services/Services/ModuleAccessService.cs` - Servicio completo
- `InfoportOneAdmon.Services.Tests/Services/ModuleAccessServiceTests.cs` - Tests
- Migración EF Core

**DEPENDENCIAS:**
- TASK-016-BE - Module existe
- TASK-001-BE - Organization existe
- TASK-001-EV-PUB - OrganizationEvent existe

**DEFINITION OF DONE:**
- [ ] Entidad ModuleAccess creada
- [ ] Índice único (OrganizationId, ModuleId) con filtro para soft delete
- [ ] Validaciones de FK implementadas
- [ ] Validación de duplicados implementada
- [ ] PostActions publica OrganizationEvent con Apps.AccessibleModules
- [ ] OrganizationEvent incluye AppAccessInfo con módulos accesibles
- [ ] Tests >80% cobertura
- [ ] Migración aplicada
- [ ] Code review aprobado

**RECURSOS:**
- User Story: `userStories.md#us-017`

=============================================================

---

### US-016: Definir módulos funcionales de una aplicación

**Resumen de tickets generados:**
- TASK-016-BE: Entidad Module con validaciones de nomenclatura y reglas de negocio
- TASK-016-EV-PUB: Actualizar ApplicationEvent con lista de módulos

---

#### TASK-016-BE: Entidad Module con validaciones de nomenclatura

=============================================================
**TICKET ID:** TASK-016-BE  
**EPIC:** Configuración de Módulos y Permisos de Acceso  
**USER STORY:** US-016 - Definir módulos funcionales de una aplicación  
**COMPONENT:** Backend  
**PRIORITY:** Alta  
**ESTIMATION:** 5 horas  
=============================================================

**TÍTULO:**
Implementar entidad Module con validación de nomenclatura M{Prefix}_

**DESCRIPCIÓN:**
Crear la entidad `Module` que representa módulos funcionales de una aplicación. Los módulos permiten licenciar funcionalidades de forma granular (ej: "MCRM_Facturacion", "MCRM_Reporting"). La nomenclatura DEBE seguir el patrón `M{RolePrefix}_{NombreDescriptivo}`.

**CONTEXTO TÉCNICO:**
- **Nomenclatura obligatoria**: `M{RolePrefix}_{NombreDescriptivo}` (ej: MCRM_Facturacion)
- **Validación**: Regex `^M{RolePrefix}_[A-Za-z0-9_]+$`
- **Regla de negocio**: Una aplicación DEBE tener al menos 1 módulo activo
- **Soft delete**: No eliminar físicamente, usar AuditDeletionDate
- **Relación**: 1:N entre Application y Module

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] Entidad Module con campos: ModuleName, Description, DisplayOrder, ApplicationId
- [ ] Validación de nomenclatura en ValidateView
- [ ] Índice único compuesto (ApplicationId, ModuleName)
- [ ] Validación: no permitir eliminar el último módulo activo de una aplicación
- [ ] Endpoints CRUD automáticos generados por Helix6
- [ ] Tests unitarios e integración

**GUÍA DE IMPLEMENTACIÓN:**

**Paso 1: Crear Entidad Module**

Archivo: `InfoportOneAdmon.DataModel/Entities/Module.cs`

```csharp
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;

namespace InfoportOneAdmon.DataModel.Entities
{
    /// <summary>
    /// Módulo funcional de una aplicación (granularidad de licenciamiento)
    /// Ejemplo: MCRM_Facturacion, MCRM_Reporting
    /// </summary>
    [Table("MODULE")]
    public class Module : IEntityBase
    {
        [Key]
        public int Id { get; set; }

        /// <summary>
        /// Nombre del módulo con nomenclatura: M{RolePrefix}_{NombreDescriptivo}
        /// Ejemplo: MCRM_Facturacion, MERP_Contabilidad
        /// </summary>
        [Required]
        [StringLength(100)]
        public string ModuleName { get; set; } = string.Empty;

        /// <summary>
        /// Descripción funcional del módulo
        /// </summary>
        [StringLength(500)]
        public string? Description { get; set; }

        /// <summary>
        /// Orden de visualización en interfaces de usuario
        /// </summary>
        public int DisplayOrder { get; set; }

        /// <summary>
        /// FK a la aplicación propietaria del módulo
        /// </summary>
        [ForeignKey(nameof(Application))]
        public int ApplicationId { get; set; }

        /// <summary>
        /// Navegación a la aplicación
        /// </summary>
        public virtual Application? Application { get; set; }

        /// <summary>
        /// Relación N:M con organizaciones (quién tiene acceso al módulo)
        /// </summary>
        [InverseProperty(nameof(ModuleAccess.Module))]
        public virtual ICollection<ModuleAccess>? ModuleAccesses { get; set; }

        // Auditoría
        public int AuditCreationUser { get; set; }
        public DateTime AuditCreationDate { get; set; }
        public int AuditModificationUser { get; set; }
        public DateTime AuditModificationDate { get; set; }
        public DateTime? AuditDeletionDate { get; set; }
    }
}
```

**Paso 2: Actualizar Application para incluir Modules**

Modificar: `InfoportOneAdmon.DataModel/Entities/Application.cs`

```csharp
/// <summary>
/// Módulos funcionales de la aplicación (granularidad de licenciamiento)
/// </summary>
[InverseProperty(nameof(Module.Application))]
public virtual ICollection<Module>? Modules { get; set; }
```

**Paso 3: Crear View**

Archivo: `InfoportOneAdmon.Entities/Views/ModuleView.cs`

```csharp
using Helix6.Base.Domain.BaseInterfaces;

namespace InfoportOneAdmon.Entities.Views
{
    public partial class ModuleView : IViewBase
    {
        public int Id { get; set; }
        public string ModuleName { get; set; } = string.Empty;
        public string? Description { get; set; }
        public int DisplayOrder { get; set; }
        public int ApplicationId { get; set; }

        // Auditoría
        public int AuditCreationUser { get; set; }
        public DateTime AuditCreationDate { get; set; }
        public int AuditModificationUser { get; set; }
        public DateTime AuditModificationDate { get; set; }
        public DateTime? AuditDeletionDate { get; set; }
    }
}
```

**Paso 4: Crear Servicio con Validaciones**

Archivo: `InfoportOneAdmon.Services/Services/ModuleService.cs`

```csharp
using System.Text.RegularExpressions;
using Helix6.Base.Domain;
using Helix6.Base.Service;
using Helix6.Base.Domain.Repositories;
using InfoportOneAdmon.DataModel.Entities;
using InfoportOneAdmon.Entities.Views;

namespace InfoportOneAdmon.Services.Services
{
    public class ModuleService : BaseService<ModuleView, Module, ModuleViewMetadata>
    {
        private readonly IRepository<Module> _moduleRepository;
        private readonly IRepository<Application> _applicationRepository;

        public ModuleService(
            IApplicationContext appCtx,
            IUserContext userCtx,
            IRepository<Module> repo,
            IRepository<Application> applicationRepository)
            : base(appCtx, userCtx, repo)
        {
            _moduleRepository = repo;
            _applicationRepository = applicationRepository;
        }

        protected override async Task ValidateView(
            HelixValidationProblem validations,
            ModuleView? view,
            EnumActionType actionType,
            CancellationToken cancellationToken)
        {
            if (view != null)
            {
                // Obtener la aplicación para conocer su RolePrefix
                var application = await _applicationRepository.GetByIdAsync(view.ApplicationId, cancellationToken);
                if (application == null)
                {
                    validations.Add("ApplicationId", "La aplicación no existe");
                    await base.ValidateView(validations, view, actionType, cancellationToken);
                    return;
                }

                var rolePrefix = application.RolePrefix;

                // Validación: nomenclatura M{RolePrefix}_{NombreDescriptivo}
                var expectedPattern = $"^M{rolePrefix}_[A-Za-z0-9_]+$";
                if (!Regex.IsMatch(view.ModuleName, expectedPattern))
                {
                    validations.Add("ModuleName",
                        $"El nombre del módulo debe seguir el patrón M{rolePrefix}_NombreDescriptivo (ej: M{rolePrefix}_Facturacion)");
                }

                // Validación: unicidad dentro de la aplicación
                if (actionType == EnumActionType.Insert || actionType == EnumActionType.Update)
                {
                    var exists = await Repository.ExistsAsync(
                        m => m.ModuleName == view.ModuleName
                             && m.ApplicationId == view.ApplicationId
                             && m.Id != view.Id
                             && m.AuditDeletionDate == null,
                        cancellationToken);

                    if (exists)
                    {
                        validations.Add("ModuleName",
                            $"Ya existe un módulo con el nombre '{view.ModuleName}' en esta aplicación");
                    }
                }

                // Validación: no permitir eliminar el último módulo activo
                if (actionType == EnumActionType.DeleteUndelete)
                {
                    var activeModules = await Repository.GetQuery()
                        .Where(m => m.ApplicationId == view.ApplicationId
                                    && m.AuditDeletionDate == null
                                    && m.Id != view.Id)
                        .CountAsync(cancellationToken);

                    if (activeModules == 0)
                    {
                        validations.Add("Module",
                            "No se puede eliminar el último módulo activo de una aplicación. Debe haber al menos un módulo.");
                    }
                }
            }

            await base.ValidateView(validations, view, actionType, cancellationToken);
        }
    }
}
```

**Paso 5: Crear Migración**

```bash
dotnet ef migrations add AddModuleEntity -p InfoportOneAdmon.DataModel -s InfoportOneAdmon.Api
dotnet ef database update -p InfoportOneAdmon.DataModel -s InfoportOneAdmon.Api
```

**Paso 6: Configurar Índice Único**

Modificar: `InfoportOneAdmon.DataModel/InfoportOneAdmonContext.cs`

```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    base.OnModelCreating(modelBuilder);

    // Índice único compuesto (ApplicationId, ModuleName)
    modelBuilder.Entity<Module>()
        .HasIndex(m => new { m.ApplicationId, m.ModuleName })
        .IsUnique()
        .HasDatabaseName("IX_Module_ApplicationId_ModuleName");
}
```

**Paso 7: Tests Unitarios**

Archivo: `InfoportOneAdmon.Services.Tests/Services/ModuleServiceTests.cs`

```csharp
using Xunit;
using FluentAssertions;
using Moq;
using InfoportOneAdmon.Services.Services;
using InfoportOneAdmon.Entities.Views;
using InfoportOneAdmon.DataModel.Entities;
using Helix6.Base.Domain;

namespace InfoportOneAdmon.Services.Tests.Services
{
    public class ModuleServiceTests
    {
        private readonly Mock<IRepository<Module>> _repositoryMock;
        private readonly Mock<IRepository<Application>> _applicationRepositoryMock;
        private readonly ModuleService _service;

        public ModuleServiceTests()
        {
            _repositoryMock = new Mock<IRepository<Module>>();
            _applicationRepositoryMock = new Mock<IRepository<Application>>();

            _service = new ModuleService(
                Mock.Of<IApplicationContext>(),
                Mock.Of<IUserContext>(),
                _repositoryMock.Object,
                _applicationRepositoryMock.Object);
        }

        [Fact]
        public async Task ValidateView_WithCorrectNomenclature_ReturnsTrue()
        {
            // Arrange
            var application = new Application { Id = 1, RolePrefix = "CRM" };
            _applicationRepositoryMock.Setup(r => r.GetByIdAsync(1, It.IsAny<CancellationToken>()))
                .ReturnsAsync(application);

            _repositoryMock.Setup(r => r.ExistsAsync(It.IsAny<Expression<Func<Module, bool>>>(), It.IsAny<CancellationToken>()))
                .ReturnsAsync(false);

            var view = new ModuleView
            {
                ModuleName = "MCRM_Facturacion",
                ApplicationId = 1,
                Description = "Módulo de facturación"
            };

            var validations = new HelixValidationProblem();

            // Act
            await _service.ValidateView(validations, view, EnumActionType.Insert, CancellationToken.None);

            // Assert
            validations.IsValid.Should().BeTrue();
        }

        [Theory]
        [InlineData("Facturacion")] // Sin prefijo M
        [InlineData("MCRM Facturacion")] // Espacio en lugar de guion bajo
        [InlineData("MERP_Facturacion")] // Prefijo incorrecto
        [InlineData("mcrm_facturacion")] // Minúsculas en prefijo
        public async Task ValidateView_WithInvalidNomenclature_ReturnsFalse(string invalidName)
        {
            // Arrange
            var application = new Application { Id = 1, RolePrefix = "CRM" };
            _applicationRepositoryMock.Setup(r => r.GetByIdAsync(1, It.IsAny<CancellationToken>()))
                .ReturnsAsync(application);

            var view = new ModuleView
            {
                ModuleName = invalidName,
                ApplicationId = 1
            };

            var validations = new HelixValidationProblem();

            // Act
            await _service.ValidateView(validations, view, EnumActionType.Insert, CancellationToken.None);

            // Assert
            validations.IsValid.Should().BeFalse();
            validations.Errors.Should().ContainKey("ModuleName");
        }

        [Fact]
        public async Task ValidateView_DuplicateModuleName_ReturnsFalse()
        {
            // Arrange
            var application = new Application { Id = 1, RolePrefix = "CRM" };
            _applicationRepositoryMock.Setup(r => r.GetByIdAsync(1, It.IsAny<CancellationToken>()))
                .ReturnsAsync(application);

            _repositoryMock.Setup(r => r.ExistsAsync(It.IsAny<Expression<Func<Module, bool>>>(), It.IsAny<CancellationToken>()))
                .ReturnsAsync(true); // Existe otro módulo con el mismo nombre

            var view = new ModuleView
            {
                ModuleName = "MCRM_Facturacion",
                ApplicationId = 1
            };

            var validations = new HelixValidationProblem();

            // Act
            await _service.ValidateView(validations, view, EnumActionType.Insert, CancellationToken.None);

            // Assert
            validations.IsValid.Should().BeFalse();
            validations.Errors.Should().ContainKey("ModuleName");
        }

        [Fact]
        public async Task ValidateView_DeleteLastActiveModule_ReturnsFalse()
        {
            // Arrange
            var application = new Application { Id = 1, RolePrefix = "CRM" };
            _applicationRepositoryMock.Setup(r => r.GetByIdAsync(1, It.IsAny<CancellationToken>()))
                .ReturnsAsync(application);

            // No hay otros módulos activos
            _repositoryMock.Setup(r => r.GetQuery())
                .Returns(new List<Module>().AsQueryable());

            var view = new ModuleView
            {
                Id = 1,
                ModuleName = "MCRM_Facturacion",
                ApplicationId = 1
            };

            var validations = new HelixValidationProblem();

            // Act
            await _service.ValidateView(validations, view, EnumActionType.DeleteUndelete, CancellationToken.None);

            // Assert
            validations.IsValid.Should().BeFalse();
            validations.Errors.Should().ContainKey("Module");
        }
    }
}
```

**ARCHIVOS A CREAR/MODIFICAR:**
- `InfoportOneAdmon.DataModel/Entities/Module.cs` - Nueva entidad
- `InfoportOneAdmon.DataModel/Entities/Application.cs` - Añadir relación Modules
- `InfoportOneAdmon.DataModel/InfoportOneAdmonContext.cs` - Índice único
- `InfoportOneAdmon.Entities/Views/ModuleView.cs` - ViewModel
- `InfoportOneAdmon.Services/Services/ModuleService.cs` - Servicio con validaciones
- `InfoportOneAdmon.Services.Tests/Services/ModuleServiceTests.cs` - Tests
- Migración EF Core

**DEPENDENCIAS:**
- TASK-009-BE - Application existe

**DEFINITION OF DONE:**
- [ ] Entidad Module creada con campos especificados
- [ ] Índice único compuesto (ApplicationId, ModuleName) configurado
- [ ] Validación de nomenclatura M{RolePrefix}_ implementada
- [ ] Validación de unicidad implementada
- [ ] Validación: no eliminar último módulo activo
- [ ] Endpoints CRUD generados automáticamente por Helix6
- [ ] Tests unitarios >80% cobertura
- [ ] Tests validan nomenclatura correcta e incorrecta
- [ ] Migración aplicada
- [ ] Code review aprobado

**RECURSOS:**
- User Story: `userStories.md#us-016`

=============================================================

---

#### TASK-016-EV-PUB: Actualizar ApplicationEvent con lista de módulos

=============================================================
**TICKET ID:** TASK-016-EV-PUB  
**EPIC:** Configuración de Módulos y Permisos de Acceso  
**USER STORY:** US-016 - Definir módulos funcionales de una aplicación  
**COMPONENT:** Backend - Event Publishing  
**PRIORITY:** Alta  
**ESTIMATION:** 2 horas  
=============================================================

**TÍTULO:**
Actualizar ApplicationEvent para incluir lista completa de módulos

**DESCRIPCIÓN:**
Modificar el método `PublishApplicationEventAsync` en `ApplicationService` para incluir el array completo de módulos activos de la aplicación en cada evento publicado.

**CONTEXTO TÉCNICO:**
- **ApplicationEvent ya existe** desde TASK-009-EV-PUB
- **Añadir**: Array `Modules` con ModuleInfo[] 
- **Trigger**: Publicar evento cuando se crea/modifica/elimina un módulo
- **State Transfer**: Incluir estado completo de todos los módulos activos

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] ApplicationEvent.Modules incluye todos los módulos activos (AuditDeletionDate == null)
- [ ] PostActions en ModuleService republica ApplicationEvent
- [ ] Tests verifican que módulos eliminados no se incluyen

**GUÍA DE IMPLEMENTACIÓN:**

**Paso 1: Actualizar ApplicationEvent**

Modificar: `InfoportOneAdmon.Entities/Events/ApplicationEvent.cs`

```csharp
// Añadir al final de la clase ApplicationEvent:

/// <summary>
/// Módulos funcionales de la aplicación
/// </summary>
public List<ModuleInfo> Modules { get; set; } = new();
```

```csharp
// Añadir clase ModuleInfo al mismo archivo:

public class ModuleInfo
{
    public int ModuleId { get; set; }
    public string ModuleName { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int DisplayOrder { get; set; }
}
```

**Paso 2: Actualizar PublishApplicationEventAsync en ApplicationService**

Modificar: `InfoportOneAdmon.Services/Services/ApplicationService.cs`

```csharp
private async Task PublishApplicationEventAsync(Application application, CancellationToken cancellationToken)
{
    var applicationEvent = new ApplicationEvent
    {
        ApplicationId = application.Id,
        Name = application.Name,
        RolePrefix = application.RolePrefix,
        DatabasePrefix = application.DatabasePrefix,
        Description = application.Description,
        IsDeleted = application.AuditDeletionDate.HasValue,
        CreatedAt = application.AuditCreationDate,
        ModifiedAt = application.AuditModificationDate,

        // Incluir módulos activos
        Modules = application.Modules?
            .Where(m => m.AuditDeletionDate == null)
            .OrderBy(m => m.DisplayOrder)
            .Select(m => new ModuleInfo
            {
                ModuleId = m.Id,
                ModuleName = m.ModuleName,
                Description = m.Description,
                DisplayOrder = m.DisplayOrder
            }).ToList() ?? new List<ModuleInfo>(),

        // ... resto de campos existentes (Roles, Credentials)
    };

    var topic = _configuration["EventBroker:Topics:ApplicationEvents"];
    await _messagePublisher.PublishAsync(topic, applicationEvent, cancellationToken);

    Logger.LogInformation($"ApplicationEvent publicado para Application ID {application.Id} con {applicationEvent.Modules.Count} módulos");
}
```

**Paso 3: Añadir PostActions en ModuleService**

Modificar: `InfoportOneAdmon.Services/Services/ModuleService.cs`

```csharp
private readonly IMessagePublisher _messagePublisher;
private readonly IConfiguration _configuration;

public ModuleService(
    IApplicationContext appCtx,
    IUserContext userCtx,
    IRepository<Module> repo,
    IRepository<Application> applicationRepository,
    IMessagePublisher messagePublisher,
    IConfiguration configuration)
    : base(appCtx, userCtx, repo)
{
    _moduleRepository = repo;
    _applicationRepository = applicationRepository;
    _messagePublisher = messagePublisher;
    _configuration = configuration;
}

protected override async Task PostActions(
    ModuleView view,
    EnumActionType actionType,
    CancellationToken cancellationToken)
{
    // Republicar ApplicationEvent cuando cambian los módulos
    var application = await _applicationRepository.GetByIdAsync(view.ApplicationId, cancellationToken);
    if (application != null)
    {
        // Delegar a ApplicationService para publicar el evento
        // O publicar directamente aquí
        var applicationEvent = new ApplicationEvent
        {
            ApplicationId = application.Id,
            Name = application.Name,
            RolePrefix = application.RolePrefix,
            DatabasePrefix = application.DatabasePrefix,
            Description = application.Description,
            IsDeleted = application.AuditDeletionDate.HasValue,
            CreatedAt = application.AuditCreationDate,
            ModifiedAt = DateTime.UtcNow,

            Modules = application.Modules?
                .Where(m => m.AuditDeletionDate == null)
                .OrderBy(m => m.DisplayOrder)
                .Select(m => new ModuleInfo
                {
                    ModuleId = m.Id,
                    ModuleName = m.ModuleName,
                    Description = m.Description,
                    DisplayOrder = m.DisplayOrder
                }).ToList() ?? new List<ModuleInfo>()
        };

        var topic = _configuration["EventBroker:Topics:ApplicationEvents"];
        await _messagePublisher.PublishAsync(topic, applicationEvent, cancellationToken);

        Logger.LogInformation($"ApplicationEvent republicado tras cambio en módulo {view.ModuleName}");
    }

    await base.PostActions(view, actionType, cancellationToken);
}
```

**Paso 4: Tests**

Archivo: `InfoportOneAdmon.Services.Tests/Services/ModuleServiceTests.cs`

Añadir:

```csharp
[Fact]
public async Task PostActions_Insert_RepublishesApplicationEvent()
{
    // Arrange
    var messagePublisherMock = new Mock<IMessagePublisher>();
    var application = new Application
    {
        Id = 1,
        Name = "CRM",
        RolePrefix = "CRM",
        Modules = new List<Module>
        {
            new Module { Id = 1, ModuleName = "MCRM_Facturacion", DisplayOrder = 1 }
        }
    };

    _applicationRepositoryMock.Setup(r => r.GetByIdAsync(1, It.IsAny<CancellationToken>()))
        .ReturnsAsync(application);

    var service = new ModuleService(
        Mock.Of<IApplicationContext>(),
        Mock.Of<IUserContext>(),
        _repositoryMock.Object,
        _applicationRepositoryMock.Object,
        messagePublisherMock.Object,
        Mock.Of<IConfiguration>());

    var view = new ModuleView
    {
        ModuleName = "MCRM_Facturacion",
        ApplicationId = 1
    };

    // Act
    await service.PostActions(view, EnumActionType.Insert, CancellationToken.None);

    // Assert
    messagePublisherMock.Verify(m => m.PublishAsync(
        It.IsAny<string>(),
        It.Is<ApplicationEvent>(e => e.Modules.Count == 1 && e.Modules[0].ModuleName == "MCRM_Facturacion"),
        It.IsAny<CancellationToken>()),
        Times.Once);
}
```

**ARCHIVOS A MODIFICAR:**
- `InfoportOneAdmon.Entities/Events/ApplicationEvent.cs` - Añadir Modules y ModuleInfo
- `InfoportOneAdmon.Services/Services/ApplicationService.cs` - Actualizar PublishApplicationEventAsync
- `InfoportOneAdmon.Services/Services/ModuleService.cs` - Añadir PostActions
- `InfoportOneAdmon.Services.Tests/Services/ModuleServiceTests.cs` - Tests

**DEPENDENCIAS:**
- TASK-016-BE - Module existe
- TASK-009-EV-PUB - ApplicationEvent existe

**DEFINITION OF DONE:**
- [ ] ApplicationEvent incluye array Modules
- [ ] PublishApplicationEventAsync incluye módulos activos ordenados
- [ ] PostActions en ModuleService republica evento
- [ ] Tests verifican publicación correcta
- [ ] Módulos eliminados (soft delete) NO se incluyen en evento
- [ ] Code review aprobado

**RECURSOS:**
- User Story: `userStories.md#us-016`

=============================================================

---

#### TASK-016-FE: Implementar grid de módulos con modal de creación/edición

=============================================================
**TICKET ID:** TASK-016-FE  
**EPIC:** Configuración de Módulos y Permisos de Acceso  
**USER STORY:** US-016 - Definir módulos funcionales de una aplicación  
**COMPONENT:** Frontend  
**PRIORITY:** Alta  
**ESTIMATION:** 6 horas  
=============================================================

**TÍTULO:**
Implementar grid de módulos con modal de creación/edición

**DESCRIPCIÓN:**
Crear la interfaz de usuario para gestionar módulos funcionales de una aplicación usando ClGrid y ClModal. El grid se mostrará dentro del detalle de una aplicación, permitiendo crear, editar y eliminar módulos con validación de nomenclatura M{Prefix}_.

**CONTEXTO TÉCNICO:**
- **Framework**: Angular 20 Standalone Components
- **Librería UI**: @cl/common-library (ClGrid, ClModal, ClFormFields)
- **Cliente API**: NSwag generado desde Swagger
- **Validación**: Nomenclatura M{RolePrefix}_{NombreDescriptivo}
- **Permisos**: AccessService con Access.Create, Update, Delete

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] Componente ModuleGridComponent creado como Standalone
- [ ] Componente ModuleDialogComponent creado como Standalone
- [ ] ClGrid configurado con columnas: ModuleName, Description, DisplayOrder
- [ ] Validación de nomenclatura en formulario reactivo
- [ ] Modal para crear/editar módulos
- [ ] Validación: no permitir eliminar último módulo activo
- [ ] Cliente NSwag integrado
- [ ] Traducciones en es.json y en.json
- [ ] Tests unitarios >80%

**GUÍA DE IMPLEMENTACIÓN:**

**Paso 1: Crear Componente Grid**

Archivo: `src/app/modules/admin/components/module-grid/module-grid.component.ts`

```typescript
import { Component, OnInit, Input, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ClGridComponent, ClGridConfig } from '@cl/common-library/cl-grid';
import { ClModalService } from '@cl/common-library/cl-modal';
import { TranslateModule } from '@ngx-translate/core';
import { ModuleClient, ModuleView } from '@webServicesReferences/api/apiClients';
import { AccessService, Access } from '@services/access.service';
import { ModuleDialogComponent } from '../module-dialog/module-dialog.component';

@Component({
  selector: 'app-module-grid',
  standalone: true,
  imports: [CommonModule, ClGridComponent, TranslateModule],
  templateUrl: './module-grid.component.html',
  styleUrls: ['./module-grid.component.scss']
})
export class ModuleGridComponent implements OnInit {
  @Input() applicationId!: number;
  @Input() rolePrefix!: string; // Para validar nomenclatura

  private readonly moduleClient = inject(ModuleClient);
  private readonly modalService = inject(ClModalService);
  private readonly accessService = inject(AccessService);

  gridConfig!: ClGridConfig<ModuleView>;
  modules: ModuleView[] = [];
  loading = false;

  hasCreatePermission = false;
  hasUpdatePermission = false;
  hasDeletePermission = false;

  ngOnInit(): void {
    this.checkPermissions();
    this.configureGrid();
    this.loadData();
  }

  private checkPermissions(): void {
    const moduleName = 'MSTP_Applications';
    this.hasCreatePermission = this.accessService.hasAccess(moduleName, Access.Create);
    this.hasUpdatePermission = this.accessService.hasAccess(moduleName, Access.Update);
    this.hasDeletePermission = this.accessService.hasAccess(moduleName, Access.Delete);
  }

  private configureGrid(): void {
    this.gridConfig = new ClGridConfig<ModuleView>({
      idGrid: 'moduleGridConfig',
      serverSide: false,
      columns: [
        {
          field: 'moduleName',
          title: 'Module.Name',
          width: 300
        },
        {
          field: 'description',
          title: 'Module.Description',
          width: 400
        },
        {
          field: 'displayOrder',
          title: 'Module.DisplayOrder',
          width: 120,
          type: 'number'
        }
      ],
      rowActions: [
        {
          icon: 'edit',
          tooltip: 'Common.Edit',
          visible: () => this.hasUpdatePermission,
          action: (row: ModuleView) => this.openEditDialog(row)
        },
        {
          icon: 'delete',
          tooltip: 'Common.Delete',
          visible: () => this.hasDeletePermission,
          action: (row: ModuleView) => this.confirmDelete(row),
          confirmMessage: 'Module.ConfirmDelete'
        }
      ],
      toolbarActions: [
        {
          text: 'Common.Add',
          icon: 'add',
          visible: this.hasCreatePermission,
          action: () => this.openCreateDialog()
        }
      ]
    });
  }

  async loadData(): Promise<void> {
    this.loading = true;
    try {
      const result = await this.moduleClient.getByApplication(this.applicationId).toPromise();
      this.modules = result || [];
    } catch (error) {
      console.error('Error loading modules:', error);
    } finally {
      this.loading = false;
    }
  }

  openCreateDialog(): void {
    const dialogRef = this.modalService.open(ModuleDialogComponent, {
      title: 'Module.CreateTitle',
      data: { applicationId: this.applicationId, rolePrefix: this.rolePrefix }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.loadData();
      }
    });
  }

  openEditDialog(module: ModuleView): void {
    const dialogRef = this.modalService.open(ModuleDialogComponent, {
      title: 'Module.EditTitle',
      data: { module, rolePrefix: this.rolePrefix }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.loadData();
      }
    });
  }

  async confirmDelete(module: ModuleView): Promise<void> {
    // Validar que no es el último módulo activo
    const activeModules = this.modules.filter(m => !m.auditDeletionDate);
    if (activeModules.length === 1) {
      alert('No se puede eliminar el último módulo activo de la aplicación');
      return;
    }

    const confirmed = await this.modalService.confirm({
      title: 'Common.Confirm',
      message: 'Module.ConfirmDelete'
    });

    if (confirmed) {
      try {
        await this.moduleClient.delete(module.id).toPromise();
        this.loadData();
      } catch (error) {
        console.error('Error deleting module:', error);
      }
    }
  }
}
```

**Paso 2: Crear Template del Grid**

Archivo: `src/app/modules/admin/components/module-grid/module-grid.component.html`

```html
<cl-grid
  [config]="gridConfig"
  [data]="modules"
  [loading]="loading">
</cl-grid>
```

**Paso 3: Crear Componente Modal**

Archivo: `src/app/modules/admin/components/module-dialog/module-dialog.component.ts`

```typescript
import { Component, OnInit, Inject, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { ClModalRef, CL_MODAL_DATA } from '@cl/common-library/cl-modal';
import { ClFormFieldsModule } from '@cl/common-library/cl-form-fields';
import { ClButtonModule } from '@cl/common-library/cl-buttons';
import { TranslateModule } from '@ngx-translate/core';
import { ModuleClient, ModuleView } from '@webServicesReferences/api/apiClients';

@Component({
  selector: 'app-module-dialog',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    ClFormFieldsModule,
    ClButtonModule,
    TranslateModule
  ],
  templateUrl: './module-dialog.component.html',
  styleUrls: ['./module-dialog.component.scss']
})
export class ModuleDialogComponent implements OnInit {
  private readonly fb = inject(FormBuilder);
  private readonly moduleClient = inject(ModuleClient);
  private readonly dialogRef = inject(ClModalRef);

  form!: FormGroup;
  isEditMode = false;
  saving = false;
  rolePrefix = '';

  constructor(@Inject(CL_MODAL_DATA) public data: any) {
    this.isEditMode = !!data.module;
    this.rolePrefix = data.rolePrefix;
  }

  ngOnInit(): void {
    this.buildForm();
  }

  private buildForm(): void {
    const expectedPrefix = `M${this.rolePrefix}_`;
    
    this.form = this.fb.group({
      id: [this.data.module?.id || 0],
      moduleName: [
        this.data.module?.moduleName || expectedPrefix,
        [
          Validators.required,
          Validators.pattern(`^M${this.rolePrefix}_[A-Za-z0-9_]+$`)
        ]
      ],
      description: [
        this.data.module?.description || '',
        [Validators.maxLength(500)]
      ],
      displayOrder: [
        this.data.module?.displayOrder || 0,
        [Validators.required, Validators.min(0)]
      ],
      applicationId: [this.data.applicationId]
    });
  }

  get nomenclatureHint(): string {
    return `Formato: M${this.rolePrefix}_NombreDescriptivo (ej: M${this.rolePrefix}_Facturacion)`;
  }

  async save(): Promise<void> {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    this.saving = true;
    try {
      const moduleView = this.form.value as ModuleView;

      if (this.isEditMode) {
        await this.moduleClient.update(moduleView.id, moduleView).toPromise();
      } else {
        await this.moduleClient.create(moduleView).toPromise();
      }

      this.dialogRef.close(true);
    } catch (error) {
      console.error('Error saving module:', error);
      this.saving = false;
    }
  }

  cancel(): void {
    this.dialogRef.close();
  }
}
```

**Paso 4: Template del Modal**

Archivo: `src/app/modules/admin/components/module-dialog/module-dialog.component.html`

```html
<form [formGroup]="form" (ngSubmit)="save()">
  <div class="modal-body">
    <cl-text-field
      formControlName="moduleName"
      [label]="'Module.Name' | translate"
      [hint]="nomenclatureHint"
      [required]="true">
    </cl-text-field>

    <cl-text-area
      formControlName="description"
      [label]="'Module.Description' | translate"
      [rows]="3">
    </cl-text-area>

    <cl-number-field
      formControlName="displayOrder"
      [label]="'Module.DisplayOrder' | translate"
      [required]="true">
    </cl-number-field>
  </div>

  <div class="modal-footer">
    <cl-button
      [text]="'Common.Cancel' | translate"
      [type]="'secondary'"
      (onClick)="cancel()">
    </cl-button>
    
    <cl-button
      [text]="'Common.Save' | translate"
      [type]="'primary'"
      [loading]="saving"
      [disabled]="form.invalid"
      (onClick)="save()">
    </cl-button>
  </div>
</form>
```

**Paso 5: Traducciones**

Archivo: `src/assets/i18n/es.json`

```json
{
  "Module": {
    "Name": "Nombre del módulo",
    "Description": "Descripción",
    "DisplayOrder": "Orden de visualización",
    "CreateTitle": "Crear módulo",
    "EditTitle": "Editar módulo",
    "ConfirmDelete": "¿Está seguro de eliminar este módulo?"
  }
}
```

**Paso 6: Tests Unitarios**

Archivo: `src/app/modules/admin/components/module-grid/module-grid.component.spec.ts`

```typescript
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ModuleGridComponent } from './module-grid.component';
import { ModuleClient } from '@webServicesReferences/api/apiClients';
import { of } from 'rxjs';

describe('ModuleGridComponent', () => {
  let component: ModuleGridComponent;
  let fixture: ComponentFixture<ModuleGridComponent>;
  let moduleClientSpy: jasmine.SpyObj<ModuleClient>;

  beforeEach(async () => {
    const spy = jasmine.createSpyObj('ModuleClient', ['getByApplication', 'delete']);

    await TestBed.configureTestingModule({
      imports: [ModuleGridComponent],
      providers: [
        { provide: ModuleClient, useValue: spy }
      ]
    }).compileComponents();

    moduleClientSpy = TestBed.inject(ModuleClient) as jasmine.SpyObj<ModuleClient>;
    fixture = TestBed.createComponent(ModuleGridComponent);
    component = fixture.componentInstance;
    component.applicationId = 1;
    component.rolePrefix = 'CRM';
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should load modules on init', async () => {
    const mockModules = [
      { id: 1, moduleName: 'MCRM_Facturacion', applicationId: 1 }
    ];
    moduleClientSpy.getByApplication.and.returnValue(of(mockModules));

    await component.ngOnInit();

    expect(component.modules.length).toBe(1);
  });

  it('should prevent deleting last active module', async () => {
    component.modules = [
      { id: 1, moduleName: 'MCRM_Facturacion', auditDeletionDate: null }
    ];

    spyOn(window, 'alert');
    await component.confirmDelete(component.modules[0]);

    expect(window.alert).toHaveBeenCalled();
    expect(moduleClientSpy.delete).not.toHaveBeenCalled();
  });
});
```

**ARCHIVOS A CREAR:**
- `src/app/modules/admin/components/module-grid/module-grid.component.ts`
- `src/app/modules/admin/components/module-grid/module-grid.component.html`
- `src/app/modules/admin/components/module-grid/module-grid.component.scss`
- `src/app/modules/admin/components/module-dialog/module-dialog.component.ts`
- `src/app/modules/admin/components/module-dialog/module-dialog.component.html`
- `src/app/modules/admin/components/module-dialog/module-dialog.component.scss`
- `src/app/modules/admin/components/module-grid/module-grid.component.spec.ts`
- `src/app/modules/admin/components/module-dialog/module-dialog.component.spec.ts`

**DEPENDENCIAS:**
- TASK-016-BE - Endpoints del backend
- Cliente NSwag generado

**DEFINITION OF DONE:**
- [ ] Componentes creados como Standalone
- [ ] ClGrid configurado correctamente
- [ ] Modal de creación/edición funcional
- [ ] Validación de nomenclatura M{Prefix}_ implementada
- [ ] Validación: no eliminar último módulo
- [ ] Traducciones añadidas
- [ ] Tests unitarios >80%
- [ ] Sin errores de compilación

**RECURSOS:**
- User Story: `userStories.md#us-016`
- Helix6 Frontend: `Helix6_Frontend_Architecture.md`

=============================================================

---

### US-017: Asignar módulos de una aplicación a una organización

**Resumen de tickets generados:**
- TASK-017-BE: Entidad ModuleAccess (N:M soft delete) con publicación de OrganizationEvent
- TASK-017-FE: UI de asignación de módulos con checklist

---

[TASK-017-BE contenido ya existe arriba]

---

#### TASK-017-FE: Implementar UI de asignación de módulos a organización

=============================================================
**TICKET ID:** TASK-017-FE  
**EPIC:** Configuración de Módulos y Permisos de Acceso  
**USER STORY:** US-017 - Asignar módulos de una aplicación a una organización  
**COMPONENT:** Frontend  
**PRIORITY:** Alta  
**ESTIMATION:** 7 horas  
=============================================================

**TÍTULO:**
Implementar UI de asignación de módulos a organización con checklist por aplicación

**DESCRIPCIÓN:**
Crear interfaz dentro del detalle de organización que muestre las aplicaciones disponibles y permita marcar/desmarcar módulos mediante checkboxes. Los cambios se guardan automáticamente al hacer toggle del checkbox.

**CONTEXTO TÉCNICO:**
- **Ubicación**: Pestaña "Módulos" en detalle de organización
- **Layout**: Accordion con aplicaciones, cada una con checklist de módulos
- **Guardado**: Auto-save al marcar/desmarcar (sin botón "Guardar")
- **Estado**: Indicador de "Guardando..." durante peticiones
- **Permisos**: AccessService valida Access.Update

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] Componente ModuleAccessComponent creado como Standalone
- [ ] Accordion de aplicaciones implementado con ClAccordion
- [ ] Checklist de módulos por aplicación
- [ ] Auto-save al toggle de checkbox
- [ ] Indicador de loading durante guardado
- [ ] Cliente NSwag integrado
- [ ] Traducciones en es.json y en.json
- [ ] Tests unitarios >80%

**GUÍA DE IMPLEMENTACIÓN:**

**Paso 1: Crear Componente Principal**

Archivo: `src/app/modules/admin/components/module-access/module-access.component.ts`

```typescript
import { Component, OnInit, Input, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ClAccordionModule } from '@cl/common-library/cl-accordion';
import { ClCheckboxModule } from '@cl/common-library/cl-form-fields';
import { ClLoadingModule } from '@cl/common-library/cl-loading';
import { TranslateModule } from '@ngx-translate/core';
import { 
  ModuleAccessClient, 
  ApplicationClient, 
  ModuleClient,
  ModuleAccessView 
} from '@webServicesReferences/api/apiClients';
import { AccessService, Access } from '@services/access.service';

interface ModuleWithAccess {
  moduleId: number;
  moduleName: string;
  description: string;
  hasAccess: boolean;
  moduleAccessId?: number; // ID del registro ModuleAccess si existe
  saving?: boolean;
}

interface AppWithModules {
  applicationId: number;
  applicationName: string;
  rolePrefix: string;
  modules: ModuleWithAccess[];
  expanded: boolean;
}

@Component({
  selector: 'app-module-access',
  standalone: true,
  imports: [
    CommonModule,
    ClAccordionModule,
    ClCheckboxModule,
    ClLoadingModule,
    TranslateModule
  ],
  templateUrl: './module-access.component.html',
  styleUrls: ['./module-access.component.scss']
})
export class ModuleAccessComponent implements OnInit {
  @Input() organizationId!: number;

  private readonly moduleAccessClient = inject(ModuleAccessClient);
  private readonly applicationClient = inject(ApplicationClient);
  private readonly moduleClient = inject(ModuleClient);
  private readonly accessService = inject(AccessService);

  apps: AppWithModules[] = [];
  loading = false;
  hasUpdatePermission = false;

  ngOnInit(): void {
    this.checkPermissions();
    this.loadData();
  }

  private checkPermissions(): void {
    const moduleName = 'MSTP_Organizations';
    this.hasUpdatePermission = this.accessService.hasAccess(moduleName, Access.Update);
  }

  async loadData(): Promise<void> {
    this.loading = true;
    try {
      // 1. Cargar todas las aplicaciones
      const applications = await this.applicationClient.getAll().toPromise();

      // 2. Cargar accesos actuales de la organización
      const currentAccess = await this.moduleAccessClient
        .getByOrganization(this.organizationId)
        .toPromise();

      // 3. Por cada aplicación, cargar sus módulos
      this.apps = [];
      for (const app of applications || []) {
        const modules = await this.moduleClient.getByApplication(app.id).toPromise();

        const modulesWithAccess: ModuleWithAccess[] = (modules || []).map(module => {
          const access = currentAccess?.find(
            a => a.moduleId === module.id && !a.auditDeletionDate
          );

          return {
            moduleId: module.id,
            moduleName: module.moduleName,
            description: module.description,
            hasAccess: !!access,
            moduleAccessId: access?.id
          };
        });

        this.apps.push({
          applicationId: app.id,
          applicationName: app.name,
          rolePrefix: app.rolePrefix,
          modules: modulesWithAccess,
          expanded: false
        });
      }

      // Expandir primera app por defecto
      if (this.apps.length > 0) {
        this.apps[0].expanded = true;
      }

    } catch (error) {
      console.error('Error loading module access:', error);
    } finally {
      this.loading = false;
    }
  }

  async toggleModuleAccess(appModule: ModuleWithAccess): Promise<void> {
    if (!this.hasUpdatePermission) {
      return;
    }

    appModule.saving = true;
    try {
      if (appModule.hasAccess) {
        // Revocar acceso (soft delete)
        await this.moduleAccessClient.delete(appModule.moduleAccessId!).toPromise();
        appModule.hasAccess = false;
        appModule.moduleAccessId = undefined;
      } else {
        // Otorgar acceso
        const newAccess: ModuleAccessView = {
          organizationId: this.organizationId,
          moduleId: appModule.moduleId
        } as ModuleAccessView;

        const created = await this.moduleAccessClient.create(newAccess).toPromise();
        appModule.hasAccess = true;
        appModule.moduleAccessId = created.id;
      }
    } catch (error) {
      console.error('Error toggling module access:', error);
      // Revertir estado en caso de error
      appModule.hasAccess = !appModule.hasAccess;
    } finally {
      appModule.saving = false;
    }
  }

  getAccessCount(app: AppWithModules): number {
    return app.modules.filter(m => m.hasAccess).length;
  }
}
```

**Paso 2: Template del Componente**

Archivo: `src/app/modules/admin/components/module-access/module-access.component.html`

```html
<div class="module-access-container" *ngIf="!loading; else loadingTemplate">
  <cl-accordion [allowMultiple]="true">
    <cl-accordion-item
      *ngFor="let app of apps"
      [(expanded)]="app.expanded">
      
      <ng-template clAccordionHeader>
        <div class="app-header">
          <span class="app-name">{{ app.applicationName }}</span>
          <span class="app-badge">
            {{ getAccessCount(app) }} / {{ app.modules.length }} módulos
          </span>
        </div>
      </ng-template>

      <ng-template clAccordionContent>
        <div class="modules-checklist">
          <div
            *ngFor="let module of app.modules"
            class="module-item">
            
            <cl-checkbox
              [(ngModel)]="module.hasAccess"
              (ngModelChange)="toggleModuleAccess(module)"
              [disabled]="!hasUpdatePermission || module.saving">
              
              <div class="module-info">
                <span class="module-name">{{ module.moduleName }}</span>
                <span class="module-description">{{ module.description }}</span>
              </div>
            </cl-checkbox>

            <span *ngIf="module.saving" class="saving-indicator">
              <cl-loading [size]="'small'"></cl-loading>
              {{ 'Common.Saving' | translate }}
            </span>
          </div>
        </div>
      </ng-template>
    </cl-accordion-item>
  </cl-accordion>

  <div class="empty-state" *ngIf="apps.length === 0">
    <p>{{ 'ModuleAccess.NoApplications' | translate }}</p>
  </div>
</div>

<ng-template #loadingTemplate>
  <cl-loading [message]="'Common.Loading' | translate"></cl-loading>
</ng-template>
```

**Paso 3: Estilos SCSS**

Archivo: `src/app/modules/admin/components/module-access/module-access.component.scss`

```scss
.module-access-container {
  padding: 16px;

  .app-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    width: 100%;

    .app-name {
      font-weight: 600;
      font-size: 16px;
    }

    .app-badge {
      background-color: #e3f2fd;
      color: #1976d2;
      padding: 4px 12px;
      border-radius: 12px;
      font-size: 12px;
      font-weight: 500;
    }
  }

  .modules-checklist {
    display: flex;
    flex-direction: column;
    gap: 12px;
    padding: 16px 8px;

    .module-item {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 8px;
      border-radius: 4px;
      transition: background-color 0.2s;

      &:hover {
        background-color: #f5f5f5;
      }

      .module-info {
        display: flex;
        flex-direction: column;
        margin-left: 8px;

        .module-name {
          font-weight: 500;
          color: #333;
        }

        .module-description {
          font-size: 12px;
          color: #666;
          margin-top: 2px;
        }
      }

      .saving-indicator {
        display: flex;
        align-items: center;
        gap: 8px;
        color: #1976d2;
        font-size: 12px;
      }
    }
  }

  .empty-state {
    text-align: center;
    padding: 48px;
    color: #666;
  }
}
```

**Paso 4: Traducciones**

Archivo: `src/assets/i18n/es.json`

```json
{
  "ModuleAccess": {
    "NoApplications": "No hay aplicaciones disponibles",
    "Saving": "Guardando...",
    "AccessGranted": "Acceso otorgado",
    "AccessRevoked": "Acceso revocado"
  }
}
```

**Paso 5: Integrar en Detalle de Organización**

Modificar: `src/app/modules/admin/components/organization-detail/organization-detail.component.html`

```html
<cl-tabs>
  <cl-tab [label]="'Organization.GeneralTab' | translate">
    <!-- Información general existente -->
  </cl-tab>

  <cl-tab [label]="'Organization.ModulesTab' | translate">
    <app-module-access [organizationId]="organizationId"></app-module-access>
  </cl-tab>

  <cl-tab [label]="'Organization.AuditTab' | translate">
    <!-- Auditoría existente -->
  </cl-tab>
</cl-tabs>
```

**Paso 6: Tests Unitarios**

Archivo: `src/app/modules/admin/components/module-access/module-access.component.spec.ts`

```typescript
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ModuleAccessComponent } from './module-access.component';
import { ModuleAccessClient } from '@webServicesReferences/api/apiClients';
import { of } from 'rxjs';

describe('ModuleAccessComponent', () => {
  let component: ModuleAccessComponent;
  let fixture: ComponentFixture<ModuleAccessComponent>;
  let moduleAccessClientSpy: jasmine.SpyObj<ModuleAccessClient>;

  beforeEach(async () => {
    const spy = jasmine.createSpyObj('ModuleAccessClient', [
      'getByOrganization',
      'create',
      'delete'
    ]);

    await TestBed.configureTestingModule({
      imports: [ModuleAccessComponent],
      providers: [
        { provide: ModuleAccessClient, useValue: spy }
      ]
    }).compileComponents();

    moduleAccessClientSpy = TestBed.inject(ModuleAccessClient) as jasmine.SpyObj<ModuleAccessClient>;
    fixture = TestBed.createComponent(ModuleAccessComponent);
    component = fixture.componentInstance;
    component.organizationId = 1;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should load module access on init', async () => {
    moduleAccessClientSpy.getByOrganization.and.returnValue(of([]));

    await component.ngOnInit();

    expect(moduleAccessClientSpy.getByOrganization).toHaveBeenCalledWith(1);
  });

  it('should toggle module access', async () => {
    const module = {
      moduleId: 1,
      moduleName: 'MCRM_Facturacion',
      hasAccess: false
    };

    moduleAccessClientSpy.create.and.returnValue(of({ id: 10 }));

    await component.toggleModuleAccess(module);

    expect(module.hasAccess).toBeTrue();
    expect(moduleAccessClientSpy.create).toHaveBeenCalled();
  });
});
```

**ARCHIVOS A CREAR:**
- `src/app/modules/admin/components/module-access/module-access.component.ts`
- `src/app/modules/admin/components/module-access/module-access.component.html`
- `src/app/modules/admin/components/module-access/module-access.component.scss`
- `src/app/modules/admin/components/module-access/module-access.component.spec.ts`

**ARCHIVOS A MODIFICAR:**
- `src/app/modules/admin/components/organization-detail/organization-detail.component.html`

**DEPENDENCIAS:**
- TASK-017-BE - Endpoints del backend
- Cliente NSwag generado

**DEFINITION OF DONE:**
- [ ] Componente creado como Standalone
- [ ] Accordion de aplicaciones funcional
- [ ] Checklist de módulos implementada
- [ ] Auto-save al toggle funcional
- [ ] Indicador de "Guardando..." funcional
- [ ] Integrado en detalle de organización
- [ ] Traducciones añadidas
- [ ] Tests unitarios >80%
- [ ] Sin errores de compilación

**RECURSOS:**
- User Story: `userStories.md#us-017`
- Helix6 Frontend: `Helix6_Frontend_Architecture.md`

=============================================================

---

### US-018: Configurar acceso masivo de módulos

**Resumen de tickets generados:**
- TASK-018-BE: Endpoint de asignación masiva de módulos
- TASK-018-FE: UI de configuración masiva

---

#### TASK-018-BE: Endpoint de asignación masiva de módulos

=============================================================
**TICKET ID:** TASK-018-BE  
**EPIC:** Configuración de Módulos y Permisos de Acceso  
**USER STORY:** US-018 - Configurar acceso masivo de módulos  
**COMPONENT:** Backend  
**PRIORITY:** Media  
**ESTIMATION:** 4 horas  
=============================================================

**TÍTULO:**
Implementar endpoint de asignación masiva de módulos a múltiples organizaciones

**DESCRIPCIÓN:**
Crear endpoint POST que permita asignar un conjunto de módulos a múltiples organizaciones en una sola transacción atómica. El endpoint debe procesar la operación en batch, publicar eventos para cada organización afectada y manejar errores sin dejar el sistema en estado inconsistente.

**CONTEXTO TÉCNICO:**
- **Endpoint**: POST /api/module-access/bulk-assign
- **Transacción**: Atómica (todo o nada) usando DbContext.Transaction
- **Eventos**: Publicar OrganizationEvent para cada organización afectada
- **Validaciones**: Verificar que organizaciones y módulos existen
- **Optimización**: Evitar N+1 queries usando Include/ThenInclude

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] DTO BulkModuleAssignRequest creado
- [ ] Endpoint POST /api/module-access/bulk-assign implementado
- [ ] Transacción atómica implementada
- [ ] Validaciones de existencia de organizaciones y módulos
- [ ] No crear duplicados (verificar accesos existentes)
- [ ] Publicar OrganizationEvent para cada organización
- [ ] Respuesta con resumen: total asignados, errores
- [ ] Tests de integración

**GUÍA DE IMPLEMENTACIÓN:**

**Paso 1: Crear DTO de Request**

Archivo: `InfoportOneAdmon.Entities/DTOs/BulkModuleAssignRequest.cs`

```csharp
using System.ComponentModel.DataAnnotations;

namespace InfoportOneAdmon.Entities.DTOs
{
    /// <summary>
    /// DTO para asignación masiva de módulos a organizaciones
    /// </summary>
    public class BulkModuleAssignRequest
    {
        /// <summary>
        /// IDs de las organizaciones a las que asignar módulos
        /// </summary>
        [Required]
        [MinLength(1, ErrorMessage = "Debe especificar al menos una organización")]
        public List<int> OrganizationIds { get; set; } = new();

        /// <summary>
        /// IDs de los módulos a asignar
        /// </summary>
        [Required]
        [MinLength(1, ErrorMessage = "Debe especificar al menos un módulo")]
        public List<int> ModuleIds { get; set; } = new();
    }

    /// <summary>
    /// DTO de respuesta con resumen de la operación
    /// </summary>
    public class BulkModuleAssignResponse
    {
        public int TotalOrganizations { get; set; }
        public int TotalModules { get; set; }
        public int TotalAssigned { get; set; }
        public int TotalSkipped { get; set; } // Ya existían
        public List<string> Errors { get; set; } = new();
        public bool Success { get; set; }
    }
}
```

**Paso 2: Implementar Método en ModuleAccessService**

Modificar: `InfoportOneAdmon.Services/Services/ModuleAccessService.cs`

```csharp
using InfoportOneAdmon.Entities.DTOs;
using Microsoft.EntityFrameworkCore.Storage;

public async Task<BulkModuleAssignResponse> BulkAssignAsync(
    BulkModuleAssignRequest request,
    CancellationToken cancellationToken)
{
    var response = new BulkModuleAssignResponse
    {
        TotalOrganizations = request.OrganizationIds.Count,
        TotalModules = request.ModuleIds.Count
    };

    // Iniciar transacción
    using var transaction = await _context.Database.BeginTransactionAsync(cancellationToken);

    try
    {
        // Validar que organizaciones existen y están activas
        var organizations = await _organizationRepository.GetQuery()
            .Where(o => request.OrganizationIds.Contains(o.Id) && o.AuditDeletionDate == null)
            .ToListAsync(cancellationToken);

        if (organizations.Count != request.OrganizationIds.Count)
        {
            response.Errors.Add("Una o más organizaciones no existen o están inactivas");
            response.Success = false;
            return response;
        }

        // Validar que módulos existen y están activos
        var modules = await _moduleRepository.GetQuery()
            .Include(m => m.Application)
            .Where(m => request.ModuleIds.Contains(m.Id) && m.AuditDeletionDate == null)
            .ToListAsync(cancellationToken);

        if (modules.Count != request.ModuleIds.Count)
        {
            response.Errors.Add("Uno o más módulos no existen o están inactivos");
            response.Success = false;
            return response;
        }

        // Obtener accesos existentes para evitar duplicados
        var existingAccess = await _moduleAccessRepository.GetQuery()
            .Where(ma => request.OrganizationIds.Contains(ma.OrganizationId)
                         && request.ModuleIds.Contains(ma.ModuleId)
                         && ma.AuditDeletionDate == null)
            .ToListAsync(cancellationToken);

        var existingPairs = existingAccess
            .Select(ma => (ma.OrganizationId, ma.ModuleId))
            .ToHashSet();

        // Crear nuevos accesos
        var newAccesses = new List<ModuleAccess>();
        foreach (var orgId in request.OrganizationIds)
        {
            foreach (var moduleId in request.ModuleIds)
            {
                if (existingPairs.Contains((orgId, moduleId)))
                {
                    response.TotalSkipped++;
                    continue;
                }

                newAccesses.Add(new ModuleAccess
                {
                    OrganizationId = orgId,
                    ModuleId = moduleId,
                    AuditCreationDate = DateTime.UtcNow,
                    AuditCreationUser = _userContext.UserId,
                    AuditModificationDate = DateTime.UtcNow,
                    AuditModificationUser = _userContext.UserId
                });

                response.TotalAssigned++;
            }
        }

        // Insertar en batch
        if (newAccesses.Any())
        {
            await _moduleAccessRepository.AddRangeAsync(newAccesses, cancellationToken);
            await _context.SaveChangesAsync(cancellationToken);
        }

        // Publicar eventos para cada organización afectada
        foreach (var orgId in request.OrganizationIds)
        {
            var organization = await _organizationRepository.GetQuery()
                .Include(o => o.ModuleAccesses)
                    .ThenInclude(ma => ma.Module)
                        .ThenInclude(m => m.Application)
                .FirstOrDefaultAsync(o => o.Id == orgId, cancellationToken);

            if (organization != null)
            {
                await PublishOrganizationEventAsync(organization, cancellationToken);
            }
        }

        // Commit transacción
        await transaction.CommitAsync(cancellationToken);
        response.Success = true;

        _logger.LogInformation(
            "Bulk assign completado: {TotalAssigned} asignados, {TotalSkipped} omitidos",
            response.TotalAssigned,
            response.TotalSkipped);

    }
    catch (Exception ex)
    {
        await transaction.RollbackAsync(cancellationToken);
        response.Errors.Add($"Error durante asignación masiva: {ex.Message}");
        response.Success = false;

        _logger.LogError(ex, "Error en bulk assign de módulos");
    }

    return response;
}
```

**Paso 3: Crear Endpoint**

Archivo: `InfoportOneAdmon.Api/Endpoints/ModuleAccessEndpoints.cs`

```csharp
using Microsoft.AspNetCore.Mvc;
using InfoportOneAdmon.Services.Services;
using InfoportOneAdmon.Entities.DTOs;

namespace InfoportOneAdmon.Api.Endpoints
{
    public static class ModuleAccessEndpoints
    {
        public static void MapModuleAccessEndpoints(this IEndpointRouteBuilder app)
        {
            var group = app.MapGroup("/api/module-access")
                .WithTags("ModuleAccess");

            /// <summary>
            /// Asigna módulos a múltiples organizaciones de forma masiva
            /// </summary>
            group.MapPost("/bulk-assign", async (
                [FromBody] BulkModuleAssignRequest request,
                [FromServices] ModuleAccessService service,
                CancellationToken cancellationToken) =>
            {
                var result = await service.BulkAssignAsync(request, cancellationToken);

                return result.Success
                    ? Results.Ok(result)
                    : Results.BadRequest(result);
            })
            .WithName("BulkAssignModules")
            .WithOpenApi()
            .Produces<BulkModuleAssignResponse>(StatusCodes.Status200OK)
            .Produces<BulkModuleAssignResponse>(StatusCodes.Status400BadRequest);

            // Endpoints CRUD estándar generados por Helix6
            // ...
        }
    }
}
```

Registrar en `Program.cs`:

```csharp
app.MapModuleAccessEndpoints();
```

**Paso 4: Tests de Integración**

Archivo: `InfoportOneAdmon.Services.Tests/Services/ModuleAccessServiceTests.cs`

```csharp
[Fact]
public async Task BulkAssignAsync_ValidData_AssignsSuccessfully()
{
    // Arrange
    var request = new BulkModuleAssignRequest
    {
        OrganizationIds = new List<int> { 1, 2, 3 },
        ModuleIds = new List<int> { 10, 20 }
    };

    _organizationRepositoryMock.Setup(r => r.GetQuery())
        .Returns(new List<Organization>
        {
            new Organization { Id = 1 },
            new Organization { Id = 2 },
            new Organization { Id = 3 }
        }.AsQueryable());

    _moduleRepositoryMock.Setup(r => r.GetQuery())
        .Returns(new List<Module>
        {
            new Module { Id = 10 },
            new Module { Id = 20 }
        }.AsQueryable());

    _moduleAccessRepositoryMock.Setup(r => r.GetQuery())
        .Returns(new List<ModuleAccess>().AsQueryable());

    // Act
    var result = await _service.BulkAssignAsync(request, CancellationToken.None);

    // Assert
    result.Success.Should().BeTrue();
    result.TotalAssigned.Should().Be(6); // 3 orgs × 2 modules
    result.TotalSkipped.Should().Be(0);
}

[Fact]
public async Task BulkAssignAsync_WithExistingAccess_SkipsDuplicates()
{
    // Arrange
    var request = new BulkModuleAssignRequest
    {
        OrganizationIds = new List<int> { 1 },
        ModuleIds = new List<int> { 10, 20 }
    };

    // Ya existe acceso para org 1 y module 10
    _moduleAccessRepositoryMock.Setup(r => r.GetQuery())
        .Returns(new List<ModuleAccess>
        {
            new ModuleAccess { OrganizationId = 1, ModuleId = 10 }
        }.AsQueryable());

    // Act
    var result = await _service.BulkAssignAsync(request, CancellationToken.None);

    // Assert
    result.TotalAssigned.Should().Be(1); // Solo org 1 × module 20
    result.TotalSkipped.Should().Be(1); // org 1 × module 10 ya existía
}
```

**ARCHIVOS A CREAR/MODIFICAR:**
- `InfoportOneAdmon.Entities/DTOs/BulkModuleAssignRequest.cs` - DTO de request
- `InfoportOneAdmon.Services/Services/ModuleAccessService.cs` - Método BulkAssignAsync
- `InfoportOneAdmon.Api/Endpoints/ModuleAccessEndpoints.cs` - Endpoint
- `InfoportOneAdmon.Api/Program.cs` - Registrar endpoints
- `InfoportOneAdmon.Services.Tests/Services/ModuleAccessServiceTests.cs` - Tests

**DEPENDENCIAS:**
- TASK-017-BE - ModuleAccessService existe

**DEFINITION OF DONE:**
- [ ] DTO creado con validaciones
- [ ] Método BulkAssignAsync implementado
- [ ] Transacción atómica funcional
- [ ] Validaciones de entidades implementadas
- [ ] No crea duplicados
- [ ] Publica eventos para organizaciones afectadas
- [ ] Endpoint POST /bulk-assign documentado en Swagger
- [ ] Tests de integración >80%
- [ ] Code review aprobado

**RECURSOS:**
- User Story: `userStories.md#us-018`

=============================================================

---

#### TASK-018-FE: UI de configuración masiva de módulos

=============================================================
**TICKET ID:** TASK-018-FE  
**EPIC:** Configuración de Módulos y Permisos de Acceso  
**USER STORY:** US-018 - Configurar acceso masivo de módulos  
**COMPONENT:** Frontend  
**PRIORITY:** Media  
**ESTIMATION:** 6 horas  
=============================================================

**TÍTULO:**
Implementar UI de configuración masiva de módulos a múltiples organizaciones

**DESCRIPCIÓN:**
Crear interfaz de usuario para asignar módulos a múltiples organizaciones de forma masiva, permitiendo seleccionar un conjunto de organizaciones, elegir una aplicación y marcar los módulos a asignar, ejecutando la asignación en batch.

**CONTEXTO TÉCNICO:**
- **Ubicación**: Nueva página en módulo admin (/admin/bulk-module-assign)
- **Selector múltiple**: Organizaciones con autocomplete y chips
- **Selector de aplicación**: Dropdown que carga módulos dinámicamente
- **Checklist de módulos**: Con select-all
- **Preview**: Resumen antes de confirmar
- **Progreso**: Indicador durante asignación
- **Cliente NSwag**: Llamada a endpoint POST /bulk-assign

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] Componente BulkModuleAssignComponent creado como Standalone
- [ ] Multi-selector de organizaciones con búsqueda
- [ ] Selector de aplicación que carga módulos
- [ ] Checklist de módulos con select-all
- [ ] Preview con resumen: "X módulos a Y organizaciones"
- [ ] Indicador de progreso durante asignación
- [ ] Mensaje de resultado con estadísticas
- [ ] Traducciones en es.json y en.json
- [ ] Tests unitarios >80%

**GUÍA DE IMPLEMENTACIÓN:**

**Paso 1: Crear Componente Principal**

Archivo: `src/app/modules/admin/pages/bulk-module-assign/bulk-module-assign.component.ts`

```typescript
import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { ClAutocompleteModule } from '@cl/common-library/cl-autocomplete';
import { ClSelectModule } from '@cl/common-library/cl-select';
import { ClCheckboxModule } from '@cl/common-library/cl-form-fields';
import { ClButtonModule } from '@cl/common-library/cl-buttons';
import { ClCardModule } from '@cl/common-library/cl-card';
import { ClLoadingModule } from '@cl/common-library/cl-loading';
import { TranslateModule } from '@ngx-translate/core';
import { 
  OrganizationClient,
  ApplicationClient,
  ModuleClient,
  ModuleAccessClient,
  BulkModuleAssignRequest
} from '@webServicesReferences/api/apiClients';

interface ModuleOption {
  id: number;
  name: string;
  description: string;
  selected: boolean;
}

@Component({
  selector: 'app-bulk-module-assign',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    ClAutocompleteModule,
    ClSelectModule,
    ClCheckboxModule,
    ClButtonModule,
    ClCardModule,
    ClLoadingModule,
    TranslateModule
  ],
  templateUrl: './bulk-module-assign.component.html',
  styleUrls: ['./bulk-module-assign.component.scss']
})
export class BulkModuleAssignComponent implements OnInit {
  private readonly fb = inject(FormBuilder);
  private readonly organizationClient = inject(OrganizationClient);
  private readonly applicationClient = inject(ApplicationClient);
  private readonly moduleClient = inject(ModuleClient);
  private readonly moduleAccessClient = inject(ModuleAccessClient);

  form!: FormGroup;
  
  // Data sources
  organizations: any[] = [];
  applications: any[] = [];
  modules: ModuleOption[] = [];

  // Selected data
  selectedOrganizations: any[] = [];
  selectedApplication: any = null;

  // UI state
  loadingOrganizations = false;
  loadingApplications = false;
  loadingModules = false;
  processing = false;
  showPreview = false;
  result: any = null;

  ngOnInit(): void {
    this.buildForm();
    this.loadOrganizations();
    this.loadApplications();
  }

  private buildForm(): void {
    this.form = this.fb.group({
      organizationIds: [[], Validators.required],
      applicationId: [null, Validators.required]
    });

    // Cargar módulos cuando cambia la aplicación
    this.form.get('applicationId')?.valueChanges.subscribe(appId => {
      if (appId) {
        this.loadModules(appId);
      } else {
        this.modules = [];
      }
    });
  }

  async loadOrganizations(): Promise<void> {
    this.loadingOrganizations = true;
    try {
      this.organizations = await this.organizationClient.getAll().toPromise() || [];
    } catch (error) {
      console.error('Error loading organizations:', error);
    } finally {
      this.loadingOrganizations = false;
    }
  }

  async loadApplications(): Promise<void> {
    this.loadingApplications = true;
    try {
      this.applications = await this.applicationClient.getAll().toPromise() || [];
    } catch (error) {
      console.error('Error loading applications:', error);
    } finally {
      this.loadingApplications = false;
    }
  }

  async loadModules(applicationId: number): Promise<void> {
    this.loadingModules = true;
    try {
      const modulesData = await this.moduleClient.getByApplication(applicationId).toPromise();
      this.modules = (modulesData || []).map(m => ({
        id: m.id,
        name: m.moduleName,
        description: m.description,
        selected: false
      }));

      this.selectedApplication = this.applications.find(a => a.id === applicationId);
    } catch (error) {
      console.error('Error loading modules:', error);
    } finally {
      this.loadingModules = false;
    }
  }

  onOrganizationsChange(selected: any[]): void {
    this.selectedOrganizations = selected;
    this.form.patchValue({ organizationIds: selected.map(o => o.id) });
  }

  toggleSelectAllModules(event: any): void {
    const isChecked = event.target.checked;
    this.modules.forEach(m => m.selected = isChecked);
  }

  get allModulesSelected(): boolean {
    return this.modules.length > 0 && this.modules.every(m => m.selected);
  }

  get someModulesSelected(): boolean {
    return this.modules.some(m => m.selected) && !this.allModulesSelected;
  }

  get selectedModules(): ModuleOption[] {
    return this.modules.filter(m => m.selected);
  }

  get canPreview(): boolean {
    return this.selectedOrganizations.length > 0 && this.selectedModules.length > 0;
  }

  preview(): void {
    if (this.canPreview) {
      this.showPreview = true;
    }
  }

  cancelPreview(): void {
    this.showPreview = false;
  }

  async execute(): Promise<void> {
    if (!this.canPreview) {
      return;
    }

    this.processing = true;
    try {
      const request: BulkModuleAssignRequest = {
        organizationIds: this.selectedOrganizations.map(o => o.id),
        moduleIds: this.selectedModules.map(m => m.id)
      };

      this.result = await this.moduleAccessClient.bulkAssign(request).toPromise();
      
      if (this.result.success) {
        // Reset form after success
        this.reset();
      }
    } catch (error) {
      console.error('Error in bulk assign:', error);
      this.result = {
        success: false,
        errors: ['Error al procesar la asignación masiva']
      };
    } finally {
      this.processing = false;
      this.showPreview = false;
    }
  }

  reset(): void {
    this.form.reset();
    this.selectedOrganizations = [];
    this.selectedApplication = null;
    this.modules = [];
    this.showPreview = false;
  }

  closeResult(): void {
    this.result = null;
  }
}
```

**Paso 2: Template del Componente**

Archivo: `src/app/modules/admin/pages/bulk-module-assign/bulk-module-assign.component.html`

```html
<div class="bulk-assign-container">
  <h1>{{ 'BulkModuleAssign.Title' | translate }}</h1>
  <p class="subtitle">{{ 'BulkModuleAssign.Subtitle' | translate }}</p>

  <form [formGroup]="form">
    <!-- Paso 1: Seleccionar Organizaciones -->
    <cl-card [title]="'BulkModuleAssign.Step1' | translate">
      <cl-autocomplete-multi
        formControlName="organizationIds"
        [label]="'BulkModuleAssign.SelectOrganizations' | translate"
        [data]="organizations"
        [displayField]="'name'"
        [valueField]="'id'"
        [loading]="loadingOrganizations"
        (selectionChange)="onOrganizationsChange($event)">
      </cl-autocomplete-multi>

      <div class="selected-count" *ngIf="selectedOrganizations.length > 0">
        {{ 'BulkModuleAssign.OrganizationsSelected' | translate: { count: selectedOrganizations.length } }}
      </div>
    </cl-card>

    <!-- Paso 2: Seleccionar Aplicación -->
    <cl-card [title]="'BulkModuleAssign.Step2' | translate">
      <cl-select
        formControlName="applicationId"
        [label]="'BulkModuleAssign.SelectApplication' | translate"
        [data]="applications"
        [displayField]="'name'"
        [valueField]="'id'"
        [loading]="loadingApplications">
      </cl-select>
    </cl-card>

    <!-- Paso 3: Seleccionar Módulos -->
    <cl-card 
      [title]="'BulkModuleAssign.Step3' | translate"
      *ngIf="modules.length > 0">
      
      <div class="select-all">
        <cl-checkbox
          [(ngModel)]="allModulesSelected"
          [ngModelOptions]="{standalone: true}"
          [indeterminate]="someModulesSelected"
          (change)="toggleSelectAllModules($event)">
          {{ 'BulkModuleAssign.SelectAll' | translate }}
        </cl-checkbox>
      </div>

      <div class="modules-list">
        <div *ngFor="let module of modules" class="module-item">
          <cl-checkbox [(ngModel)]="module.selected" [ngModelOptions]="{standalone: true}">
            <div class="module-info">
              <span class="module-name">{{ module.name }}</span>
              <span class="module-description">{{ module.description }}</span>
            </div>
          </cl-checkbox>
        </div>
      </div>

      <div class="selected-count" *ngIf="selectedModules.length > 0">
        {{ 'BulkModuleAssign.ModulesSelected' | translate: { count: selectedModules.length } }}
      </div>
    </cl-card>

    <!-- Loading state -->
    <div class="loading-state" *ngIf="loadingModules">
      <cl-loading [message]="'Common.Loading' | translate"></cl-loading>
    </div>

    <!-- Actions -->
    <div class="actions">
      <cl-button
        [text]="'Common.Reset' | translate"
        [type]="'secondary'"
        (onClick)="reset()">
      </cl-button>

      <cl-button
        [text]="'BulkModuleAssign.Preview' | translate"
        [type]="'primary'"
        [disabled]="!canPreview"
        (onClick)="preview()">
      </cl-button>
    </div>
  </form>

  <!-- Preview Modal -->
  <cl-modal [(visible)]="showPreview" [title]="'BulkModuleAssign.PreviewTitle' | translate">
    <div class="preview-content">
      <p class="preview-summary">
        {{ 'BulkModuleAssign.PreviewSummary' | translate: { 
          modules: selectedModules.length,
          organizations: selectedOrganizations.length,
          total: selectedModules.length * selectedOrganizations.length
        } }}
      </p>

      <div class="preview-details">
        <div class="detail-section">
          <h4>{{ 'BulkModuleAssign.Organizations' | translate }}</h4>
          <ul>
            <li *ngFor="let org of selectedOrganizations">{{ org.name }}</li>
          </ul>
        </div>

        <div class="detail-section">
          <h4>{{ 'BulkModuleAssign.Modules' | translate }}</h4>
          <ul>
            <li *ngFor="let module of selectedModules">{{ module.name }}</li>
          </ul>
        </div>
      </div>
    </div>

    <div class="modal-footer">
      <cl-button
        [text]="'Common.Cancel' | translate"
        [type]="'secondary'"
        (onClick)="cancelPreview()">
      </cl-button>

      <cl-button
        [text]="'BulkModuleAssign.Execute' | translate"
        [type]="'primary'"
        [loading]="processing"
        (onClick)="execute()">
      </cl-button>
    </div>
  </cl-modal>

  <!-- Result Modal -->
  <cl-modal 
    [(visible)]="result" 
    [title]="result?.success ? 'BulkModuleAssign.SuccessTitle' : 'BulkModuleAssign.ErrorTitle'">
    
    <div class="result-content" *ngIf="result">
      <div class="result-icon" [class.success]="result.success" [class.error]="!result.success">
        <i [class]="result.success ? 'icon-check-circle' : 'icon-error-circle'"></i>
      </div>

      <div class="result-stats" *ngIf="result.success">
        <div class="stat">
          <span class="label">{{ 'BulkModuleAssign.TotalAssigned' | translate }}</span>
          <span class="value">{{ result.totalAssigned }}</span>
        </div>
        <div class="stat">
          <span class="label">{{ 'BulkModuleAssign.TotalSkipped' | translate }}</span>
          <span class="value">{{ result.totalSkipped }}</span>
        </div>
      </div>

      <div class="result-errors" *ngIf="result.errors?.length > 0">
        <h4>{{ 'Common.Errors' | translate }}</h4>
        <ul>
          <li *ngFor="let error of result.errors">{{ error }}</li>
        </ul>
      </div>
    </div>

    <div class="modal-footer">
      <cl-button
        [text]="'Common.Close' | translate"
        [type]="'primary'"
        (onClick)="closeResult()">
      </cl-button>
    </div>
  </cl-modal>
</div>
```

**Paso 3: Estilos SCSS**

Archivo: `src/app/modules/admin/pages/bulk-module-assign/bulk-module-assign.component.scss`

```scss
.bulk-assign-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 24px;

  h1 {
    font-size: 28px;
    font-weight: 600;
    margin-bottom: 8px;
  }

  .subtitle {
    color: #666;
    margin-bottom: 24px;
  }

  cl-card {
    margin-bottom: 24px;
  }

  .selected-count {
    margin-top: 12px;
    padding: 8px 12px;
    background-color: #e3f2fd;
    border-radius: 4px;
    color: #1976d2;
    font-size: 14px;
    font-weight: 500;
  }

  .select-all {
    padding: 12px 0;
    border-bottom: 1px solid #e0e0e0;
    margin-bottom: 16px;
  }

  .modules-list {
    display: flex;
    flex-direction: column;
    gap: 12px;

    .module-item {
      padding: 8px;
      border-radius: 4px;
      transition: background-color 0.2s;

      &:hover {
        background-color: #f5f5f5;
      }

      .module-info {
        display: flex;
        flex-direction: column;
        margin-left: 8px;

        .module-name {
          font-weight: 500;
        }

        .module-description {
          font-size: 12px;
          color: #666;
          margin-top: 2px;
        }
      }
    }
  }

  .actions {
    display: flex;
    justify-content: flex-end;
    gap: 12px;
    margin-top: 24px;
  }

  .preview-content {
    .preview-summary {
      font-size: 16px;
      font-weight: 500;
      margin-bottom: 24px;
      padding: 16px;
      background-color: #fff3cd;
      border-radius: 4px;
    }

    .preview-details {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 24px;

      .detail-section {
        h4 {
          font-size: 14px;
          font-weight: 600;
          margin-bottom: 12px;
          text-transform: uppercase;
          color: #666;
        }

        ul {
          list-style: none;
          padding: 0;
          margin: 0;

          li {
            padding: 8px;
            border-bottom: 1px solid #e0e0e0;
          }
        }
      }
    }
  }

  .result-content {
    text-align: center;

    .result-icon {
      font-size: 48px;
      margin-bottom: 16px;

      &.success {
        color: #4caf50;
      }

      &.error {
        color: #f44336;
      }
    }

    .result-stats {
      display: flex;
      justify-content: center;
      gap: 48px;
      margin: 24px 0;

      .stat {
        display: flex;
        flex-direction: column;
        gap: 8px;

        .label {
          font-size: 12px;
          color: #666;
          text-transform: uppercase;
        }

        .value {
          font-size: 32px;
          font-weight: 600;
          color: #1976d2;
        }
      }
    }

    .result-errors {
      text-align: left;
      margin-top: 24px;
      padding: 16px;
      background-color: #ffebee;
      border-radius: 4px;

      h4 {
        color: #f44336;
        margin-bottom: 8px;
      }

      ul {
        margin: 0;
        padding-left: 20px;

        li {
          color: #d32f2f;
        }
      }
    }
  }
}
```

**Paso 4: Traducciones**

Archivo: `src/assets/i18n/es.json`

```json
{
  "BulkModuleAssign": {
    "Title": "Asignación Masiva de Módulos",
    "Subtitle": "Asigne módulos a múltiples organizaciones de una sola vez",
    "Step1": "Paso 1: Seleccionar Organizaciones",
    "Step2": "Paso 2: Seleccionar Aplicación",
    "Step3": "Paso 3: Seleccionar Módulos",
    "SelectOrganizations": "Seleccionar organizaciones",
    "SelectApplication": "Seleccionar aplicación",
    "SelectAll": "Seleccionar todos",
    "OrganizationsSelected": "{count} organizaciones seleccionadas",
    "ModulesSelected": "{count} módulos seleccionados",
    "Preview": "Vista Previa",
    "PreviewTitle": "Confirmar Asignación Masiva",
    "PreviewSummary": "Se asignarán {modules} módulos a {organizations} organizaciones (total: {total} asignaciones)",
    "Organizations": "Organizaciones",
    "Modules": "Módulos",
    "Execute": "Ejecutar Asignación",
    "SuccessTitle": "Asignación Completada",
    "ErrorTitle": "Error en Asignación",
    "TotalAssigned": "Asignaciones creadas",
    "TotalSkipped": "Ya existían"
  }
}
```

**Paso 5: Configurar Ruta**

Modificar: `src/app/app.routes.ts`

```typescript
{
  path: 'admin/bulk-module-assign',
  component: BulkModuleAssignComponent,
  canActivate: [AuthGuard],
  data: { module: 'MSTP_Applications', access: Access.Create }
}
```

**Paso 6: Tests Unitarios**

Archivo: `src/app/modules/admin/pages/bulk-module-assign/bulk-module-assign.component.spec.ts`

```typescript
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { BulkModuleAssignComponent } from './bulk-module-assign.component';
import { ModuleAccessClient } from '@webServicesReferences/api/apiClients';
import { of } from 'rxjs';

describe('BulkModuleAssignComponent', () => {
  let component: BulkModuleAssignComponent;
  let fixture: ComponentFixture<BulkModuleAssignComponent>;
  let moduleAccessClientSpy: jasmine.SpyObj<ModuleAccessClient>;

  beforeEach(async () => {
    const spy = jasmine.createSpyObj('ModuleAccessClient', ['bulkAssign']);

    await TestBed.configureTestingModule({
      imports: [BulkModuleAssignComponent],
      providers: [
        { provide: ModuleAccessClient, useValue: spy }
      ]
    }).compileComponents();

    moduleAccessClientSpy = TestBed.inject(ModuleAccessClient) as jasmine.SpyObj<ModuleAccessClient>;
    fixture = TestBed.createComponent(BulkModuleAssignComponent);
    component = fixture.componentInstance;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should execute bulk assign', async () => {
    component.selectedOrganizations = [{ id: 1 }, { id: 2 }];
    component.modules = [
      { id: 10, name: 'Module1', selected: true },
      { id: 20, name: 'Module2', selected: true }
    ];

    moduleAccessClientSpy.bulkAssign.and.returnValue(of({
      success: true,
      totalAssigned: 4,
      totalSkipped: 0
    }));

    await component.execute();

    expect(moduleAccessClientSpy.bulkAssign).toHaveBeenCalled();
    expect(component.result.success).toBeTrue();
  });
});
```

**ARCHIVOS A CREAR:**
- `src/app/modules/admin/pages/bulk-module-assign/bulk-module-assign.component.ts`
- `src/app/modules/admin/pages/bulk-module-assign/bulk-module-assign.component.html`
- `src/app/modules/admin/pages/bulk-module-assign/bulk-module-assign.component.scss`
- `src/app/modules/admin/pages/bulk-module-assign/bulk-module-assign.component.spec.ts`

**ARCHIVOS A MODIFICAR:**
- `src/app/app.routes.ts` - Añadir ruta

**DEPENDENCIAS:**
- TASK-018-BE - Endpoint bulk-assign
- Cliente NSwag generado

**DEFINITION OF DONE:**
- [ ] Componente creado como Standalone
- [ ] Multi-selector de organizaciones funcional
- [ ] Selector de aplicación carga módulos dinámicamente
- [ ] Checklist con select-all funcional
- [ ] Preview muestra resumen correcto
- [ ] Indicador de progreso durante ejecución
- [ ] Resultado muestra estadísticas
- [ ] Traducciones añadidas
- [ ] Ruta configurada
- [ ] Tests unitarios >80%
- [ ] Sin errores de compilación

**RECURSOS:**
- User Story: `userStories.md#us-018`

=============================================================

---

### US-019: Revocar acceso a módulo de organización

**Resumen de tickets generados:**
- TASK-019-NOTE: Funcionalidad ya implementada en TASK-017

---

#### TASK-019-NOTE: Funcionalidad de revocación ya implementada

=============================================================
**TICKET ID:** TASK-019-NOTE  
**EPIC:** Configuración de Módulos y Permisos de Acceso  
**USER STORY:** US-019 - Revocar acceso a módulo de organización  
**COMPONENT:** Nota Arquitectónica  
**PRIORITY:** Media  
**ESTIMATION:** 0 horas  
=============================================================

**TÍTULO:**
Documentar que la revocación de módulos ya está implementada en TASK-017

**DESCRIPCIÓN:**
**US-019 ya fue completamente implementada como parte de TASK-017-BE y TASK-017-FE**. No se requiere desarrollo adicional.

**Funcionalidad ya implementada:**

**Backend (TASK-017-BE):**
- ✅ Soft delete en tabla MODULE_ACCESS mediante AuditDeletionDate
- ✅ PostActions en ModuleAccessService republica OrganizationEvent excluyendo módulos revocados
- ✅ OrganizationEvent solo incluye módulos con AuditDeletionDate == null

**Frontend (TASK-017-FE):**
- ✅ Checkbox en ModuleAccessComponent permite marcar/desmarcar módulos
- ✅ Desmarcar checkbox revoca acceso (DELETE del registro con soft delete)
- ✅ Indicador visual de progreso durante revocación

**Evidencia de implementación:**

En `ModuleAccessService.cs`:
```csharp
// Soft delete al revocar
protected override async Task<bool> DeleteAsync(int id, CancellationToken cancellationToken)
{
    var entity = await Repository.GetByIdAsync(id, cancellationToken);
    if (entity != null)
    {
        entity.AuditDeletionDate = DateTime.UtcNow; // Soft delete
        await Repository.SaveChangesAsync(cancellationToken);
        
        // Republicar OrganizationEvent sin este módulo
        await PublishOrganizationEventAsync(entity.OrganizationId, cancellationToken);
    }
    return true;
}
```

En `ModuleAccessComponent.ts`:
```typescript
async toggleModuleAccess(appModule: ModuleWithAccess): Promise<void> {
    if (appModule.hasAccess) {
        // Revocar acceso (soft delete)
        await this.moduleAccessClient.delete(appModule.moduleAccessId).toPromise();
        appModule.hasAccess = false;
    } else {
        // Otorgar acceso
        const created = await this.moduleAccessClient.create(newAccess).toPromise();
        appModule.hasAccess = true;
    }
}
```

**Casos de uso cubiertos:**
1. ✅ Revocación individual desde detalle de organización (desmarcar checkbox)
2. ✅ Soft delete garantiza trazabilidad (AuditDeletionDate registra cuándo se revocó)
3. ✅ Evento actualizado publicado inmediatamente
4. ✅ Aplicaciones satélite respetan revocación al procesar evento

**RECURSOS:**
- TASK-017-BE - Implementación backend
- TASK-017-FE - Implementación frontend  
- User Story: `userStories.md#us-019`

=============================================================

---

### US-020: Visualizar matriz de permisos organización-módulo

**Resumen de tickets generados:**
- TASK-020-FE: UI de matriz de permisos

---

#### TASK-020-FE: Implementar UI de matriz de permisos organización-módulo

=============================================================
**TICKET ID:** TASK-020-FE  
**EPIC:** Configuración de Módulos y Permisos de Acceso  
**USER STORY:** US-020 - Visualizar matriz de permisos organización-módulo  
**COMPONENT:** Frontend  
**PRIORITY:** Media  
**ESTIMATION:** 8 horas  
=============================================================

**TÍTULO:**
Implementar matriz consolidada de permisos organización-módulo

**DESCRIPCIÓN:**
Crear vista de matriz que cruce organizaciones (filas) con módulos de aplicaciones (columnas), mostrando visualmente qué organización tiene acceso a qué módulos. Incluye filtros, exportación a Excel y optimización de rendimiento para grandes volúmenes.

**CONTEXTO TÉCNICO:**
- **Matriz pivoteada**: Filas=organizaciones, Columnas=módulos agrupados por aplicación
- **Celdas**: ✓ (tiene acceso) / ✗ (no tiene acceso) con toggle editable
- **Virtual scrolling**: Para rendimiento con 100+ organizaciones
- **Exportación**: Excel con formato y colores
- **Filtros**: Por aplicación, organización, grupo
- **Optimización**: Carga lazy, debounce en búsquedas

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] Componente PermissionsMatrixComponent creado como Standalone
- [ ] Matriz pivoteada funcional con virtual scrolling (CDK)
- [ ] Filtros por aplicación, organización, grupo implementados
- [ ] Celdas editables con guardado automático
- [ ] Exportación a Excel con biblioteca SheetJS (xlsx)
- [ ] Rendimiento: <2s para 100 orgs × 50 módulos
- [ ] Indicadores visuales: colores para estado
- [ ] Traducciones en es.json y en.json
- [ ] Tests unitarios >80%

**GUÍA DE IMPLEMENTACIÓN:**

**Paso 1: Instalar Dependencias**

```bash
npm install xlsx @types/xlsx --save
npm install @angular/cdk --save
```

**Paso 2: Crear Componente Principal**

Archivo: `src/app/modules/admin/pages/permissions-matrix/permissions-matrix.component.ts`

```typescript
import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule } from '@angular/forms';
import { ScrollingModule } from '@angular/cdk/scrolling';
import { ClSelectModule } from '@cl/common-library/cl-select';
import { ClButtonModule } from '@cl/common-library/cl-buttons';
import { ClLoadingModule } from '@cl/common-library/cl-loading';
import { TranslateModule } from '@ngx-translate/core';
import { 
  OrganizationClient,
  ApplicationClient,
  ModuleClient,
  ModuleAccessClient
} from '@webServicesReferences/api/apiClients';
import * as XLSX from 'xlsx';

interface MatrixCell {
  organizationId: number;
  moduleId: number;
  hasAccess: boolean;
  moduleAccessId?: number;
  saving?: boolean;
}

interface MatrixRow {
  organizationId: number;
  organizationName: string;
  groupName?: string;
  cells: Map<number, MatrixCell>; // moduleId => cell
}

interface MatrixColumn {
  moduleId: number;
  moduleName: string;
  applicationName: string;
  applicationId: number;
}

@Component({
  selector: 'app-permissions-matrix',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    ScrollingModule,
    ClSelectModule,
    ClButtonModule,
    ClLoadingModule,
    TranslateModule
  ],
  templateUrl: './permissions-matrix.component.html',
  styleUrls: ['./permissions-matrix.component.scss']
})
export class PermissionsMatrixComponent implements OnInit {
  private readonly fb = inject(FormBuilder);
  private readonly organizationClient = inject(OrganizationClient);
  private readonly applicationClient = inject(ApplicationClient);
  private readonly moduleClient = inject(ModuleClient);
  private readonly moduleAccessClient = inject(ModuleAccessClient);

  filterForm!: FormGroup;

  // Data
  organizations: any[] = [];
  applications: any[] = [];
  modules: any[] = [];
  moduleAccess: any[] = [];

  // Matrix structure
  rows: MatrixRow[] = [];
  columns: MatrixColumn[] = [];
  columnsByApp: Map<number, MatrixColumn[]> = new Map();

  // UI state
  loading = false;
  exporting = false;

  ngOnInit(): void {
    this.buildFilterForm();
    this.loadInitialData();
  }

  private buildFilterForm(): void {
    this.filterForm = this.fb.group({
      applicationId: [null],
      organizationSearch: [''],
      groupId: [null]
    });

    // Aplicar filtros cuando cambian
    this.filterForm.valueChanges.subscribe(() => {
      this.applyFilters();
    });
  }

  async loadInitialData(): Promise<void> {
    this.loading = true;
    try {
      // Cargar datos en paralelo
      const [orgs, apps, mods, access] = await Promise.all([
        this.organizationClient.getAll().toPromise(),
        this.applicationClient.getAll().toPromise(),
        this.moduleClient.getAll().toPromise(),
        this.moduleAccessClient.getAll().toPromise()
      ]);

      this.organizations = orgs || [];
      this.applications = apps || [];
      this.modules = mods || [];
      this.moduleAccess = access || [];

      this.buildMatrix();
    } catch (error) {
      console.error('Error loading matrix data:', error);
    } finally {
      this.loading = false;
    }
  }

  private buildMatrix(): void {
    // Construir columnas agrupadas por aplicación
    this.columns = [];
    this.columnsByApp.clear();

    const appFilter = this.filterForm.get('applicationId')?.value;

    for (const app of this.applications) {
      if (appFilter && app.id !== appFilter) continue;

      const appModules = this.modules
        .filter(m => m.applicationId === app.id)
        .map(m => ({
          moduleId: m.id,
          moduleName: m.moduleName,
          applicationName: app.name,
          applicationId: app.id
        }));

      this.columnsByApp.set(app.id, appModules);
      this.columns.push(...appModules);
    }

    // Construir filas
    this.rows = this.organizations.map(org => {
      const cellsMap = new Map<number, MatrixCell>();

      for (const column of this.columns) {
        const access = this.moduleAccess.find(
          ma => ma.organizationId === org.id && 
                ma.moduleId === column.moduleId &&
                !ma.auditDeletionDate
        );

        cellsMap.set(column.moduleId, {
          organizationId: org.id,
          moduleId: column.moduleId,
          hasAccess: !!access,
          moduleAccessId: access?.id
        });
      }

      return {
        organizationId: org.id,
        organizationName: org.name,
        groupName: org.group?.name,
        cells: cellsMap
      };
    });

    this.applyFilters();
  }

  private applyFilters(): void {
    const searchTerm = this.filterForm.get('organizationSearch')?.value?.toLowerCase() || '';
    const groupId = this.filterForm.get('groupId')?.value;

    this.rows = this.rows.filter(row => {
      let matches = true;

      if (searchTerm) {
        matches = matches && row.organizationName.toLowerCase().includes(searchTerm);
      }

      if (groupId) {
        // Implementar filtro por grupo
        matches = matches; // TODO: filtrar por groupId
      }

      return matches;
    });
  }

  async toggleAccess(cell: MatrixCell): Promise<void> {
    cell.saving = true;
    try {
      if (cell.hasAccess) {
        // Revocar
        await this.moduleAccessClient.delete(cell.moduleAccessId!).toPromise();
        cell.hasAccess = false;
        cell.moduleAccessId = undefined;
      } else {
        // Otorgar
        const newAccess = await this.moduleAccessClient.create({
          organizationId: cell.organizationId,
          moduleId: cell.moduleId
        } as any).toPromise();

        cell.hasAccess = true;
        cell.moduleAccessId = newAccess.id;
      }
    } catch (error) {
      console.error('Error toggling access:', error);
      cell.hasAccess = !cell.hasAccess; // Revertir
    } finally {
      cell.saving = false;
    }
  }

  getAccessCount(row: MatrixRow): number {
    return Array.from(row.cells.values()).filter(c => c.hasAccess).length;
  }

  getAppAccessCount(row: MatrixRow, appId: number): number {
    const appModules = this.columnsByApp.get(appId) || [];
    return appModules.filter(col => row.cells.get(col.moduleId)?.hasAccess).length;
  }

  async exportToExcel(): Promise<void> {
    this.exporting = true;
    try {
      const data: any[] = [];

      // Header row
      const headerRow: any = { 'Organización': 'ORGANIZACIÓN' };
      for (const column of this.columns) {
        headerRow[column.moduleName] = column.moduleName;
      }
      data.push(headerRow);

      // Data rows
      for (const row of this.rows) {
        const dataRow: any = { 'Organización': row.organizationName };
        
        for (const column of this.columns) {
          const cell = row.cells.get(column.moduleId);
          dataRow[column.moduleName] = cell?.hasAccess ? '✓' : '✗';
        }
        
        data.push(dataRow);
      }

      // Crear workbook
      const ws: XLSX.WorkSheet = XLSX.utils.json_to_sheet(data);
      const wb: XLSX.WorkBook = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(wb, ws, 'Matriz de Permisos');

      // Aplicar estilos (opcional)
      // TODO: Aplicar colores y formato

      // Descargar
      const fileName = `matriz-permisos-${new Date().toISOString().split('T')[0]}.xlsx`;
      XLSX.writeFile(wb, fileName);

    } catch (error) {
      console.error('Error exporting to Excel:', error);
    } finally {
      this.exporting = false;
    }
  }
}
```

**Paso 3: Template del Componente**

Archivo: `src/app/modules/admin/pages/permissions-matrix/permissions-matrix.component.html`

```html
<div class="permissions-matrix-container">
  <div class="header">
    <h1>{{ 'PermissionsMatrix.Title' | translate }}</h1>
    
    <div class="actions">
      <cl-button
        [text]="'PermissionsMatrix.ExportExcel' | translate"
        [icon]="'download'"
        [type]="'secondary'"
        [loading]="exporting"
        (onClick)="exportToExcel()">
      </cl-button>

      <cl-button
        [text]="'Common.Refresh' | translate"
        [icon]="'refresh'"
        [type]="'secondary'"
        (onClick)="loadInitialData()">
      </cl-button>
    </div>
  </div>

  <!-- Filtros -->
  <div class="filters" [formGroup]="filterForm">
    <cl-select
      formControlName="applicationId"
      [label]="'PermissionsMatrix.FilterByApp' | translate"
      [data]="applications"
      [displayField]="'name'"
      [valueField]="'id'"
      [allowClear]="true">
    </cl-select>

    <cl-text-field
      formControlName="organizationSearch"
      [label]="'PermissionsMatrix.SearchOrganization' | translate"
      [icon]="'search'">
    </cl-text-field>
  </div>

  <!-- Matriz -->
  <div class="matrix-wrapper" *ngIf="!loading; else loadingTemplate">
    <div class="matrix-scroll">
      <table class="permissions-matrix">
        <thead>
          <tr>
            <th class="sticky-column org-column">
              {{ 'PermissionsMatrix.Organization' | translate }}
            </th>
            <ng-container *ngFor="let app of columnsByApp | keyvalue">
              <th [attr.colspan]="app.value.length" class="app-header">
                {{ app.value[0]?.applicationName }}
              </th>
            </ng-container>
          </tr>
          <tr>
            <th class="sticky-column org-column"></th>
            <th *ngFor="let column of columns" class="module-column">
              <div class="module-name" [title]="column.moduleName">
                {{ column.moduleName }}
              </div>
            </th>
          </tr>
        </thead>

        <tbody>
          <tr *ngFor="let row of rows">
            <td class="sticky-column org-cell">
              <div class="org-info">
                <span class="org-name">{{ row.organizationName }}</span>
                <span class="access-count">
                  {{ getAccessCount(row) }} / {{ columns.length }}
                </span>
              </div>
            </td>

            <td *ngFor="let column of columns" class="access-cell">
              <div 
                class="access-toggle"
                [class.has-access]="row.cells.get(column.moduleId)?.hasAccess"
                [class.saving]="row.cells.get(column.moduleId)?.saving"
                (click)="toggleAccess(row.cells.get(column.moduleId)!)">
                
                <span *ngIf="!row.cells.get(column.moduleId)?.saving">
                  {{ row.cells.get(column.moduleId)?.hasAccess ? '✓' : '✗' }}
                </span>
                
                <cl-loading 
                  *ngIf="row.cells.get(column.moduleId)?.saving"
                  [size]="'small'">
                </cl-loading>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="empty-state" *ngIf="rows.length === 0">
      <p>{{ 'PermissionsMatrix.NoData' | translate }}</p>
    </div>
  </div>

  <ng-template #loadingTemplate>
    <cl-loading [message]="'Common.Loading' | translate"></cl-loading>
  </ng-template>
</div>
```

**Paso 4: Estilos SCSS**

Archivo: `src/app/modules/admin/pages/permissions-matrix/permissions-matrix.component.scss`

```scss
.permissions-matrix-container {
  padding: 24px;

  .header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;

    h1 {
      font-size: 28px;
      font-weight: 600;
    }

    .actions {
      display: flex;
      gap: 12px;
    }
  }

  .filters {
    display: grid;
    grid-template-columns: 300px 300px;
    gap: 16px;
    margin-bottom: 24px;
    padding: 16px;
    background-color: #f5f5f5;
    border-radius: 8px;
  }

  .matrix-wrapper {
    background-color: white;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    overflow: hidden;
  }

  .matrix-scroll {
    overflow: auto;
    max-height: calc(100vh - 300px);
  }

  .permissions-matrix {
    width: 100%;
    border-collapse: collapse;
    table-layout: fixed;

    thead {
      position: sticky;
      top: 0;
      z-index: 10;
      background-color: white;

      tr:first-child {
        .app-header {
          background-color: #1976d2;
          color: white;
          padding: 12px 8px;
          text-align: center;
          font-weight: 600;
          border-right: 2px solid white;
        }
      }

      tr:nth-child(2) {
        .module-column {
          background-color: #e3f2fd;
          padding: 8px 4px;
          font-size: 11px;
          text-align: center;
          writing-mode: vertical-rl;
          text-orientation: mixed;
          max-width: 40px;
          height: 150px;

          .module-name {
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
          }
        }
      }
    }

    .sticky-column {
      position: sticky;
      left: 0;
      z-index: 5;
      background-color: white;
      box-shadow: 2px 0 4px rgba(0, 0, 0, 0.05);
    }

    .org-column {
      min-width: 250px;
      max-width: 250px;
      font-weight: 600;
      padding: 12px;
    }

    tbody {
      tr {
        border-bottom: 1px solid #e0e0e0;

        &:hover {
          background-color: #fafafa;
        }
      }

      .org-cell {
        .org-info {
          display: flex;
          flex-direction: column;
          gap: 4px;

          .org-name {
            font-weight: 500;
          }

          .access-count {
            font-size: 12px;
            color: #666;
            padding: 2px 8px;
            background-color: #e3f2fd;
            border-radius: 12px;
            display: inline-block;
            width: fit-content;
          }
        }
      }

      .access-cell {
        text-align: center;
        padding: 0;
        width: 40px;
        max-width: 40px;

        .access-toggle {
          width: 100%;
          height: 48px;
          display: flex;
          align-items: center;
          justify-content: center;
          cursor: pointer;
          font-size: 18px;
          transition: all 0.2s;

          &.has-access {
            background-color: #c8e6c9;
            color: #2e7d32;

            &:hover {
              background-color: #a5d6a7;
            }
          }

          &:not(.has-access) {
            background-color: #ffcdd2;
            color: #c62828;

            &:hover {
              background-color: #ef9a9a;
            }
          }

          &.saving {
            cursor: wait;
            opacity: 0.6;
          }
        }
      }
    }
  }

  .empty-state {
    text-align: center;
    padding: 64px;
    color: #666;
  }
}
```

**Paso 5: Traducciones**

Archivo: `src/assets/i18n/es.json`

```json
{
  "PermissionsMatrix": {
    "Title": "Matriz de Permisos",
    "Organization": "Organización",
    "FilterByApp": "Filtrar por aplicación",
    "SearchOrganization": "Buscar organización",
    "ExportExcel": "Exportar a Excel",
    "NoData": "No hay datos para mostrar"
  }
}
```

**Paso 6: Configurar Ruta**

Modificar: `src/app/app.routes.ts`

```typescript
{
  path: 'admin/permissions-matrix',
  component: PermissionsMatrixComponent,
  canActivate: [AuthGuard],
  data: { module: 'MSTP_Organizations', access: Access.Read }
}
```

**Paso 7: Tests Unitarios**

Archivo: `src/app/modules/admin/pages/permissions-matrix/permissions-matrix.component.spec.ts`

```typescript
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { PermissionsMatrixComponent } from './permissions-matrix.component';
import { ModuleAccessClient } from '@webServicesReferences/api/apiClients';
import { of } from 'rxjs';

describe('PermissionsMatrixComponent', () => {
  let component: PermissionsMatrixComponent;
  let fixture: ComponentFixture<PermissionsMatrixComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [PermissionsMatrixComponent]
    }).compileComponents();

    fixture = TestBed.createComponent(PermissionsMatrixComponent);
    component = fixture.componentInstance;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should build matrix correctly', () => {
    component.organizations = [{ id: 1, name: 'Org 1' }];
    component.modules = [{ id: 10, moduleName: 'Module 1', applicationId: 1 }];
    component.moduleAccess = [];

    component['buildMatrix']();

    expect(component.rows.length).toBe(1);
    expect(component.columns.length).toBe(1);
  });

  it('should export to Excel', async () => {
    spyOn(XLSX, 'writeFile');

    component.rows = [
      {
        organizationId: 1,
        organizationName: 'Org 1',
        cells: new Map()
      }
    ];
    component.columns = [];

    await component.exportToExcel();

    expect(XLSX.writeFile).toHaveBeenCalled();
  });
});
```

**ARCHIVOS A CREAR:**
- `src/app/modules/admin/pages/permissions-matrix/permissions-matrix.component.ts`
- `src/app/modules/admin/pages/permissions-matrix/permissions-matrix.component.html`
- `src/app/modules/admin/pages/permissions-matrix/permissions-matrix.component.scss`
- `src/app/modules/admin/pages/permissions-matrix/permissions-matrix.component.spec.ts`

**ARCHIVOS A MODIFICAR:**
- `src/app/app.routes.ts` - Añadir ruta
- `package.json` - Añadir dependencias xlsx

**DEPENDENCIAS:**
- TASK-017-BE - Endpoints de ModuleAccess
- Cliente NSwag generado
- Angular CDK (Virtual Scrolling)
- SheetJS (xlsx)

**DEFINITION OF DONE:**
- [ ] Componente creado como Standalone
- [ ] Matriz pivoteada renderizada correctamente
- [ ] Filtros funcionales
- [ ] Toggle de acceso con guardado automático funcional
- [ ] Exportación a Excel implementada
- [ ] Virtual scrolling optimizado (opcional si hay muchas filas)
- [ ] Rendimiento validado con datasets grandes
- [ ] Traducciones añadidas
- [ ] Ruta configurada
- [ ] Tests unitarios >80%
- [ ] Sin errores de compilación

**RECURSOS:**
- User Story: `userStories.md#us-020`
- Angular CDK Scrolling: https://material.angular.io/cdk/scrolling/overview
- SheetJS: https://sheetjs.com/

=============================================================

---

**FIN DE ÉPICA 3: Configuración de Módulos y Permisos de Acceso**

---