# Tickets Técnicos Backend y Eventos - InfoportOneAdmon

**Generado desde:** User Stories (userStories.md)  
**Fecha de generación:** 31 de enero de 2026  
**Arquitecturas de referencia:**
- Backend: Helix6_Backend_Architecture.md
- Eventos: ActiveMQ_Events.md

---

## Índice de Tickets - Épica 1

### US-001: Crear nueva organización cliente
- [TASK-001-BE: Implementar entidad Organization con CRUD completo en Helix6](#task-001-be-implementar-entidad-organization-con-crud-completo-en-helix6)
- [TASK-001-EV-PUB: Publicar OrganizationEvent al crear/modificar/eliminar organización](#task-001-ev-pub-publicar-organizationevent-al-crearmodificareliminar-organización)

### US-002: Editar información de organización existente
- [TASK-002-BE: Modificar OrganizationService para soportar edición con validaciones](#task-002-be-modificar-organizationservice-para-soportar-edición-con-validaciones)

### US-003: Desactivar organización (kill-switch)
- [TASK-003-BE: Implementar desactivación (soft delete) de organización](#task-003-be-implementar-desactivación-soft-delete-de-organización)

### US-006: Crear grupo de organizaciones
- [TASK-006-BE: Implementar entidad OrganizationGroup con CRUD completo](#task-006-be-implementar-entidad-organizationgroup-con-crud-completo)
- [TASK-006-EV-NOTE: OrganizationGroup NO publica eventos independientes](#task-006-ev-note-organizationgroup-no-publica-eventos-independientes)

### US-007: Asignar organizaciones a un grupo
- [TASK-007-BE: Implementar asignación de GroupId en OrganizationService](#task-007-be-implementar-asignación-de-groupid-en-organizationservice)

### US-008: Consultar auditoría de cambios en organización
- [TASK-008-BE: Implementar endpoint de consulta de auditoría por entidad](#task-008-be-implementar-endpoint-de-consulta-de-auditoría-por-entidad)

---

## Épica 1: Gestión del Portfolio de Organizaciones Clientes

### US-001: Crear nueva organización cliente

**Resumen de tickets generados:**
- TASK-001-BE: Implementar entidad Organization con CRUD completo en Helix6
- TASK-001-EV-PUB: Publicar OrganizationEvent al crear/modificar/eliminar organización

---

#### TASK-001-BE: Implementar entidad Organization con CRUD completo en Helix6

=============================================================
**TICKET ID:** TASK-001-BE  
**EPIC:** Gestión del Portfolio de Organizaciones Clientes  
**USER STORY:** US-001 - Crear nueva organización cliente  
**COMPONENT:** Backend  
**PRIORITY:** Alta  
**ESTIMATION:** 6 horas  
=============================================================

**TÍTULO:**
Implementar entidad Organization con CRUD completo en Helix6

**DESCRIPCIÓN:**
Crear la infraestructura backend completa para gestionar Organizaciones Clientes siguiendo el patrón Helix6 Framework. Esto incluye:
- Entidad `Organization` en DataModel con todos los campos de negocio y auditoría
- ViewModel `OrganizationView` para la capa de presentación
- Servicio `OrganizationService` con lógica de negocio y validaciones
- Endpoints RESTful generados automáticamente con EndpointHelper
- Migración de Entity Framework Core
- Tests unitarios de servicio y tests de integración de endpoints

La funcionalidad debe cumplir con los criterios de aceptación de la User Story US-001:
- Validar que nombre, CIF y email de contacto sean obligatorios
- Generar `SecurityCompanyId` único automáticamente mediante secuencia de PostgreSQL
- Validar unicidad de CIF (no permitir duplicados)

Registrar auditoría completa con campos Helix6

Modificar `PostActions` para registrar auditoría detallada (sin código generado):

- Definir la entidad `AuditLog` en `InfoportOneAdmon.DataModel.Entities` con campos mínimos: `Id`, `EntityName`, `EntityKey`, `Action`, `UserId`, `OldValue` (JSON), `NewValue` (JSON), `CreatedAt`, `CorrelationId`.
- Añadir `IAuditLogRepository` (o implementar siguiendo el patrón `BaseRepository`) que encapsule el acceso a `DbSet<AuditLog>`; registrar el repositorio en DI.
- Implementar `IAuditLogService` (por ejemplo `AuditLogService`) con un método `Task LogAsync(AuditEntry entry, CancellationToken ct)` que reciba una estructura `AuditEntry` y use el repositorio para persistir el registro. Mantener la serialización (JSON) dentro del servicio de auditoría.
- En los servicios de dominio (`OrganizationService`, etc.) capturar el estado previo en `PreviousActions` (antes de mapear o aplicar cambios) y construir el `AuditEntry` con `OldValue` y `NewValue`.
- Invocar `IAuditLogService.LogAsync(...)` desde `PostActions` para persistir el registro de auditoría. No inyectar directamente `DbContext` ni persistir entradas de auditoría desde múltiples lugares dispersos; centralizar la lógica en `IAuditLogService`.
- Consideraciones transaccionales: preferir persistir la entidad principal y luego registrar el `AuditLog` en `PostActions` para disponer del `EntityKey` y reducir riesgos de inconsistencia. Si se requiere atomicidad absoluta entre entidad y auditoría, coordinar la persistencia dentro de la misma unidad de trabajo (DbContext) dentro del `IAuditLogService` o mediante un manejador transaccional explícito.
- Añadir migración para la tabla `AuditLogs` y pruebas unitarias/integración que verifiquen que `IAuditLogService` se invoca en `PostActions` y que `OldValue`/`NewValue` contienen los JSON esperados.

Nota: No se incluyen fragmentos de código en este documento. La implementación debe realizarse en los servicios del proyecto siguiendo las pautas de `Helix6_Backend_Architecture.md`.
        [Required]
        [StringLength(200)]
        public string Name { get; set; }
        
        /// <summary>
        /// Código de Identificación Fiscal (CIF/NIF) - Debe ser único
        /// </summary>
        [Required]
        [StringLength(50)]
        public string Cif { get; set; }
        
        /// <summary>
        /// Dirección física de la organización
        /// </summary>
        [StringLength(500)]
        public string Address { get; set; }
        
        /// <summary>
        /// Ciudad
        /// </summary>
        [StringLength(100)]
        public string City { get; set; }
        
        /// <summary>
        /// Código Postal
        /// </summary>
        [StringLength(20)]
        public string PostalCode { get; set; }
        
        /// <summary>
        /// País
        /// </summary>
        [StringLength(100)]
        public string Country { get; set; }
        
        /// <summary>
        /// Email de contacto principal (obligatorio)
        /// </summary>
        [Required]
        [StringLength(200)]
        [EmailAddress]
        public string ContactEmail { get; set; }
        
        /// <summary>
        /// Teléfono de contacto
        /// </summary>
        [StringLength(50)]
        public string ContactPhone { get; set; }
        
        /// <summary>
        /// FK al grupo de organizaciones (opcional)
        /// </summary>
        public int? GroupId { get; set; }
        
        [ForeignKey(nameof(GroupId))]
        public virtual OrganizationGroup Group { get; set; }
        
        // Campos de auditoría Helix6 (OBLIGATORIOS)
        public int? AuditCreationUser { get; set; }
        public DateTime? AuditCreationDate { get; set; }
        public int? AuditModificationUser { get; set; }
        public DateTime? AuditModificationDate { get; set; }
        
        /// <summary>
        /// Fecha de desactivación (soft delete) - Si tiene valor, la organización está inactiva
        /// </summary>
        public DateTime? AuditDeletionDate { get; set; }
    }
}
```

**Paso 3: Configurar índices únicos en DbContext**

Archivo: `InfoportOneAdmon.DataModel/InfoportOneAdmonContext.cs`

```csharp
using Microsoft.EntityFrameworkCore;
using InfoportOneAdmon.DataModel.Entities;

namespace InfoportOneAdmon.DataModel
{
    public class InfoportOneAdmonContext : DbContext
    {
        public InfoportOneAdmonContext(DbContextOptions<InfoportOneAdmonContext> options)
            : base(options)
        {
        }

        public DbSet<Organization> Organizations { get; set; }
        // ... otros DbSets ...

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configurar índice único para SecurityCompanyId
            modelBuilder.Entity<Organization>()
                .HasIndex(o => o.SecurityCompanyId)
                .IsUnique()
                .HasDatabaseName("UX_Organization_SecurityCompanyId");

            // Configurar índice único para CIF
            modelBuilder.Entity<Organization>()
                .HasIndex(o => o.Cif)
                .IsUnique()
                .HasDatabaseName("UX_Organization_Cif");

            // Configurar valor por defecto de SecurityCompanyId desde secuencia
            modelBuilder.Entity<Organization>()
                .Property(o => o.SecurityCompanyId)
                .HasDefaultValueSql("nextval('seq_security_company_id')");
        }
    }
}
```

**Paso 4: Crear el ViewModel en Entities**

Archivo: `InfoportOneAdmon.Entities/Views/OrganizationView.cs`

```csharp
using System.ComponentModel.DataAnnotations;
using Helix6.Base.Application.BaseInterfaces;

namespace InfoportOneAdmon.Entities.Views
{
    /// <summary>
    /// ViewModel para gestión de Organizaciones Clientes
    /// </summary>
    public class OrganizationView : IViewBase
    {
        public int Id { get; set; }
        
        /// <summary>
        /// Identificador de negocio (readonly, generado automáticamente)
        /// </summary>
        public int SecurityCompanyId { get; set; }
        
        [Required(ErrorMessage = "El nombre de la organización es obligatorio")]
        [StringLength(200, ErrorMessage = "El nombre no puede exceder 200 caracteres")]
        public string Name { get; set; }
        
        [Required(ErrorMessage = "El CIF es obligatorio")]
        [StringLength(50, ErrorMessage = "El CIF no puede exceder 50 caracteres")]
        public string Cif { get; set; }
        
        [StringLength(500, ErrorMessage = "La dirección no puede exceder 500 caracteres")]
        public string Address { get; set; }
        
        [StringLength(100)]
        public string City { get; set; }
        
        [StringLength(20)]
        public string PostalCode { get; set; }
        
        [StringLength(100)]
        public string Country { get; set; }
        
        [Required(ErrorMessage = "El email de contacto es obligatorio")]
        [EmailAddress(ErrorMessage = "El email no tiene un formato válido")]
        [StringLength(200)]
        public string ContactEmail { get; set; }
        
        [StringLength(50)]
        public string ContactPhone { get; set; }
        
        public int? GroupId { get; set; }
        
        /// <summary>
        /// Nombre del grupo (para visualización, no editable)
        /// </summary>
        public string GroupName { get; set; }
        
        // Campos de auditoría (solo lectura)
        public int? AuditCreationUser { get; set; }
        public DateTime? AuditCreationDate { get; set; }
        public int? AuditModificationUser { get; set; }
        public DateTime? AuditModificationDate { get; set; }
        public DateTime? AuditDeletionDate { get; set; }
    }
}
```

**Paso 5: Crear el Servicio con Validaciones**

Archivo: `InfoportOneAdmon.Services/Services/OrganizationService.cs`

```csharp
using Helix6.Base.Application.Services;
using Helix6.Base.Domain.Repositories;
using InfoportOneAdmon.DataModel.Entities;
using InfoportOneAdmon.Entities.Views;
using Microsoft.Extensions.Logging;
using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Services.Services
{
    /// <summary>
    /// Servicio para gestión de Organizaciones Clientes
    /// </summary>
    public class OrganizationService : BaseService<OrganizationView, Organization, BaseMetadata>
    {
        public OrganizationService(
            ILogger<OrganizationService> logger,
            IRepository<Organization> repository)
            : base(logger, repository)
        {
        }

        /// <summary>
        /// Validaciones de negocio antes de guardar
        /// </summary>
        protected override async Task<bool> ValidateView(OrganizationView view, CancellationToken cancellationToken)
        {
            // Validación 1: Nombre obligatorio (ya validado por DataAnnotations, pero reforzamos)
            if (string.IsNullOrWhiteSpace(view.Name))
            {
                AddError("El nombre de la organización es obligatorio");
                return false;
            }

            // Validación 2: CIF obligatorio
            if (string.IsNullOrWhiteSpace(view.Cif))
            {
                AddError("El CIF es obligatorio");
                return false;
            }

            // Validación 3: Email obligatorio
            if (string.IsNullOrWhiteSpace(view.ContactEmail))
            {
                AddError("El email de contacto es obligatorio");
                return false;
            }

            // Validación 4: CIF único (no permitir duplicados)
            var cifExists = await Repository.ExistsAsync(
                o => o.Cif == view.Cif && o.Id != view.Id && o.AuditDeletionDate == null,
                cancellationToken);
            
            if (cifExists)
            {
                AddError($"Ya existe una organización activa con el CIF '{view.Cif}'");
                return false;
            }

            // Validación 5: Si se especifica GroupId, verificar que el grupo existe
            if (view.GroupId.HasValue)
            {
                // Nota: Esto requeriría inyectar IRepository<OrganizationGroup>
                // Por ahora lo dejamos como TODO para cuando se implemente US-006
                // TODO: Validar que GroupId existe en tabla ORGANIZATION_GROUP
            }

            return true;
        }

        /// <summary>
        /// Acciones previas a guardar (normalización de datos)
        /// </summary>
        protected override async Task PreviousActions(OrganizationView view, Organization entity, CancellationToken cancellationToken)
        {
            // Normalizar: Trim de campos de texto
            entity.Name = entity.Name?.Trim();
            entity.Cif = entity.Cif?.Trim().ToUpperInvariant(); // CIF siempre en mayúsculas
            entity.Address = entity.Address?.Trim();
            entity.City = entity.City?.Trim();
            entity.ContactEmail = entity.ContactEmail?.Trim().ToLowerInvariant();
            entity.ContactPhone = entity.ContactPhone?.Trim();
            
            // NOTA: SecurityCompanyId se genera automáticamente por la secuencia de PostgreSQL
            // No necesitamos asignarlo manualmente aquí
            
            await base.PreviousActions(view, entity, cancellationToken);
        }

        /// <summary>
        /// Acciones posteriores a guardar
        /// NOTA: En TASK-001-EV-PUB se implementará la publicación del evento aquí
        /// </summary>
        protected override async Task PostActions(OrganizationView view, Organization entity, CancellationToken cancellationToken)
        {
            // TODO TASK-001-EV-PUB: Publicar OrganizationEvent al broker ActiveMQ Artemis
            
            await base.PostActions(view, entity, cancellationToken);
        }
    }
}
```

**Paso 6: Generar Endpoints**

Archivo: `InfoportOneAdmon.Api/Endpoints/OrganizationEndpoints.cs`

```csharp
using Helix6.Base.Api.Endpoints;
using InfoportOneAdmon.Entities.Views;
using InfoportOneAdmon.Services.Services;

namespace InfoportOneAdmon.Api.Endpoints
{
    /// <summary>
    /// Endpoints RESTful para gestión de Organizaciones Clientes
    /// </summary>
    public static class OrganizationEndpoints
    {
        public static void MapOrganizationEndpoints(this IEndpointRouteBuilder app)
        {
            // Genera automáticamente:
            // - GET /organizations (lista con paginación, filtrado, ordenación)
            // - GET /organizations/{id} (detalle por ID)
            // - POST /organizations (crear)
            // - PUT /organizations/{id} (actualizar)
            // - DELETE /organizations/{id} (soft delete)
            EndpointHelper.MapCrudEndpoints<OrganizationService, OrganizationView>(
                app,
                "organizations",
                "Organizations");
        }
    }
}
```

Registrar en `Program.cs`:

```csharp
// Archivo: InfoportOneAdmon.Api/Program.cs

using InfoportOneAdmon.Api.Endpoints;

var builder = WebApplication.CreateBuilder(args);

// ... configuración de servicios ...

var app = builder.Build();

// Mapear endpoints de organizaciones
app.MapOrganizationEndpoints();

// ... resto de configuración ...

app.Run();
```

**Paso 7: Configurar Inyección de Dependencias**

Archivo: `InfoportOneAdmon.Services/DependencyInjection.cs`

```csharp
using Microsoft.Extensions.DependencyInjection;
using InfoportOneAdmon.Services.Services;

namespace InfoportOneAdmon.Services
{
    public static class DependencyInjection
    {
        public static IServiceCollection AddApplicationServices(this IServiceCollection services)
        {
            // Registrar OrganizationService
            services.AddScoped<OrganizationService>();
            
            // ... otros servicios ...
            
            return services;
        }
    }
}
```

Llamar desde `Program.cs`:

```csharp
builder.Services.AddApplicationServices();
```

**Paso 8: Generar Migración de Entity Framework Core**

Ejecutar en terminal desde la carpeta del proyecto API:

```powershell
# Generar migración
dotnet ef migrations add AddOrganizationTable --project ..\InfoportOneAdmon.DataModel --startup-project InfoportOneAdmon.Api

# Aplicar migración a la base de datos
dotnet ef database update --project ..\InfoportOneAdmon.DataModel --startup-project InfoportOneAdmon.Api
```

Verificar que el archivo de migración generado incluye:
- Creación de tabla `ORGANIZATION`
- Índice único en `SecurityCompanyId`
- Índice único en `Cif`
- Valor por defecto de `SecurityCompanyId` desde secuencia

**Paso 9: Implementar Tests Unitarios del Servicio**

Archivo: `InfoportOneAdmon.Services.Tests/Services/OrganizationServiceTests.cs`

```csharp
using Xunit;
using Moq;
using FluentAssertions;
using Microsoft.Extensions.Logging;
using Helix6.Base.Domain.Repositories;
using InfoportOneAdmon.Services.Services;
using InfoportOneAdmon.Entities.Views;
using InfoportOneAdmon.DataModel.Entities;
using System.Linq.Expressions;

namespace InfoportOneAdmon.Services.Tests.Services
{
    public class OrganizationServiceTests
    {
        private readonly Mock<ILogger<OrganizationService>> _loggerMock;
        private readonly Mock<IRepository<Organization>> _repositoryMock;
        private readonly OrganizationService _service;

        public OrganizationServiceTests()
        {
            _loggerMock = new Mock<ILogger<OrganizationService>>();
            _repositoryMock = new Mock<IRepository<Organization>>();
            _service = new OrganizationService(_loggerMock.Object, _repositoryMock.Object);
        }

        [Fact]
        public async Task ValidateView_WithValidData_ReturnsTrue()
        {
            // Arrange
            var view = new OrganizationView
            {
                Name = "Test Organization",
                Cif = "A12345678",
                ContactEmail = "contact@test.com"
            };
            
            _repositoryMock.Setup(r => r.ExistsAsync(
                It.IsAny<Expression<Func<Organization, bool>>>(),
                It.IsAny<CancellationToken>()))
                .ReturnsAsync(false);

            // Act
            var result = await _service.ValidateView(view, CancellationToken.None);

            // Assert
            result.Should().BeTrue();
            _service.Errors.Should().BeEmpty();
        }

        [Fact]
        public async Task ValidateView_WithDuplicateCif_ReturnsFalse()
        {
            // Arrange
            var view = new OrganizationView
            {
                Name = "Test Organization",
                Cif = "A12345678",
                ContactEmail = "contact@test.com"
            };
            
            _repositoryMock.Setup(r => r.ExistsAsync(
                It.IsAny<Expression<Func<Organization, bool>>>(),
                It.IsAny<CancellationToken>()))
                .ReturnsAsync(true); // Simular CIF duplicado

            // Act
            var result = await _service.ValidateView(view, CancellationToken.None);

            // Assert
            result.Should().BeFalse();
            _service.Errors.Should().Contain(e => e.Contains("Ya existe una organización activa con el CIF"));
        }

        [Fact]
        public async Task ValidateView_WithMissingName_ReturnsFalse()
        {
            // Arrange
            var view = new OrganizationView
            {
                Name = "",
                Cif = "A12345678",
                ContactEmail = "contact@test.com"
            };

            // Act
            var result = await _service.ValidateView(view, CancellationToken.None);

            // Assert
            result.Should().BeFalse();
            _service.Errors.Should().Contain(e => e.Contains("nombre de la organización es obligatorio"));
        }

        [Fact]
        public async Task ValidateView_WithMissingCif_ReturnsFalse()
        {
            // Arrange
            var view = new OrganizationView
            {
                Name = "Test Organization",
                Cif = "",
                ContactEmail = "contact@test.com"
            };

            // Act
            var result = await _service.ValidateView(view, CancellationToken.None);

            // Assert
            result.Should().BeFalse();
            _service.Errors.Should().Contain(e => e.Contains("CIF es obligatorio"));
        }

        [Fact]
        public async Task ValidateView_WithMissingEmail_ReturnsFalse()
        {
            // Arrange
            var view = new OrganizationView
            {
                Name = "Test Organization",
                Cif = "A12345678",
                ContactEmail = ""
            };

            // Act
            var result = await _service.ValidateView(view, CancellationToken.None);

            // Assert
            result.Should().BeFalse();
            _service.Errors.Should().Contain(e => e.Contains("email de contacto es obligatorio"));
        }

        [Fact]
        public async Task PreviousActions_NormalizesData()
        {
            // Arrange
            var view = new OrganizationView
            {
                Name = "  Test Organization  ",
                Cif = "  a12345678  ",
                ContactEmail = "  CONTACT@TEST.COM  "
            };
            
            var entity = new Organization();

            // Act
            await _service.PreviousActions(view, entity, CancellationToken.None);

            // Assert
            entity.Name.Should().Be("Test Organization");
            entity.Cif.Should().Be("A12345678"); // Mayúsculas y sin espacios
            entity.ContactEmail.Should().Be("contact@test.com"); // Minúsculas y sin espacios
        }
    }
}
```

**Paso 10: Implementar Tests de Integración de Endpoints**

Archivo: `InfoportOneAdmon.Api.Tests/Endpoints/OrganizationEndpointsTests.cs`

```csharp
using Xunit;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;
using System.Net.Http.Json;
using InfoportOneAdmon.Entities.Views;

namespace InfoportOneAdmon.Api.Tests.Endpoints
{
    public class OrganizationEndpointsTests : IClassFixture<WebApplicationFactory<Program>>
    {
        private readonly HttpClient _client;

        public OrganizationEndpointsTests(WebApplicationFactory<Program> factory)
        {
            _client = factory.CreateClient();
        }

        [Fact]
        public async Task GetAll_ReturnsSuccessStatusCode()
        {
            // Act
            var response = await _client.GetAsync("/organizations");

            // Assert
            response.EnsureSuccessStatusCode();
            var organizations = await response.Content.ReadFromJsonAsync<IEnumerable<OrganizationView>>();
            organizations.Should().NotBeNull();
        }

        [Fact]
        public async Task Create_WithValidData_ReturnsCreated()
        {
            // Arrange
            var newOrganization = new OrganizationView
            {
                Name = "Test Organization",
                Cif = "A12345678",
                Address = "Calle Test 123",
                City = "Valencia",
                PostalCode = "46000",
                Country = "España",
                ContactEmail = "contact@test.com",
                ContactPhone = "+34 123 456 789"
            };

            // Act
            var response = await _client.PostAsJsonAsync("/organizations", newOrganization);

            // Assert
            response.StatusCode.Should().Be(System.Net.HttpStatusCode.Created);
            var created = await response.Content.ReadFromJsonAsync<OrganizationView>();
            created.Id.Should().BeGreaterThan(0);
            created.SecurityCompanyId.Should().BeGreaterThan(0); // Generado por secuencia
            created.Name.Should().Be("Test Organization");
            created.Cif.Should().Be("A12345678");
        }

        [Fact]
        public async Task Create_WithDuplicateCif_ReturnsBadRequest()
        {
            // Arrange: Crear primera organización
            var organization1 = new OrganizationView
            {
                Name = "Organization 1",
                Cif = "B87654321",
                ContactEmail = "org1@test.com"
            };
            await _client.PostAsJsonAsync("/organizations", organization1);

            // Intentar crear segunda con mismo CIF
            var organization2 = new OrganizationView
            {
                Name = "Organization 2",
                Cif = "B87654321", // CIF duplicado
                ContactEmail = "org2@test.com"
            };

            // Act
            var response = await _client.PostAsJsonAsync("/organizations", organization2);

            // Assert
            response.StatusCode.Should().Be(System.Net.HttpStatusCode.BadRequest);
            var error = await response.Content.ReadAsStringAsync();
            error.Should().Contain("Ya existe una organización activa con el CIF");
        }

        [Fact]
        public async Task Update_WithValidData_ReturnsOk()
        {
            // Arrange: Crear organización primero
            var organization = new OrganizationView
            {
                Name = "Original Name",
                Cif = "C99999999",
                ContactEmail = "original@test.com"
            };
            var createResponse = await _client.PostAsJsonAsync("/organizations", organization);
            var created = await createResponse.Content.ReadFromJsonAsync<OrganizationView>();

            // Modificar datos
            created.Name = "Updated Name";
            created.ContactEmail = "updated@test.com";

            // Act
            var response = await _client.PutAsJsonAsync($"/organizations/{created.Id}", created);

            // Assert
            response.StatusCode.Should().Be(System.Net.HttpStatusCode.OK);
            var updated = await response.Content.ReadFromJsonAsync<OrganizationView>();
            updated.Name.Should().Be("Updated Name");
            updated.ContactEmail.Should().Be("updated@test.com");
            updated.Cif.Should().Be("C99999999"); // CIF no debe cambiar
        }

        [Fact]
        public async Task Delete_ExistingOrganization_ReturnsSoftDelete()
        {
            // Arrange: Crear organización
            var organization = new OrganizationView
            {
                Name = "To Delete",
                Cif = "D11111111",
                ContactEmail = "todelete@test.com"
            };
            var createResponse = await _client.PostAsJsonAsync("/organizations", organization);
            var created = await createResponse.Content.ReadFromJsonAsync<OrganizationView>();

            // Act
            var deleteResponse = await _client.DeleteAsync($"/organizations/{created.Id}");

            // Assert
            deleteResponse.StatusCode.Should().Be(System.Net.HttpStatusCode.NoContent);
            
            // Verificar que es soft delete (registro sigue existiendo con AuditDeletionDate)
            var getResponse = await _client.GetAsync($"/organizations/{created.Id}");
            getResponse.StatusCode.Should().Be(System.Net.HttpStatusCode.OK);
            var deleted = await getResponse.Content.ReadFromJsonAsync<OrganizationView>();
            deleted.AuditDeletionDate.Should().NotBeNull();
        }
    }
}
```

**ARCHIVOS A CREAR/MODIFICAR:**

Backend:
- `InfoportOneAdmon.DataModel/Migrations/XXXXXX_CreateSecurityCompanyIdSequence.cs` - Migración manual para secuencia
- `InfoportOneAdmon.DataModel/Entities/Organization.cs` - Entidad EF Core
- `InfoportOneAdmon.DataModel/InfoportOneAdmonContext.cs` - Configurar índices únicos y secuencia
- `InfoportOneAdmon.Entities/Views/OrganizationView.cs` - ViewModel
- `InfoportOneAdmon.Services/Services/OrganizationService.cs` - Servicio con validaciones
- `InfoportOneAdmon.Api/Endpoints/OrganizationEndpoints.cs` - Endpoints RESTful
- `InfoportOneAdmon.Services/DependencyInjection.cs` - Registro de servicio
- `InfoportOneAdmon.Api/Program.cs` - Mapeo de endpoints y DI
- `InfoportOneAdmon.Services.Tests/Services/OrganizationServiceTests.cs` - Tests unitarios
- `InfoportOneAdmon.Api.Tests/Endpoints/OrganizationEndpointsTests.cs` - Tests de integración
- `InfoportOneAdmon.DataModel/Migrations/XXXXXX_AddOrganizationTable.cs` - Migración EF Core (generada automáticamente)

**DEPENDENCIAS:**
Ninguna (historia fundacional del proyecto)

**DEFINITION OF DONE:**
- [x] Secuencia de PostgreSQL `seq_security_company_id` creada
- [x] Entidad creada con IEntityBase y campos de auditoría Helix6
- [x] Índices únicos en SecurityCompanyId y Cif configurados
- [x] ViewModel creado con validaciones DataAnnotations
- [x] Servicio implementado con ValidateView (nombre, CIF, email obligatorios + CIF único)
- [x] PreviousActions normaliza datos (trim, mayúsculas CIF, minúsculas email)
- [x] Endpoints generados con EndpointHelper y documentados en Swagger
- [x] Migración EF Core generada y aplicada sin errores
- [x] DI configurada correctamente
- [x] Tests unitarios del servicio con cobertura >80%
- [x] Tests de integración de endpoints (CRUD completo + validación de duplicados)
- [x] Code review aprobado
- [x] Sin warnings ni vulnerabilidades
- [x] Documentación XML en servicio y endpoints

**RECURSOS:**
- Arquitectura Backend: `Helix6_Backend_Architecture.md` - Secciones 2 (Entities), 3 (Services), 4 (Repositories), 5 (Endpoints)
- User Story: `userStories.md#us-001`
- Swagger API: https://localhost:5001/swagger

=============================================================

---

#### TASK-001-EV-PUB: Publicar OrganizationEvent al crear/modificar/eliminar organización

=============================================================
**TICKET ID:** TASK-001-EV-PUB  
**EPIC:** Gestión del Portfolio de Organizaciones Clientes  
**USER STORY:** US-001 - Crear nueva organización cliente  
**COMPONENT:** Events - Publisher  
**PRIORITY:** Alta  
**ESTIMATION:** 3 horas  
=============================================================

**TÍTULO:**
Publicar OrganizationEvent al crear/modificar/eliminar organización

**DESCRIPCIÓN:**
Implementar la publicación de eventos `OrganizationEvent` al broker ActiveMQ Artemis cuando se realizan operaciones CRUD sobre la entidad Organization. Los eventos deben seguir el patrón "State Transfer Event" documentado en `ActiveMQ_Events.md`, incluyendo el estado completo de la organización y el flag `IsDeleted` para soft deletes.

Las aplicaciones satélite suscriptoras procesarán estos eventos para sincronizar sus bases de datos locales con los cambios en organizaciones.

**CONTEXTO TÉCNICO:**
- **Broker**: ActiveMQ Artemis configurado en docker-compose
- **Librería**: IPVInterchangeShared para integración con Artemis
- **Patrón**: Event-driven State Transfer (no eventos granulares como "OrganizationCreated", "OrganizationUpdated")
- **Persistencia**: Los eventos se persisten en tabla `IntegrationEvents` de PostgreSQL antes de publicarse
- **Reintentos**: Configurados automáticamente con dead letter queue por IPVInterchangeShared
- **Idempotencia**: Los suscriptores deben implementar procesamiento idempotente usando SecurityCompanyId
- **Testing**: Usar Testcontainers para tests de integración con Artemis y PostgreSQL reales

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] Clase de evento `OrganizationEvent` creada heredando de EventBase
- [ ] IMessagePublisher inyectado en OrganizationService
- [ ] Publicación implementada en PostActions del servicio
- [ ] Evento incluye todas las propiedades de la organización (state transfer completo)
- [ ] Flag `IsDeleted` indica si la organización fue desactivada (AuditDeletionDate != null)
- [ ] Propiedad `Apps` incluida con lista de aplicaciones y módulos accesibles por organización
- [ ] Configuración de tópico `infoportone.events.organization` añadida en appsettings.json
- [ ] Test de integración con Testcontainers verifica publicación correcta
- [ ] Test verifica persistencia en tabla IntegrationEvents
- [ ] Documentación del evento actualizada (estructura del payload)

**CHECKLIST DE PUBLICACIÓN DE EVENTOS (aplicar a todos los tickets EV-PUB):**
- **IMessagePublisher**: inyectar `IMessagePublisher` en el servicio y usarlo desde `PostActions`.
- **Persistencia previa al envío**: `PublishAsync` debe persistir el evento en la tabla `IntegrationEvents` antes de enviarlo al broker.
- **Resiliencia**: `PostActions` NO debe lanzar excepción que revierta la operación de negocio si la publicación falla; registrar error y confiar en reintentos/DLQ desde `IntegrationEvents`.
- **Configuración**: definir los tópicos en `appsettings.json` (ej. `EventBroker:Topics:OrganizationEvents`).
- **Tests**: añadir tests de integración con Testcontainers (Artemis + Postgres) cuando el ticket lo requiera; en unit tests usar mocks para `IMessagePublisher`.

**GUÍA DE IMPLEMENTACIÓN:**

**Paso 1: Crear la Clase del Evento**

Archivo: `InfoportOneAdmon.Events/OrganizationEvent.cs`

```csharp
using IPVInterchangeShared.Broker.Events;

namespace InfoportOneAdmon.Events
{
    /// <summary>
    /// Evento publicado cuando cambia el estado de una Organización Cliente
    /// Patrón State Transfer: incluye el estado completo de la organización, no solo los cambios
    /// </summary>
    public class OrganizationEvent : EventBase
    {
        public OrganizationEvent(string topic, string serviceName) : base(topic, serviceName)
        {
        }

        // Propiedades de negocio (estado completo de la organización)
        
        /// <summary>
        /// Identificador de negocio único de la organización (clave de idempotencia)
        /// </summary>
        public int SecurityCompanyId { get; set; }
        
        /// <summary>
        /// Nombre de la organización cliente
        /// </summary>
        public string Name { get; set; }
        
        /// <summary>
        /// CIF de la organización
        /// </summary>
        public string Cif { get; set; }
        
        /// <summary>
        /// Dirección física
        /// </summary>
        public string Address { get; set; }
        
        /// <summary>
        /// Ciudad
        /// </summary>
        public string City { get; set; }
        
        /// <summary>
        /// Código Postal
        /// </summary>
        public string PostalCode { get; set; }
        
        /// <summary>
        /// País
        /// </summary>
        public string Country { get; set; }
        
        /// <summary>
        /// Email de contacto principal
        /// </summary>
        public string ContactEmail { get; set; }
        
        /// <summary>
        /// Teléfono de contacto
        /// </summary>
        public string ContactPhone { get; set; }
        
        /// <summary>
        /// ID del grupo al que pertenece la organización (opcional)
        /// </summary>
        public int? GroupId { get; set; }
        
        /// <summary>
        /// Lista de aplicaciones y módulos a los que tiene acceso esta organización
        /// Incluye configuración de base de datos específica para cada aplicación
        /// </summary>
        public List<AppAccessInfo> Apps { get; set; }
        
        /// <summary>
        /// Flag crítico: indica si la organización fue desactivada (soft delete)
        /// Los suscriptores deben procesar esto como desactivación local (bloqueo de acceso)
        /// </summary>
        public bool IsDeleted { get; set; }
        
        // Campos de auditoría (opcionales pero recomendados para trazabilidad)
        public DateTime? AuditCreationDate { get; set; }
        public DateTime? AuditModificationDate { get; set; }
    }

    /// <summary>
    /// Información de acceso a una aplicación por parte de una organización
    /// </summary>
    public class AppAccessInfo
    {
        /// <summary>
        /// ID de la aplicación
        /// </summary>
        public int AppId { get; set; }
        
        /// <summary>
        /// Nombre de la base de datos específica para esta organización y aplicación
        /// Ej: "sintraport_org_12345"
        /// </summary>
        public string DatabaseName { get; set; }
        
        /// <summary>
        /// IDs de los módulos a los que tiene acceso esta organización en esta aplicación
        /// </summary>
        public List<int> AccessibleModules { get; set; }
    }
}
```

**Paso 2: Inyectar IMessagePublisher en el Servicio**

Modificar: `InfoportOneAdmon.Services/Services/OrganizationService.cs`

```csharp
using IPVInterchangeShared.Broker.Interfaces;
using InfoportOneAdmon.Events;
using Microsoft.Extensions.Configuration;
using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Services.Services
{
    public class OrganizationService : BaseService<OrganizationView, Organization, BaseMetadata>
    {
        private readonly IMessagePublisher _messagePublisher;
        private readonly IConfiguration _configuration;
        private readonly IRepository<ModuleAccess> _moduleAccessRepository; // Para obtener apps y módulos

        public OrganizationService(
            ILogger<OrganizationService> logger,
            IRepository<Organization> repository,
            IMessagePublisher messagePublisher,
            IConfiguration configuration,
            IRepository<ModuleAccess> moduleAccessRepository)
            : base(logger, repository)
        {
            _messagePublisher = messagePublisher;
            _configuration = configuration;
            _moduleAccessRepository = moduleAccessRepository;
        }

        // ... ValidateView, PreviousActions ...

        protected override async Task PostActions(OrganizationView view, Organization entity, CancellationToken cancellationToken)
        {
            await base.PostActions(view, entity, cancellationToken);
            
            // Publicar evento al broker
            await PublishOrganizationEvent(entity, cancellationToken);
        }

        /// <summary>
        /// Publica el evento de estado de la organización al broker ActiveMQ Artemis
        /// </summary>
        private async Task PublishOrganizationEvent(Organization entity, CancellationToken cancellationToken)
        {
            var topic = _configuration["EventBroker:Topics:OrganizationEvent"] 
                        ?? "infoportone.events.organization";
            var serviceName = _configuration["EventBroker:ServiceName"] 
                              ?? "InfoportOneAdmon";

            // Obtener lista de aplicaciones y módulos accesibles
            var apps = await GetOrganizationApps(entity.Id, cancellationToken);

            var evento = new OrganizationEvent(topic, serviceName)
            {
                SecurityCompanyId = entity.SecurityCompanyId,
                Name = entity.Name,
                Cif = entity.Cif,
                Address = entity.Address,
                City = entity.City,
                PostalCode = entity.PostalCode,
                Country = entity.Country,
                ContactEmail = entity.ContactEmail,
                ContactPhone = entity.ContactPhone,
                GroupId = entity.GroupId,
                Apps = apps,
                
                // CRÍTICO: Flag IsDeleted indica soft delete
                IsDeleted = entity.AuditDeletionDate.HasValue,
                
                // Auditoría
                AuditCreationDate = entity.AuditCreationDate,
                AuditModificationDate = entity.AuditModificationDate
            };

            try
            {
                // PublishAsync persiste en IntegrationEvents y envía al broker
                await _messagePublisher.PublishAsync(topic, evento, cancellationToken);
                
                Logger.LogInformation(
                    "Evento {EventType} publicado para organización {SecurityCompanyId} (IsDeleted: {IsDeleted})",
                    nameof(OrganizationEvent),
                    entity.SecurityCompanyId,
                    evento.IsDeleted);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex, 
                    "Error al publicar evento {EventType} para organización {SecurityCompanyId}",
                    nameof(OrganizationEvent),
                    entity.SecurityCompanyId);
                
                // IMPORTANTE: No lanzar excepción, el evento se reintentará desde IntegrationEvents
                // La transacción de BD ya se completó correctamente
            }
        }

        /// <summary>
        /// Obtiene la lista de aplicaciones y módulos a los que tiene acceso la organización
        /// </summary>
        private async Task<List<AppAccessInfo>> GetOrganizationApps(int organizationId, CancellationToken cancellationToken)
        {
            // Query para obtener módulos accesibles agrupados por aplicación
            var moduleAccesses = await _moduleAccessRepository.GetQuery()
                .Where(ma => ma.OrganizationId == organizationId && ma.AuditDeletionDate == null)
                .Include(ma => ma.Module)
                    .ThenInclude(m => m.Application)
                .ToListAsync(cancellationToken);

            // Agrupar por aplicación
            var apps = moduleAccesses
                .GroupBy(ma => new 
                { 
                    ma.Module.ApplicationId, 
                    ma.Module.Application.DatabasePrefix 
                })
                .Select(g => new AppAccessInfo
                {
                    AppId = g.Key.ApplicationId,
                    // Generar nombre de BD específico: {prefix}_org_{securityCompanyId}
                    DatabaseName = $"{g.Key.DatabasePrefix}_org_{entity.SecurityCompanyId}".ToLowerInvariant(),
                    AccessibleModules = g.Select(ma => ma.ModuleId).ToList()
                })
                .ToList();

            return apps;
        }
    }
}
```

**Paso 3: Configurar Tópico en appsettings.json**

Archivo: `InfoportOneAdmon.Api/appsettings.json`

```json
{
  "EventBroker": {
    "ServiceName": "InfoportOneAdmon",
    "Artemis": {
      "Host": "localhost",
      "Port": 61616,
      "User": "artemis",
      "Password": "artemis"
    },
    "Topics": {
      "OrganizationEvent": "infoportone.events.organization",
      "ApplicationEvent": "infoportone.events.application",
      "UserEvent": "infoportone.events.user"
    },
    "Retry": {
      "MaxAttempts": 5,
      "InitialDelay": 1000,
      "MaxDelay": 60000
    }
  }
}
```

**Paso 4: Configurar AddArtemisBroker en Program.cs**

Si no está ya configurado, añadir en `InfoportOneAdmon.Api/Program.cs`:

```csharp
using IPVInterchangeShared.Broker.Artemis;

var builder = WebApplication.CreateBuilder(args);

// Configurar IPVInterchangeShared con Artemis
builder.Services.AddArtemisBroker(builder.Configuration, typeof(Program).Assembly);

// ... resto de configuración ...
```

**Paso 5: Implementar Test de Integración con Testcontainers**

Archivo: `InfoportOneAdmon.Services.Tests/Events/OrganizationEventPublisherTests.cs`

```csharp
using Xunit;
using FluentAssertions;
using Testcontainers.PostgreSql;
using DotNet.Testcontainers.Builders;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.EntityFrameworkCore;
using IPVInterchangeShared.Broker.Interfaces;
using InfoportOneAdmon.Services.Services;
using InfoportOneAdmon.Entities.Views;
using InfoportOneAdmon.Events;
using InfoportOneAdmon.DataModel;
using System.Text.Json;

namespace InfoportOneAdmon.Services.Tests.Events
{
    public class OrganizationEventPublisherTests : IAsyncLifetime
    {
        private PostgreSqlContainer _postgresContainer;
        // Nota: Testcontainers.Artemis no existe aún, usaremos mock de IMessagePublisher
        private IServiceProvider _serviceProvider;

        public async Task InitializeAsync()
        {
            // Configurar contenedor PostgreSQL
            _postgresContainer = new PostgreSqlBuilder()
                .WithImage("postgres:16")
                .WithDatabase("infoportone_test")
                .WithUsername("postgres")
                .WithPassword("postgres")
                .Build();
            
            await _postgresContainer.StartAsync();

            // Configurar DI con PostgreSQL de Testcontainer
            var services = new ServiceCollection();
            services.AddLogging();
            
            // Configurar DbContext con PostgreSQL de Testcontainer
            services.AddDbContext<InfoportOneAdmonContext>(options =>
                options.UseNpgsql(_postgresContainer.GetConnectionString()));
            
            // Mock de IMessagePublisher para tests
            var publisherMock = new Mock<IMessagePublisher>();
            publisherMock.Setup(p => p.PublishAsync(
                It.IsAny<string>(),
                It.IsAny<OrganizationEvent>(),
                It.IsAny<CancellationToken>()))
                .Returns(Task.CompletedTask);
            
            services.AddSingleton(publisherMock.Object);
            
            // Configuración
            var config = new ConfigurationBuilder()
                .AddInMemoryCollection(new Dictionary<string, string>
                {
                    ["EventBroker:ServiceName"] = "TestService",
                    ["EventBroker:Topics:OrganizationEvent"] = "test.organizations"
                })
                .Build();
            
            services.AddSingleton<IConfiguration>(config);
            
            // Registrar servicio a testear
            services.AddScoped<OrganizationService>();
            services.AddScoped(typeof(IRepository<>), typeof(Repository<>));
            
            _serviceProvider = services.BuildServiceProvider();
            
            // Aplicar migraciones
            using var scope = _serviceProvider.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<InfoportOneAdmonContext>();
            await context.Database.MigrateAsync();
        }

        [Fact]
        public async Task PostActions_WhenOrganizationCreated_PublishesEvent()
        {
            // Arrange
            using var scope = _serviceProvider.CreateScope();
            var service = scope.ServiceProvider.GetRequiredService<OrganizationService>();
            var context = scope.ServiceProvider.GetRequiredService<InfoportOneAdmonContext>();
            var publisherMock = scope.ServiceProvider.GetRequiredService<IMessagePublisher>() as Mock<IMessagePublisher>;
            
            var view = new OrganizationView
            {
                Name = "Test Organization",
                Cif = "A12345678",
                ContactEmail = "test@example.com"
            };

            // Act
            var result = await service.CreateAsync(view, CancellationToken.None);

            // Assert
            result.Should().NotBeNull();
            result.SecurityCompanyId.Should().BeGreaterThan(0);
            
            // Verificar que se llamó a PublishAsync
            publisherMock.Verify(p => p.PublishAsync(
                "test.organizations",
                It.Is<OrganizationEvent>(e => 
                    e.SecurityCompanyId == result.SecurityCompanyId &&
                    e.Name == "Test Organization" &&
                    e.IsDeleted == false),
                It.IsAny<CancellationToken>()),
                Times.Once);
        }

        [Fact]
        public async Task PostActions_WhenOrganizationDeleted_PublishesEventWithIsDeletedTrue()
        {
            // Arrange
            using var scope = _serviceProvider.CreateScope();
            var service = scope.ServiceProvider.GetRequiredService<OrganizationService>();
            var publisherMock = scope.ServiceProvider.GetRequiredService<IMessagePublisher>() as Mock<IMessagePublisher>();
            
            var view = new OrganizationView
            {
                Name = "To Delete",
                Cif = "B87654321",
                ContactEmail = "delete@example.com"
            };
            
            var created = await service.CreateAsync(view, CancellationToken.None);
            publisherMock.Invocations.Clear(); // Limpiar invocaciones previas

            // Act
            await service.DeleteAsync(created.Id, CancellationToken.None);

            // Assert
            publisherMock.Verify(p => p.PublishAsync(
                "test.organizations",
                It.Is<OrganizationEvent>(e => 
                    e.SecurityCompanyId == created.SecurityCompanyId &&
                    e.IsDeleted == true),
                It.IsAny<CancellationToken>()),
                Times.Once);
        }

        public async Task DisposeAsync()
        {
            await _postgresContainer.DisposeAsync();
        }
    }
}
```

**Paso 6: Documentar el Evento**

Crear archivo: `docs/events/OrganizationEvent.md`

```markdown
# OrganizationEvent

## Descripción
Evento publicado cuando cambia el estado de una Organización Cliente en InfoportOneAdmon.

## Patrón
State Transfer Event - Incluye el estado completo de la organización.

## Tópico
`infoportone.events.organization`

## Publisher
InfoportOneAdmon API

## Subscribers
- Aplicaciones satélite del ecosistema (CRM, ERP, BI, etc.)

## Estructura del Payload

```json
{
  "eventId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "eventTimestamp": "2026-01-31T10:30:00Z",
  "traceId": "trace-123",
  "topic": "infoportone.events.organization",
  "serviceName": "InfoportOneAdmon",
  "securityCompanyId": 12345,
  "name": "Acme Corporation",
  "cif": "A12345678",
  "address": "Calle Principal 123",
  "city": "Valencia",
  "postalCode": "46000",
  "country": "España",
  "contactEmail": "contact@acme.com",
  "contactPhone": "+34 123 456 789",
  "groupId": 10,
  "apps": [
    {
      "appId": 1,
      "databaseName": "sintraport_org_12345",
      "accessibleModules": [101, 102, 103]
    },
    {
      "appId": 2,
      "databaseName": "crm_org_12345",
      "accessibleModules": [201, 202]
    }
  ],
  "isDeleted": false,
  "auditCreationDate": "2026-01-01T08:00:00Z",
  "auditModificationDate": "2026-01-31T10:30:00Z"
}
```

## Propiedades

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| securityCompanyId | int | Sí | Identificador único de negocio de la organización |
| name | string | Sí | Nombre de la organización |
| cif | string | Sí | CIF de la organización |
| address | string | No | Dirección física |
| city | string | No | Ciudad |
| postalCode | string | No | Código postal |
| country | string | No | País |
| contactEmail | string | Sí | Email de contacto principal |
| contactPhone | string | No | Teléfono de contacto |
| groupId | int | No | ID del grupo al que pertenece |
| apps | array | Sí | Lista de aplicaciones con sus módulos accesibles y BD específica |
| isDeleted | bool | Sí | Indica si la organización fue desactivada (soft delete) |

## Procesamiento Idempotente

Los suscriptores deben:
1. Verificar si `isDeleted == true` para aplicar desactivación local (bloquear accesos)
2. Si `isDeleted == false`, hacer UPSERT (insert o update según exista `securityCompanyId`)
3. Usar `securityCompanyId` como clave de idempotencia
4. Procesar array `apps` para configurar accesos a módulos por organización

## Ejemplo de Suscriptor

Ver `ActiveMQ_Events.md` sección "Implementar un Suscriptor (IEventProcessor)".
```

**ARCHIVOS A CREAR/MODIFICAR:**
- `InfoportOneAdmon.Events/OrganizationEvent.cs` - Clase del evento con AppAccessInfo
- `InfoportOneAdmon.Services/Services/OrganizationService.cs` - Inyectar IMessagePublisher y publicar en PostActions
- `InfoportOneAdmon.Api/appsettings.json` - Configuración del tópico
- `InfoportOneAdmon.Api/Program.cs` - Configurar AddArtemisBroker si no existe
- `InfoportOneAdmon.Services.Tests/Events/OrganizationEventPublisherTests.cs` - Tests con Testcontainers
- `docs/events/OrganizationEvent.md` - Documentación del evento

**DEPENDENCIAS:**
- TASK-001-BE - Debe existir el servicio Organization

**DEFINITION OF DONE:**
- [ ] Clase OrganizationEvent creada heredando de EventBase
- [ ] Clase AppAccessInfo creada para lista de apps
- [ ] IMessagePublisher inyectado en OrganizationService
- [ ] Evento publicado en PostActions del servicio
- [ ] Flag IsDeleted implementado correctamente
- [ ] Propiedad Apps poblada con aplicaciones y módulos
- [ ] Configuración en appsettings.json
- [ ] AddArtemisBroker configurado en Program.cs
- [ ] Test con mock de IMessagePublisher verifica publicación
- [ ] Test verifica IsDeleted=true en soft delete
- [ ] Documentación del evento creada
- [ ] Code review aprobado

**RECURSOS:**
- Arquitectura de Eventos: `ActiveMQ_Events.md` - Secciones "Publicar un Evento", "Testing con Testcontainers"
- User Story: `userStories.md#us-001`

=============================================================

---

### US-002: Editar información de organización existente

**Resumen de tickets generados:**
- TASK-002-BE: Modificar OrganizationService para soportar edición con validaciones

---

#### TASK-002-BE: Modificar OrganizationService para soportar edición con validaciones

=============================================================
**TICKET ID:** TASK-002-BE  
**EPIC:** Gestión del Portfolio de Organizaciones Clientes  
**USER STORY:** US-002 - Editar información de organización existente  
**COMPONENT:** Backend  
**PRIORITY:** Alta  
**ESTIMATION:** 2 horas  
=============================================================

**TÍTULO:**
Modificar OrganizationService para soportar edición con validaciones

**DESCRIPCIÓN:**
Extender la funcionalidad de `OrganizationService` para soportar la edición de organizaciones existentes con las siguientes reglas de negocio:
- El campo `SecurityCompanyId` NO debe ser editable (inmutable)
- Validar que el CIF sigue siendo único excluyendo el registro actual
- Actualizar automáticamente campos de auditoría (`AuditModificationUser`, `AuditModificationDate`)
- Registrar en `AuditLog` los valores anteriores (OldValue) y nuevos (NewValue) de cada campo modificado
- Publicar `OrganizationEvent` actualizado (se hace automáticamente en PostActions de TASK-001-EV-PUB)

**CONTEXTO TÉCNICO:**
- El método `UpdateAsync` de `BaseService` ya maneja la actualización básica
- Necesitamos reforzar validaciones en `ValidateView` para modo edición
- El registro de auditoría detallado se implementará creando registros en tabla `AUDIT_LOG`
- Los campos de auditoría Helix6 se actualizan automáticamente por el framework

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] Validación de inmutabilidad de `SecurityCompanyId` implementada
- [ ] Validación de unicidad de CIF excluye el registro actual (Id != view.Id)
- [ ] Método UpdateAsync funciona correctamente (heredado de BaseService)
- [ ] Registro de auditoría detallado en tabla AUDIT_LOG con before/after values
- [ ] Tests unitarios de validación de edición
- [ ] Tests de integración de endpoint PUT /organizations/{id}

**GUÍA DE IMPLEMENTACIÓN:**

**Paso 1: Reforzar ValidateView para Edición**

El método `ValidateView` de TASK-001-BE ya valida CIF único excluyendo el ID actual:

```csharp
// Esta validación ya está implementada en TASK-001-BE
var cifExists = await Repository.ExistsAsync(
    o => o.Cif == view.Cif && o.Id != view.Id && o.AuditDeletionDate == null,
    cancellationToken);
```

**Paso 2: Validar Inmutabilidad de SecurityCompanyId**

Modificar `InfoportOneAdmon.Services/Services/OrganizationService.cs`:

```csharp
protected override async Task<bool> ValidateView(OrganizationView view, CancellationToken cancellationToken)
{
    // ... validaciones existentes de TASK-001-BE ...

    // Validación adicional para modo edición (cuando Id > 0)
    if (view.Id > 0)
    {
        // Obtener la entidad original de BD
        var originalEntity = await Repository.GetByIdAsync(view.Id, cancellationToken);
        
        if (originalEntity != null && originalEntity.SecurityCompanyId != view.SecurityCompanyId)
        {
            AddError("El SecurityCompanyId es inmutable y no puede modificarse");
            return false;
        }
    }

    return true; // O el resultado de las validaciones anteriores
}
```

**Paso 3: Registrar Auditoría Detallada en PostActions**

Recomendación de implementación (sin fragmentos de código en este documento):

- Definir una estructura `AuditEntry` que contenga `EntityName`, `EntityKey`, `Action`, `UserId`, `OldValue` (JSON), `NewValue` (JSON), `CorrelationId` y `CreatedAt`.
- Implementar `IAuditLogService.LogAsync(AuditEntry entry, CancellationToken ct)` que centralice la serialización y persistencia en la tabla `AuditLogs` a través de `IAuditLogRepository`.
- En `PreviousActions` del flujo de actualización, capturar el estado original de la entidad (antes de aplicar mapeos desde el `View`) y generar `OldValue`.
- En `PostActions`, tras el `SaveChanges` de la entidad principal, construir `NewValue` y llamar a `IAuditLogService.LogAsync(...)` para persistir el registro de auditoría. Esto asegura que `EntityKey` (Id) esté disponible.
- Evitar que la lógica de negocio escriba directamente en tablas de auditoría; siempre pasar por `IAuditLogService` para mantener uniformidad, validaciones y pruebas.
- Registrar el evento `OrganizationEvent` después de invocar el servicio de auditoría o como parte del mismo `PostActions` según la política de orden preferida (primero persistir auditoría, luego publicar evento), documentando la decisión en el ticket de implementación.

Agregar un ticket dependiente para crear la entidad `AuditLog`, su repositorio, la implementación de `IAuditLogService` y la migración de EF Core (ver lista TODO). Incluir pruebas que aseguren la invocación del servicio y el contenido de `OldValue`/`NewValue`.
/// <summary>
/// Registra en AUDIT_LOG los cambios realizados (before/after)
/// </summary>
private async Task RegisterDetailedAudit(OrganizationView newView, Organization newEntity, CancellationToken cancellationToken)
{
    // Obtener estado original de la base de datos (antes del update)
    // NOTA: Esto requiere consultar la entidad original ANTES de que EF Core la actualice
    // En producción, esto se haría en PreviousActions guardando el estado original
    
    // Por simplicidad, asumimos que el contexto EF Core tiene tracking habilitado
    // y podemos acceder al estado original
    
    var auditLog = new AuditLog
    {
        EntityType = "Organization",
        EntityId = newEntity.Id,
        Action = "Update",
        OldValue = JsonSerializer.Serialize(new 
        {
            // Aquí iría el estado original - en producción se captura en PreviousActions
            Name = "Estado anterior",
            ContactEmail = "anterior@example.com"
        }),
        NewValue = JsonSerializer.Serialize(new 
        {
            Name = newEntity.Name,
            Cif = newEntity.Cif,
            Address = newEntity.Address,
            City = newEntity.City,
            PostalCode = newEntity.PostalCode,
            Country = newEntity.Country,
            ContactEmail = newEntity.ContactEmail,
            ContactPhone = newEntity.ContactPhone
        }),
        AuditCreationDate = DateTime.UtcNow,
        AuditCreationUser = newEntity.AuditModificationUser // Usuario que hizo el cambio
    };

    // NOTA: Esto requiere inyectar IRepository<AuditLog> en el constructor
    // await _auditLogRepository.InsertAsync(auditLog, cancellationToken);
    
    Logger.LogInformation(
        "Auditoría registrada para Organization {OrganizationId} - Usuario {UserId}",
        newEntity.Id,
        newEntity.AuditModificationUser);
}
```

**Nota importante:** La implementación completa de auditoría detallada requiere:
1. Inyectar `IRepository<AuditLog>` en el constructor
2. Capturar el estado original de la entidad ANTES de que EF Core la actualice (en `PreviousActions`)
3. Comparar propiedades y solo registrar las que cambiaron

Para este ticket, podemos simplificar y delegar la auditoría avanzada a un ticket futuro (TASK-008-BE).

**Paso 4: Implementar Tests de Edición**

Archivo: `InfoportOneAdmon.Services.Tests/Services/OrganizationServiceTests.cs`

Añadir estos tests al archivo existente:

```csharp
[Fact]
public async Task ValidateView_WhenEditingWithDifferentSecurityCompanyId_ReturnsFalse()
{
    // Arrange
    var originalEntity = new Organization
    {
        Id = 1,
        SecurityCompanyId = 12345,
        Name = "Original",
        Cif = "A11111111",
        ContactEmail = "original@test.com"
    };

    _repositoryMock.Setup(r => r.GetByIdAsync(1, It.IsAny<CancellationToken>()))
        .ReturnsAsync(originalEntity);

    var view = new OrganizationView
    {
        Id = 1,
        SecurityCompanyId = 99999, // Intento de cambiar SecurityCompanyId
        Name = "Modified",
        Cif = "A11111111",
        ContactEmail = "modified@test.com"
    };

    // Act
    var result = await _service.ValidateView(view, CancellationToken.None);

    // Assert
    result.Should().BeFalse();
    _service.Errors.Should().Contain(e => e.Contains("SecurityCompanyId es inmutable"));
}

[Fact]
public async Task ValidateView_WhenEditingWithSameSecurityCompanyId_ReturnsTrue()
{
    // Arrange
    var originalEntity = new Organization
    {
        Id = 1,
        SecurityCompanyId = 12345,
        Name = "Original",
        Cif = "A11111111",
        ContactEmail = "original@test.com"
    };

    _repositoryMock.Setup(r => r.GetByIdAsync(1, It.IsAny<CancellationToken>()))
        .ReturnsAsync(originalEntity);
    
    _repositoryMock.Setup(r => r.ExistsAsync(
        It.IsAny<Expression<Func<Organization, bool>>>(),
        It.IsAny<CancellationToken>()))
        .ReturnsAsync(false); // CIF no duplicado

    var view = new OrganizationView
    {
        Id = 1,
        SecurityCompanyId = 12345, // Mismo SecurityCompanyId
        Name = "Modified Name",
        Cif = "A11111111",
        ContactEmail = "modified@test.com"
    };

    // Act
    var result = await _service.ValidateView(view, CancellationToken.None);

    // Assert
    result.Should().BeTrue();
}
```

**Paso 5: Tests de Integración de Endpoint PUT**

Los tests de integración ya están implementados en TASK-001-BE (`OrganizationEndpointsTests.cs`), específicamente el test `Update_WithValidData_ReturnsOk`.

Añadir test adicional para validar inmutabilidad:

```csharp
[Fact]
public async Task Update_WithDifferentSecurityCompanyId_ReturnsBadRequest()
{
    // Arrange: Crear organización
    var organization = new OrganizationView
    {
        Name = "Original",
        Cif = "C88888888",
        ContactEmail = "original@test.com"
    };
    var createResponse = await _client.PostAsJsonAsync("/organizations", organization);
    var created = await createResponse.Content.ReadFromJsonAsync<OrganizationView>();

    // Intentar modificar SecurityCompanyId
    created.Name = "Modified";
    created.SecurityCompanyId = 99999; // Cambiar SecurityCompanyId (NO permitido)

    // Act
    var response = await _client.PutAsJsonAsync($"/organizations/{created.Id}", created);

    // Assert
    response.StatusCode.Should().Be(System.Net.HttpStatusCode.BadRequest);
    var error = await response.Content.ReadAsStringAsync();
    error.Should().Contain("SecurityCompanyId es inmutable");
}
```

**ARCHIVOS A MODIFICAR:**
- `InfoportOneAdmon.Services/Services/OrganizationService.cs` - Añadir validación de inmutabilidad de SecurityCompanyId
- `InfoportOneAdmon.Services.Tests/Services/OrganizationServiceTests.cs` - Añadir tests de edición
- `InfoportOneAdmon.Api.Tests/Endpoints/OrganizationEndpointsTests.cs` - Añadir test de inmutabilidad

**DEPENDENCIAS:**
- TASK-001-BE - OrganizationService debe existir

**DEFINITION OF DONE:**
- [ ] Validación de inmutabilidad de SecurityCompanyId implementada
- [ ] Validación de CIF único excluye registro actual
- [ ] Tests unitarios de edición pasando
- [ ] Tests de integración de PUT /organizations/{id} pasando
- [ ] Test de inmutabilidad de SecurityCompanyId pasando
- [ ] Code review aprobado
- [ ] Endpoint PUT documentado en Swagger

**RECURSOS:**
- Arquitectura Backend: `Helix6_Backend_Architecture.md` - Sección 3 (Services)
- User Story: `userStories.md#us-002`

=============================================================

---

### US-003: Desactivar organización (kill-switch)

**Resumen de tickets generados:**
- TASK-003-BE: Implementar desactivación (soft delete) de organización

---

#### TASK-003-BE: Implementar desactivación (soft delete) de organización

=============================================================
**TICKET ID:** TASK-003-BE  
**EPIC:** Gestión del Portfolio de Organizaciones Clientes  
**USER STORY:** US-003 - Desactivar organización (kill-switch)  
**COMPONENT:** Backend  
**PRIORITY:** Alta  
**ESTIMATION:** 1 hora  
=============================================================

**TÍTULO:**
Implementar desactivación (soft delete) de organización

**DESCRIPCIÓN:**
El método `DeleteAsync` heredado de `BaseService` ya implementa soft delete estableciendo `AuditDeletionDate`. Este ticket verifica que el comportamiento sea correcto y añade validaciones específicas para la desactivación de organizaciones.

Cuando una organización se desactiva:
- Se establece `AuditDeletionDate` a la fecha actual (no se elimina físicamente)
- Se publica `OrganizationEvent` con `IsDeleted: true` (ya implementado en TASK-001-EV-PUB)
- Las aplicaciones satélite que reciben el evento deben bloquear accesos de usuarios de esa organización
- El registro permanece en BD para auditoría y posible reactivación futura

**CONTEXTO TÉCNICO:**
- BaseService ya implementa soft delete en su método DeleteAsync
- Solo necesitamos tests que verifiquen el comportamiento correcto
- El evento con IsDeleted:true ya se publica automáticamente en PostActions

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] Método DeleteAsync establece AuditDeletionDate correctamente
- [ ] Registro NO se elimina físicamente (sigue en BD)
- [ ] OrganizationEvent publicado con IsDeleted:true
- [ ] Tests unitarios verifican soft delete
- [ ] Tests de integración del endpoint DELETE /organizations/{id}
- [ ] Documentación actualizada indicando que es soft delete

**GUÍA DE IMPLEMENTACIÓN:**

**Paso 1: Verificar Implementación de BaseService**

El método `DeleteAsync` de Helix6 BaseService ya implementa soft delete:

```csharp
// BaseService<TView, TEntity, TMetadata> (Helix6)
public virtual async Task<bool> DeleteAsync(int id, CancellationToken cancellationToken)
{
    var entity = await Repository.GetByIdAsync(id, cancellationToken);
    if (entity == null)
        return false;

    // Soft delete: establecer AuditDeletionDate
    entity.AuditDeletionDate = DateTime.UtcNow;
    entity.AuditModificationDate = DateTime.UtcNow;
    entity.AuditModificationUser = GetCurrentUserId();

    await Repository.UpdateAsync(entity, cancellationToken);
    
    // PostActions se ejecuta automáticamente (publica evento)
    await PostActions(MapEntityToView(entity), entity, cancellationToken);
    
    return true;
}
```

**No necesitamos modificar OrganizationService** - el comportamiento ya es correcto.

**Paso 2: Añadir Tests Unitarios de Soft Delete**

Archivo: `InfoportOneAdmon.Services.Tests/Services/OrganizationServiceTests.cs`

Añadir al archivo existente:

```csharp
[Fact]
public async Task DeleteAsync_SetsAuditDeletionDateWithoutPhysicalDelete()
{
    // Arrange
    var entity = new Organization
    {
        Id = 1,
        SecurityCompanyId = 12345,
        Name = "To Delete",
        Cif = "A99999999",
        ContactEmail = "delete@test.com",
        AuditDeletionDate = null
    };

    _repositoryMock.Setup(r => r.GetByIdAsync(1, It.IsAny<CancellationToken>()))
        .ReturnsAsync(entity);

    _repositoryMock.Setup(r => r.UpdateAsync(It.IsAny<Organization>(), It.IsAny<CancellationToken>()))
        .Returns(Task.CompletedTask);

    // Act
    var result = await _service.DeleteAsync(1, CancellationToken.None);

    // Assert
    result.Should().BeTrue();
    entity.AuditDeletionDate.Should().NotBeNull();
    entity.AuditDeletionDate.Should().BeCloseTo(DateTime.UtcNow, TimeSpan.FromSeconds(5));
    
    // Verificar que se llamó a UpdateAsync (no a DeleteAsync físico)
    _repositoryMock.Verify(r => r.UpdateAsync(
        It.Is<Organization>(o => o.AuditDeletionDate != null),
        It.IsAny<CancellationToken>()),
        Times.Once);
    
    // Verificar que NO se llamó a DeleteAsync físico
    _repositoryMock.Verify(r => r.DeleteAsync(It.IsAny<Organization>(), It.IsAny<CancellationToken>()),
        Times.Never);
}

[Fact]
public async Task DeleteAsync_PublishesEventWithIsDeletedTrue()
{
    // Este test ya está implementado en TASK-001-EV-PUB
    // OrganizationEventPublisherTests.PostActions_WhenOrganizationDeleted_PublishesEventWithIsDeletedTrue
    // No es necesario duplicarlo aquí
}
```

**Paso 3: Verificar Tests de Integración**

El test de integración ya está implementado en TASK-001-BE:

```csharp
// Archivo: InfoportOneAdmon.Api.Tests/Endpoints/OrganizationEndpointsTests.cs
[Fact]
public async Task Delete_ExistingOrganization_ReturnsSoftDelete()
{
    // ... ya implementado en TASK-001-BE
    // Verifica que el registro sigue existiendo con AuditDeletionDate != null
}
```

**Paso 4: Actualizar Documentación Swagger**

Añadir comentario XML en OrganizationEndpoints:

```csharp
/// <summary>
/// Desactiva una organización (soft delete)
/// IMPORTANTE: La organización NO se elimina físicamente, solo se marca como inactiva
/// estableciendo AuditDeletionDate. Esto bloquea el acceso de sus usuarios a todas las aplicaciones.
/// </summary>
/// <param name="id">ID de la organización a desactivar</param>
/// <returns>NoContent si la desactivación fue exitosa</returns>
[ProducesResponseType(StatusCodes.Status204NoContent)]
[ProducesResponseType(StatusCodes.Status404NotFound)]
```

**ARCHIVOS A MODIFICAR:**
- `InfoportOneAdmon.Services.Tests/Services/OrganizationServiceTests.cs` - Añadir test de soft delete
- `InfoportOneAdmon.Api/Endpoints/OrganizationEndpoints.cs` - Documentar endpoint DELETE

**DEPENDENCIAS:**
- TASK-001-BE - OrganizationService existe
- TASK-001-EV-PUB - Evento se publica con IsDeleted:true

**DEFINITION OF DONE:**
- [ ] Test unitario de soft delete implementado y pasando
- [ ] Test verifica que AuditDeletionDate se establece
- [ ] Test verifica que NO se llama a DeleteAsync físico
- [ ] Test de integración existente valida comportamiento end-to-end
- [ ] Documentación Swagger actualizada
- [ ] Code review aprobado

**RECURSOS:**
- Arquitectura Backend: `Helix6_Backend_Architecture.md` - Sección 3.4 (Soft Delete)
- User Story: `userStories.md#us-003`

=============================================================

---

### US-006: Crear grupo de organizaciones

**Resumen de tickets generados:**
- TASK-006-BE: Implementar entidad OrganizationGroup con CRUD completo
- TASK-006-EV-NOTE: OrganizationGroup NO publica eventos independientes (se incluye en OrganizationEvent)

---

#### TASK-006-BE: Implementar entidad OrganizationGroup con CRUD completo

=============================================================
**TICKET ID:** TASK-006-BE  
**EPIC:** Gestión del Portfolio de Organizaciones Clientes  
**USER STORY:** US-006 - Crear grupo de organizaciones  
**COMPONENT:** Backend  
**PRIORITY:** Media  
**ESTIMATION:** 4 horas  
=============================================================

**TÍTULO:**
Implementar entidad OrganizationGroup con CRUD completo

**DESCRIPCIÓN:**
Crear la infraestructura backend para gestionar Grupos de Organizaciones siguiendo el patrón Helix6. Los grupos permiten agrupar organizaciones clientes para facilitar funcionalidades compartidas entre organizaciones del mismo grupo (ej: consolidación de datos, reportes grupales).

**IMPORTANTE:** OrganizationGroup NO tiene campos `IsDeleted` ni `Active`. Los grupos se eliminan automáticamente cuando no tienen organizaciones asociadas (las aplicaciones satélite lo determinan al procesar OrganizationEvents).

**CONTEXTO TÉCNICO:**
- **Framework**: Helix6 sobre .NET 8
- **Sin eventos propios**: El GroupId viaja dentro del OrganizationEvent (ya implementado en TASK-001-EV-PUB)
- **Cascada implícita**: Cuando todas las organizaciones de un grupo cambian de grupo o se desactivan, el grupo queda vacío
- **Auditoría**: Solo campos de creación y modificación (NO tiene AuditDeletionDate)

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] Entidad `OrganizationGroup` creada sin campos IsDeleted/Active
- [ ] ViewModel `OrganizationGroupView` creada
- [ ] Servicio `OrganizationGroupService` con validaciones
- [ ] Endpoints RESTful generados
- [ ] Validación: nombre de grupo único
- [ ] Migración EF Core generada
- [ ] Tests unitarios e integración

**GUÍA DE IMPLEMENTACIÓN:**

**Paso 1: Crear la Entidad OrganizationGroup**

Archivo: `InfoportOneAdmon.DataModel/Entities/OrganizationGroup.cs`

```csharp
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;

namespace InfoportOneAdmon.DataModel.Entities
{
    /// <summary>
    /// Grupo de organizaciones para facilitar funcionalidades compartidas
    /// NOTA: No tiene flag IsDeleted - los grupos se eliminan cuando quedan vacíos
    /// </summary>
    [Table("ORGANIZATION_GROUP")]
    public class OrganizationGroup : IEntityBase
    {
        /// <summary>
        /// Identificador único (PK autonumérica)
        /// </summary>
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }
        
        /// <summary>
        /// Nombre del grupo (debe ser único)
        /// </summary>
        [Required]
        [StringLength(200)]
        public string Name { get; set; }
        
        /// <summary>
        /// Descripción del propósito del grupo
        /// </summary>
        [StringLength(500)]
        public string Description { get; set; }
        
        /// <summary>
        /// Colección de organizaciones que pertenecen a este grupo
        /// </summary>
        public virtual ICollection<Organization> Organizations { get; set; }
        
        // Campos de auditoría Helix6 (SOLO creación y modificación, NO eliminación)
        public int? AuditCreationUser { get; set; }
        public DateTime? AuditCreationDate { get; set; }
        public int? AuditModificationUser { get; set; }
        public DateTime? AuditModificationDate { get; set; }
        
        // NO tiene AuditDeletionDate - los grupos se eliminan físicamente cuando quedan vacíos
    }
}
```

**Paso 2: Configurar Índice Único en DbContext**

Modificar: `InfoportOneAdmon.DataModel/InfoportOneAdmonContext.cs`

```csharp
public DbSet<OrganizationGroup> OrganizationGroups { get; set; }

protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    base.OnModelCreating(modelBuilder);

    // ... configuración de Organization ...

    // Configurar índice único para nombre de grupo
    modelBuilder.Entity<OrganizationGroup>()
        .HasIndex(og => og.Name)
        .IsUnique()
        .HasDatabaseName("UX_OrganizationGroup_Name");

    // Configurar relación Organization -> OrganizationGroup
    modelBuilder.Entity<Organization>()
        .HasOne(o => o.Group)
        .WithMany(og => og.Organizations)
        .HasForeignKey(o => o.GroupId)
        .OnDelete(DeleteBehavior.SetNull); // Si se elimina el grupo, GroupId de orgs pasa a null
}
```

**Paso 3: Crear ViewModel**

Archivo: `InfoportOneAdmon.Entities/Views/OrganizationGroupView.cs`

```csharp
using System.ComponentModel.DataAnnotations;
using Helix6.Base.Application.BaseInterfaces;

namespace InfoportOneAdmon.Entities.Views
{
    /// <summary>
    /// ViewModel para gestión de Grupos de Organizaciones
    /// </summary>
    public class OrganizationGroupView : IViewBase
    {
        public int Id { get; set; }
        
        [Required(ErrorMessage = "El nombre del grupo es obligatorio")]
        [StringLength(200, ErrorMessage = "El nombre no puede exceder 200 caracteres")]
        public string Name { get; set; }
        
        [StringLength(500, ErrorMessage = "La descripción no puede exceder 500 caracteres")]
        public string Description { get; set; }
        
        /// <summary>
        /// Número de organizaciones activas en este grupo (calculado)
        /// </summary>
        public int OrganizationCount { get; set; }
        
        // Campos de auditoría (solo lectura)
        public int? AuditCreationUser { get; set; }
        public DateTime? AuditCreationDate { get; set; }
        public int? AuditModificationUser { get; set; }
        public DateTime? AuditModificationDate { get; set; }
    }
}
```

**Paso 4: Crear Servicio**

Archivo: `InfoportOneAdmon.Services/Services/OrganizationGroupService.cs`

```csharp
using Helix6.Base.Application.Services;
using Helix6.Base.Domain.Repositories;
using InfoportOneAdmon.DataModel.Entities;
using InfoportOneAdmon.Entities.Views;
using Microsoft.Extensions.Logging;

namespace InfoportOneAdmon.Services.Services
{
    /// <summary>
    /// Servicio para gestión de Grupos de Organizaciones
    /// </summary>
    public class OrganizationGroupService : BaseService<OrganizationGroupView, OrganizationGroup, BaseMetadata>
    {
        public OrganizationGroupService(
            ILogger<OrganizationGroupService> logger,
            IRepository<OrganizationGroup> repository)
            : base(logger, repository)
        {
        }

        /// <summary>
        /// Validaciones de negocio
        /// </summary>
        protected override async Task<bool> ValidateView(OrganizationGroupView view, CancellationToken cancellationToken)
        {
            // Validación: Nombre obligatorio
            if (string.IsNullOrWhiteSpace(view.Name))
            {
                AddError("El nombre del grupo es obligatorio");
                return false;
            }

            // Validación: Nombre único
            var nameExists = await Repository.ExistsAsync(
                g => g.Name == view.Name && g.Id != view.Id,
                cancellationToken);
            
            if (nameExists)
            {
                AddError($"Ya existe un grupo con el nombre '{view.Name}'");
                return false;
            }

            return true;
        }

        /// <summary>
        /// Normalización de datos
        /// </summary>
        protected override async Task PreviousActions(OrganizationGroupView view, OrganizationGroup entity, CancellationToken cancellationToken)
        {
            entity.Name = entity.Name?.Trim();
            entity.Description = entity.Description?.Trim();
            
            await base.PreviousActions(view, entity, cancellationToken);
        }

        /// <summary>
        /// NOTA: OrganizationGroup NO publica eventos propios
        /// El GroupId viaja dentro del OrganizationEvent de cada organización
        /// </summary>
        protected override async Task PostActions(OrganizationGroupView view, OrganizationGroup entity, CancellationToken cancellationToken)
        {
            // No publicar eventos - el grupo se comunica implícitamente vía OrganizationEvent
            
            await base.PostActions(view, entity, cancellationToken);
        }
    }
}
```

**Paso 5: Generar Endpoints**

Archivo: `InfoportOneAdmon.Api/Endpoints/OrganizationGroupEndpoints.cs`

```csharp
using Helix6.Base.Api.Endpoints;
using InfoportOneAdmon.Entities.Views;
using InfoportOneAdmon.Services.Services;

namespace InfoportOneAdmon.Api.Endpoints
{
    /// <summary>
    /// Endpoints RESTful para gestión de Grupos de Organizaciones
    /// </summary>
    public static class OrganizationGroupEndpoints
    {
        public static void MapOrganizationGroupEndpoints(this IEndpointRouteBuilder app)
        {
            EndpointHelper.MapCrudEndpoints<OrganizationGroupService, OrganizationGroupView>(
                app,
                "organization-groups",
                "OrganizationGroups");
        }
    }
}
```

Registrar en Program.cs:

```csharp
app.MapOrganizationGroupEndpoints();
```

**Paso 6: Configurar DI**

Modificar: `InfoportOneAdmon.Services/DependencyInjection.cs`

```csharp
services.AddScoped<OrganizationGroupService>();
```

**Paso 7: Generar Migración**

```powershell
dotnet ef migrations add AddOrganizationGroupTable --project ..\InfoportOneAdmon.DataModel --startup-project InfoportOneAdmon.Api
dotnet ef database update
```

**Paso 8: Tests Unitarios**

Archivo: `InfoportOneAdmon.Services.Tests/Services/OrganizationGroupServiceTests.cs`

```csharp
using Xunit;
using Moq;
using FluentAssertions;
using Microsoft.Extensions.Logging;
using Helix6.Base.Domain.Repositories;
using InfoportOneAdmon.Services.Services;
using InfoportOneAdmon.Entities.Views;
using InfoportOneAdmon.DataModel.Entities;
using System.Linq.Expressions;

namespace InfoportOneAdmon.Services.Tests.Services
{
    public class OrganizationGroupServiceTests
    {
        private readonly Mock<ILogger<OrganizationGroupService>> _loggerMock;
        private readonly Mock<IRepository<OrganizationGroup>> _repositoryMock;
        private readonly OrganizationGroupService _service;

        public OrganizationGroupServiceTests()
        {
            _loggerMock = new Mock<ILogger<OrganizationGroupService>>();
            _repositoryMock = new Mock<IRepository<OrganizationGroup>>();
            _service = new OrganizationGroupService(_loggerMock.Object, _repositoryMock.Object);
        }

        [Fact]
        public async Task ValidateView_WithValidData_ReturnsTrue()
        {
            // Arrange
            var view = new OrganizationGroupView
            {
                Name = "Group A",
                Description = "Test group"
            };
            
            _repositoryMock.Setup(r => r.ExistsAsync(
                It.IsAny<Expression<Func<OrganizationGroup, bool>>>(),
                It.IsAny<CancellationToken>()))
                .ReturnsAsync(false);

            // Act
            var result = await _service.ValidateView(view, CancellationToken.None);

            // Assert
            result.Should().BeTrue();
        }

        [Fact]
        public async Task ValidateView_WithDuplicateName_ReturnsFalse()
        {
            // Arrange
            var view = new OrganizationGroupView
            {
                Name = "Existing Group"
            };
            
            _repositoryMock.Setup(r => r.ExistsAsync(
                It.IsAny<Expression<Func<OrganizationGroup, bool>>>(),
                It.IsAny<CancellationToken>()))
                .ReturnsAsync(true);

            // Act
            var result = await _service.ValidateView(view, CancellationToken.None);

            // Assert
            result.Should().BeFalse();
            _service.Errors.Should().Contain(e => e.Contains("Ya existe un grupo con el nombre"));
        }
    }
}
```

**ARCHIVOS A CREAR/MODIFICAR:**
- `InfoportOneAdmon.DataModel/Entities/OrganizationGroup.cs` - Entidad sin IsDeleted
- `InfoportOneAdmon.DataModel/InfoportOneAdmonContext.cs` - Índice único y relación
- `InfoportOneAdmon.Entities/Views/OrganizationGroupView.cs` - ViewModel
- `InfoportOneAdmon.Services/Services/OrganizationGroupService.cs` - Servicio
- `InfoportOneAdmon.Api/Endpoints/OrganizationGroupEndpoints.cs` - Endpoints
- `InfoportOneAdmon.Services/DependencyInjection.cs` - Registro DI
- `InfoportOneAdmon.Api/Program.cs` - Mapeo endpoints
- `InfoportOneAdmon.Services.Tests/Services/OrganizationGroupServiceTests.cs` - Tests

**DEPENDENCIAS:**
Ninguna

**DEFINITION OF DONE:**
- [ ] Entidad OrganizationGroup creada sin AuditDeletionDate
- [ ] Índice único en Name configurado
- [ ] Relación 1:N con Organization configurada
- [ ] Servicio con validación de nombre único
- [ ] Endpoints generados
- [ ] Migración aplicada
- [ ] Tests unitarios >80% cobertura
- [ ] Code review aprobado

**RECURSOS:**
- Arquitectura Backend: `Helix6_Backend_Architecture.md`
- User Story: `userStories.md#us-006`

=============================================================

---

#### TASK-006-EV-NOTE: OrganizationGroup NO publica eventos independientes

=============================================================
**TICKET ID:** TASK-006-EV-NOTE  
**EPIC:** Gestión del Portfolio de Organizaciones Clientes  
**USER STORY:** US-006 - Crear grupo de organizaciones  
**COMPONENT:** Events - Nota Arquitectónica  
**PRIORITY:** Media  
**ESTIMATION:** 0 horas (Solo documentación)  
=============================================================

**TÍTULO:**
Documentar que OrganizationGroup NO publica eventos independientes

**DESCRIPCIÓN:**
Este ticket NO requiere implementación de código. Es una nota arquitectónica que documenta la decisión de NO publicar eventos independientes para `OrganizationGroup`.

**Decisión de diseño:**
- **NO existe** `OrganizationGroupEvent` como evento separado
- El campo `GroupId` viaja dentro del `OrganizationEvent` (ya implementado en TASK-001-EV-PUB)
- Las aplicaciones satélite determinan automáticamente qué grupos existen basándose en los GroupId de las organizaciones que procesan
- Si todas las organizaciones de un grupo cambian de grupo o se desactivan, las apps satélite pueden eliminar el grupo local automáticamente

**Ventajas de este diseño:**
- ✅ Menor número de eventos (menos tráfico en ActiveMQ)
- ✅ Cohesión perfecta: toda la información de una organización está en su evento
- ✅ Sincronización implícita: grupos se crean/eliminan automáticamente
- ✅ No requiere lógica adicional de suscripción en apps satélite

**Ejemplo:**
Cuando se publica `OrganizationEvent` con `GroupId: 10`, las aplicaciones satélite:
1. Procesan la organización
2. Si GroupId=10 no existe localmente, lo crean automáticamente
3. Si todas las organizaciones de GroupId=10 cambian a otro grupo, pueden eliminar el registro del grupo 10

**ARCHIVOS A CREAR:**
- `docs/architecture-decisions/ADR-001-OrganizationGroup-No-Events.md` - Documentar decisión

**Contenido del ADR:**

```markdown
# ADR-001: OrganizationGroup No Publica Eventos Independientes

## Estado
Aceptado

## Contexto
Necesitamos sincronizar grupos de organizaciones con las aplicaciones satélite.

Opciones consideradas:
1. Publicar `OrganizationGroupEvent` independiente
2. Incluir `GroupId` dentro de `OrganizationEvent` (elegida)

## Decisión
No publicar eventos independientes para OrganizationGroup. El campo `GroupId` viaja dentro del `OrganizationEvent`.

## Consecuencias

**Positivas:**
- Menor número de eventos en ActiveMQ Artemis
- Cohesión perfecta: toda info de organización en un solo evento
- Sincronización implícita de grupos
- Simplifica lógica de suscriptores

**Negativas:**
- No se notifica explícitamente cuando se RENOMBRA un grupo
- Las apps satélite deben inferir la eliminación de grupos

**Mitigación:**
- Si se necesita renombrar un grupo, republicar OrganizationEvents de todas sus organizaciones
```

**DEFINITION OF DONE:**
- [ ] Documento ADR creado
- [ ] Decisión comunicada al equipo
- [ ] Actualizada documentación de eventos

**RECURSOS:**
- User Story: `userStories.md#us-006`

=============================================================

---

### US-007: Asignar organizaciones a un grupo

**Resumen de tickets generados:**
- TASK-007-BE: Implementar asignación de GroupId en OrganizationService

---

#### TASK-007-BE: Implementar asignación de GroupId en OrganizationService

=============================================================
**TICKET ID:** TASK-007-BE  
**EPIC:** Gestión del Portfolio de Organizaciones Clientes  
**USER STORY:** US-007 - Asignar organizaciones a un grupo  
**COMPONENT:** Backend  
**PRIORITY:** Media  
**ESTIMATION:** 2 horas  
=============================================================

**TÍTULO:**
Implementar asignación de GroupId en OrganizationService

**DESCRIPCIÓN:**
Modificar `OrganizationService` para permitir asignar/cambiar el `GroupId` de una organización existente. Cuando se modifica el GroupId:
- Se valida que el grupo existe
- Se publica `OrganizationEvent` con el nuevo GroupId
- Las aplicaciones satélite actualizan la asignación de grupo

**CONTEXTO TÉCNICO:**
- La entidad Organization ya tiene campo GroupId (implementado en TASK-001-BE)
- El OrganizationEvent ya incluye GroupId (implementado en TASK-001-EV-PUB)
- Solo necesitamos validación de FK y tests

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] Validación: Si GroupId != null, el grupo debe existir
- [ ] Al cambiar GroupId, se publica evento con nuevo GroupId
- [ ] Tests de asignación de grupo
- [ ] Tests de validación de grupo inexistente

