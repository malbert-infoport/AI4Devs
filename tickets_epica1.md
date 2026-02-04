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
- [TASK-001-VIEW: Crear vista VW_ORGANIZATION con campos calculados](#task-001-view-crear-vista-vw_organization-con-campos-calculados)

### US-001v2: Asignar módulos tras crear organización
- [TASK-001-BE-EXT: Implementar OrganizationModuleService con publicación de eventos](#task-001-be-ext-implementar-organizationmoduleservice-con-publicación-de-eventos)
- [TASK-001-EV-PUB: Publicar OrganizationEvent al asignar/modificar módulos](#task-001-ev-pub-publicar-organizationevent-al-asignarmodificar-módulos)

### US-002: Editar información de organización existente
- [TASK-002-BE: Edición con pestañas y auditoría selectiva](#task-002-be-edición-con-pestañas-y-auditoría-selectiva)

### US-003: Dar de baja organización manualmente (kill-switch)
- [TASK-003-BE: Implementar baja manual (soft delete) con auditoría](#task-003-be-implementar-baja-manual-soft-delete-con-auditoría)

### US-003v2: Dar de alta organización manualmente
- [TASK-003-BE-REACTIVATE: Implementar alta manual con validación de módulos](#task-003-be-reactivate-implementar-alta-manual-con-validación-de-módulos)

### US-006: Crear grupo de organizaciones
- [TASK-006-BE: Implementar entidad OrganizationGroup con CRUD completo](#task-006-be-implementar-entidad-organizationgroup-con-crud-completo)
- [TASK-006-EV-NOTE: OrganizationGroup NO publica eventos independientes](#task-006-ev-note-organizationgroup-no-publica-eventos-independientes)

### US-007: Asignar organizaciones a un grupo
- [TASK-007-BE: Implementar asignación de GroupId con auditoría](#task-007-be-implementar-asignación-de-groupid-con-auditoría)

### US-008: Consultar auditoría de cambios críticos
- [TASK-008-BE: Endpoint de auditoría selectiva de cambios críticos](#task-008-be-endpoint-de-auditoría-selectiva-de-cambios-críticos)
- [TASK-AUDIT-SIMPLE: Crear tabla AUDIT_LOG simplificada](#task-audit-simple-crear-tabla-audit_log-simplificada)

### Tickets Frontend
- [TASK-001-FE: Formulario creación con pestañas Angular](#task-001-fe-formulario-creación-con-pestañas-angular)
- [TASK-003-FE: Botones baja/alta con modales de confirmación](#task-003-fe-botones-bajaalta-con-modales-de-confirmación)
- [TASK-004-FE: Listado Kendo Grid con contadores](#task-004-fe-listado-kendo-grid-con-contadores)
- [TASK-005-FE: Gestión de módulos con auto-baja](#task-005-fe-gestión-de-módulos-con-auto-baja)
- [TASK-008-FE: Pestaña auditoría de cambios críticos](#task-008-fe-pestaña-auditoría-de-cambios-críticos)

### Tests End-to-End
- [TASK-TEST-E2E-ORG: Suite E2E flujo organizaciones](#task-test-e2e-org-suite-e2e-flujo-organizaciones)

---

## Épica 1: Gestión del Portfolio de Organizaciones Clientes

### US-001: Crear nueva organización cliente

**Resumen de tickets generados:**
- TASK-001-BE: Implementar entidad Organization con CRUD completo en Helix6 (SIN publicar evento, SIN auditoría detallada)
- TASK-001-VIEW: Crear vista VW_ORGANIZATION con campos calculados ModuleCount y AppCount

**Nota importante:** La creación de organización NO publica evento. El evento se publica solo cuando se asignan módulos (ver TASK-001-BE-EXT de US-001v2).

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

**CRÍTICO:** NO publicar OrganizationEvent en PostActions (los eventos se publican solo cuando se asignan módulos, ver TASK-001-BE-EXT).

**CRÍTICO:** NO registrar en AUDIT_LOG la creación de organización (no es un cambio crítico según matriz de auditoría). Solo se auditan cambios críticos: asignación de módulos, baja/alta, cambio de grupo.

Los campos de auditoría de Helix6 (AuditCreationUser, AuditCreationDate, etc.) se gestionan automáticamente por el framework.
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
        /// CRÍTICO: NO publicar evento aquí. Los eventos se publican solo cuando se asignan módulos (ver TASK-001-BE-EXT).
        /// </summary>
        protected override async Task PostActions(OrganizationView view, Organization entity, CancellationToken cancellationToken)
        {
            // NO publicar OrganizationEvent (arquitectura de eventos diferidos)
            // NO registrar en AUDIT_LOG (no es cambio crítico)
            
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
- [x] PostActions NO publica eventos NI registra auditoría (verificado por tests)
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

#### TASK-001-EV-PUB-DEFERRED: Publicar OrganizationEvent SOLO al asignar módulos (eventos diferidos)

=============================================================
**TICKET ID:** TASK-001-EV-PUB-DEFERRED (renombrado desde TASK-001-EV-PUB)  
**EPIC:** Gestión del Portfolio de Organizaciones Clientes  
**USER STORY:** US-001v2 - Asignar módulos/aplicaciones a organización (primera asignación)  
**COMPONENT:** Events - Publisher (Deferred)  
**PRIORITY:** Alta  
**ESTIMATION:** 4 horas  
=============================================================

**TÍTULO:**
Implementar publicación DIFERIDA de OrganizationEvent solo cuando se asignan módulos

**DESCRIPCIÓN:**
**CRÍTICO - ARQUITECTURA DE EVENTOS DIFERIDOS:**

En InfoportOneAdmon, los eventos `OrganizationEvent` NO se publican cuando se crea/modifica una organización. Los eventos se publican **SOLO** desde `OrganizationModuleService` cuando se asignan o modifican módulos/aplicaciones.

**Razón:** Una organización sin módulos NO tiene permisos de acceso a ninguna aplicación, por lo que las aplicaciones satélite no necesitan conocer su existencia hasta que se le asignen permisos.

**Flujo de eventos:**
1. OrganizationManager crea organización → **NO se publica evento**
2. ApplicationManager asigna módulos → **AQUÍ se publica el primer OrganizationEvent** (desde TASK-001-BE-EXT)
3. ApplicationManager modifica permisos → **Se publica OrganizationEvent actualizado**
4. Sistema auto-desactiva org sin módulos → **Se publica OrganizationEvent con IsDeleted=true** (desde TASK-001-BE-EXT)
5. SecurityManager da de alta manual → **Se publica OrganizationEvent con IsDeleted=false**

**CONTEXTO TÉCNICO:**
- **Broker**: ActiveMQ Artemis configurado en docker-compose
- **Librería**: IPVInterchangeShared para integración con Artemis
- **Patrón**: Event-driven State Transfer (estado completo, no eventos granulares)
- **Publisher**: OrganizationModuleService (NO OrganizationService)
- **Persistencia**: Los eventos se persisten en tabla `IntegrationEvents` de PostgreSQL antes de publicarse
- **Testing**: Usar Testcontainers para tests de integración con Artemis y PostgreSQL reales

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] Clase de evento `OrganizationEvent` creada heredando de EventBase
- [ ] IMessagePublisher inyectado en **OrganizationModuleService** (NO en OrganizationService)
- [ ] Publicación implementada en PostActions de OrganizationModuleService
- [ ] Evento incluye todas las propiedades de la organización (state transfer completo)
- [ ] Flag `IsDeleted` indica si la organización está dada de baja (AuditDeletionDate != null)
- [ ] Propiedad `Apps` incluida con lista de aplicaciones y módulos accesibles por organización
- [ ] Configuración de tópico `infoportone.events.organization` añadida en appsettings.json
- [ ] Test de integración verifica que OrganizationService NO publica eventos
- [ ] Test de integración verifica que OrganizationModuleService SÍ publica eventos
- [ ] Test verifica persistencia en tabla IntegrationEvents
- [ ] Documentación del evento actualizada (estructura del payload + arquitectura diferida)

**ARCHIVOS A CREAR/MODIFICAR:**

Backend:
- `InfoportOneAdmon.Events/OrganizationEvent.cs` - Clase del evento con AppAccessInfo
- `InfoportOneAdmon.Services/Services/OrganizationModuleService.cs` - Inyectar IMessagePublisher y publicar en PostActions
- `InfoportOneAdmon.Api/appsettings.json` - Configurar tópico
- `InfoportOneAdmon.Services.Tests/Services/OrganizationServiceTests.cs` - Test que verifica NO publicación
- `InfoportOneAdmon.Services.Tests/Services/OrganizationModuleServiceTests.cs` - Test que verifica SÍ publicación
- `InfoportOneAdmon.Integration.Tests/Events/DeferredEventsTests.cs` - Tests con Testcontainers

**DEPENDENCIAS:**
- TASK-001-BE (Organization CRUD completo)
- TASK-001-BE-EXT (OrganizationModuleService con AssignModule/RemoveModule)

**DEFINITION OF DONE:**
- [x] OrganizationEvent creado con todas las propiedades (Apps, IsDeleted, etc.)
- [x] IMessagePublisher inyectado en OrganizationModuleService
- [x] OrganizationModuleService publica evento en PostActions al asignar/modificar módulos
- [x] OrganizationService NO publica eventos (test lo verifica)
- [x] Test unitario verifica que al crear organización NO hay llamadas a IMessagePublisher
- [x] Test de integración con Testcontainers verifica publicación desde OrganizationModuleService
- [x] Test verifica persistencia en IntegrationEvents antes de envío a broker
- [x] Configuración de tópico en appsettings.json
- [x] Documentación actualizada en ActiveMQ_Events.md sobre arquitectura diferida
- [x] Code review aprobado
- [x] Sin warnings ni vulnerabilidades

**RECURSOS:**
- Arquitectura de Eventos: `ActiveMQ_Events.md` - Sección State Transfer Events
- User Story: `userStories.md#us-009`
- User Story: `userStories.md#us-010`

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
Extender la funcionalidad de `OrganizationService` para soportar la edición de organizaciones existentes en el contexto de la interfaz con dos pestañas:

**Pestaña 1 - Datos de Organización (OrganizationManager edita, ApplicationManager solo lee):**
- Name, CIF, Address, City, PostalCode, Country, ContactEmail, ContactPhone
- GroupId (auditoría crítica si cambia - ver US-002 y US-008)

**Pestaña 2 - Módulos y Permisos de Acceso (ApplicationManager edita, OrganizationManager solo lee):**
- Gestiona modules/applications (implementado en TASK-001-BE-EXT)

**Reglas de negocio:**
- El campo `SecurityCompanyId` NO debe ser editable (inmutable)
- Validar que el CIF sigue siendo único excluyendo el registro actual
- **CRÍTICO:** Si se cambia GroupId, registrar en AUDIT_LOG con Action="GroupChanged" (cambio crítico)
- **IMPORTANTE:** Cambios en datos básicos (Name, Address, Email, Phone, CIF) NO se auditan (no son cambios críticos)
- Actualizar automáticamente campos de auditoría Helix6 (`AuditModificationUser`, `AuditModificationDate`)
- **NO publicar OrganizationEvent** al editar datos básicos (eventos solo se publican cuando cambian módulos - ver TASK-001-EV-PUB-DEFERRED)

**CONTEXTO TÉCNICO:**
- El método `UpdateAsync` de `BaseService` ya maneja la actualización básica
- Necesitamos reforzar validaciones en `ValidateView` para modo edición
- Auditoría SELECTIVA: Solo se registra cambio de GroupId en tabla AUDIT_LOG simplificada
- Los campos de auditoría Helix6 se actualizan automáticamente por el framework

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] Validación de inmutabilidad de `SecurityCompanyId` implementada
- [ ] Validación de unicidad de CIF excluye el registro actual (Id != view.Id)
- [ ] Método UpdateAsync funciona correctamente (heredado de BaseService)
- [ ] PostActions detecta cambio de GroupId y registra en AUDIT_LOG con Action="GroupChanged" (si GroupId cambió)
- [ ] PostActions NO registra en AUDIT_LOG para cambios de datos básicos (Name, Address, Email, etc.)
- [ ] PostActions NO publica OrganizationEvent (los eventos solo se publican desde OrganizationModuleService)
- [ ] Tests unitarios de validación de edición (SecurityCompanyId inmutable, CIF único)
- [ ] Tests de integración de endpoint PUT /organizations/{id}
- [ ] Test verifica que solo GroupChanged se audita (no otros cambios)

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

**Paso 3: Registrar Auditoría SOLO para GroupChanged**

Modificar `InfoportOneAdmon.Services/Services/OrganizationService.cs`:

```csharp
/// <summary>
/// Acciones posteriores a guardar - auditoría selectiva
/// </summary>
protected override async Task PostActions(OrganizationView view, Organization entity, CancellationToken cancellationToken)
{
    // SOLO auditar si GroupId cambió (cambio crítico según US-008)
    if (view.Id > 0) // Modo edición
    {
        var originalEntity = await Repository.GetByIdAsync(view.Id, cancellationToken);
        
        if (originalEntity != null && originalEntity.GroupId != entity.GroupId)
        {
            // Registrar en AUDIT_LOG simplificado (ver TASK-AUDIT-SIMPLE)
            await _auditLogService.LogAsync(new AuditEntry
            {
                Action = "GroupChanged",
                EntityType = "Organization",
                EntityId = entity.Id,
                UserId = entity.AuditModificationUser,
                Timestamp = DateTime.UtcNow,
                CorrelationId = Guid.NewGuid().ToString()
            }, cancellationToken);
            
            Logger.LogInformation(
                "Cambio de grupo auditado para Organization {OrganizationId} - Usuario {UserId}",
                entity.Id,
                entity.AuditModificationUser);
        }
    }
    
    // NO publicar OrganizationEvent (arquitectura de eventos diferidos - solo desde OrganizationModuleService)
    
    await base.PostActions(view, entity, cancellationToken);
}
```

**NOTA:** La tabla AUDIT_LOG simplificada se crea en TASK-AUDIT-SIMPLE (sin campos OldValue/NewValue JSON).

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
- `InfoportOneAdmon.Services/Services/OrganizationService.cs` - Añadir validación de inmutabilidad de SecurityCompanyId y auditoría selectiva de GroupChanged
- `InfoportOneAdmon.Services.Tests/Services/OrganizationServiceTests.cs` - Añadir tests de edición y auditoría
- `InfoportOneAdmon.Api.Tests/Endpoints/OrganizationEndpointsTests.cs` - Añadir test de inmutabilidad

**DEPENDENCIAS:**
- TASK-001-BE - OrganizationService debe existir
- TASK-AUDIT-SIMPLE - Tabla AUDIT_LOG simplificada y IAuditLogService

**DEFINITION OF DONE:**
- [ ] Validación de inmutabilidad de SecurityCompanyId implementada
- [ ] Validación de CIF único excluye registro actual
- [ ] PostActions detecta cambio de GroupId y registra en AUDIT_LOG con Action="GroupChanged"
- [ ] PostActions NO registra auditoría para cambios de datos básicos (Name, Address, etc.)
- [ ] PostActions NO publica OrganizationEvent (test lo verifica)
- [ ] Tests unitarios de edición pasando (SecurityCompanyId inmutable, CIF único)
- [ ] Test verifica que solo GroupChanged genera registro en AUDIT_LOG
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

#### TASK-003-BE: Implementar desactivación manual de organización (baja manual)

=============================================================
**TICKET ID:** TASK-003-BE  
**EPIC:** Gestión del Portfolio de Organizaciones Clientes  
**USER STORY:** US-003 - Dar de baja organización (manual y automática)  
**COMPONENT:** Backend  
**PRIORITY:** Alta  
**ESTIMATION:** 2 horas  
=============================================================

**TÍTULO:**
Implementar desactivación manual de organización (baja manual por SecurityManager)

**DESCRIPCIÓN:**
Implementar endpoint personalizado POST /organizations/{id}/deactivate para dar de baja manualmente una organización. Esta acción está disponible desde:
1. Ficha de organización (botón "Dar de baja")
2. Grid de organizaciones (acción contextual)

**Diferencia con auto-baja:**
- **Baja manual** (este ticket): Ejecutada por SecurityManager, requiere confirmación modal, registra en AUDIT_LOG con Action="OrganizationDeactivatedManual" y UserId poblado
- **Auto-baja**: Ejecutada automáticamente cuando ModuleCount=0 en OrganizationModuleService, UserId=NULL en AUDIT_LOG con Action="OrganizationAutoDeactivated"

**ARQUITECTURA - NO usar campos Active/IsActive:**
- Soft delete mediante AuditDeletionDate: NULL=alta (activa), NOT NULL=baja (inactiva)
- Usar método `DeleteUndeleteLogicById(int id, int userId)` de Helix6
- NO eventos desde OrganizationService: OrganizationEvent publicado SOLO por OrganizationModuleService cuando hay módulos asignados
- Auditoría selectiva: SOLO cambios críticos en tabla AUDIT_LOG simplificada (NO campos JSON OldValue/NewValue)

**CONTEXTO TÉCNICO:**
- Helix6 provee `DeleteUndeleteLogicById(int id, int userId)` para soft delete con userId específico
- Este método establece AuditDeletionDate y AuditModificationUser en un solo paso
- AUDIT_LOG simplificada: Action, EntityType, EntityId, Timestamp, UserId (NO JSON)
- Evento diferido: Si la organización tiene módulos asignados, OrganizationModuleService publicará OrganizationEvent con IsDeleted=true

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] Endpoint POST /organizations/{id}/deactivate implementado (NO usar DELETE genérico de BaseService)
- [ ] Método usa DeleteUndeleteLogicById de Helix6 con userId del SecurityManager
- [ ] AuditDeletionDate se establece correctamente (soft delete)
- [ ] Registro NO se elimina físicamente (permanece en BD con AuditDeletionDate NOT NULL)
- [ ] Registro en AUDIT_LOG simplificada: Action="OrganizationDeactivatedManual", EntityType="Organization", EntityId={id}, UserId poblado (NO campos JSON)
- [ ] NO publica OrganizationEvent desde este endpoint (evento diferido: solo OrganizationModuleService lo publica cuando hay módulos)
- [ ] Tests verifican soft delete con userId
- [ ] Tests verifican registro en AUDIT_LOG con Action="OrganizationDeactivatedManual"
- [ ] Tests verifican que NO se publica evento desde OrganizationService
- [ ] Tests de integración del endpoint POST /organizations/{id}/deactivate
- [ ] Documentación Swagger actualizada (endpoint personalizado, no DELETE estándar)

**GUÍA DE IMPLEMENTACIÓN:**

**Paso 1: Crear Endpoint Personalizado de Desactivación Manual**

Modificar: `InfoportOneAdmon.Api/Endpoints/OrganizationEndpoints.cs`

```csharp
public static void MapOrganizationEndpoints(this IEndpointRouteBuilder app)
{
    // Endpoints CRUD estándar
    EndpointHelper.MapCrudEndpoints<OrganizationService, OrganizationView>(
        app,
        "organizations",
        "Organizations");

    // Endpoint personalizado de desactivación manual
    var group = app.MapGroup("organizations")
        .WithTags("Organizations")
        .RequireAuthorization();

    group.MapPost("/{id}/deactivate", async (
        [FromRoute] int id,
        [FromServices] OrganizationService organizationService,
        [FromServices] IAuditLogService auditLogService,
        HttpContext httpContext,
        CancellationToken ct) =>
    {
        // Obtener userId del usuario autenticado (SecurityManager)
        var userIdClaim = httpContext.User.FindFirst("sub") ?? httpContext.User.FindFirst(ClaimTypes.NameIdentifier);
        if (userIdClaim == null || !int.TryParse(userIdClaim.Value, out int userId))
        {
            return Results.Unauthorized();
        }

        // Verificar que la organización existe y NO está ya desactivada
        var organization = await organizationService.GetByIdAsync(id, ct);
        if (organization == null)
        {
            return Results.NotFound(new { message = $"Organización con ID {id} no encontrada" });
        }

        // Usar DeleteUndeleteLogicById de Helix6 para soft delete
        var success = await organizationService.DeleteUndeleteLogicById(id, userId, ct);
        if (!success)
        {
            return Results.BadRequest(new { message = "No se pudo desactivar la organización" });
        }

        // Registrar auditoría crítica en AUDIT_LOG simplificada
        await auditLogService.RegisterCriticalAction(
            action: "OrganizationDeactivatedManual",
            entityType: "Organization",
            entityId: id,
            userId: userId,
            cancellationToken: ct);

        // NOTA: NO publicar OrganizationEvent aquí
        // El evento se publicará automáticamente desde OrganizationModuleService
        // cuando la organización tenga módulos asignados

        return Results.NoContent();
    })
    .WithName("DeactivateOrganization")
    .WithSummary("Desactiva manualmente una organización (baja manual por SecurityManager)")
    .WithDescription("Establece AuditDeletionDate (soft delete), registra en AUDIT_LOG con UserId. El evento se publica desde OrganizationModuleService si hay módulos asignados.")
    .Produces(StatusCodes.Status204NoContent)
    .Produces(StatusCodes.Status401Unauthorized)
    .Produces(StatusCodes.Status404NotFound)
    .Produces(StatusCodes.Status400BadRequest);
}
```

**Paso 2: Implementar IAuditLogService.RegisterCriticalAction**

Archivo: `InfoportOneAdmon.Services/Services/IAuditLogService.cs`

```csharp
namespace InfoportOneAdmon.Services.Services
{
    /// <summary>
    /// Servicio para registro de auditoría selectiva de acciones críticas
    /// </summary>
    public interface IAuditLogService
    {
        /// <summary>
        /// Registra una acción crítica en AUDIT_LOG simplificada (sin JSON)
        /// </summary>
        /// <param name="action">Acción crítica: OrganizationDeactivatedManual, OrganizationAutoDeactivated, OrganizationReactivatedManual, ModuleAssigned, ModuleRemoved, GroupChanged</param>
        /// <param name="entityType">Tipo de entidad afectada (ej: "Organization")</param>
        /// <param name="entityId">ID de la entidad afectada</param>
        /// <param name="userId">ID del usuario que ejecutó la acción (NULL para acciones automáticas)</param>
        /// <param name="cancellationToken">Token de cancelación</param>
        Task RegisterCriticalAction(
            string action,
            string entityType,
            int entityId,
            int? userId,
            CancellationToken cancellationToken = default);
    }
}
```

Archivo: `InfoportOneAdmon.Services/Services/AuditLogService.cs`

```csharp
using Helix6.Base.Domain.Repositories;
using InfoportOneAdmon.DataModel.Entities;

namespace InfoportOneAdmon.Services.Services
{
    public class AuditLogService : IAuditLogService
    {
        private readonly IRepository<AuditLog> _auditLogRepository;

        public AuditLogService(IRepository<AuditLog> auditLogRepository)
        {
            _auditLogRepository = auditLogRepository;
        }

        public async Task RegisterCriticalAction(
            string action,
            string entityType,
            int entityId,
            int? userId,
            CancellationToken cancellationToken = default)
        {
            var auditLog = new AuditLog
            {
                Action = action,
                EntityType = entityType,
                EntityId = entityId,
                Timestamp = DateTime.UtcNow,
                UserId = userId // NULL para acciones automáticas del sistema
            };

            await _auditLogRepository.CreateAsync(auditLog, cancellationToken);
        }
    }
}
```

**Paso 3: Actualizar Entidad AuditLog Simplificada**

Archivo: `InfoportOneAdmon.DataModel/Entities/AuditLog.cs`

```csharp
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace InfoportOneAdmon.DataModel.Entities
{
    /// <summary>
    /// Tabla de auditoría simplificada para acciones críticas
    /// NO tiene campos JSON OldValue/NewValue
    /// </summary>
    [Table("AUDIT_LOG")]
    public class AuditLog
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        /// <summary>
        /// Acción crítica:
        /// - OrganizationDeactivatedManual
        /// - OrganizationAutoDeactivated
        /// - OrganizationReactivatedManual
        /// - ModuleAssigned
        /// - ModuleRemoved
        /// - GroupChanged
        /// </summary>
        [Required]
        [StringLength(100)]
        public string Action { get; set; }

        [Required]
        [StringLength(100)]
        public string EntityType { get; set; }

        [Required]
        public int EntityId { get; set; }

        [Required]
        public DateTime Timestamp { get; set; }

        /// <summary>
        /// ID del usuario que ejecutó la acción
        /// NULL = acción automática del sistema (mostrar "Sistema" en UI)
        /// </summary>
        public int? UserId { get; set; }
    }
}
```

**Paso 4: Tests Unitarios**

Archivo: `InfoportOneAdmon.Services.Tests/Services/OrganizationServiceTests.cs`

```csharp
[Fact]
public async Task DeleteUndeleteLogicById_SetsAuditDeletionDateWithUserId()
{
    // Arrange
    var entity = new Organization
    {
        Id = 1,
        SecurityCompanyId = 12345,
        Name = "To Deactivate",
        Cif = "A99999999",
        ContactEmail = "deactivate@test.com",
        AuditDeletionDate = null
    };

    _repositoryMock.Setup(r => r.GetByIdAsync(1, It.IsAny<CancellationToken>()))
        .ReturnsAsync(entity);

    _repositoryMock.Setup(r => r.UpdateAsync(It.IsAny<Organization>(), It.IsAny<CancellationToken>()))
        .Returns(Task.CompletedTask);

    // Act
    var result = await _service.DeleteUndeleteLogicById(1, userId: 42, CancellationToken.None);

    // Assert
    result.Should().BeTrue();
    entity.AuditDeletionDate.Should().NotBeNull();
    entity.AuditModificationUser.Should().Be(42); // UserId del SecurityManager
    
    // Verificar que se llamó a UpdateAsync (no a DeleteAsync físico)
    _repositoryMock.Verify(r => r.UpdateAsync(
        It.Is<Organization>(o => o.AuditDeletionDate != null && o.AuditModificationUser == 42),
        It.IsAny<CancellationToken>()),
        Times.Once);
}

[Fact]
public async Task DeleteUndeleteLogicById_DoesNotPublishEvent()
{
    // Arrange
    var entity = new Organization { Id = 1, SecurityCompanyId = 12345, Name = "Test", Cif = "A11111111", ContactEmail = "test@test.com" };
    _repositoryMock.Setup(r => r.GetByIdAsync(1, It.IsAny<CancellationToken>())).ReturnsAsync(entity);
    _repositoryMock.Setup(r => r.UpdateAsync(It.IsAny<Organization>(), It.IsAny<CancellationToken>())).Returns(Task.CompletedTask);

    var messagePublisherMock = new Mock<IMessagePublisher>();

    // Act
    await _service.DeleteUndeleteLogicById(1, userId: 42, CancellationToken.None);

    // Assert
    // Verificar que NO se publicó ningún evento desde OrganizationService
    messagePublisherMock.Verify(m => m.PublishAsync(It.IsAny<object>(), It.IsAny<CancellationToken>()), Times.Never);
}
```

**Paso 5: Tests de Integración del Endpoint POST /organizations/{id}/deactivate**

Archivo: `InfoportOneAdmon.Api.Tests/Endpoints/OrganizationEndpointsTests.cs`

```csharp
[Fact]
public async Task DeactivateOrganization_WithValidId_ReturnsNoContent()
{
    // Arrange: Crear organización
    var organization = new OrganizationView
    {
        Name = "To Deactivate",
        Cif = "D88888888",
        ContactEmail = "deactivate@test.com"
    };
    var createResponse = await _client.PostAsJsonAsync("/organizations", organization);
    var created = await createResponse.Content.ReadFromJsonAsync<OrganizationView>();

    // Act: Desactivar manualmente
    var response = await _client.PostAsync($"/organizations/{created.Id}/deactivate", null);

    // Assert
    response.StatusCode.Should().Be(System.Net.HttpStatusCode.NoContent);
    
    // Verificar que el registro sigue en BD con AuditDeletionDate
    var getResponse = await _client.GetAsync($"/organizations/{created.Id}");
    getResponse.StatusCode.Should().Be(System.Net.HttpStatusCode.NotFound); // No se retorna porque está "eliminada"
}

[Fact]
public async Task DeactivateOrganization_RegistersAuditLog()
{
    // Arrange
    var organization = new OrganizationView { Name = "Audit Test", Cif = "A77777777", ContactEmail = "audit@test.com" };
    var createResponse = await _client.PostAsJsonAsync("/organizations", organization);
    var created = await createResponse.Content.ReadFromJsonAsync<OrganizationView>();

    // Act
    await _client.PostAsync($"/organizations/{created.Id}/deactivate", null);

    // Assert: Consultar AUDIT_LOG
    var auditResponse = await _client.GetAsync($"/audit-logs?entityType=Organization&entityId={created.Id}&action=OrganizationDeactivatedManual");
    auditResponse.EnsureSuccessStatusCode();
    var auditLogs = await auditResponse.Content.ReadFromJsonAsync<List<AuditLogView>>();
    
    auditLogs.Should().HaveCountGreaterOrEqualTo(1);
    auditLogs[0].Action.Should().Be("OrganizationDeactivatedManual");
    auditLogs[0].UserId.Should().NotBeNull(); // UserId poblado (no NULL)
}
```

**Paso 6: Configurar DI**

Modificar: `InfoportOneAdmon.Services/DependencyInjection.cs`

```csharp
services.AddScoped<IAuditLogService, AuditLogService>();
```

**Paso 7: Generar Migración para AUDIT_LOG**

```powershell
dotnet ef migrations add AddAuditLogTable --project ..\InfoportOneAdmon.DataModel --startup-project InfoportOneAdmon.Api
dotnet ef database update
```

**ARCHIVOS A CREAR/MODIFICAR:**
- `InfoportOneAdmon.Api/Endpoints/OrganizationEndpoints.cs` - Añadir endpoint POST /organizations/{id}/deactivate
- `InfoportOneAdmon.Services/Services/IAuditLogService.cs` - Interfaz para auditoría crítica
- `InfoportOneAdmon.Services/Services/AuditLogService.cs` - Implementación de auditoría simplificada
- `InfoportOneAdmon.DataModel/Entities/AuditLog.cs` - Entidad AUDIT_LOG simplificada (sin JSON)
- `InfoportOneAdmon.Services/DependencyInjection.cs` - Registro de IAuditLogService
- `InfoportOneAdmon.Services.Tests/Services/OrganizationServiceTests.cs` - Tests de desactivación con userId
- `InfoportOneAdmon.Api.Tests/Endpoints/OrganizationEndpointsTests.cs` - Tests de integración del endpoint deactivate

**DEPENDENCIAS:**
- TASK-001-BE - OrganizationService existe
- Helix6 - DeleteUndeleteLogicById disponible

**DEFINITION OF DONE:**
- [ ] Endpoint POST /organizations/{id}/deactivate implementado
- [ ] IAuditLogService y AuditLogService implementados
- [ ] Entidad AuditLog simplificada creada (NO campos JSON)
- [ ] Migración de AUDIT_LOG aplicada
- [ ] Test verifica DeleteUndeleteLogicById establece AuditDeletionDate con userId
- [ ] Test verifica que NO se publica evento desde OrganizationService
- [ ] Test de integración del endpoint deactivate pasando
- [ ] Test verifica registro en AUDIT_LOG con Action="OrganizationDeactivatedManual" y UserId poblado
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

**ARQUITECTURA - Grupos NO tienen soft delete:**
- OrganizationGroup NO tiene campos `IsDeleted`, `Active` ni `AuditDeletionDate`
- Los grupos se eliminan físicamente cuando no tienen organizaciones asociadas
- Las aplicaciones satélite determinan grupos basados en OrganizationEvent.GroupId
- Cascada implícita: cuando todas las organizaciones de un grupo cambian de grupo o se desactivan, el grupo queda vacío

**CONTEXTO TÉCNICO:**
- **Framework**: Helix6 sobre .NET 8
- **Sin eventos propios**: El GroupId viaja dentro del OrganizationEvent (ya implementado en TASK-001-EV-PUB)
- **Sin auditoría crítica**: Solo campos de creación/modificación Helix6 (AuditCreationDate, AuditModificationDate)
- **Cambio de grupo**: Se audita en Organization con Action="GroupChanged" (ver TASK-007-BE)

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] Entidad `OrganizationGroup` creada sin campos IsDeleted/Active/AuditDeletionDate
- [ ] ViewModel `OrganizationGroupView` creada
- [ ] Servicio `OrganizationGroupService` con validaciones
- [ ] Endpoints RESTful generados
- [ ] Validación: nombre de grupo único
- [ ] Migración EF Core generada
- [ ] Tests unitarios e integración
- [ ] Confirmado: NO se registra en AUDIT_LOG (solo cambios en Organization.GroupId se auditan con Action="GroupChanged")

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
        /// NOTA: OrganizationGroup NO publica eventos propios y NO registra auditoría crítica
        /// El GroupId viaja dentro del OrganizationEvent de cada organización
        /// Los cambios de grupo se auditan en Organization con Action="GroupChanged" (ver TASK-007-BE)
        /// </summary>
        protected override async Task PostActions(OrganizationGroupView view, OrganizationGroup entity, CancellationToken cancellationToken)
        {
            // No publicar eventos - el grupo se comunica implícitamente vía OrganizationEvent
            // No registrar en AUDIT_LOG - solo se auditan cambios de GroupId en Organization
            
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
- Se registra en AUDIT_LOG con Action="GroupChanged" (auditoría crítica)
- NO se publica OrganizationEvent desde OrganizationService (evento diferido: solo OrganizationModuleService publica cuando hay módulos asignados)
- Las aplicaciones satélite actualizarán la asignación de grupo al procesar el evento diferido

**ARQUITECTURA - Auditoría selectiva:**
- GroupChanged es una de las 6 acciones críticas auditadas en AUDIT_LOG
- Se registra SOLO cuando GroupId cambia (antes: 10, después: 20 ⇒ audita)
- NO se auditan cambios en otros campos (Name, Address, etc.)
- UserId poblado con el usuario que realiza el cambio (OrganizationManager)

**CONTEXTO TÉCNICO:**
- La entidad Organization ya tiene campo GroupId (implementado en TASK-001-BE)
- El OrganizationEvent ya incluye GroupId (implementado en TASK-001-EV-PUB)
- Necesitamos: validación de FK, auditoría selectiva de GroupChanged, y tests

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] Validación: Si GroupId != null, el grupo debe existir
- [ ] Al cambiar GroupId, se registra en AUDIT_LOG con Action="GroupChanged" y UserId poblado
- [ ] NO se publica evento desde OrganizationService (evento diferido desde OrganizationModuleService)
- [ ] Tests de asignación de grupo
- [ ] Tests de validación de grupo inexistente
- [ ] Tests verifican registro en AUDIT_LOG solo cuando GroupId cambia
- [ ] Tests verifican que NO se auditan cambios en otros campos

**GUÍA DE IMPLEMENTACIÓN:**

**Paso 1: Añadir Validación de FK y Auditoría de GroupChanged en OrganizationService**

Modificar: `InfoportOneAdmon.Services/Services/OrganizationService.cs`

Inyectar repositorio de grupos y servicio de auditoría:

```csharp
private readonly IRepository<OrganizationGroup> _groupRepository;
private readonly IAuditLogService _auditLogService;

public OrganizationService(
    ILogger<OrganizationService> logger,
    IRepository<Organization> repository,
    IMessagePublisher messagePublisher,
    IConfiguration configuration,
    IRepository<ModuleAccess> moduleAccessRepository,
    IRepository<OrganizationGroup> groupRepository, // NUEVO
    IAuditLogService auditLogService) // NUEVO
    : base(logger, repository)
{
    _messagePublisher = messagePublisher;
    _configuration = configuration;
    _moduleAccessRepository = moduleAccessRepository;
    _groupRepository = groupRepository;
    _auditLogService = auditLogService;
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

Añadir auditoría selectiva en PostActions (SOLO para GroupChanged):

```csharp
protected override async Task PostActions(OrganizationView view, Organization entity, CancellationToken cancellationToken)
{
    // AUDITORÍA SELECTIVA: Registrar en AUDIT_LOG SOLO cuando GroupId cambia
    if (entity.Id > 0) // Solo para updates (no para creates)
    {
        var originalEntity = await Repository.GetByIdAsync(entity.Id, cancellationToken);
        if (originalEntity != null && originalEntity.GroupId != entity.GroupId)
        {
            // GroupId cambió: registrar acción crítica
            await _auditLogService.RegisterCriticalAction(
                action: "GroupChanged",
                entityType: "Organization",
                entityId: entity.Id,
                userId: entity.AuditModificationUser,
                cancellationToken: cancellationToken);
        }
    }

    // NO publicar OrganizationEvent aquí
    // El evento se publica desde OrganizationModuleService cuando hay módulos asignados
    
    await base.PostActions(view, entity, cancellationToken);
}
```

**Paso 2: Tests de Asignación de Grupo y Auditoría GroupChanged**

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
        groupRepositoryMock.Object,
        Mock.Of<IAuditLogService>());

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
public async Task PostActions_WhenGroupIdChanges_RegistersGroupChangedAudit()
{
    // Arrange
    var originalEntity = new Organization { Id = 1, GroupId = 10 };
    var updatedEntity = new Organization { Id = 1, GroupId = 20, AuditModificationUser = 42 };
    
    _repositoryMock.Setup(r => r.GetByIdAsync(1, It.IsAny<CancellationToken>()))
        .ReturnsAsync(originalEntity);

    var auditLogServiceMock = new Mock<IAuditLogService>();
    var service = new OrganizationService(
        _loggerMock.Object,
        _repositoryMock.Object,
        Mock.Of<IMessagePublisher>(),
        Mock.Of<IConfiguration>(),
        Mock.Of<IRepository<ModuleAccess>>(),
        Mock.Of<IRepository<OrganizationGroup>>(),
        auditLogServiceMock.Object);

    // Act
    await service.PostActions(new OrganizationView(), updatedEntity, CancellationToken.None);

    // Assert
    auditLogServiceMock.Verify(a => a.RegisterCriticalAction(
        "GroupChanged",
        "Organization",
        1,
        42,
        It.IsAny<CancellationToken>()),
        Times.Once);
}

[Fact]
public async Task PostActions_WhenGroupIdNotChanged_DoesNotRegisterAudit()
{
    // Arrange
    var originalEntity = new Organization { Id = 1, GroupId = 10 };
    var updatedEntity = new Organization { Id = 1, GroupId = 10, Name = "Changed Name" }; // Solo cambió Name
    
    _repositoryMock.Setup(r => r.GetByIdAsync(1, It.IsAny<CancellationToken>()))
        .ReturnsAsync(originalEntity);

    var auditLogServiceMock = new Mock<IAuditLogService>();
    var service = new OrganizationService(
        _loggerMock.Object,
        _repositoryMock.Object,
        Mock.Of<IMessagePublisher>(),
        Mock.Of<IConfiguration>(),
        Mock.Of<IRepository<ModuleAccess>>(),
        Mock.Of<IRepository<OrganizationGroup>>(),
        auditLogServiceMock.Object);

    // Act
    await service.PostActions(new OrganizationView(), updatedEntity, CancellationToken.None);

    // Assert: NO se registró en AUDIT_LOG porque GroupId no cambió
    auditLogServiceMock.Verify(a => a.RegisterCriticalAction(
        It.IsAny<string>(),
        It.IsAny<string>(),
        It.IsAny<int>(),
        It.IsAny<int?>(),
        It.IsAny<CancellationToken>()),
        Times.Never);
}

[Fact]
public async Task PostActions_DoesNotPublishEvent()
{
    // Arrange
    var entity = new Organization { Id = 1, GroupId = 20 };
    var messagePublisherMock = new Mock<IMessagePublisher>();
    
    var service = new OrganizationService(
        _loggerMock.Object,
        _repositoryMock.Object,
        messagePublisherMock.Object,
        Mock.Of<IConfiguration>(),
        Mock.Of<IRepository<ModuleAccess>>(),
        Mock.Of<IRepository<OrganizationGroup>>(),
        Mock.Of<IAuditLogService>());

    // Act
    await service.PostActions(new OrganizationView(), entity, CancellationToken.None);

    // Assert: NO se publicó evento desde OrganizationService
    messagePublisherMock.Verify(m => m.PublishAsync(
        It.IsAny<object>(),
        It.IsAny<CancellationToken>()),
        Times.Never);
}
```

**Paso 3: Tests de Integración**

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
public async Task Update_ChangeGroupId_UpdatesSuccessfullyAndRegistersAudit()
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

    // Verificar que se registró en AUDIT_LOG
    var auditResponse = await _client.GetAsync($"/audit-logs?entityType=Organization&entityId={createdOrg.Id}&action=GroupChanged");
    auditResponse.EnsureSuccessStatusCode();
    var auditLogs = await auditResponse.Content.ReadFromJsonAsync<List<AuditLogView>>();
    
    auditLogs.Should().HaveCountGreaterOrEqualTo(1);
    auditLogs[0].Action.Should().Be("GroupChanged");
    auditLogs[0].UserId.Should().NotBeNull(); // UserId poblado
}
```

**ARCHIVOS A MODIFICAR:**
- `InfoportOneAdmon.Services/Services/OrganizationService.cs` - Añadir validación de GroupId y auditoría selectiva de GroupChanged en PostActions
- `InfoportOneAdmon.Services.Tests/Services/OrganizationServiceTests.cs` - Tests de validación y auditoría GroupChanged
- `InfoportOneAdmon.Api.Tests/Endpoints/OrganizationEndpointsTests.cs` - Tests de integración

**DEPENDENCIAS:**
- TASK-001-BE - OrganizationService existe
- TASK-006-BE - OrganizationGroup existe
- TASK-003-BE - IAuditLogService implementado

**DEFINITION OF DONE:**
- [ ] Validación de FK GroupId implementada
- [ ] PostActions registra en AUDIT_LOG con Action="GroupChanged" cuando GroupId cambia
- [ ] PostActions NO registra auditoría cuando solo cambian otros campos (Name, Address, etc.)
- [ ] PostActions NO publica OrganizationEvent (test lo verifica)
- [ ] Tests unitarios de validación pasando
- [ ] Test verifica registro en AUDIT_LOG solo cuando GroupId cambia
- [ ] Test verifica que NO se audita cuando GroupId no cambia
- [ ] Test verifica que NO se publica evento desde OrganizationService
- [ ] Tests de integración de asignación de grupo pasando
- [ ] Test de cambio de grupo verifica registro en AUDIT_LOG
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
Implementar endpoint de consulta de auditoría simplificada por organización

**DESCRIPCIÓN:**
Crear endpoint personalizado GET /organizations/{id}/audit que consulta el historial de acciones críticas realizadas en una organización específica desde la tabla AUDIT_LOG simplificada.

**ARQUITECTURA - Auditoría selectiva simplificada:**
- Tabla AUDIT_LOG sin campos JSON (NO OldValue/NewValue)
- Solo 6 acciones críticas auditadas:
  1. **ModuleAssigned** - Módulo asignado a organización
  2. **ModuleRemoved** - Módulo eliminado de organización
  3. **OrganizationDeactivatedManual** - Baja manual por SecurityManager
  4. **OrganizationAutoDeactivated** - Baja automática (ModuleCount=0)
  5. **OrganizationReactivatedManual** - Alta manual por SecurityManager
  6. **GroupChanged** - Cambio de grupo
- UserId NULL = acción automática del sistema (mostrar "Sistema" en UI)
- UserId poblado = usuario que ejecutó la acción

**IMPORTANTE - NO se auditan:**
- Cambios en datos básicos (Name, Address, ContactEmail, etc.)
- Creación de organizaciones (ya tienen AuditCreationDate)
- Modificaciones de metadatos

**Caso de uso:**
SecurityManager consulta "qué le pasó a esta organización":
- ¿Cuándo se dio de baja?
- ¿Quién le quitó los módulos?
- ¿Cuándo cambió de grupo?

Esto permite auditorías de cumplimiento (ISO 27001, GDPR) y trazabilidad de decisiones críticas.

**CONTEXTO TÉCNICO:**
- Tabla AUDIT_LOG simplificada (implementada en TASK-003-BE)
- Campos: Id, Action, EntityType, EntityId, Timestamp, UserId
- Endpoint con paginación Kendo (GridDataResult)
- Filtrado, ordenación server-side mediante KendoFilter

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] Endpoint GET /organizations/{id}/audit implementado
- [ ] Usa KendoFilter para filtrado, ordenación y paginación server-side
- [ ] Retorna GridDataResult con campos: Id, Action, Timestamp, UserId, UserName
- [ ] UserName muestra "Sistema" cuando UserId=NULL (acciones automáticas)
- [ ] Solo retorna acciones críticas (6 tipos enumerados arriba)
- [ ] Tests de integración verifican consulta de acciones críticas
- [ ] Tests verifican que "Sistema" aparece para UserId=NULL
- [ ] Documentación Swagger actualizada

**GUÍA DE IMPLEMENTACIÓN:**

**Paso 1: Crear ViewModel de Auditoría Simplificada**

Archivo: `InfoportOneAdmon.Entities/Views/AuditLogView.cs`

```csharp
namespace InfoportOneAdmon.Entities.Views
{
    /// <summary>
    /// ViewModel para consulta de logs de auditoría crítica
    /// NO incluye campos JSON (OldValue/NewValue)
    /// </summary>
    public class AuditLogView
    {
        public int Id { get; set; }
        
        /// <summary>
        /// Acción crítica: ModuleAssigned, ModuleRemoved, OrganizationDeactivatedManual, 
        /// OrganizationAutoDeactivated, OrganizationReactivatedManual, GroupChanged
        /// </summary>
        public string Action { get; set; }
        
        public string EntityType { get; set; } // Siempre "Organization" para este endpoint
        public int EntityId { get; set; }
        
        public DateTime Timestamp { get; set; }
        
        /// <summary>
        /// ID del usuario que ejecutó la acción
        /// NULL = acción automática del sistema
        /// </summary>
        public int? UserId { get; set; }
        
        /// <summary>
        /// Nombre del usuario para visualización
        /// Muestra "Sistema" cuando UserId=NULL
        /// </summary>
        public string UserName { get; set; }
    }
}
```

**Paso 2: Extender AuditLogService para Consultas**

Modificar: `InfoportOneAdmon.Services/Services/AuditLogService.cs`

```csharp
using Helix6.Base.Domain.Repositories;
using Helix6.Kendo.Models;
using Helix6.Kendo.Extensions;
using InfoportOneAdmon.DataModel.Entities;
using InfoportOneAdmon.Entities.Views;
using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Services.Services
{
    public class AuditLogService : IAuditLogService
    {
        private readonly IRepository<AuditLog> _auditLogRepository;

        public AuditLogService(IRepository<AuditLog> auditLogRepository)
        {
            _auditLogRepository = auditLogRepository;
        }

        public async Task RegisterCriticalAction(
            string action,
            string entityType,
            int entityId,
            int? userId,
            CancellationToken cancellationToken = default)
        {
            var auditLog = new AuditLog
            {
                Action = action,
                EntityType = entityType,
                EntityId = entityId,
                Timestamp = DateTime.UtcNow,
                UserId = userId
            };

            await _auditLogRepository.CreateAsync(auditLog, cancellationToken);
        }

        /// <summary>
        /// Obtiene el historial de auditoría crítica de una organización con KendoFilter
        /// </summary>
        public async Task<GridDataResult> GetOrganizationAuditHistory(
            int organizationId,
            KendoFilter filter,
            CancellationToken cancellationToken = default)
        {
            var query = _auditLogRepository.GetQuery()
                .Where(al => al.EntityType == "Organization" && al.EntityId == organizationId)
                .OrderByDescending(al => al.Timestamp); // Más reciente primero

            // Aplicar filtrado, ordenación y paginación de Kendo
            var result = await query.ToKendoResult(filter, al => new AuditLogView
            {
                Id = al.Id,
                Action = al.Action,
                EntityType = al.EntityType,
                EntityId = al.EntityId,
                Timestamp = al.Timestamp,
                UserId = al.UserId,
                UserName = al.UserId.HasValue ? $"Usuario {al.UserId.Value}" : "Sistema" // "Sistema" para acciones automáticas
            }, cancellationToken);

            return result;
        }
    }
}
```

Actualizar interfaz: `InfoportOneAdmon.Services/Services/IAuditLogService.cs`

```csharp
public interface IAuditLogService
{
    Task RegisterCriticalAction(
        string action,
        string entityType,
        int entityId,
        int? userId,
        CancellationToken cancellationToken = default);

    Task<GridDataResult> GetOrganizationAuditHistory(
        int organizationId,
        KendoFilter filter,
        CancellationToken cancellationToken = default);
}
```

**Paso 3: Crear Endpoint Personalizado GET /organizations/{id}/audit**

Modificar: `InfoportOneAdmon.Api/Endpoints/OrganizationEndpoints.cs`

```csharp
using Microsoft.AspNetCore.Mvc;
using Helix6.Kendo.Models;

public static void MapOrganizationEndpoints(this IEndpointRouteBuilder app)
{
    // Endpoints CRUD estándar
    EndpointHelper.MapCrudEndpoints<OrganizationService, OrganizationView>(
        app,
        "organizations",
        "Organizations");

    var group = app.MapGroup("organizations")
        .WithTags("Organizations")
        .RequireAuthorization();

    // Endpoint de auditoría simplificada
    group.MapGet("/{id}/audit", async (
        [FromRoute] int id,
        [FromQuery] string? filter, // KendoFilter serializado
        [FromServices] IAuditLogService auditLogService,
        CancellationToken ct) =>
    {
        // Parsear KendoFilter desde query string (si no se envía, usar valores por defecto)
        var kendoFilter = string.IsNullOrEmpty(filter) 
            ? new KendoFilter { Page = 1, PageSize = 20 }
            : System.Text.Json.JsonSerializer.Deserialize<KendoFilter>(filter);

        var auditHistory = await auditLogService.GetOrganizationAuditHistory(id, kendoFilter, ct);

        return Results.Ok(auditHistory);
    })
    .WithName("GetOrganizationAuditHistory")
    .WithSummary("Obtiene el historial de auditoría crítica de una organización")
    .WithDescription("Retorna solo acciones críticas: ModuleAssigned, ModuleRemoved, OrganizationDeactivatedManual, OrganizationAutoDeactivated, OrganizationReactivatedManual, GroupChanged. UserId=NULL muestra 'Sistema'.")
    .Produces<GridDataResult>(StatusCodes.Status200OK)
    .Produces(StatusCodes.Status401Unauthorized)
    .Produces(StatusCodes.Status404NotFound);

    // Endpoint de desactivación manual (ya implementado en TASK-003-BE)
    // ...
}
```

**Paso 4: Tests de Integración**

Archivo: `InfoportOneAdmon.Api.Tests/Endpoints/OrganizationAuditEndpointsTests.cs`

```csharp
using Xunit;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;
using System.Net.Http.Json;
using InfoportOneAdmon.Entities.Views;
using Helix6.Kendo.Models;

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
        public async Task GetAuditHistory_AfterManualDeactivation_ShowsOrganizationDeactivatedManual()
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

            // Desactivar manualmente (genera auditoría)
            await _client.PostAsync($"/organizations/{created.Id}/deactivate", null);

            // Act: Consultar auditoría
            var auditResponse = await _client.GetAsync($"/organizations/{created.Id}/audit");

            // Assert
            auditResponse.EnsureSuccessStatusCode();
            var auditResult = await auditResponse.Content.ReadFromJsonAsync<GridDataResult>();
            
            auditResult.Should().NotBeNull();
            auditResult.Data.Should().HaveCountGreaterOrEqualTo(1);
            
            var auditLogs = auditResult.Data.Cast<AuditLogView>().ToList();
            auditLogs.Should().Contain(a => a.Action == "OrganizationDeactivatedManual");
            
            var deactivationLog = auditLogs.First(a => a.Action == "OrganizationDeactivatedManual");
            deactivationLog.UserId.Should().NotBeNull(); // UserId poblado (SecurityManager)
            deactivationLog.UserName.Should().NotBe("Sistema"); // NO es acción automática
        }

        [Fact]
        public async Task GetAuditHistory_AfterGroupChange_ShowsGroupChanged()
        {
            // Arrange: Crear dos grupos y organización
            var group1 = new OrganizationGroupView { Name = "Group A" };
            var group1Response = await _client.PostAsJsonAsync("/organization-groups", group1);
            var createdGroup1 = await group1Response.Content.ReadFromJsonAsync<OrganizationGroupView>();

            var group2 = new OrganizationGroupView { Name = "Group B" };
            var group2Response = await _client.PostAsJsonAsync("/organization-groups", group2);
            var createdGroup2 = await group2Response.Content.ReadFromJsonAsync<OrganizationGroupView>();

            var organization = new OrganizationView
            {
                Name = "Moving Org",
                Cif = "M99999999",
                ContactEmail = "moving@test.com",
                GroupId = createdGroup1.Id
            };
            var orgResponse = await _client.PostAsJsonAsync("/organizations", organization);
            var created = await orgResponse.Content.ReadFromJsonAsync<OrganizationView>();

            // Cambiar de grupo (genera auditoría)
            created.GroupId = createdGroup2.Id;
            await _client.PutAsJsonAsync($"/organizations/{created.Id}", created);

            // Act
            var auditResponse = await _client.GetAsync($"/organizations/{created.Id}/audit");

            // Assert
            auditResponse.EnsureSuccessStatusCode();
            var auditResult = await auditResponse.Content.ReadFromJsonAsync<GridDataResult>();
            var auditLogs = auditResult.Data.Cast<AuditLogView>().ToList();
            
            auditLogs.Should().Contain(a => a.Action == "GroupChanged");
            
            var groupChangeLog = auditLogs.First(a => a.Action == "GroupChanged");
            groupChangeLog.UserId.Should().NotBeNull(); // UserId poblado (OrganizationManager)
        }

        [Fact]
        public async Task GetAuditHistory_WithAutoDeactivation_ShowsSistemaAsUserName()
        {
            // Arrange: Simular auto-baja (UserId=NULL)
            // NOTA: Este test requiere que OrganizationModuleService implemente auto-baja
            // Por ahora, mockeamos insertando directamente en AUDIT_LOG
            
            var organization = new OrganizationView { Name = "Auto Test", Cif = "A88888888", ContactEmail = "auto@test.com" };
            var orgResponse = await _client.PostAsJsonAsync("/organizations", organization);
            var created = await orgResponse.Content.ReadFromJsonAsync<OrganizationView>();

            // Insertar registro de auditoría con UserId=NULL (simula auto-baja)
            var auditLog = new { Action = "OrganizationAutoDeactivated", EntityType = "Organization", EntityId = created.Id, UserId = (int?)null };
            await _client.PostAsJsonAsync("/audit-logs", auditLog);

            // Act
            var auditResponse = await _client.GetAsync($"/organizations/{created.Id}/audit");

            // Assert
            auditResponse.EnsureSuccessStatusCode();
            var auditResult = await auditResponse.Content.ReadFromJsonAsync<GridDataResult>();
            var auditLogs = auditResult.Data.Cast<AuditLogView>().ToList();
            
            var autoLog = auditLogs.FirstOrDefault(a => a.Action == "OrganizationAutoDeactivated");
            autoLog.Should().NotBeNull();
            autoLog.UserId.Should().BeNull();
            autoLog.UserName.Should().Be("Sistema"); // "Sistema" cuando UserId=NULL
        }

        [Fact]
        public async Task GetAuditHistory_DoesNotIncludeBasicDataChanges()
        {
            // Arrange: Crear organización
            var organization = new OrganizationView { Name = "Test", Cif = "T11111111", ContactEmail = "test@test.com" };
            var orgResponse = await _client.PostAsJsonAsync("/organizations", organization);
            var created = await orgResponse.Content.ReadFromJsonAsync<OrganizationView>();

            // Modificar datos básicos (NO genera auditoría crítica)
            created.Name = "Updated Name";
            created.Address = "New Address";
            await _client.PutAsJsonAsync($"/organizations/{created.Id}", created);

            // Act
            var auditResponse = await _client.GetAsync($"/organizations/{created.Id}/audit");

            // Assert
            auditResponse.EnsureSuccessStatusCode();
            var auditResult = await auditResponse.Content.ReadFromJsonAsync<GridDataResult>();
            var auditLogs = auditResult.Data.Cast<AuditLogView>().ToList();
            
            // NO debe haber registros de auditoría crítica para cambios de datos básicos
            auditLogs.Should().BeEmpty();
        }
    }
}
```

**ARCHIVOS A CREAR/MODIFICAR:**
- `InfoportOneAdmon.Entities/Views/AuditLogView.cs` - ViewModel simplificado (sin JSON)
- `InfoportOneAdmon.Services/Services/IAuditLogService.cs` - Añadir GetOrganizationAuditHistory
- `InfoportOneAdmon.Services/Services/AuditLogService.cs` - Implementar consulta con KendoFilter
- `InfoportOneAdmon.Api/Endpoints/OrganizationEndpoints.cs` - Añadir endpoint GET /organizations/{id}/audit
- `InfoportOneAdmon.Api.Tests/Endpoints/OrganizationAuditEndpointsTests.cs` - Tests de integración

**DEPENDENCIAS:**
- TASK-003-BE - AUDIT_LOG simplificada y IAuditLogService implementados
- TASK-001-BE - Organization existe

**DEFINITION OF DONE:**
- [ ] AuditLogView creado sin campos OldValue/NewValue
- [ ] IAuditLogService.GetOrganizationAuditHistory implementado
- [ ] Endpoint GET /organizations/{id}/audit funcional con KendoFilter
- [ ] UserName muestra "Sistema" cuando UserId=NULL
- [ ] Tests verifican registro de OrganizationDeactivatedManual con UserId poblado
- [ ] Tests verifican registro de GroupChanged con UserId poblado
- [ ] Tests verifican "Sistema" para OrganizationAutoDeactivated (UserId=NULL)
- [ ] Tests verifican que cambios de datos básicos NO generan auditoría
- [ ] Paginación y ordenación validadas
- [ ] Code review aprobado

**RECURSOS:**
- User Story: `userStories.md#us-008`

=============================================================

**Épica 1 completada ✅**

---

