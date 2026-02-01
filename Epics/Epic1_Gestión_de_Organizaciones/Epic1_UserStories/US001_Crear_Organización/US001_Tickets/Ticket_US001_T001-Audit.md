# TASK-001-Audit: Crear tabla AUDIT_LOG simplificada

=============================================================
**TICKET ID:** TASK-001-Audit  
**EPIC:** Gestión del Portfolio de Organizaciones Clientes  
**USER STORY:** US-001 - Crear nueva organización cliente  
**COMPONENT:** Backend - Database  
**PRIORITY:** Alta  
**ESTIMATION:** 3 horas  
=============================================================

## TÍTULO
Crear tabla AUDIT_LOG simplificada para auditoría selectiva de cambios críticos

## DESCRIPCIÓN
Implementar tabla de auditoría simplificada que registre SOLO cambios críticos en organizaciones, sin almacenar JSON de valores anteriores/nuevos. Esta tabla es fundamental para la trazabilidad de seguridad y permisos.

**Filosofía de auditoría selectiva:**
- **SÍ se auditan** (6 acciones críticas): Cambios en permisos, activación/desactivación, cambios de grupo
- **NO se auditan**: Cambios en datos básicos (nombre, dirección, email, teléfono, CIF)

**Acciones críticas auditadas:**
1. `ModuleAssigned` - Se asignó un módulo/aplicación (UserId poblado)
2. `ModuleRemoved` - Se removió un módulo/aplicación (UserId poblado)
3. `OrganizationDeactivatedManual` - Baja manual por SecurityManager (UserId poblado)
4. `OrganizationAutoDeactivated` - Baja automática por sistema (UserId=NULL)
5. `OrganizationReactivatedManual` - Alta manual por SecurityManager (UserId poblado)
6. `GroupChanged` - Cambió el grupo de la organización (UserId poblado)

**Diferencia con auditoría Helix6:**
- **Helix6** (AuditCreationUser, AuditModificationUser, etc.): Auditoría básica automática de TODOS los cambios
- **AUDIT_LOG** (esta tabla): Auditoría selectiva de cambios CRÍTICOS con contexto de acción

## CONTEXTO TÉCNICO
- **Base de datos**: PostgreSQL 15+
- **Sin JSON**: NO incluye campos OldValue/NewValue (simplificación arquitectónica)
- **UserId nullable**: NULL indica acción del sistema (ej: auto-baja)
- **Índices**: Por EntityType + EntityId para consultas rápidas por organización
- **CorrelationId**: Para trazar flujos completos (ej: asignación múltiple de módulos)

## CRITERIOS DE ACEPTACIÓN TÉCNICOS
- [ ] Tabla AUDIT_LOG creada en PostgreSQL con estructura simplificada
- [ ] Campos: Id, Action, EntityType, EntityId, UserId (nullable), Timestamp, CorrelationId
- [ ] Índice compuesto (EntityType, EntityId) para consultas por entidad
- [ ] Índice por Timestamp para consultas temporales
- [ ] Migración EF Core generada
- [ ] Entidad AuditLog creada sin campos JSON
- [ ] IAuditLogService con método LogAsync(AuditEntry)
- [ ] Tests unitarios de IAuditLogService
- [ ] Tests de integración verifican persistencia

## GUÍA DE IMPLEMENTACIÓN

### Paso 1: Crear Entidad AuditLog

Archivo: `InfoportOneAdmon.DataModel/Entities/AuditLog.cs`

```csharp
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace InfoportOneAdmon.DataModel.Entities
{
    /// <summary>
    /// Registro de auditoría para cambios CRÍTICOS en organizaciones
    /// NO incluye JSON de valores anteriores/nuevos (simplificación)
    /// </summary>
    [Table("AUDIT_LOG")]
    public class AuditLog
    {
        [Key]
        public int Id { get; set; }
        
        /// <summary>
        /// Acción realizada (ModuleAssigned, OrganizationDeactivatedManual, etc.)
        /// </summary>
        [Required]
        [StringLength(100)]
        public string Action { get; set; }
        
        /// <summary>
        /// Tipo de entidad afectada (ej: "Organization")
        /// </summary>
        [Required]
        [StringLength(100)]
        public string EntityType { get; set; }
        
        /// <summary>
        /// ID de la entidad afectada
        /// </summary>
        [Required]
        public int EntityId { get; set; }
        
        /// <summary>
        /// ID del usuario que realizó la acción
        /// NULLABLE: NULL indica acción del sistema (ej: auto-baja)
        /// </summary>
        public int? UserId { get; set; }
        
        /// <summary>
        /// Timestamp de la acción (UTC)
        /// </summary>
        [Required]
        public DateTime Timestamp { get; set; }
        
        /// <summary>
        /// ID de correlación para trazar flujos completos
        /// Ej: Asignación múltiple de módulos comparte mismo CorrelationId
        /// </summary>
        [StringLength(100)]
        public string CorrelationId { get; set; }
    }
}
```