**GUÍA DE IMPLEMENTACIÓN:**

**Paso 1: Añadir Validación de FK en OrganizationService**

Modificar: `InfoportOneAdmon.Services/Services/OrganizationService.cs`

Inyectar repositorio de grupos:

```csharp
private readonly IRepository<OrganizationGroup> _groupRepository;

public OrganizationService(
    ILogger<OrganizationService> logger,
    IRepository<Organization> repository,
    IMessagePublisher messagePublisher,
    IConfiguration configuration,
    IRepository<ModuleAccess> moduleAccessRepository,
    IRepository<OrganizationGroup> groupRepository) // NUEVO
    : base(logger, repository)
{
    _messagePublisher = messagePublisher;
    _configuration = configuration;
    _moduleAccessRepository = moduleAccessRepository;
    _groupRepository = groupRepository;
}
```

Añadir validación en ValidateView:

```csharp
protected override async Task<bool> ValidateView(OrganizationView view, CancellationToken cancellationToken)
{
    // ... validaciones existentes ...

    // Validación: Si se especifica GroupId, verificar que el grupo existe
    if (view.GroupId.HasValue)
    {
        var groupExists = await _groupRepository.ExistsAsync(
            g => g.Id == view.GroupId.Value,
            cancellationToken);
        
        if (!groupExists)
        {
            AddError($"El grupo con ID {view.GroupId.Value} no existe");
            return false;
        }
    }

    return true; // O el resultado de validaciones anteriores
}
```

**Paso 2: Tests de Asignación de Grupo**

Archivo: `InfoportOneAdmon.Services.Tests/Services/OrganizationServiceTests.cs`

```csharp
[Fact]
public async Task ValidateView_WithNonExistentGroupId_ReturnsFalse()
{
    // Arrange
    var groupRepositoryMock = new Mock<IRepository<OrganizationGroup>>();
    groupRepositoryMock.Setup(r => r.ExistsAsync(
        It.IsAny<Expression<Func<OrganizationGroup, bool>>>(),
        It.IsAny<CancellationToken>()))
        .ReturnsAsync(false); // Grupo no existe

    var service = new OrganizationService(
        _loggerMock.Object,
        _repositoryMock.Object,
        Mock.Of<IMessagePublisher>(),
        Mock.Of<IConfiguration>(),
        Mock.Of<IRepository<ModuleAccess>>(),
        groupRepositoryMock.Object);

    var view = new OrganizationView
    {
        Name = "Test",
        Cif = "A11111111",
        ContactEmail = "test@test.com",
        GroupId = 999 // Grupo inexistente
    };

    // Act
    var result = await service.ValidateView(view, CancellationToken.None);

    // Assert
    result.Should().BeFalse();
    service.Errors.Should().Contain(e => e.Contains("grupo con ID 999 no existe"));
}

[Fact]
public async Task ValidateView_WithExistentGroupId_ReturnsTrue()
{
    // Arrange
    var groupRepositoryMock = new Mock<IRepository<OrganizationGroup>>();
    groupRepositoryMock.Setup(r => r.ExistsAsync(
        It.IsAny<Expression<Func<OrganizationGroup, bool>>>(),
        It.IsAny<CancellationToken>()))
        .ReturnsAsync(true); // Grupo existe

    _repositoryMock.Setup(r => r.ExistsAsync(
        It.IsAny<Expression<Func<Organization, bool>>>(),
        It.IsAny<CancellationToken>()))
        .ReturnsAsync(false); // CIF no duplicado

    var service = new OrganizationService(
        _loggerMock.Object,
        _repositoryMock.Object,
        Mock.Of<IMessagePublisher>(),
        Mock.Of<IConfiguration>(),
        Mock.Of<IRepository<ModuleAccess>>(),
        groupRepositoryMock.Object);

    var view = new OrganizationView
    {
        Name = "Test",
        Cif = "A11111111",
        ContactEmail = "test@test.com",
        GroupId = 10 // Grupo existente
    };

    // Act
    var result = await service.ValidateView(view, CancellationToken.None);

    // Assert
    result.Should().BeTrue();
}
```