### Paso 2: Configurar Índices en DbContext

Archivo: `InfoportOneAdmon.DataModel/InfoportOneAdmonContext.cs`

```csharp
public DbSet<AuditLog> AuditLogs { get; set; }

protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    base.OnModelCreating(modelBuilder);
    
    // Índice compuesto para consultas por entidad (más frecuente)
    modelBuilder.Entity<AuditLog>()
        .HasIndex(a => new { a.EntityType, a.EntityId })
        .HasDatabaseName("IX_AuditLog_Entity");
    
    // Índice por timestamp para consultas temporales
    modelBuilder.Entity<AuditLog>()
        .HasIndex(a => a.Timestamp)
        .HasDatabaseName("IX_AuditLog_Timestamp");
    
    // Índice por UserId para consultas de actividad de usuario
    modelBuilder.Entity<AuditLog>()
        .HasIndex(a => a.UserId)
        .HasDatabaseName("IX_AuditLog_UserId");
}
```

### Paso 3: Crear DTO AuditEntry

Archivo: `InfoportOneAdmon.Entities/DTOs/AuditEntry.cs`

```csharp
namespace InfoportOneAdmon.Entities.DTOs
{
    /// <summary>
    /// DTO para crear un registro de auditoría
    /// </summary>
    public class AuditEntry
    {
        public string Action { get; set; }
        public string EntityType { get; set; }
        public int EntityId { get; set; }
        public int? UserId { get; set; } // NULL = acción del sistema
        public DateTime Timestamp { get; set; }
        public string CorrelationId { get; set; }
    }
}
```

### Paso 4: Crear IAuditLogService

Archivo: `InfoportOneAdmon.Services/Interfaces/IAuditLogService.cs`

```csharp
using InfoportOneAdmon.Entities.DTOs;

namespace InfoportOneAdmon.Services.Interfaces
{
    /// <summary>
    /// Servicio para registrar auditoría de cambios críticos
    /// </summary>
    public interface IAuditLogService
    {
        /// <summary>
        /// Registra un cambio crítico en la tabla AUDIT_LOG
        /// </summary>
        Task LogAsync(AuditEntry entry, CancellationToken cancellationToken);
        
        /// <summary>
        /// Obtiene el histórico de auditoría de una entidad
        /// </summary>
        Task<List<AuditLog>> GetEntityAuditHistory(
            string entityType,
            int entityId,
            CancellationToken cancellationToken);
    }
}
```

### Paso 5: Implementar AuditLogService

Archivo: `InfoportOneAdmon.Services/Services/AuditLogService.cs`

```csharp
using Helix6.Base.Domain.Repositories;
using InfoportOneAdmon.DataModel.Entities;
using InfoportOneAdmon.Entities.DTOs;
using InfoportOneAdmon.Services.Interfaces;
using Microsoft.Extensions.Logging;

namespace InfoportOneAdmon.Services.Services
{
    /// <summary>
    /// Implementación del servicio de auditoría simplificada
    /// </summary>
    public class AuditLogService : IAuditLogService
    {
        private readonly ILogger<AuditLogService> _logger;
        private readonly IRepository<AuditLog> _repository;

        public AuditLogService(
            ILogger<AuditLogService> logger,
            IRepository<AuditLog> repository)
        {
            _logger = logger;
            _repository = repository;
        }

        /// <summary>
        /// Registra un cambio crítico en AUDIT_LOG
        /// </summary>
        public async Task LogAsync(AuditEntry entry, CancellationToken cancellationToken)
        {
            var auditLog = new AuditLog
            {
                Action = entry.Action,
                EntityType = entry.EntityType,
                EntityId = entry.EntityId,
                UserId = entry.UserId,
                Timestamp = entry.Timestamp,
                CorrelationId = entry.CorrelationId
            };

            await _repository.InsertAsync(auditLog, cancellationToken);

            _logger.LogInformation(
                "Auditoría registrada: {Action} en {EntityType} {EntityId} por {UserId}",
                entry.Action,
                entry.EntityType,
                entry.EntityId,
                entry.UserId?.ToString() ?? "Sistema");
        }

        /// <summary>
        /// Obtiene histórico de auditoría de una entidad específica
        /// </summary>
        public async Task<List<AuditLog>> GetEntityAuditHistory(
            string entityType,
            int entityId,
            CancellationToken cancellationToken)
        {
            return await _repository.GetAllAsync(
                a => a.EntityType == entityType && a.EntityId == entityId,
                cancellationToken,
                orderBy: q => q.OrderByDescending(a => a.Timestamp));
        }
    }
}
```

### Paso 6: Registrar en DI

Archivo: `InfoportOneAdmon.Services/DependencyInjection.cs`

```csharp
public static IServiceCollection AddApplicationServices(this IServiceCollection services)
{
    // ... otros servicios ...
    
    services.AddScoped<IAuditLogService, AuditLogService>();
    
    return services;
}
```

### Paso 7: Crear Migración

```bash
dotnet ef migrations add CreateAuditLogTable -p InfoportOneAdmon.DataModel -s InfoportOneAdmon.Api
```

### Paso 8: Tests Unitarios

Archivo: `InfoportOneAdmon.Services.Tests/Services/AuditLogServiceTests.cs`

```csharp
using Xunit;
using FluentAssertions;
using Moq;
using InfoportOneAdmon.Services.Services;
using InfoportOneAdmon.Entities.DTOs;

namespace InfoportOneAdmon.Services.Tests.Services
{
    public class AuditLogServiceTests
    {
        private readonly Mock<IRepository<AuditLog>> _repositoryMock;
        private readonly AuditLogService _service;

        public AuditLogServiceTests()
        {
            _repositoryMock = new Mock<IRepository<AuditLog>>();
            var loggerMock = new Mock<ILogger<AuditLogService>>();
            
            _service = new AuditLogService(loggerMock.Object, _repositoryMock.Object);
        }

        [Fact]
        public async Task LogAsync_WithUserId_PersistsCorrectly()
        {
            // Arrange
            var entry = new AuditEntry
            {
                Action = "ModuleAssigned",
                EntityType = "Organization",
                EntityId = 123,
                UserId = 456,
                Timestamp = DateTime.UtcNow,
                CorrelationId = Guid.NewGuid().ToString()
            };

            // Act
            await _service.LogAsync(entry, CancellationToken.None);

            // Assert
            _repositoryMock.Verify(r => r.InsertAsync(
                It.Is<AuditLog>(a =>
                    a.Action == "ModuleAssigned" &&
                    a.EntityType == "Organization" &&
                    a.EntityId == 123 &&
                    a.UserId == 456),
                It.IsAny<CancellationToken>()),
                Times.Once);
        }

        [Fact]
        public async Task LogAsync_WithNullUserId_PersistsAsSystemAction()
        {
            // Arrange: Acción del sistema (auto-baja)
            var entry = new AuditEntry
            {
                Action = "OrganizationAutoDeactivated",
                EntityType = "Organization",
                EntityId = 789,
                UserId = null, // Sistema
                Timestamp = DateTime.UtcNow,
                CorrelationId = Guid.NewGuid().ToString()
            };

            // Act
            await _service.LogAsync(entry, CancellationToken.None);

            // Assert
            _repositoryMock.Verify(r => r.InsertAsync(
                It.Is<AuditLog>(a =>
                    a.Action == "OrganizationAutoDeactivated" &&
                    a.UserId == null),
                It.IsAny<CancellationToken>()),
                Times.Once);
        }

        [Fact]
        public async Task GetEntityAuditHistory_ReturnsOrderedByTimestamp()
        {
            // Arrange
            var auditLogs = new List<AuditLog>
            {
                new AuditLog { Action = "ModuleAssigned", Timestamp = DateTime.UtcNow.AddHours(-2) },
                new AuditLog { Action = "ModuleRemoved", Timestamp = DateTime.UtcNow.AddHours(-1) },
                new AuditLog { Action = "GroupChanged", Timestamp = DateTime.UtcNow }
            };

            _repositoryMock.Setup(r => r.GetAllAsync(
                It.IsAny<Expression<Func<AuditLog, bool>>>(),
                It.IsAny<CancellationToken>(),
                It.IsAny<Func<IQueryable<AuditLog>, IOrderedQueryable<AuditLog>>>()))
                .ReturnsAsync(auditLogs.OrderByDescending(a => a.Timestamp).ToList());

            // Act
            var result = await _service.GetEntityAuditHistory("Organization", 123, CancellationToken.None);

            // Assert
            result.Should().HaveCount(3);
            result.First().Action.Should().Be("GroupChanged"); // Más reciente primero
            result.Last().Action.Should().Be("ModuleAssigned"); // Más antiguo último
        }
    }
}
```