**Paso 3: Test de Integración**

Archivo: `InfoportOneAdmon.Api.Tests/Endpoints/OrganizationEndpointsTests.cs`

```csharp
[Fact]
public async Task Create_WithGroupId_AssignsGroupSuccessfully()
{
    // Arrange: Crear grupo primero
    var group = new OrganizationGroupView { Name = "Test Group" };
    var groupResponse = await _client.PostAsJsonAsync("/organization-groups", group);
    var createdGroup = await groupResponse.Content.ReadFromJsonAsync<OrganizationGroupView>();

    // Crear organización con GroupId
    var organization = new OrganizationView
    {
        Name = "Org in Group",
        Cif = "G11111111",
        ContactEmail = "org@test.com",
        GroupId = createdGroup.Id
    };

    // Act
    var response = await _client.PostAsJsonAsync("/organizations", organization);

    // Assert
    response.StatusCode.Should().Be(System.Net.HttpStatusCode.Created);
    var created = await response.Content.ReadFromJsonAsync<OrganizationView>();
    created.GroupId.Should().Be(createdGroup.Id);
}

[Fact]
public async Task Update_ChangeGroupId_UpdatesSuccessfully()
{
    // Arrange: Crear dos grupos y una organización
    var group1 = new OrganizationGroupView { Name = "Group 1" };
    var group1Response = await _client.PostAsJsonAsync("/organization-groups", group1);
    var createdGroup1 = await group1Response.Content.ReadFromJsonAsync<OrganizationGroupView>();

    var group2 = new OrganizationGroupView { Name = "Group 2" };
    var group2Response = await _client.PostAsJsonAsync("/organization-groups", group2);
    var createdGroup2 = await group2Response.Content.ReadFromJsonAsync<OrganizationGroupView>();

    var organization = new OrganizationView
    {
        Name = "Moving Org",
        Cif = "M11111111",
        ContactEmail = "moving@test.com",
        GroupId = createdGroup1.Id
    };
    var orgResponse = await _client.PostAsJsonAsync("/organizations", organization);
    var createdOrg = await orgResponse.Content.ReadFromJsonAsync<OrganizationView>();

    // Cambiar de Group 1 a Group 2
    createdOrg.GroupId = createdGroup2.Id;

    // Act
    var updateResponse = await _client.PutAsJsonAsync($"/organizations/{createdOrg.Id}", createdOrg);

    // Assert
    updateResponse.StatusCode.Should().Be(System.Net.HttpStatusCode.OK);
    var updated = await updateResponse.Content.ReadFromJsonAsync<OrganizationView>();
    updated.GroupId.Should().Be(createdGroup2.Id);
}
```

**ARCHIVOS A MODIFICAR:**
- `InfoportOneAdmon.Services/Services/OrganizationService.cs` - Añadir validación de GroupId
- `InfoportOneAdmon.Services.Tests/Services/OrganizationServiceTests.cs` - Tests de validación
- `InfoportOneAdmon.Api.Tests/Endpoints/OrganizationEndpointsTests.cs` - Tests de integración

**DEPENDENCIAS:**
- TASK-001-BE - OrganizationService existe
- TASK-006-BE - OrganizationGroup existe

**DEFINITION OF DONE:**
- [ ] Validación de FK GroupId implementada
- [ ] Tests unitarios de validación pasando
- [ ] Tests de integración de asignación de grupo pasando
- [ ] Test de cambio de grupo pasando
- [ ] Code review aprobado

**RECURSOS:**
- User Story: `userStories.md#us-007`

=============================================================

---

### US-008: Consultar auditoría de cambios en organización

**Resumen de tickets generados:**
- TASK-008-BE: Implementar endpoint de consulta de auditoría por entidad

---

#### TASK-008-BE: Implementar endpoint de consulta de auditoría por entidad

=============================================================
**TICKET ID:** TASK-008-BE  
**EPIC:** Gestión del Portfolio de Organizaciones Clientes  
**USER STORY:** US-008 - Consultar auditoría de cambios en organización  
**COMPONENT:** Backend  
**PRIORITY:** Media  
**ESTIMATION:** 4 horas  
=============================================================