### Paso 9: Tests de Integración

Archivo: `InfoportOneAdmon.Services.Tests/Integration/AuditLogIntegrationTests.cs`

```csharp
using Xunit;
using FluentAssertions;
using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Services.Tests.Integration
{
    public class AuditLogIntegrationTests : IClassFixture<DatabaseFixture>
    {
        private readonly InfoportOneAdmonContext _context;
        private readonly IAuditLogService _service;

        public AuditLogIntegrationTests(DatabaseFixture fixture)
        {
            _context = fixture.Context;
            _service = fixture.GetService<IAuditLogService>();
        }

        [Fact]
        public async Task LogAsync_PersistsToDatabase()
        {
            // Arrange
            var entry = new AuditEntry
            {
                Action = "ModuleAssigned",
                EntityType = "Organization",
                EntityId = 999,
                UserId = 111,
                Timestamp = DateTime.UtcNow,
                CorrelationId = Guid.NewGuid().ToString()
            };

            // Act
            await _service.LogAsync(entry, CancellationToken.None);

            // Assert
            var persisted = await _context.AuditLogs
                .FirstOrDefaultAsync(a => a.EntityId == 999 && a.Action == "ModuleAssigned");

            persisted.Should().NotBeNull();
            persisted.UserId.Should().Be(111);
            persisted.EntityType.Should().Be("Organization");
        }

        [Fact]
        public async Task GetEntityAuditHistory_FiltersCorrectly()
        {
            // Arrange: Crear múltiples registros para diferentes organizaciones
            await _service.LogAsync(new AuditEntry
            {
                Action = "ModuleAssigned",
                EntityType = "Organization",
                EntityId = 100,
                UserId = 1,
                Timestamp = DateTime.UtcNow
            }, CancellationToken.None);

            await _service.LogAsync(new AuditEntry
            {
                Action = "GroupChanged",
                EntityType = "Organization",
                EntityId = 200,
                UserId = 2,
                Timestamp = DateTime.UtcNow
            }, CancellationToken.None);

            // Act: Buscar solo para organización 100
            var history = await _service.GetEntityAuditHistory("Organization", 100, CancellationToken.None);

            // Assert
            history.Should().HaveCount(1);
            history.First().Action.Should().Be("ModuleAssigned");
            history.First().EntityId.Should().Be(100);
        }
    }
}
```

## ARCHIVOS A CREAR/MODIFICAR

**Backend:**
- `InfoportOneAdmon.DataModel/Entities/AuditLog.cs` - Entidad simplificada
- `InfoportOneAdmon.DataModel/InfoportOneAdmonContext.cs` - Configurar índices
- `InfoportOneAdmon.DataModel/Migrations/XXXXXX_CreateAuditLogTable.cs` - Migración
- `InfoportOneAdmon.Entities/DTOs/AuditEntry.cs` - DTO para crear auditoría
- `InfoportOneAdmon.Services/Interfaces/IAuditLogService.cs` - Interface
- `InfoportOneAdmon.Services/Services/AuditLogService.cs` - Implementación
- `InfoportOneAdmon.Services/DependencyInjection.cs` - Registro DI
- `InfoportOneAdmon.Services.Tests/Services/AuditLogServiceTests.cs` - Tests unitarios
- `InfoportOneAdmon.Services.Tests/Integration/AuditLogIntegrationTests.cs` - Tests integración

## DEPENDENCIAS
Ninguna (tabla fundacional del sistema de auditoría)

## DEFINITION OF DONE
- [x] Entidad AuditLog creada sin campos JSON (simplificada)
- [x] Tabla AUDIT_LOG creada con índices (EntityType+EntityId, Timestamp, UserId)
- [x] UserId es nullable (NULL = acción del sistema)
- [x] Migración EF Core generada y aplicada sin errores
- [x] IAuditLogService creada con LogAsync y GetEntityAuditHistory
- [x] AuditLogService implementado correctamente
- [x] Servicio registrado en DI
- [x] Test unitario verifica persistencia con UserId poblado
- [x] Test unitario verifica persistencia con UserId=NULL (sistema)
- [x] Test unitario verifica consulta de histórico ordenado
- [x] Test integración verifica persistencia real en BD
- [x] Test integración verifica filtrado por entidad
- [x] Code review aprobado
- [x] Documentación XML completa en IAuditLogService

## RECURSOS
- PostgreSQL Indexes: [CREATE INDEX](https://www.postgresql.org/docs/current/sql-createindex.html)
- User Story: `userStories.md#us-008`
- Arquitectura: Matriz de auditoría crítica (6 acciones) en documentación

=============================================================