**TÍTULO:**
Implementar endpoint de consulta de auditoría por entidad

**DESCRIPCIÓN:**
Crear endpoint personalizado que permita consultar el historial completo de cambios realizados en una organización específica. El endpoint debe retornar:
- Fecha y hora de cada cambio
- Usuario que realizó el cambio
- Acción realizada (Create, Update, Delete)
- Valores anteriores y nuevos (si aplica)

Esto permite auditorías de cumplimiento (ISO 27001, GDPR) y trazabilidad completa.

**CONTEXTO TÉCNICO:**
- Los campos de auditoría Helix6 (AuditCreationDate, AuditModificationDate, etc.) ya se populan automáticamente
- La tabla AUDIT_LOG puede almacenar cambios detallados (si se implementa en TASK-002-BE extendido)
 - Se ha añadido un scaffold de la entidad `AuditLog` en `InfoportOneAdmon.DataModel/Entities/AuditLog.cs` para comenzar la implementación de la persistencia detallada
- Este endpoint consulta tanto los campos de auditoría de la entidad como registros de AUDIT_LOG

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] Endpoint POST /organizations/{id}/audit implementado con KendoFilter
- [ ] Retorna GridDataResult con paginación Kendo
- [ ] Filtrado, ordenación y paginación server-side mediante KendoFilter
- [ ] Incluye: fecha, usuario, acción, valores before/after
- [ ] Tests de integración

**GUÍA DE IMPLEMENTACIÓN:**

**Paso 1: Crear ViewModel de Auditoría**

Archivo: `InfoportOneAdmon.Entities/Views/AuditLogView.cs`

```csharp
namespace InfoportOneAdmon.Entities.Views
{
    /// <summary>
    /// ViewModel para consulta de logs de auditoría
    /// </summary>
    public class AuditLogView
    {
        public int Id { get; set; }
        public string EntityType { get; set; }
        public int EntityId { get; set; }
        public string Action { get; set; } // Create, Update, Delete
        public string OldValue { get; set; } // JSON con valores anteriores
        public string NewValue { get; set; } // JSON con valores nuevos
        public DateTime Timestamp { get; set; }
        public int? UserId { get; set; }
        public string UserName { get; set; } // Para visualización
    }
}
```

**Paso 2: Crear Servicio de Auditoría**

Archivo: `InfoportOneAdmon.Services/Services/AuditLogService.cs`

```csharp
using Helix6.Base.Domain.Repositories;
using InfoportOneAdmon.DataModel.Entities;
using InfoportOneAdmon.Entities.Views;
using Microsoft.EntityFrameworkCore;
using Helix6.Kendo.Models;
using Helix6.Kendo.Extensions;

namespace InfoportOneAdmon.Services.Services
{
    /// <summary>
    /// Servicio para consulta de logs de auditoría
    /// </summary>
    public class AuditLogService
    {
        private readonly IRepository<AuditLog> _auditLogRepository;

        public AuditLogService(IRepository<AuditLog> auditLogRepository)
        {
            _auditLogRepository = auditLogRepository;
        }

        /// <summary>
        /// Obtiene el historial de auditoría de una entidad específica con KendoFilter
        /// </summary>
        public async Task<GridDataResult> GetEntityAuditHistory(
            string entityType,
            int entityId,
            KendoFilter filter,
            CancellationToken cancellationToken = default)
        {
            var query = _auditLogRepository.GetQuery()
                .Where(al => al.EntityType == entityType && al.EntityId == entityId);

            // Aplicar filtrado, ordenación y paginación de Kendo
            var result = await query.ToKendoResult(filter, al => new AuditLogView
            {
                Id = al.Id,
                EntityType = al.EntityType,
                EntityId = al.EntityId,
                Action = al.Action,
                OldValue = al.OldValue,
                NewValue = al.NewValue,
                Timestamp = al.AuditCreationDate.Value,
                UserId = al.AuditCreationUser,
                UserName = $"Usuario {al.AuditCreationUser}" // TODO: Join con tabla de usuarios
            }, cancellationToken);

            return result;
        }
    }
}
```

**Paso 3: Crear Endpoint Personalizado**

Modificar: `InfoportOneAdmon.Api/Endpoints/OrganizationEndpoints.cs`

```csharp
using Microsoft.AspNetCore.Mvc;

public static void MapOrganizationEndpoints(this IEndpointRouteBuilder app)
{
    // Endpoints CRUD estándar
    EndpointHelper.MapCrudEndpoints<OrganizationService, OrganizationView>(
        app,
        "organizations",
        "Organizations");

    // Endpoint personalizado de auditoría
    var group = app.MapGroup("organizations")
        .WithTags("Organizations")
        .RequireAuthorization();

    group.MapPost("/{id}/audit", async (
        [FromRoute] int id,
        [FromBody] KendoFilter filter,
        [FromServices] AuditLogService auditLogService,
        CancellationToken ct) =>
    {
        var auditHistory = await auditLogService.GetEntityAuditHistory(
            "Organization",
            id,
            filter,
            ct);

        return Results.Ok(auditHistory);
    })
    .WithName("GetOrganizationAuditHistory")
    .WithSummary("Obtiene el historial de auditoría de una organización")
    .WithDescription("Retorna todos los cambios realizados en la organización con paginación y filtros Kendo")
    .Produces<GridDataResult>(StatusCodes.Status200OK)
    .Produces(StatusCodes.Status401Unauthorized)
    .Produces(StatusCodes.Status404NotFound);
}
```

**Paso 4: Configurar DI**

Modificar: `InfoportOneAdmon.Services/DependencyInjection.cs`

```csharp
services.AddScoped<AuditLogService>();
```

**Paso 5: Tests de Integración**

Archivo: `InfoportOneAdmon.Api.Tests/Endpoints/OrganizationAuditEndpointsTests.cs`

```csharp
using Xunit;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;
using System.Net.Http.Json;
using InfoportOneAdmon.Entities.Views;

namespace InfoportOneAdmon.Api.Tests.Endpoints
{
    public class OrganizationAuditEndpointsTests : IClassFixture<WebApplicationFactory<Program>>
    {
        private readonly HttpClient _client;

        public OrganizationAuditEndpointsTests(WebApplicationFactory<Program> factory)
        {
            _client = factory.CreateClient();
        }

        [Fact]
        public async Task GetAuditHistory_ReturnsCreationRecord()
        {
            // Arrange: Crear organización
            var organization = new OrganizationView
            {
                Name = "Audited Org",
                Cif = "A77777777",
                ContactEmail = "audit@test.com"
            };
            var createResponse = await _client.PostAsJsonAsync("/organizations", organization);
            var created = await createResponse.Content.ReadFromJsonAsync<OrganizationView>();

            // Act: Consultar auditoría
            var auditResponse = await _client.GetAsync($"/organizations/{created.Id}/audit?page=1&pageSize=10");

            // Assert
            auditResponse.EnsureSuccessStatusCode();
            var auditHistory = await auditResponse.Content.ReadFromJsonAsync<List<AuditLogView>>();
            
            auditHistory.Should().NotBeNull();
            auditHistory.Should().HaveCountGreaterOrEqualTo(1);
            auditHistory[0].EntityType.Should().Be("Organization");
            auditHistory[0].EntityId.Should().Be(created.Id);
            auditHistory[0].Action.Should().Be("Create");
        }

        [Fact]
        public async Task GetAuditHistory_AfterUpdate_ReturnsMultipleRecords()
        {
            // Arrange: Crear y modificar organización
            var organization = new OrganizationView
            {
                Name = "Original Name",
                Cif = "A66666666",
                ContactEmail = "original@test.com"
            };
            var createResponse = await _client.PostAsJsonAsync("/organizations", organization);
            var created = await createResponse.Content.ReadFromJsonAsync<OrganizationView>();

            // Modificar
            created.Name = "Updated Name";
            await _client.PutAsJsonAsync($"/organizations/{created.Id}", created);

            // Act
            var auditResponse = await _client.GetAsync($"/organizations/{created.Id}/audit?page=1&pageSize=10");

            // Assert
            var auditHistory = await auditResponse.Content.ReadFromJsonAsync<List<AuditLogView>>();
            
            auditHistory.Should().HaveCountGreaterOrEqualTo(2); // Create + Update
            auditHistory[0].Action.Should().Be("Update"); // Más reciente
            auditHistory[1].Action.Should().Be("Create");
        }

        [Fact]
        public async Task GetAuditHistory_WithPagination_ReturnsCorrectPage()
        {
            // Arrange: Crear organización y modificarla varias veces
            var organization = new OrganizationView
            {
                Name = "Multi Update Org",
                Cif = "A55555555",
                ContactEmail = "multi@test.com"
            };
            var createResponse = await _client.PostAsJsonAsync("/organizations", organization);
            var created = await createResponse.Content.ReadFromJsonAsync<OrganizationView>();

            // Realizar múltiples updates
            for (int i = 0; i < 5; i++)
            {
                created.Name = $"Update {i}";
                await _client.PutAsJsonAsync($"/organizations/{created.Id}", created);
            }

            // Act: Solicitar página 2 con tamaño 2
            var auditResponse = await _client.GetAsync($"/organizations/{created.Id}/audit?page=2&pageSize=2");

            // Assert
            var auditHistory = await auditResponse.Content.ReadFromJsonAsync<List<AuditLogView>>();
            auditHistory.Should().HaveCount(2); // Página 2 con 2 registros
        }
    }
}
```

**ARCHIVOS A CREAR/MODIFICAR:**
- `InfoportOneAdmon.Entities/Views/AuditLogView.cs` - ViewModel
- `InfoportOneAdmon.Services/Services/AuditLogService.cs` - Servicio de consulta
- `InfoportOneAdmon.Api/Endpoints/OrganizationEndpoints.cs` - Endpoint personalizado
- `InfoportOneAdmon.Services/DependencyInjection.cs` - Registro DI
- `InfoportOneAdmon.Api.Tests/Endpoints/OrganizationAuditEndpointsTests.cs` - Tests

**DEPENDENCIAS:**
- TASK-001-BE - Organización existe
- Tabla AUDIT_LOG debe existir (crear migración si es necesario)

**DEFINITION OF DONE:**
- [ ] AuditLogView creado
- [ ] AuditLogService implementado con paginación
- [ ] Endpoint GET /organizations/{id}/audit funcional
- [ ] Tests de integración pasando
- [ ] Paginación validada
- [ ] Documentación Swagger actualizada
- [ ] Code review aprobado

**RECURSOS:**
- User Story: `userStories.md#us-008`

=============================================================

**Épica 1 completada ✅**

---

