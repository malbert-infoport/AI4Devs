# Tickets Técnicos Backend y Eventos - InfoportOneAdmon

**Generado desde:** User Stories (userStories.md)  
**Fecha de generación:** 31 de enero de 2026  
**Arquitecturas de referencia:**
- Backend: Helix6_Backend_Architecture.md
- Eventos: ActiveMQ_Events.md

---

## Índice

1. [Épica 1: Gestión del Portfolio de Organizaciones Clientes](#épica-1-gestión-del-portfolio-de-organizaciones-clientes)
   - [US-001: Crear nueva organización cliente](#us-001-crear-nueva-organización-cliente)
   - [US-002: Editar información de organización existente](#us-002-editar-información-de-organización-existente)
   - [US-003: Desactivar organización (kill-switch)](#us-003-desactivar-organización-kill-switch)
   - [US-006: Crear grupo de organizaciones](#us-006-crear-grupo-de-organizaciones)
   - [US-007: Asignar organizaciones a un grupo](#us-007-asignar-organizaciones-a-un-grupo)
   - [US-008: Consultar auditoría de cambios en organización](#us-008-consultar-auditoría-de-cambios-en-organización)

2. [Épica 2: Administración de Aplicaciones del Ecosistema](#épica-2-administración-de-aplicaciones-del-ecosistema)
   - [US-009: Registrar aplicación frontend (SPA)](#us-009-registrar-aplicación-frontend-spa)
   - [US-010: Registrar aplicación backend (API)](#us-010-registrar-aplicación-backend-api)
   - [US-011: Definir prefijo único de aplicación](#us-011-definir-prefijo-único-de-aplicación)

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
- Registrar auditoría completa con campos Helix6
- Implementar soft delete mediante `AuditDeletionDate`

**CONTEXTO TÉCNICO:**
- **Framework**: Helix6 Framework sobre .NET 8
- **Base de datos**: PostgreSQL 16 con Entity Framework Core 9.0
- **Patrón arquitectónico**: Repository/Service pattern de Helix6
- **Auditoría**: Campos Helix6 (AuditCreationUser, AuditCreationDate, AuditModificationUser, AuditModificationDate, AuditDeletionDate)
- **Soft Delete**: Usar AuditDeletionDate (no DELETE físico de SQL)
- **Validaciones**: Implementar en ValidateView del servicio
- **SecurityCompanyId**: Generado por secuencia de PostgreSQL independiente

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] Entidad `Organization` creada en DataModel implementando IEntityBase
- [ ] Secuencia de PostgreSQL `seq_security_company_id` creada para generar IDs únicos
- [ ] ViewModel `OrganizationView` creada en Entities implementando IViewBase
- [ ] Servicio `OrganizationService` creado heredando de BaseService<OrganizationView, Organization, BaseMetadata>
- [ ] Validaciones implementadas en ValidateView: nombre, CIF y email obligatorios, CIF único
- [ ] Endpoints generados con EndpointHelper (GET, GET/{id}, POST, PUT, DELETE)
- [ ] Migración de Entity Framework Core generada y aplicada
- [ ] Índice único en campo `Cif` configurado
- [ ] Índice único en campo `SecurityCompanyId` configurado
- [ ] Inyección de dependencias configurada en DependencyInjection.cs
- [ ] Tests unitarios del servicio con cobertura >80%
- [ ] Tests de integración de endpoints (GET, POST, PUT, DELETE)
- [ ] Documentación Swagger actualizada con comentarios XML
- [ ] Sin warnings de compilación ni vulnerabilidades

**GUÍA DE IMPLEMENTACIÓN:**

**Paso 1: Crear la Secuencia de PostgreSQL para SecurityCompanyId**

Crear migración manual para la secuencia (antes de crear la entidad):

Archivo: `InfoportOneAdmon.DataModel/Migrations/XXXXXX_CreateSecurityCompanyIdSequence.cs`

```csharp
using Microsoft.EntityFrameworkCore.Migrations;

namespace InfoportOneAdmon.DataModel.Migrations
{
    public partial class CreateSecurityCompanyIdSequence : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Crear secuencia para SecurityCompanyId (empieza en 10000)
            migrationBuilder.Sql(@"
                CREATE SEQUENCE IF NOT EXISTS seq_security_company_id
                START WITH 10000
                INCREMENT BY 1
                NO MAXVALUE
                NO CYCLE;
            ");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("DROP SEQUENCE IF EXISTS seq_security_company_id;");
        }
    }
}
```

**Paso 2: Crear la Entidad en DataModel**

Archivo: `InfoportOneAdmon.DataModel/Entities/Organization.cs`

```csharp
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;

namespace InfoportOneAdmon.DataModel.Entities
{
    /// <summary>
    /// Representa una organización cliente del ecosistema InfoportOne
    /// </summary>
    [Table("ORGANIZATION")]
    public class Organization : IEntityBase
    {
        /// <summary>
        /// Identificador único interno (PK autonumérica)
        /// </summary>
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }
        
        /// <summary>
        /// Identificador de negocio único e inmutable (generado por secuencia)
        /// Este ID viaja en el claim c_ids del token JWT
        /// </summary>
        [Required]
        public int SecurityCompanyId { get; set; }
        
        /// <summary>
        /// Nombre de la organización cliente
        /// </summary>
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

Modificar `PostActions` para registrar cambios en `AUDIT_LOG`:

```csharp
using InfoportOneAdmon.DataModel.Entities;
using System.Text.Json;

protected override async Task PostActions(OrganizationView view, Organization entity, CancellationToken cancellationToken)
{
    await base.PostActions(view, entity, cancellationToken);

    // Registrar auditoría detallada si es actualización (Id > 0)
    if (view.Id > 0)
    {
        await RegisterDetailedAudit(view, entity, cancellationToken);
    }

    // Publicar evento (ya implementado en TASK-001-EV-PUB)
    await PublishOrganizationEvent(entity, cancellationToken);
}

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

---

## Épica 2: Administración de Aplicaciones del Ecosistema

### US-009: Registrar aplicación frontend (SPA)

**Resumen de tickets generados:**
- TASK-009-BE: Implementar entidades Application y ApplicationSecurity con CRUD
- TASK-009-KC: Integrar con Keycloak Admin API para crear public clients con PKCE
- TASK-009-EV-PUB: Publicar ApplicationEvent al crear/modificar aplicaciones

---

#### TASK-009-BE: Implementar entidades Application y ApplicationSecurity con CRUD

=============================================================
**TICKET ID:** TASK-009-BE  
**EPIC:** Administración de Aplicaciones del Ecosistema  
**USER STORY:** US-009 - Registrar aplicación frontend (SPA)  
**COMPONENT:** Backend  
**PRIORITY:** Alta  
**ESTIMATION:** 8 horas  
=============================================================

**TÍTULO:**
Implementar entidades Application y ApplicationSecurity con registro de clients OAuth2

**DESCRIPCIÓN:**
Crear la infraestructura backend para gestionar el catálogo de aplicaciones del ecosistema. Esto incluye:
- Entidad `Application` con información general de la aplicación
- Entidad `ApplicationSecurity` para credenciales OAuth2 (relación 1:N)
- Soporte para dos tipos de clients: CODE (SPAs con PKCE) y ClientCredentials (APIs)
- Generación automática de `client_id` único
- Para clients CODE: RedirectURIs, sin client_secret (public client)
- Para clients ClientCredentials: generación segura de client_secret con hash bcrypt

**CONTEXTO TÉCNICO:**
- **Separación de credenciales**: ApplicationSecurity es tabla independiente (1:N con Application)
- **Security**: Secrets se hashean con bcrypt antes de almacenar, NUNCA en texto plano
- **Client naming**: client_id sigue patrón `{databasePrefix}-{tipo}` (ej: "crm-frontend", "crm-api")
- **RolePrefix inmutable**: Una vez asignado el prefijo de roles, no se puede modificar

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] Entidad Application creada con RolePrefix único e inmutable
- [ ] Entidad ApplicationSecurity creada con soporte CODE y ClientCredentials
- [ ] Servicio ApplicationService con validaciones de RolePrefix
- [ ] Servicio ApplicationSecurityService con generación de client_id y secrets
- [ ] Generación automática de client_id siguiendo patrón establecido
- [ ] Generación segura de client_secret para tipo ClientCredentials
- [ ] Hash bcrypt de secrets antes de almacenar (factor de trabajo 12)
- [ ] Endpoints RESTful para ambas entidades
- [ ] Tests unitarios e integración con >80% cobertura

**GUÍA DE IMPLEMENTACIÓN:**

**Paso 1: Crear Entidad Application**

Archivo: `InfoportOneAdmon.DataModel/Entities/Application.cs`

```csharp
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;

namespace InfoportOneAdmon.DataModel.Entities
{
    /// <summary>
    /// Representa una aplicación del ecosistema InfoportOne
    /// </summary>
    [Table("APPLICATION")]
    public class Application : IEntityBase
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }
        
        /// <summary>
        /// Nombre de la aplicación (ej: "CRM", "Sintraport", "Business Intelligence")
        /// </summary>
        [Required]
        [StringLength(200)]
        public string Name { get; set; }
        
        /// <summary>
        /// Descripción de la aplicación
        /// </summary>
        [StringLength(500)]
        public string Description { get; set; }
        
        /// <summary>
        /// Prefijo único para roles y módulos (ej: "CRM", "STP", "BI")
        /// 2-5 caracteres, solo mayúsculas, INMUTABLE
        /// </summary>
        [Required]
        [StringLength(5)]
        public string RolePrefix { get; set; }
        
        /// <summary>
        /// Prefijo para nombres de bases de datos (ej: "crm", "sintraport", "bi")
        /// Se usa para generar nombres de BD específicos por organización
        /// </summary>
        [Required]
        [StringLength(50)]
        public string DatabasePrefix { get; set; }
        
        /// <summary>
        /// Colección de credenciales OAuth2 para esta aplicación
        /// Una aplicación puede tener múltiples credenciales (frontend CODE + backend ClientCredentials)
        /// </summary>
        public virtual ICollection<ApplicationSecurity> Credentials { get; set; }
        
        /// <summary>
        /// Módulos funcionales de esta aplicación
        /// </summary>
        public virtual ICollection<Module> Modules { get; set; }
        
        /// <summary>
        /// Roles de seguridad definidos para esta aplicación
        /// </summary>
        public virtual ICollection<AppRoleDefinition> Roles { get; set; }
        
        // Campos de auditoría Helix6
        public int? AuditCreationUser { get; set; }
        public DateTime? AuditCreationDate { get; set; }
        public int? AuditModificationUser { get; set; }
        public DateTime? AuditModificationDate { get; set; }
        public DateTime? AuditDeletionDate { get; set; }
    }
}
```

**Paso 2: Crear Entidad ApplicationSecurity**

Archivo: `InfoportOneAdmon.DataModel/Entities/ApplicationSecurity.cs`

```csharp
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;

namespace InfoportOneAdmon.DataModel.Entities
{
    /// <summary>
    /// Credenciales OAuth2 de una aplicación
    /// Una aplicación puede tener múltiples credenciales (frontend + backend)
    /// </summary>
    [Table("APPLICATION_SECURITY")]
    public class ApplicationSecurity : IEntityBase
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }
        
        /// <summary>
        /// FK a la aplicación
        /// </summary>
        [Required]
        public int ApplicationId { get; set; }
        
        [ForeignKey(nameof(ApplicationId))]
        public virtual Application Application { get; set; }
        
        /// <summary>
        /// Tipo de credencial OAuth2: CODE (SPAs con PKCE) o ClientCredentials (APIs)
        /// </summary>
        [Required]
        [StringLength(50)]
        public string CredentialType { get; set; } // "CODE" | "ClientCredentials"
        
        /// <summary>
        /// client_id único de OAuth2 (ej: "crm-frontend", "crm-api")
        /// </summary>
        [Required]
        [StringLength(100)]
        public string ClientId { get; set; }
        
        /// <summary>
        /// Hash bcrypt del client_secret (solo para CredentialType = ClientCredentials)
        /// NULL para public clients (CODE con PKCE)
        /// </summary>
        [StringLength(200)]
        public string ClientSecretHash { get; set; }
        
        /// <summary>
        /// RedirectURIs permitidos (solo para CredentialType = CODE)
        /// Almacenado como JSON array: ["https://app.com/*", "http://localhost:4200/*"]
        /// </summary>
        public string RedirectUris { get; set; }
        
        /// <summary>
        /// Scopes OAuth2 de esta credencial
        /// </summary>
        [StringLength(500)]
        public string Scope { get; set; }
        
        /// <summary>
        /// Indica si esta credencial está activa
        /// </summary>
        public bool IsActive { get; set; } = true;
        
        // Campos de auditoría Helix6
        public int? AuditCreationUser { get; set; }
        public DateTime? AuditCreationDate { get; set; }
        public int? AuditModificationUser { get; set; }
        public DateTime? AuditModificationDate { get; set; }
        public DateTime? AuditDeletionDate { get; set; }
    }
}
```

**Paso 3: Configurar DbContext**

Modificar: `InfoportOneAdmon.DataModel/InfoportOneAdmonContext.cs`

```csharp
public DbSet<Application> Applications { get; set; }
public DbSet<ApplicationSecurity> ApplicationSecurities { get; set; }

protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    base.OnModelCreating(modelBuilder);

    // Índice único para RolePrefix
    modelBuilder.Entity<Application>()
        .HasIndex(a => a.RolePrefix)
        .IsUnique()
        .HasDatabaseName("UX_Application_RolePrefix");

    // Índice único para DatabasePrefix
    modelBuilder.Entity<Application>()
        .HasIndex(a => a.DatabasePrefix)
        .IsUnique()
        .HasDatabaseName("UX_Application_DatabasePrefix");

    // Índice único para ClientId
    modelBuilder.Entity<ApplicationSecurity>()
        .HasIndex(a => a.ClientId)
        .IsUnique()
        .HasDatabaseName("UX_ApplicationSecurity_ClientId");

    // Relación Application -> ApplicationSecurity (1:N)
    modelBuilder.Entity<ApplicationSecurity>()
        .HasOne(a => a.Application)
        .WithMany(app => app.Credentials)
        .HasForeignKey(a => a.ApplicationId)
        .OnDelete(DeleteBehavior.Cascade);
}
```

**Paso 4: Crear ViewModels**

Archivo: `InfoportOneAdmon.Entities/Views/ApplicationView.cs`

```csharp
using System.ComponentModel.DataAnnotations;
using Helix6.Base.Application.BaseInterfaces;

namespace InfoportOneAdmon.Entities.Views
{
    public class ApplicationView : IViewBase
    {
        public int Id { get; set; }
        
        [Required(ErrorMessage = "El nombre de la aplicación es obligatorio")]
        [StringLength(200)]
        public string Name { get; set; }
        
        [StringLength(500)]
        public string Description { get; set; }
        
        [Required(ErrorMessage = "El prefijo de roles es obligatorio")]
        [StringLength(5, MinimumLength = 2, ErrorMessage = "El prefijo debe tener entre 2 y 5 caracteres")]
        [RegularExpression("^[A-Z]{2,5}$", ErrorMessage = "El prefijo solo puede contener letras mayúsculas")]
        public string RolePrefix { get; set; }
        
        [Required]
        [StringLength(50)]
        [RegularExpression("^[a-z0-9-]+$", ErrorMessage = "DatabasePrefix solo puede contener minúsculas, números y guiones")]
        public string DatabasePrefix { get; set; }
        
        // Lista de credenciales (para visualización)
        public List<ApplicationSecurityView> Credentials { get; set; }
        
        // Auditoría
        public int? AuditCreationUser { get; set; }
        public DateTime? AuditCreationDate { get; set; }
        public int? AuditModificationUser { get; set; }
        public DateTime? AuditModificationDate { get; set; }
        public DateTime? AuditDeletionDate { get; set; }
    }
}
```

Archivo: `InfoportOneAdmon.Entities/Views/ApplicationSecurityView.cs`

```csharp
using System.ComponentModel.DataAnnotations;
using Helix6.Base.Application.BaseInterfaces;

namespace InfoportOneAdmon.Entities.Views
{
    public class ApplicationSecurityView : IViewBase
    {
        public int Id { get; set; }
        
        [Required]
        public int ApplicationId { get; set; }
        
        [Required]
        public string CredentialType { get; set; } // "CODE" | "ClientCredentials"
        
        public string ClientId { get; set; } // Generado automáticamente
        
        /// <summary>
        /// Solo se muestra al crear ClientCredentials (UNA VEZ)
        /// Después siempre retorna "***"
        /// </summary>
        public string ClientSecret { get; set; }
        
        public List<string> RedirectUris { get; set; } // Para CredentialType = CODE
        
        [StringLength(500)]
        public string Scope { get; set; }
        
        public bool IsActive { get; set; }
        
        // Auditoría
        public DateTime? AuditCreationDate { get; set; }
    }
}
```

**Paso 5: Implementar Servicio ApplicationService**

Archivo: `InfoportOneAdmon.Services/Services/ApplicationService.cs`

```csharp
using Helix6.Base.Application.Services;
using Helix6.Base.Domain.Repositories;
using InfoportOneAdmon.DataModel.Entities;
using InfoportOneAdmon.Entities.Views;
using Microsoft.Extensions.Logging;

namespace InfoportOneAdmon.Services.Services
{
    public class ApplicationService : BaseService<ApplicationView, Application, BaseMetadata>
    {
        public ApplicationService(
            ILogger<ApplicationService> logger,
            IRepository<Application> repository)
            : base(logger, repository)
        {
        }

        protected override async Task<bool> ValidateView(ApplicationView view, CancellationToken cancellationToken)
        {
            // Validación: Nombre obligatorio
            if (string.IsNullOrWhiteSpace(view.Name))
            {
                AddError("El nombre de la aplicación es obligatorio");
                return false;
            }

            // Validación: RolePrefix obligatorio y formato correcto
            if (string.IsNullOrWhiteSpace(view.RolePrefix))
            {
                AddError("El prefijo de roles es obligatorio");
                return false;
            }

            if (!System.Text.RegularExpressions.Regex.IsMatch(view.RolePrefix, "^[A-Z]{2,5}$"))
            {
                AddError("El prefijo debe tener entre 2 y 5 caracteres en mayúsculas");
                return false;
            }

            // Validación: RolePrefix único
            var prefixExists = await Repository.ExistsAsync(
                a => a.RolePrefix == view.RolePrefix && a.Id != view.Id && a.AuditDeletionDate == null,
                cancellationToken);
            
            if (prefixExists)
            {
                AddError($"Ya existe una aplicación con el prefijo '{view.RolePrefix}'");
                return false;
            }

            // Validación: DatabasePrefix único
            var dbPrefixExists = await Repository.ExistsAsync(
                a => a.DatabasePrefix == view.DatabasePrefix && a.Id != view.Id && a.AuditDeletionDate == null,
                cancellationToken);
            
            if (dbPrefixExists)
            {
                AddError($"Ya existe una aplicación con el prefijo de BD '{view.DatabasePrefix}'");
                return false;
            }

            // Validación: RolePrefix inmutable en edición
            if (view.Id > 0)
            {
                var originalEntity = await Repository.GetByIdAsync(view.Id, cancellationToken);
                if (originalEntity != null && originalEntity.RolePrefix != view.RolePrefix)
                {
                    AddError("El RolePrefix es inmutable y no puede modificarse una vez asignado");
                    return false;
                }
            }

            return true;
        }

        protected override async Task PreviousActions(ApplicationView view, Application entity, CancellationToken cancellationToken)
        {
            entity.Name = entity.Name?.Trim();
            entity.Description = entity.Description?.Trim();
            entity.RolePrefix = entity.RolePrefix?.Trim().ToUpperInvariant();
            entity.DatabasePrefix = entity.DatabasePrefix?.Trim().ToLowerInvariant();
            
            await base.PreviousActions(view, entity, cancellationToken);
        }
    }
}
```

**Paso 6: Implementar Servicio ApplicationSecurityService**

Archivo: `InfoportOneAdmon.Services/Services/ApplicationSecurityService.cs`

```csharp
using Helix6.Base.Application.Services;
using Helix6.Base.Domain.Repositories;
using InfoportOneAdmon.DataModel.Entities;
using InfoportOneAdmon.Entities.Views;
using Microsoft.Extensions.Logging;
using System.Security.Cryptography;
using System.Text;
using BCrypt.Net;

namespace InfoportOneAdmon.Services.Services
{
    public class ApplicationSecurityService : BaseService<ApplicationSecurityView, ApplicationSecurity, BaseMetadata>
    {
        private readonly IRepository<Application> _applicationRepository;

        public ApplicationSecurityService(
            ILogger<ApplicationSecurityService> logger,
            IRepository<ApplicationSecurity> repository,
            IRepository<Application> applicationRepository)
            : base(logger, repository)
        {
            _applicationRepository = applicationRepository;
        }

        protected override async Task<bool> ValidateView(ApplicationSecurityView view, CancellationToken cancellationToken)
        {
            // Validación: ApplicationId debe existir
            var appExists = await _applicationRepository.ExistsAsync(
                a => a.Id == view.ApplicationId && a.AuditDeletionDate == null,
                cancellationToken);
            
            if (!appExists)
            {
                AddError($"La aplicación con ID {view.ApplicationId} no existe");
                return false;
            }

            // Validación: CredentialType válido
            if (view.CredentialType != "CODE" && view.CredentialType != "ClientCredentials")
            {
                AddError("CredentialType debe ser 'CODE' o 'ClientCredentials'");
                return false;
            }

            // Validación: Si es CODE, RedirectUris es obligatorio
            if (view.CredentialType == "CODE" && (view.RedirectUris == null || !view.RedirectUris.Any()))
            {
                AddError("RedirectUris es obligatorio para credenciales de tipo CODE");
                return false;
            }

            // Validación: No permitir crear credencial del mismo tipo para la misma aplicación
            var sameTypeExists = await Repository.ExistsAsync(
                s => s.ApplicationId == view.ApplicationId 
                     && s.CredentialType == view.CredentialType 
                     && s.Id != view.Id 
                     && s.AuditDeletionDate == null,
                cancellationToken);
            
            if (sameTypeExists)
            {
                AddError($"Ya existe una credencial de tipo {view.CredentialType} para esta aplicación");
                return false;
            }

            return true;
        }

        protected override async Task PreviousActions(ApplicationSecurityView view, ApplicationSecurity entity, CancellationToken cancellationToken)
        {
            // Generar client_id si es creación
            if (view.Id == 0)
            {
                var application = await _applicationRepository.GetByIdAsync(view.ApplicationId, cancellationToken);
                var suffix = view.CredentialType == "CODE" ? "frontend" : "api";
                entity.ClientId = $"{application.DatabasePrefix}-{suffix}".ToLowerInvariant();
            }

            // Si es ClientCredentials, generar y hashear client_secret
            if (view.CredentialType == "ClientCredentials" && view.Id == 0)
            {
                // Generar secret seguro (32 caracteres)
                var secret = GenerateSecureSecret(32);
                
                // Guardar en view para mostrarlo UNA VEZ al usuario
                view.ClientSecret = secret;
                
                // Hashear con bcrypt (factor de trabajo 12)
                entity.ClientSecretHash = BCrypt.Net.BCrypt.HashPassword(secret, 12);
            }
            else if (view.CredentialType == "CODE")
            {
                // Public clients no tienen secret
                entity.ClientSecretHash = null;
                view.ClientSecret = null;
            }

            // Serializar RedirectUris a JSON
            if (view.RedirectUris != null && view.RedirectUris.Any())
            {
                entity.RedirectUris = System.Text.Json.JsonSerializer.Serialize(view.RedirectUris);
            }

            await base.PreviousActions(view, entity, cancellationToken);
        }

        /// <summary>
        /// Genera un secret criptográficamente seguro
        /// </summary>
        private string GenerateSecureSecret(int length)
        {
            const string validChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*";
            var randomBytes = new byte[length];
            using (var rng = RandomNumberGenerator.Create())
            {
                rng.GetBytes(randomBytes);
            }

            var result = new StringBuilder(length);
            foreach (var b in randomBytes)
            {
                result.Append(validChars[b % validChars.Length]);
            }

            return result.ToString();
        }

        /// <summary>
        /// Sobrescribir MapEntityToView para ocultar secrets en consultas
        /// </summary>
        protected override ApplicationSecurityView MapEntityToView(ApplicationSecurity entity)
        {
            var view = base.MapEntityToView(entity);
            
            // NUNCA devolver el secret en consultas posteriores
            view.ClientSecret = entity.ClientSecretHash != null ? "***" : null;
            
            // Deserializar RedirectUris de JSON
            if (!string.IsNullOrEmpty(entity.RedirectUris))
            {
                view.RedirectUris = System.Text.Json.JsonSerializer.Deserialize<List<string>>(entity.RedirectUris);
            }
            
            return view;
        }
    }
}
```

**Paso 7: Generar Endpoints**

Archivo: `InfoportOneAdmon.Api/Endpoints/ApplicationEndpoints.cs`

```csharp
using Helix6.Base.Api.Endpoints;
using InfoportOneAdmon.Entities.Views;
using InfoportOneAdmon.Services.Services;

namespace InfoportOneAdmon.Api.Endpoints
{
    public static class ApplicationEndpoints
    {
        public static void MapApplicationEndpoints(this IEndpointRouteBuilder app)
        {
            EndpointHelper.MapCrudEndpoints<ApplicationService, ApplicationView>(
                app,
                "applications",
                "Applications");

            EndpointHelper.MapCrudEndpoints<ApplicationSecurityService, ApplicationSecurityView>(
                app,
                "application-credentials",
                "ApplicationCredentials");
        }
    }
}
```

Registrar en Program.cs:

```csharp
app.MapApplicationEndpoints();
```

**Paso 8: Configurar DI**

Modificar: `InfoportOneAdmon.Services/DependencyInjection.cs`

```csharp
services.AddScoped<ApplicationService>();
services.AddScoped<ApplicationSecurityService>();
```

**Paso 9: Instalar paquete BCrypt**

```powershell
dotnet add package BCrypt.Net-Next --version 4.0.3
```

**Paso 10: Generar Migración**

```powershell
dotnet ef migrations add AddApplicationAndSecurityTables --project ..\InfoportOneAdmon.DataModel --startup-project InfoportOneAdmon.Api
dotnet ef database update
```

**Paso 11: Tests Unitarios**

Archivo: `InfoportOneAdmon.Services.Tests/Services/ApplicationServiceTests.cs`

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
    public class ApplicationServiceTests
    {
        private readonly Mock<ILogger<ApplicationService>> _loggerMock;
        private readonly Mock<IRepository<Application>> _repositoryMock;
        private readonly ApplicationService _service;

        public ApplicationServiceTests()
        {
            _loggerMock = new Mock<ILogger<ApplicationService>>();
            _repositoryMock = new Mock<IRepository<Application>>();
            _service = new ApplicationService(_loggerMock.Object, _repositoryMock.Object);
        }

        [Fact]
        public async Task ValidateView_WithValidData_ReturnsTrue()
        {
            // Arrange
            var view = new ApplicationView
            {
                Name = "CRM Application",
                RolePrefix = "CRM",
                DatabasePrefix = "crm"
            };
            
            _repositoryMock.Setup(r => r.ExistsAsync(
                It.IsAny<Expression<Func<Application, bool>>>(),
                It.IsAny<CancellationToken>()))
                .ReturnsAsync(false);

            // Act
            var result = await _service.ValidateView(view, CancellationToken.None);

            // Assert
            result.Should().BeTrue();
        }

        [Fact]
        public async Task ValidateView_WithDuplicateRolePrefix_ReturnsFalse()
        {
            // Arrange
            var view = new ApplicationView
            {
                Name = "New CRM",
                RolePrefix = "CRM",
                DatabasePrefix = "crm2"
            };
            
            _repositoryMock.Setup(r => r.ExistsAsync(
                It.Is<Expression<Func<Application, bool>>>(e => e.ToString().Contains("RolePrefix")),
                It.IsAny<CancellationToken>()))
                .ReturnsAsync(true);

            // Act
            var result = await _service.ValidateView(view, CancellationToken.None);

            // Assert
            result.Should().BeFalse();
            _service.Errors.Should().Contain(e => e.Contains("Ya existe una aplicación con el prefijo 'CRM'"));
        }

        [Fact]
        public async Task ValidateView_WhenEditingRolePrefix_ReturnsFalse()
        {
            // Arrange
            var originalApp = new Application
            {
                Id = 1,
                Name = "CRM",
                RolePrefix = "CRM",
                DatabasePrefix = "crm"
            };

            var view = new ApplicationView
            {
                Id = 1,
                Name = "CRM",
                RolePrefix = "ERP", // Intentando cambiar
                DatabasePrefix = "crm"
            };
            
            _repositoryMock.Setup(r => r.GetByIdAsync(1, It.IsAny<CancellationToken>()))
                .ReturnsAsync(originalApp);

            // Act
            var result = await _service.ValidateView(view, CancellationToken.None);

            // Assert
            result.Should().BeFalse();
            _service.Errors.Should().Contain(e => e.Contains("RolePrefix es inmutable"));
        }
    }
}
```

Archivo: `InfoportOneAdmon.Services.Tests/Services/ApplicationSecurityServiceTests.cs`

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
    public class ApplicationSecurityServiceTests
    {
        private readonly Mock<ILogger<ApplicationSecurityService>> _loggerMock;
        private readonly Mock<IRepository<ApplicationSecurity>> _repositoryMock;
        private readonly Mock<IRepository<Application>> _applicationRepositoryMock;
        private readonly ApplicationSecurityService _service;

        public ApplicationSecurityServiceTests()
        {
            _loggerMock = new Mock<ILogger<ApplicationSecurityService>>();
            _repositoryMock = new Mock<IRepository<ApplicationSecurity>>();
            _applicationRepositoryMock = new Mock<IRepository<Application>>();
            _service = new ApplicationSecurityService(
                _loggerMock.Object,
                _repositoryMock.Object,
                _applicationRepositoryMock.Object);
        }

        [Fact]
        public async Task PreviousActions_ForCODEType_GeneratesClientIdWithoutSecret()
        {
            // Arrange
            var application = new Application
            {
                Id = 1,
                DatabasePrefix = "crm"
            };

            _applicationRepositoryMock.Setup(r => r.GetByIdAsync(1, It.IsAny<CancellationToken>()))
                .ReturnsAsync(application);

            var view = new ApplicationSecurityView
            {
                ApplicationId = 1,
                CredentialType = "CODE",
                RedirectUris = new List<string> { "https://app.com/*" }
            };

            var entity = new ApplicationSecurity();

            // Act
            await _service.PreviousActions(view, entity, CancellationToken.None);

            // Assert
            entity.ClientId.Should().Be("crm-frontend");
            entity.ClientSecretHash.Should().BeNull();
            view.ClientSecret.Should().BeNull();
        }

        [Fact]
        public async Task PreviousActions_ForClientCredentialsType_GeneratesClientIdAndHashesSecret()
        {
            // Arrange
            var application = new Application
            {
                Id = 1,
                DatabasePrefix = "crm"
            };

            _applicationRepositoryMock.Setup(r => r.GetByIdAsync(1, It.IsAny<CancellationToken>()))
                .ReturnsAsync(application);

            var view = new ApplicationSecurityView
            {
                ApplicationId = 1,
                CredentialType = "ClientCredentials"
            };

            var entity = new ApplicationSecurity();

            // Act
            await _service.PreviousActions(view, entity, CancellationToken.None);

            // Assert
            entity.ClientId.Should().Be("crm-api");
            entity.ClientSecretHash.Should().NotBeNull();
            entity.ClientSecretHash.Should().StartWith("$2"); // bcrypt hash starts with $2
            view.ClientSecret.Should().NotBeNullOrEmpty();
            view.ClientSecret.Should().HaveLength(32);
        }

        [Fact]
        public async Task ValidateView_WithDuplicateCredentialType_ReturnsFalse()
        {
            // Arrange
            _applicationRepositoryMock.Setup(r => r.ExistsAsync(
                It.IsAny<Expression<Func<Application, bool>>>(),
                It.IsAny<CancellationToken>()))
                .ReturnsAsync(true);

            _repositoryMock.Setup(r => r.ExistsAsync(
                It.IsAny<Expression<Func<ApplicationSecurity, bool>>>(),
                It.IsAny<CancellationToken>()))
                .ReturnsAsync(true); // Ya existe credencial del mismo tipo

            var view = new ApplicationSecurityView
            {
                ApplicationId = 1,
                CredentialType = "CODE",
                RedirectUris = new List<string> { "https://app.com/*" }
            };

            // Act
            var result = await _service.ValidateView(view, CancellationToken.None);

            // Assert
            result.Should().BeFalse();
            _service.Errors.Should().Contain(e => e.Contains("Ya existe una credencial de tipo CODE"));
        }
    }
}
```

**ARCHIVOS A CREAR/MODIFICAR:**
- `InfoportOneAdmon.DataModel/Entities/Application.cs` - Entidad
- `InfoportOneAdmon.DataModel/Entities/ApplicationSecurity.cs` - Entidad
- `InfoportOneAdmon.DataModel/InfoportOneAdmonContext.cs` - Índices y relaciones
- `InfoportOneAdmon.Entities/Views/ApplicationView.cs` - ViewModel
- `InfoportOneAdmon.Entities/Views/ApplicationSecurityView.cs` - ViewModel
- `InfoportOneAdmon.Services/Services/ApplicationService.cs` - Servicio
- `InfoportOneAdmon.Services/Services/ApplicationSecurityService.cs` - Servicio
- `InfoportOneAdmon.Api/Endpoints/ApplicationEndpoints.cs` - Endpoints
- `InfoportOneAdmon.Services/DependencyInjection.cs` - Registro DI
- `InfoportOneAdmon.Api/Program.cs` - Mapeo endpoints
- `InfoportOneAdmon.Services.Tests/Services/ApplicationServiceTests.cs` - Tests
- `InfoportOneAdmon.Services.Tests/Services/ApplicationSecurityServiceTests.cs` - Tests
- Migraciones EF Core

**DEPENDENCIAS:**
Ninguna

**DEFINITION OF DONE:**
- [ ] Entidades Application y ApplicationSecurity creadas
- [ ] Índices únicos configurados (RolePrefix, DatabasePrefix, ClientId)
- [ ] ApplicationService con validación de unicidad e inmutabilidad
- [ ] ApplicationSecurityService con generación de client_id y secrets
- [ ] Hash bcrypt de secrets con factor 12
- [ ] Secrets nunca se devuelven en consultas (solo ***)
- [ ] Endpoints funcionales
- [ ] Tests unitarios >80% cobertura
- [ ] Tests validan generación de secrets y hashing
- [ ] Migración aplicada
- [ ] Code review aprobado

**RECURSOS:**
- Arquitectura Backend: `Helix6_Backend_Architecture.md`
- User Story: `userStories.md#us-009`
- BCrypt documentation: https://github.com/BcryptNet/bcrypt.net

=============================================================

---

#### TASK-009-KC: Integrar con Keycloak Admin API para crear public clients con PKCE

=============================================================
**TICKET ID:** TASK-009-KC  
**EPIC:** Administración de Aplicaciones del Ecosistema  
**USER STORY:** US-009 - Registrar aplicación frontend (SPA)  
**COMPONENT:** Backend - Keycloak Integration  
**PRIORITY:** Alta  
**ESTIMATION:** 6 horas  
=============================================================

**TÍTULO:**
Integrar con Keycloak Admin API para crear public clients con PKCE

**DESCRIPCIÓN:**
Implementar integración con Keycloak Admin API para automatizar la creación de clients OAuth2 cuando se registra una aplicación. Esto incluye:
- Para credenciales CODE: crear public client con PKCE S256 habilitado
- Para credenciales ClientCredentials: crear confidential client con client-secret
- Configurar Protocol Mapper para claim `c_ids` (lista de SecurityCompanyId)
- Sincronizar cambios cuando se modifica/desactiva una aplicación

**CONTEXTO TÉCNICO:**
- **Keycloak Admin API**: Requiere autenticación con client credentials de un admin client
- **PKCE obligatorio**: Todos los clients CODE deben tener `pkceCodeChallengeMethod: S256`
- **Protocol Mapper**: Custom mapper que añade claim `c_ids` al token con los SecurityCompanyId de las organizaciones del usuario
- **Idempotencia**: Si el client ya existe en Keycloak, actualizar configuración en lugar de fallar

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] Servicio KeycloakAdminService creado con autenticación admin
- [ ] Método CreatePublicClient crea client CODE con PKCE S256
- [ ] Método CreateConfidentialClient crea client ClientCredentials
- [ ] Protocol Mapper `c_ids` se añade automáticamente a todos los clients
- [ ] Método UpdateClient actualiza RedirectURIs y configuración
- [ ] Método DisableClient deshabilita client al desactivar aplicación
- [ ] Manejo de errores de Keycloak con reintentos
- [ ] Tests de integración con Keycloak Testcontainer

**GUÍA DE IMPLEMENTACIÓN:**

**Paso 1: Crear Configuración de Keycloak**

Archivo: `InfoportOneAdmon.Api/appsettings.json`

```json
{
  "Keycloak": {
    "BaseUrl": "https://keycloak.infoportone.com",
    "Realm": "infoportone",
    "AdminClientId": "infoportone-admin-cli",
    "AdminClientSecret": "${KEYCLOAK_ADMIN_SECRET}",
    "TokenEndpoint": "https://keycloak.infoportone.com/realms/infoportone/protocol/openid-connect/token"
  }
}
```

**Paso 2: Crear Servicio KeycloakAdminService**

Archivo: `InfoportOneAdmon.Services/Integration/KeycloakAdminService.cs`

```csharp
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace InfoportOneAdmon.Services.Integration
{
    public class KeycloakAdminService
    {
        private readonly HttpClient _httpClient;
        private readonly IConfiguration _configuration;
        private readonly ILogger<KeycloakAdminService> _logger;
        private string _accessToken;
        private DateTime _tokenExpiration;

        public KeycloakAdminService(
            HttpClient httpClient,
            IConfiguration configuration,
            ILogger<KeycloakAdminService> logger)
        {
            _httpClient = httpClient;
            _configuration = configuration;
            _logger = logger;
        }

        /// <summary>
        /// Obtiene token de acceso del admin client
        /// </summary>
        private async Task<string> GetAccessTokenAsync()
        {
            // Reutilizar token si aún es válido
            if (!string.IsNullOrEmpty(_accessToken) && DateTime.UtcNow < _tokenExpiration)
            {
                return _accessToken;
            }

            var tokenEndpoint = _configuration["Keycloak:TokenEndpoint"];
            var clientId = _configuration["Keycloak:AdminClientId"];
            var clientSecret = _configuration["Keycloak:AdminClientSecret"];

            var requestData = new Dictionary<string, string>
            {
                { "grant_type", "client_credentials" },
                { "client_id", clientId },
                { "client_secret", clientSecret }
            };

            var response = await _httpClient.PostAsync(tokenEndpoint, new FormUrlEncodedContent(requestData));
            response.EnsureSuccessStatusCode();

            var tokenResponse = await response.Content.ReadFromJsonAsync<TokenResponse>();
            _accessToken = tokenResponse.AccessToken;
            _tokenExpiration = DateTime.UtcNow.AddSeconds(tokenResponse.ExpiresIn - 60); // Renovar 1 min antes

            return _accessToken;
        }

        /// <summary>
        /// Crea un public client (CODE) con PKCE S256 en Keycloak
        /// </summary>
        public async Task<bool> CreatePublicClientAsync(string clientId, List<string> redirectUris)
        {
            try
            {
                var token = await GetAccessTokenAsync();
                var realm = _configuration["Keycloak:Realm"];
                var baseUrl = _configuration["Keycloak:BaseUrl"];
                var url = $"{baseUrl}/admin/realms/{realm}/clients";

                var clientRepresentation = new
                {
                    clientId = clientId,
                    enabled = true,
                    publicClient = true, // Public client (no secret)
                    protocol = "openid-connect",
                    redirectUris = redirectUris,
                    webOrigins = new[] { "*" }, // CORS
                    standardFlowEnabled = true, // Authorization Code Flow
                    directAccessGrantsEnabled = false,
                    implicitFlowEnabled = false,
                    serviceAccountsEnabled = false,
                    
                    // PKCE obligatorio
                    attributes = new Dictionary<string, string>
                    {
                        { "pkce.code.challenge.method", "S256" },
                        { "post.logout.redirect.uris", "+" }
                    },

                    // Protocol Mappers
                    protocolMappers = new[]
                    {
                        CreateCompanyIdsMapper()
                    }
                };

                _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
                var content = new StringContent(JsonSerializer.Serialize(clientRepresentation), Encoding.UTF8, "application/json");
                var response = await _httpClient.PostAsync(url, content);

                if (response.StatusCode == System.Net.HttpStatusCode.Conflict)
                {
                    _logger.LogWarning($"Client {clientId} ya existe en Keycloak. Actualizando...");
                    return await UpdateClientAsync(clientId, redirectUris);
                }

                response.EnsureSuccessStatusCode();
                _logger.LogInformation($"Public client {clientId} creado exitosamente en Keycloak");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error creando public client {clientId} en Keycloak");
                throw;
            }
        }

        /// <summary>
        /// Crea un confidential client (ClientCredentials) en Keycloak
        /// </summary>
        public async Task<bool> CreateConfidentialClientAsync(string clientId, string clientSecret)
        {
            try
            {
                var token = await GetAccessTokenAsync();
                var realm = _configuration["Keycloak:Realm"];
                var baseUrl = _configuration["Keycloak:BaseUrl"];
                var url = $"{baseUrl}/admin/realms/{realm}/clients";

                var clientRepresentation = new
                {
                    clientId = clientId,
                    enabled = true,
                    publicClient = false, // Confidential client
                    secret = clientSecret, // Client secret
                    protocol = "openid-connect",
                    standardFlowEnabled = false,
                    directAccessGrantsEnabled = false,
                    implicitFlowEnabled = false,
                    serviceAccountsEnabled = true, // Client Credentials Flow
                    
                    clientAuthenticatorType = "client-secret",

                    // Protocol Mappers
                    protocolMappers = new[]
                    {
                        CreateCompanyIdsMapper()
                    }
                };

                _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
                var content = new StringContent(JsonSerializer.Serialize(clientRepresentation), Encoding.UTF8, "application/json");
                var response = await _httpClient.PostAsync(url, content);

                if (response.StatusCode == System.Net.HttpStatusCode.Conflict)
                {
                    _logger.LogWarning($"Client {clientId} ya existe en Keycloak. Actualizando...");
                    return await UpdateConfidentialClientSecretAsync(clientId, clientSecret);
                }

                response.EnsureSuccessStatusCode();
                _logger.LogInformation($"Confidential client {clientId} creado exitosamente en Keycloak");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error creando confidential client {clientId} en Keycloak");
                throw;
            }
        }

        /// <summary>
        /// Actualiza RedirectURIs de un client existente
        /// </summary>
        public async Task<bool> UpdateClientAsync(string clientId, List<string> redirectUris)
        {
            try
            {
                var token = await GetAccessTokenAsync();
                var realm = _configuration["Keycloak:Realm"];
                var baseUrl = _configuration["Keycloak:BaseUrl"];
                
                // 1. Obtener UUID del client
                var clientUuid = await GetClientUuidAsync(clientId);
                if (clientUuid == null)
                {
                    _logger.LogError($"Client {clientId} no encontrado en Keycloak");
                    return false;
                }

                // 2. Actualizar configuración
                var url = $"{baseUrl}/admin/realms/{realm}/clients/{clientUuid}";
                var updateData = new
                {
                    redirectUris = redirectUris,
                    webOrigins = new[] { "*" }
                };

                _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
                var content = new StringContent(JsonSerializer.Serialize(updateData), Encoding.UTF8, "application/json");
                var response = await _httpClient.PutAsync(url, content);
                response.EnsureSuccessStatusCode();

                _logger.LogInformation($"Client {clientId} actualizado exitosamente en Keycloak");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error actualizando client {clientId} en Keycloak");
                throw;
            }
        }

        /// <summary>
        /// Actualiza el secret de un confidential client
        /// </summary>
        public async Task<bool> UpdateConfidentialClientSecretAsync(string clientId, string newSecret)
        {
            try
            {
                var token = await GetAccessTokenAsync();
                var realm = _configuration["Keycloak:Realm"];
                var baseUrl = _configuration["Keycloak:BaseUrl"];
                
                var clientUuid = await GetClientUuidAsync(clientId);
                if (clientUuid == null) return false;

                var url = $"{baseUrl}/admin/realms/{realm}/clients/{clientUuid}";
                var updateData = new { secret = newSecret };

                _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
                var content = new StringContent(JsonSerializer.Serialize(updateData), Encoding.UTF8, "application/json");
                var response = await _httpClient.PutAsync(url, content);
                response.EnsureSuccessStatusCode();

                _logger.LogInformation($"Secret de client {clientId} actualizado en Keycloak");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error actualizando secret de {clientId}");
                throw;
            }
        }

        /// <summary>
        /// Deshabilita un client en Keycloak
        /// </summary>
        public async Task<bool> DisableClientAsync(string clientId)
        {
            try
            {
                var token = await GetAccessTokenAsync();
                var realm = _configuration["Keycloak:Realm"];
                var baseUrl = _configuration["Keycloak:BaseUrl"];
                
                var clientUuid = await GetClientUuidAsync(clientId);
                if (clientUuid == null) return false;

                var url = $"{baseUrl}/admin/realms/{realm}/clients/{clientUuid}";
                var updateData = new { enabled = false };

                _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
                var content = new StringContent(JsonSerializer.Serialize(updateData), Encoding.UTF8, "application/json");
                var response = await _httpClient.PutAsync(url, content);
                response.EnsureSuccessStatusCode();

                _logger.LogInformation($"Client {clientId} deshabilitado en Keycloak");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error deshabilitando client {clientId}");
                throw;
            }
        }

        /// <summary>
        /// Obtiene el UUID interno del client en Keycloak
        /// </summary>
        private async Task<string> GetClientUuidAsync(string clientId)
        {
            var token = await GetAccessTokenAsync();
            var realm = _configuration["Keycloak:Realm"];
            var baseUrl = _configuration["Keycloak:BaseUrl"];
            var url = $"{baseUrl}/admin/realms/{realm}/clients?clientId={clientId}";

            _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
            var response = await _httpClient.GetAsync(url);
            response.EnsureSuccessStatusCode();

            var clients = await response.Content.ReadFromJsonAsync<List<ClientRepresentation>>();
            return clients?.FirstOrDefault()?.Id;
        }

        /// <summary>
        /// Crea el Protocol Mapper para el claim c_ids
        /// </summary>
        private object CreateCompanyIdsMapper()
        {
            return new
            {
                name = "company-ids-mapper",
                protocol = "openid-connect",
                protocolMapper = "oidc-usermodel-attribute-mapper",
                consentRequired = false,
                config = new Dictionary<string, string>
                {
                    { "user.attribute", "c_ids" },
                    { "claim.name", "c_ids" },
                    { "jsonType.label", "String" },
                    { "id.token.claim", "true" },
                    { "access.token.claim", "true" },
                    { "userinfo.token.claim", "true" },
                    { "multivalued", "true" }
                }
            };
        }

        // DTOs
        private class TokenResponse
        {
            public string AccessToken { get; set; }
            public int ExpiresIn { get; set; }
        }

        private class ClientRepresentation
        {
            public string Id { get; set; }
            public string ClientId { get; set; }
        }
    }
}
```

**Paso 3: Modificar ApplicationSecurityService para Llamar a Keycloak**

Modificar: `InfoportOneAdmon.Services/Services/ApplicationSecurityService.cs`

Inyectar KeycloakAdminService y llamar en PostActions:

```csharp
private readonly KeycloakAdminService _keycloakService;

public ApplicationSecurityService(
    ILogger<ApplicationSecurityService> logger,
    IRepository<ApplicationSecurity> repository,
    IRepository<Application> applicationRepository,
    KeycloakAdminService keycloakService) // NUEVO
    : base(logger, repository)
{
    _applicationRepository = applicationRepository;
    _keycloakService = keycloakService;
}

protected override async Task PostActions(ApplicationSecurityView view, ApplicationSecurity entity, CancellationToken cancellationToken)
{
    // Crear client en Keycloak
    if (view.Id == 0) // Solo en creación
    {
        if (entity.CredentialType == "CODE")
        {
            await _keycloakService.CreatePublicClientAsync(entity.ClientId, view.RedirectUris);
        }
        else if (entity.CredentialType == "ClientCredentials")
        {
            // IMPORTANTE: Usar el secret en texto plano (view.ClientSecret) que se generó en PreviousActions
            await _keycloakService.CreateConfidentialClientAsync(entity.ClientId, view.ClientSecret);
        }
    }
    
    await base.PostActions(view, entity, cancellationToken);
}
```

**Paso 4: Configurar DI**

Modificar: `InfoportOneAdmon.Services/DependencyInjection.cs`

```csharp
services.AddHttpClient<KeycloakAdminService>();
services.AddScoped<KeycloakAdminService>();
```

**Paso 5: Tests con Keycloak Testcontainer**

Archivo: `InfoportOneAdmon.Services.Tests/Integration/KeycloakAdminServiceTests.cs`

```csharp
using Xunit;
using FluentAssertions;
using Testcontainers.Keycloak;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace InfoportOneAdmon.Services.Tests.Integration
{
    public class KeycloakAdminServiceTests : IAsyncLifetime
    {
        private KeycloakContainer _keycloakContainer;
        private KeycloakAdminService _service;

        public async Task InitializeAsync()
        {
            _keycloakContainer = new KeycloakBuilder()
                .WithImage("quay.io/keycloak/keycloak:23.0")
                .WithEnvironment("KEYCLOAK_ADMIN", "admin")
                .WithEnvironment("KEYCLOAK_ADMIN_PASSWORD", "admin")
                .WithCommand("start-dev")
                .Build();

            await _keycloakContainer.StartAsync();

            // Configurar servicio apuntando al contenedor
            var configuration = new ConfigurationBuilder()
                .AddInMemoryCollection(new Dictionary<string, string>
                {
                    { "Keycloak:BaseUrl", _keycloakContainer.GetBaseAddress() },
                    { "Keycloak:Realm", "master" },
                    { "Keycloak:AdminClientId", "admin-cli" },
                    { "Keycloak:AdminClientSecret", "" }, // admin-cli no necesita secret
                    { "Keycloak:TokenEndpoint", $"{_keycloakContainer.GetBaseAddress()}/realms/master/protocol/openid-connect/token" }
                })
                .Build();

            var httpClient = new HttpClient();
            var logger = new LoggerFactory().CreateLogger<KeycloakAdminService>();
            _service = new KeycloakAdminService(httpClient, configuration, logger);
        }

        [Fact]
        public async Task CreatePublicClient_WithValidData_CreatesClientSuccessfully()
        {
            // Arrange
            var clientId = "test-spa-frontend";
            var redirectUris = new List<string> { "http://localhost:4200/*" };

            // Act
            var result = await _service.CreatePublicClientAsync(clientId, redirectUris);

            // Assert
            result.Should().BeTrue();
        }

        [Fact]
        public async Task CreateConfidentialClient_WithValidData_CreatesClientSuccessfully()
        {
            // Arrange
            var clientId = "test-api-backend";
            var secret = "super-secret-value-123";

            // Act
            var result = await _service.CreateConfidentialClientAsync(clientId, secret);

            // Assert
            result.Should().BeTrue();
        }

        [Fact]
        public async Task UpdateClient_WithNewRedirectUris_UpdatesSuccessfully()
        {
            // Arrange: Crear client primero
            var clientId = "update-test-client";
            await _service.CreatePublicClientAsync(clientId, new List<string> { "http://old-url/*" });

            // Act: Actualizar con nuevas URIs
            var newUris = new List<string> { "http://new-url/*", "http://another-url/*" };
            var result = await _service.UpdateClientAsync(clientId, newUris);

            // Assert
            result.Should().BeTrue();
        }

        [Fact]
        public async Task DisableClient_ExistingClient_DisablesSuccessfully()
        {
            // Arrange: Crear client primero
            var clientId = "disable-test-client";
            await _service.CreatePublicClientAsync(clientId, new List<string> { "http://test/*" });

            // Act
            var result = await _service.DisableClientAsync(clientId);

            // Assert
            result.Should().BeTrue();
        }

        public async Task DisposeAsync()
        {
            await _keycloakContainer.DisposeAsync();
        }
    }
}
```

**Paso 6: Instalar Paquetes NuGet**

```powershell
dotnet add package Testcontainers.Keycloak --version 3.7.0
```

**ARCHIVOS A CREAR/MODIFICAR:**
- `InfoportOneAdmon.Services/Integration/KeycloakAdminService.cs` - Servicio de integración
- `InfoportOneAdmon.Services/Services/ApplicationSecurityService.cs` - Añadir llamadas a Keycloak
- `InfoportOneAdmon.Api/appsettings.json` - Configuración de Keycloak
- `InfoportOneAdmon.Services/DependencyInjection.cs` - Registro HttpClient
- `InfoportOneAdmon.Services.Tests/Integration/KeycloakAdminServiceTests.cs` - Tests con Testcontainer

**DEPENDENCIAS:**
- TASK-009-BE - ApplicationSecurityService existe

**DEFINITION OF DONE:**
- [ ] KeycloakAdminService implementado con autenticación admin
- [ ] Método CreatePublicClient funcional con PKCE S256
- [ ] Método CreateConfidentialClient funcional
- [ ] Protocol Mapper c_ids se añade automáticamente
- [ ] Actualización de RedirectURIs funcional
- [ ] Deshabilitación de clients funcional
- [ ] Manejo de idempotencia (si client existe, actualizar)
- [ ] Tests con Keycloak Testcontainer pasando
- [ ] Configuración en appsettings.json
- [ ] Code review aprobado

**RECURSOS:**
- Keycloak Admin REST API: https://www.keycloak.org/docs-api/23.0/rest-api/index.html
- Testcontainers Keycloak: https://dotnet.testcontainers.org/modules/keycloak/
- User Story: `userStories.md#us-009`

=============================================================

---

#### TASK-009-EV-PUB: Publicar ApplicationEvent al crear/modificar aplicaciones

=============================================================
**TICKET ID:** TASK-009-EV-PUB  
**EPIC:** Administración de Aplicaciones del Ecosistema  
**USER STORY:** US-009 - Registrar aplicación frontend (SPA)  
**COMPONENT:** Backend - Event Publishing  
**PRIORITY:** Alta  
**ESTIMATION:** 3 horas  
=============================================================

**TÍTULO:**
Publicar ApplicationEvent al crear/modificar aplicaciones

**DESCRIPCIÓN:**
Implementar publicación de eventos `ApplicationEvent` mediante IPVInterchangeShared cuando se crea, modifica o desactiva una aplicación. Las aplicaciones satélite se suscriben a estos eventos para:
- Actualizar catálogo local de aplicaciones disponibles
- Sincronizar módulos y roles definidos
- Conocer prefijos para validación de nomenclatura

El evento sigue el patrón State Transfer: contiene el estado completo de la aplicación.

**CONTEXTO TÉCNICO:**
- **Patrón**: State Transfer completo (no solo campos modificados)
- **Broker**: ActiveMQ Artemis con IPVInterchangeShared
- **Topic**: `application.events`
- **Persistencia**: Eventos se guardan en tabla INTEGRATION_EVENTS antes de publicar
- **IsDeleted**: Indica si la aplicación fue desactivada (soft delete)

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] Clase ApplicationEvent creada siguiendo estructura de EventBase
- [ ] Publicación en PostActions de ApplicationService
- [ ] Evento incluye: ApplicationId, Name, RolePrefix, DatabasePrefix, Modules, Roles, IsDeleted
- [ ] Configuración en appsettings.json del topic
- [ ] Tests con Testcontainers (PostgreSQL + Artemis)
- [ ] Evento se persiste en INTEGRATION_EVENTS
- [ ] Documentación del schema del evento

**GUÍA DE IMPLEMENTACIÓN:**

**Paso 1: Crear Clase ApplicationEvent**

Archivo: `InfoportOneAdmon.Entities/Events/ApplicationEvent.cs`

```csharp
using IPVInterchangeShared.Broker.Events;

namespace InfoportOneAdmon.Entities.Events
{
    /// <summary>
    /// Evento publicado cuando se crea, modifica o desactiva una aplicación
    /// </summary>
    public class ApplicationEvent : EventBase
    {
        /// <summary>
        /// ID de la aplicación en InfoportOneAdmon
        /// </summary>
        public int ApplicationId { get; set; }
        
        /// <summary>
        /// Nombre de la aplicación
        /// </summary>
        public string Name { get; set; }
        
        /// <summary>
        /// Prefijo de roles (ej: "CRM", "STP")
        /// </summary>
        public string RolePrefix { get; set; }
        
        /// <summary>
        /// Prefijo para nombres de bases de datos
        /// </summary>
        public string DatabasePrefix { get; set; }
        
        /// <summary>
        /// Descripción de la aplicación
        /// </summary>
        public string Description { get; set; }
        
        /// <summary>
        /// Lista de módulos funcionales de la aplicación
        /// </summary>
        public List<ModuleInfo> Modules { get; set; }
        
        /// <summary>
        /// Lista de roles definidos para la aplicación
        /// </summary>
        public List<RoleInfo> Roles { get; set; }
        
        /// <summary>
        /// Credenciales OAuth2 de la aplicación
        /// </summary>
        public List<CredentialInfo> Credentials { get; set; }
        
        /// <summary>
        /// Indica si la aplicación fue desactivada (soft delete)
        /// </summary>
        public bool IsDeleted { get; set; }
        
        /// <summary>
        /// Fecha de creación
        /// </summary>
        public DateTime CreatedAt { get; set; }
        
        /// <summary>
        /// Fecha de última modificación
        /// </summary>
        public DateTime? ModifiedAt { get; set; }
    }

    public class ModuleInfo
    {
        public int ModuleId { get; set; }
        public string ModuleName { get; set; }
        public string Description { get; set; }
        public int DisplayOrder { get; set; }
    }

    public class RoleInfo
    {
        public int RoleId { get; set; }
        public string RoleName { get; set; }
        public string Description { get; set; }
        public bool IsActive { get; set; }
    }

    public class CredentialInfo
    {
        public string CredentialType { get; set; } // "CODE" | "ClientCredentials"
        public string ClientId { get; set; }
        public bool IsActive { get; set; }
    }
}
```

**Paso 2: Modificar ApplicationService para Publicar Evento**

Modificar: `InfoportOneAdmon.Services/Services/ApplicationService.cs`

```csharp
using IPVInterchangeShared.Broker;
using InfoportOneAdmon.Entities.Events;

private readonly IMessagePublisher _messagePublisher;
private readonly IConfiguration _configuration;

public ApplicationService(
    ILogger<ApplicationService> logger,
    IRepository<Application> repository,
    IMessagePublisher messagePublisher,
    IConfiguration configuration)
    : base(logger, repository)
{
    _messagePublisher = messagePublisher;
    _configuration = configuration;
}

protected override async Task PostActions(ApplicationView view, Application entity, CancellationToken cancellationToken)
{
    // Publicar evento ApplicationEvent
    await PublishApplicationEventAsync(entity, cancellationToken);
    
    await base.PostActions(view, entity, cancellationToken);
}

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
        CreatedAt = application.AuditCreationDate ?? DateTime.UtcNow,
        ModifiedAt = application.AuditModificationDate,
        
        // Cargar módulos relacionados (lazy loading)
        Modules = application.Modules?
            .Where(m => m.AuditDeletionDate == null)
            .Select(m => new ModuleInfo
            {
                ModuleId = m.Id,
                ModuleName = m.ModuleName,
                Description = m.Description,
                DisplayOrder = m.DisplayOrder
            })
            .ToList() ?? new List<ModuleInfo>(),
        
        // Cargar roles relacionados
        Roles = application.Roles?
            .Where(r => r.AuditDeletionDate == null)
            .Select(r => new RoleInfo
            {
                RoleId = r.Id,
                RoleName = r.RoleName,
                Description = r.Description,
                IsActive = r.IsActive
            })
            .ToList() ?? new List<RoleInfo>(),
        
        // Cargar credenciales
        Credentials = application.Credentials?
            .Where(c => c.AuditDeletionDate == null)
            .Select(c => new CredentialInfo
            {
                CredentialType = c.CredentialType,
                ClientId = c.ClientId,
                IsActive = c.IsActive
            })
            .ToList() ?? new List<CredentialInfo>()
    };

    // Publicar al topic configurado
    var topic = _configuration["EventBroker:Topics:ApplicationEvents"];
    await _messagePublisher.PublishAsync(topic, applicationEvent, cancellationToken);
    
    Logger.LogInformation($"ApplicationEvent publicado para Application ID {application.Id}");
}
```

**Paso 3: Configurar Topic en appsettings.json**

Modificar: `InfoportOneAdmon.Api/appsettings.json`

```json
{
  "EventBroker": {
    "Topics": {
      "OrganizationEvents": "organization.events",
      "ApplicationEvents": "application.events"
    },
    "RetryPolicy": {
      "MaxRetries": 3,
      "RetryDelayMs": 1000
    }
  }
}
```

**Paso 4: Tests con Testcontainers**

Archivo: `InfoportOneAdmon.Services.Tests/Events/ApplicationEventPublisherTests.cs`

```csharp
using Xunit;
using FluentAssertions;
using Moq;
using Testcontainers.PostgreSql;
using Testcontainers.ActiveMq;
using IPVInterchangeShared.Broker;
using InfoportOneAdmon.Services.Services;
using InfoportOneAdmon.Entities.Events;
using InfoportOneAdmon.DataModel.Entities;

namespace InfoportOneAdmon.Services.Tests.Events
{
    public class ApplicationEventPublisherTests : IAsyncLifetime
    {
        private PostgreSqlContainer _postgresContainer;
        private ActiveMqContainer _artemisContainer;
        private Mock<IMessagePublisher> _publisherMock;

        public async Task InitializeAsync()
        {
            _postgresContainer = new PostgreSqlBuilder()
                .WithImage("postgres:16")
                .Build();

            _artemisContainer = new ActiveMqBuilder()
                .WithImage("apache/activemq-artemis:latest")
                .Build();

            await Task.WhenAll(
                _postgresContainer.StartAsync(),
                _artemisContainer.StartAsync()
            );

            _publisherMock = new Mock<IMessagePublisher>();
        }

        [Fact]
        public async Task PostActions_WhenApplicationCreated_PublishesEvent()
        {
            // Arrange
            var application = new Application
            {
                Id = 1,
                Name = "Test CRM",
                RolePrefix = "CRM",
                DatabasePrefix = "crm",
                AuditCreationDate = DateTime.UtcNow,
                Modules = new List<Module>
                {
                    new Module { Id = 1, ModuleName = "MCRM_Ventas", DisplayOrder = 1 }
                },
                Roles = new List<AppRoleDefinition>
                {
                    new AppRoleDefinition { Id = 1, RoleName = "CRM_Vendedor", IsActive = true }
                }
            };

            ApplicationEvent publishedEvent = null;
            _publisherMock.Setup(p => p.PublishAsync(
                It.IsAny<string>(),
                It.IsAny<ApplicationEvent>(),
                It.IsAny<CancellationToken>()))
                .Callback<string, ApplicationEvent, CancellationToken>((topic, evt, ct) => publishedEvent = evt)
                .Returns(Task.CompletedTask);

            var service = CreateService(_publisherMock.Object);

            // Act
            await service.PostActions(MapEntityToView(application), application, CancellationToken.None);

            // Assert
            _publisherMock.Verify(p => p.PublishAsync(
                "application.events",
                It.IsAny<ApplicationEvent>(),
                It.IsAny<CancellationToken>()),
                Times.Once);

            publishedEvent.Should().NotBeNull();
            publishedEvent.ApplicationId.Should().Be(1);
            publishedEvent.Name.Should().Be("Test CRM");
            publishedEvent.RolePrefix.Should().Be("CRM");
            publishedEvent.IsDeleted.Should().BeFalse();
            publishedEvent.Modules.Should().HaveCount(1);
            publishedEvent.Roles.Should().HaveCount(1);
        }

        [Fact]
        public async Task PostActions_WhenApplicationDeleted_PublishesEventWithIsDeletedTrue()
        {
            // Arrange
            var application = new Application
            {
                Id = 2,
                Name = "Deleted App",
                RolePrefix = "DEL",
                DatabasePrefix = "deleted",
                AuditDeletionDate = DateTime.UtcNow // Soft delete
            };

            ApplicationEvent publishedEvent = null;
            _publisherMock.Setup(p => p.PublishAsync(
                It.IsAny<string>(),
                It.IsAny<ApplicationEvent>(),
                It.IsAny<CancellationToken>()))
                .Callback<string, ApplicationEvent, CancellationToken>((topic, evt, ct) => publishedEvent = evt)
                .Returns(Task.CompletedTask);

            var service = CreateService(_publisherMock.Object);

            // Act
            await service.PostActions(MapEntityToView(application), application, CancellationToken.None);

            // Assert
            publishedEvent.Should().NotBeNull();
            publishedEvent.IsDeleted.Should().BeTrue();
        }

        public async Task DisposeAsync()
        {
            await Task.WhenAll(
                _postgresContainer.DisposeAsync().AsTask(),
                _artemisContainer.DisposeAsync().AsTask()
            );
        }

        private ApplicationService CreateService(IMessagePublisher publisher)
        {
            // Setup service with mocks
            // ...
        }
    }
}
```

**Paso 5: Documentar Schema del Evento**

Archivo: `docs/events/ApplicationEvent.md`

```markdown
# ApplicationEvent

Evento publicado cuando se crea, modifica o desactiva una aplicación.

## Topic
`application.events`

## Schema

```json
{
  "ApplicationId": 1,
  "Name": "CRM Valenciaport",
  "RolePrefix": "CRM",
  "DatabasePrefix": "crm",
  "Description": "Sistema de gestión de clientes",
  "Modules": [
    {
      "ModuleId": 1,
      "ModuleName": "MCRM_Ventas",
      "Description": "Módulo de ventas",
      "DisplayOrder": 1
    }
  ],
  "Roles": [
    {
      "RoleId": 1,
      "RoleName": "CRM_Vendedor",
      "Description": "Rol de vendedor",
      "IsActive": true
    }
  ],
  "Credentials": [
    {
      "CredentialType": "CODE",
      "ClientId": "crm-frontend",
      "IsActive": true
    },
    {
      "CredentialType": "ClientCredentials",
      "ClientId": "crm-api",
      "IsActive": true
    }
  ],
  "IsDeleted": false,
  "CreatedAt": "2026-01-31T10:00:00Z",
  "ModifiedAt": "2026-01-31T15:30:00Z"
}
```

## Casos de uso

1. **Aplicación creada**: `IsDeleted: false`, contiene módulos y roles iniciales
2. **Aplicación modificada**: `ModifiedAt` actualizado, puede incluir nuevos módulos/roles
3. **Aplicación desactivada**: `IsDeleted: true`
4. **Módulo añadido**: Evento completo con lista actualizada de módulos
5. **Rol añadido**: Evento completo con lista actualizada de roles

## Suscriptores

- Todas las aplicaciones satélite para sincronizar catálogo
- Sistema de auditoría para trazabilidad
```

**ARCHIVOS A CREAR/MODIFICAR:**
- `InfoportOneAdmon.Entities/Events/ApplicationEvent.cs` - Clase del evento
- `InfoportOneAdmon.Services/Services/ApplicationService.cs` - Publicación
- `InfoportOneAdmon.Api/appsettings.json` - Configuración del topic
- `InfoportOneAdmon.Services.Tests/Events/ApplicationEventPublisherTests.cs` - Tests
- `docs/events/ApplicationEvent.md` - Documentación

**DEPENDENCIAS:**
- TASK-009-BE - ApplicationService existe
- IPVInterchangeShared - Broker configurado

**DEFINITION OF DONE:**
- [ ] ApplicationEvent creado con estructura completa
- [ ] Publicación en PostActions implementada
- [ ] Evento incluye módulos, roles y credenciales
- [ ] IsDeleted correcto para soft delete
- [ ] Configuración del topic en appsettings
- [ ] Tests con Testcontainers pasando
- [ ] Documentación del evento completa
- [ ] Code review aprobado

**RECURSOS:**
- IPVInterchangeShared documentation
- User Story: `userStories.md#us-009`

=============================================================

---

### US-010: Registrar aplicación backend (API)

**Resumen de tickets generados:**
- TASK-010-NOTE: Backend de aplicación API ya implementado en TASK-009-BE
- TASK-010-UX: Modal "Copiar secreto una sola vez" en frontend

---

#### TASK-010-NOTE: Backend de aplicación API ya implementado en TASK-009-BE

=============================================================
**TICKET ID:** TASK-010-NOTE  
**EPIC:** Administración de Aplicaciones del Ecosistema  
**USER STORY:** US-010 - Registrar aplicación backend (API)  
**COMPONENT:** Backend - Nota Arquitectónica  
**PRIORITY:** Alta  
**ESTIMATION:** 0 horas (Solo documentación)  
=============================================================

**TÍTULO:**
Documentar que el backend para aplicaciones API ya está implementado

**DESCRIPCIÓN:**
Este ticket documenta que **NO se requiere desarrollo backend adicional** para US-010. El backend para registrar aplicaciones API (confidential clients con ClientCredentials) ya fue implementado completamente en **TASK-009-BE** y **TASK-009-KC**.

**Funcionalidad ya implementada:**
- ✅ ApplicationSecurity con CredentialType "ClientCredentials"
- ✅ Generación segura de client_secret (32 caracteres) con RandomNumberGenerator
- ✅ Hash bcrypt del secret antes de almacenar (factor 12)
- ✅ Secret en texto plano se devuelve SOLO en la creación (view.ClientSecret)
- ✅ En consultas posteriores, ClientSecret siempre retorna "***"
- ✅ Keycloak confidential client creado automáticamente con el secret

**Lo único pendiente es la interfaz de usuario (TASK-010-UX):**
- Modal que muestre el secret UNA SOLA VEZ tras la creación
- Botón "Copiar al portapapeles"
- Advertencia: "Guarde este secreto ahora. No se podrá recuperar después"

**Evidencia de implementación:**

En `ApplicationSecurityService.cs` (TASK-009-BE):
```csharp
// Generación segura del secret (línea ~150)
if (view.CredentialType == "ClientCredentials" && view.Id == 0)
{
    var secret = GenerateSecureSecret(32); // 32 caracteres aleatorios
    view.ClientSecret = secret; // Se devuelve UNA VEZ en la creación
    entity.ClientSecretHash = BCrypt.Net.BCrypt.HashPassword(secret, 12); // Solo se almacena el hash
}

// Ocultar secret en consultas posteriores (línea ~180)
protected override ApplicationSecurityView MapEntityToView(ApplicationSecurity entity)
{
    var view = base.MapEntityToView(entity);
    view.ClientSecret = entity.ClientSecretHash != null ? "***" : null; // NUNCA devolver el secret
    return view;
}
```

**ARCHIVOS RELEVANTES:**
- `InfoportOneAdmon.Services/Services/ApplicationSecurityService.cs` - Generación y hashing
- `InfoportOneAdmon.Services/Integration/KeycloakAdminService.cs` - Creación en Keycloak

**DEFINITION OF DONE:**
- [ ] Documentación actualizada confirmando que el backend ya está implementado
- [ ] Equipo de frontend informado sobre el flujo de secret único

**RECURSOS:**
- TASK-009-BE - Implementación completa
- User Story: `userStories.md#us-010`

=============================================================

---

#### TASK-010-UX: Modal "Copiar secreto una sola vez" en frontend

=============================================================
**TICKET ID:** TASK-010-UX  
**EPIC:** Administración de Aplicaciones del Ecosistema  
**USER STORY:** US-010 - Registrar aplicación backend (API)  
**COMPONENT:** Frontend Angular  
**PRIORITY:** Alta  
**ESTIMATION:** 2 horas  
=============================================================

**TÍTULO:**
Implementar modal para mostrar client_secret UNA SOLA VEZ tras creación

**DESCRIPCIÓN:**
Crear modal Angular que se muestre inmediatamente después de crear una credencial de tipo ClientCredentials. El modal debe:
- Mostrar el `client_secret` en texto plano (ÚNICA VEZ que se puede ver)
- Botón "Copiar al portapapeles" con feedback visual
- Advertencia prominente: "⚠️ IMPORTANTE: Copie este secreto ahora. No se podrá recuperar después"
- No permitir cerrar el modal sin confirmar que se ha copiado

**CONTEXTO TÉCNICO:**
- **API Response**: Al crear ApplicationSecurity con CredentialType="ClientCredentials", el backend devuelve `ClientSecret` en texto plano
- **Solo una vez**: En consultas posteriores (GET), el backend devuelve `ClientSecret: "***"`
- **Clipboard API**: Usar navigator.clipboard.writeText() para copiar

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] Modal se muestra automáticamente tras POST exitoso
- [ ] Secret visible en campo de solo lectura
- [ ] Botón "Copiar" funcional con feedback (checkmark temporal)
- [ ] Checkbox "He copiado el secreto" obligatorio antes de cerrar
- [ ] Diseño con alto contraste y advertencia visual prominente
- [ ] Tests de componente

**GUÍA DE IMPLEMENTACIÓN:**

**Paso 1: Crear Componente de Modal**

Archivo: `SintraportV4.Front/src/app/modules/admin/components/secret-modal/secret-modal.component.ts`

```typescript
import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { Clipboard } from '@angular/cdk/clipboard';

@Component({
  selector: 'app-secret-modal',
  templateUrl: './secret-modal.component.html',
  styleUrls: ['./secret-modal.component.scss']
})
export class SecretModalComponent {
  copied = false;
  confirmed = false;

  constructor(
    @Inject(MAT_DIALOG_DATA) public data: { clientSecret: string; clientId: string },
    private dialogRef: MatDialogRef<SecretModalComponent>,
    private clipboard: Clipboard
  ) {}

  copyToClipboard(): void {
    this.clipboard.copy(this.data.clientSecret);
    this.copied = true;
    
    // Resetear feedback después de 2 segundos
    setTimeout(() => this.copied = false, 2000);
  }

  close(): void {
    if (this.confirmed) {
      this.dialogRef.close();
    }
  }

  canClose(): boolean {
    return this.confirmed;
  }
}
```

**Paso 2: Template del Modal**

Archivo: `SintraportV4.Front/src/app/modules/admin/components/secret-modal/secret-modal.component.html`

```html
<h2 mat-dialog-title class="warning-title">
  <mat-icon class="warning-icon">warning</mat-icon>
  Secreto de Cliente Generado
</h2>

<mat-dialog-content>
  <div class="warning-banner">
    <p><strong>⚠️ IMPORTANTE:</strong> Este es el único momento en que podrá ver este secreto. 
    No se almacena en texto plano y no podrá recuperarlo después.</p>
  </div>

  <div class="secret-section">
    <label>Client ID:</label>
    <p class="client-id">{{ data.clientId }}</p>

    <label>Client Secret:</label>
    <div class="secret-display">
      <input 
        type="text" 
        readonly 
        [value]="data.clientSecret" 
        class="secret-input"
        #secretInput>
      <button 
        mat-raised-button 
        color="primary" 
        (click)="copyToClipboard()"
        [class.copied]="copied">
        <mat-icon>{{ copied ? 'check' : 'content_copy' }}</mat-icon>
        {{ copied ? 'Copiado!' : 'Copiar' }}
      </button>
    </div>
  </div>

  <div class="confirmation-section">
    <mat-checkbox [(ngModel)]="confirmed">
      He copiado el secreto en un lugar seguro
    </mat-checkbox>
  </div>
</mat-dialog-content>

<mat-dialog-actions align="end">
  <button 
    mat-raised-button 
    color="warn" 
    (click)="close()" 
    [disabled]="!canClose()">
    Cerrar (no se podrá recuperar)
  </button>
</mat-dialog-actions>
```

**Paso 3: Estilos del Modal**

Archivo: `SintraportV4.Front/src/app/modules/admin/components/secret-modal/secret-modal.component.scss`

```scss
.warning-title {
  color: #d32f2f;
  display: flex;
  align-items: center;
  gap: 8px;

  .warning-icon {
    color: #ff9800;
  }
}

.warning-banner {
  background-color: #fff3cd;
  border-left: 4px solid #ff9800;
  padding: 12px;
  margin-bottom: 20px;

  p {
    margin: 0;
    color: #856404;
  }
}

.secret-section {
  margin: 20px 0;

  label {
    font-weight: 600;
    display: block;
    margin-bottom: 4px;
    color: #424242;
  }

  .client-id {
    font-family: 'Courier New', monospace;
    background-color: #f5f5f5;
    padding: 8px;
    border-radius: 4px;
    margin-bottom: 16px;
  }

  .secret-display {
    display: flex;
    gap: 8px;

    .secret-input {
      flex: 1;
      font-family: 'Courier New', monospace;
      padding: 10px;
      border: 2px solid #1976d2;
      border-radius: 4px;
      font-size: 14px;
      background-color: #e3f2fd;
    }

    button.copied {
      background-color: #4caf50;
    }
  }
}

.confirmation-section {
  margin-top: 20px;
  padding: 12px;
  background-color: #f5f5f5;
  border-radius: 4px;
}
```

**Paso 4: Abrir Modal al Crear Credencial**

Modificar: `SintraportV4.Front/src/app/modules/admin/pages/application-credentials/application-credentials.component.ts`

```typescript
import { MatDialog } from '@angular/material/dialog';
import { SecretModalComponent } from '../../components/secret-modal/secret-modal.component';

constructor(
  private credentialsService: ApplicationCredentialsService,
  private dialog: MatDialog
) {}

createCredential(credential: ApplicationSecurityView): void {
  this.credentialsService.create(credential).subscribe({
    next: (response) => {
      // Si es ClientCredentials y tiene secret, mostrar modal
      if (response.CredentialType === 'ClientCredentials' && response.ClientSecret && response.ClientSecret !== '***') {
        this.dialog.open(SecretModalComponent, {
          data: { 
            clientSecret: response.ClientSecret,
            clientId: response.ClientId 
          },
          disableClose: true, // Forzar confirmación
          width: '600px'
        });
      }
      
      this.loadCredentials();
    },
    error: (err) => {
      console.error('Error creating credential', err);
    }
  });
}
```

**Paso 5: Tests del Componente**

Archivo: `SintraportV4.Front/src/app/modules/admin/components/secret-modal/secret-modal.component.spec.ts`

```typescript
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { Clipboard } from '@angular/cdk/clipboard';
import { SecretModalComponent } from './secret-modal.component';

describe('SecretModalComponent', () => {
  let component: SecretModalComponent;
  let fixture: ComponentFixture<SecretModalComponent>;
  let clipboardSpy: jasmine.SpyObj<Clipboard>;

  beforeEach(() => {
    const dialogRefSpy = jasmine.createSpyObj('MatDialogRef', ['close']);
    clipboardSpy = jasmine.createSpyObj('Clipboard', ['copy']);

    TestBed.configureTestingModule({
      declarations: [SecretModalComponent],
      providers: [
        { provide: MAT_DIALOG_DATA, useValue: { clientSecret: 'test-secret-123', clientId: 'crm-api' } },
        { provide: MatDialogRef, useValue: dialogRefSpy },
        { provide: Clipboard, useValue: clipboardSpy }
      ]
    });

    fixture = TestBed.createComponent(SecretModalComponent);
    component = fixture.componentInstance;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should copy secret to clipboard', () => {
    component.copyToClipboard();
    expect(clipboardSpy.copy).toHaveBeenCalledWith('test-secret-123');
    expect(component.copied).toBeTrue();
  });

  it('should not allow closing without confirmation', () => {
    component.confirmed = false;
    expect(component.canClose()).toBeFalse();
  });

  it('should allow closing with confirmation', () => {
    component.confirmed = true;
    expect(component.canClose()).toBeTrue();
  });
});
```

**ARCHIVOS A CREAR/MODIFICAR:**
- `SintraportV4.Front/src/app/modules/admin/components/secret-modal/secret-modal.component.ts`
- `SintraportV4.Front/src/app/modules/admin/components/secret-modal/secret-modal.component.html`
- `SintraportV4.Front/src/app/modules/admin/components/secret-modal/secret-modal.component.scss`
- `SintraportV4.Front/src/app/modules/admin/components/secret-modal/secret-modal.component.spec.ts`
- `SintraportV4.Front/src/app/modules/admin/pages/application-credentials/application-credentials.component.ts`

**DEPENDENCIAS:**
- TASK-009-BE - Backend devuelve ClientSecret en creación

**DEFINITION OF DONE:**
- [ ] Modal implementado y funcional
- [ ] Botón copiar funciona correctamente
- [ ] Feedback visual al copiar implementado
- [ ] Checkbox de confirmación obligatorio
- [ ] Modal no se puede cerrar sin confirmar
- [ ] Diseño con advertencia prominente
- [ ] Tests del componente pasando
- [ ] UX review aprobado

**RECURSOS:**
- Angular Material Dialog: https://material.angular.io/components/dialog
- Clipboard API: https://developer.mozilla.org/en-US/docs/Web/API/Clipboard
- User Story: `userStories.md#us-010`

=============================================================

---

### US-011: Definir prefijo único de aplicación

**Resumen de tickets generados:**
- TASK-011-NOTE: Prefijo único ya implementado en TASK-009-BE

---

#### TASK-011-NOTE: Prefijo único ya implementado en TASK-009-BE

=============================================================
**TICKET ID:** TASK-011-NOTE  
**EPIC:** Administración de Aplicaciones del Ecosistema  
**USER STORY:** US-011 - Definir prefijo único de aplicación  
**COMPONENT:** Backend - Nota Arquitectónica  
**PRIORITY:** Alta  
**ESTIMATION:** 0 horas (Solo documentación)  
=============================================================

**TÍTULO:**
Documentar que el prefijo único de aplicación ya está implementado

**DESCRIPCIÓN:**
Este ticket documenta que **US-011 ya fue completamente implementada en TASK-009-BE**. No se requiere desarrollo adicional.

**Funcionalidad ya implementada:**
- ✅ Campo `RolePrefix` en entidad Application (2-5 caracteres, solo mayúsculas)
- ✅ Validación de formato con regex `^[A-Z]{2,5}$`
- ✅ Índice único en `RolePrefix` garantiza unicidad a nivel de BD
- ✅ **Inmutabilidad**: Una vez asignado, el RolePrefix NO se puede modificar
- ✅ Validación rechaza cambios del prefijo en edición
- ✅ Validación de nomenclatura de roles: deben empezar con `{RolePrefix}_`
- ✅ Validación de nomenclatura de módulos: deben empezar con `M{RolePrefix}_`

**Evidencia de implementación:**

En `Application.cs` (líneas 30-38):
```csharp
/// <summary>
/// Prefijo único para roles y módulos (ej: "CRM", "STP", "BI")
/// 2-5 caracteres, solo mayúsculas, INMUTABLE
/// </summary>
[Required]
[StringLength(5)]
public string RolePrefix { get; set; }
```

En `ApplicationService.cs` (líneas 60-82):
```csharp
// Validación: RolePrefix formato correcto
if (!Regex.IsMatch(view.RolePrefix, "^[A-Z]{2,5}$"))
{
    AddError("El prefijo debe tener entre 2 y 5 caracteres en mayúsculas");
    return false;
}

// Validación: RolePrefix único
var prefixExists = await Repository.ExistsAsync(
    a => a.RolePrefix == view.RolePrefix && a.Id != view.Id && a.AuditDeletionDate == null,
    cancellationToken);

if (prefixExists)
{
    AddError($"Ya existe una aplicación con el prefijo '{view.RolePrefix}'");
    return false;
}

// Validación: RolePrefix inmutable en edición
if (view.Id > 0)
{
    var originalEntity = await Repository.GetByIdAsync(view.Id, cancellationToken);
    if (originalEntity != null && originalEntity.RolePrefix != view.RolePrefix)
    {
        AddError("El RolePrefix es inmutable y no puede modificarse una vez asignado");
        return false;
    }
}
```

**Tests unitarios que validan esta funcionalidad:**
- `ApplicationServiceTests.ValidateView_WithDuplicateRolePrefix_ReturnsFalse()`
- `ApplicationServiceTests.ValidateView_WhenEditingRolePrefix_ReturnsFalse()`

**ARCHIVOS RELEVANTES:**
- `InfoportOneAdmon.DataModel/Entities/Application.cs`
- `InfoportOneAdmon.Services/Services/ApplicationService.cs`
- `InfoportOneAdmon.DataModel/InfoportOneAdmonContext.cs` (índice único)

**DEFINITION OF DONE:**
- [ ] Documentación actualizada confirmando implementación completa
- [ ] Equipo informado que US-011 no requiere trabajo adicional

**RECURSOS:**
- TASK-009-BE - Implementación completa de Application
- User Story: `userStories.md#us-011`

=============================================================

---

### US-012: Agregar credencial adicional a aplicación

**Resumen de tickets generados:**
- TASK-012-NOTE: Credenciales adicionales ya soportadas en TASK-009-BE

---

#### TASK-012-NOTE: Credenciales adicionales ya soportadas en TASK-009-BE

=============================================================
**TICKET ID:** TASK-012-NOTE  
**EPIC:** Administración de Aplicaciones del Ecosistema  
**USER STORY:** US-012 - Agregar credencial adicional a aplicación  
**COMPONENT:** Backend - Nota Arquitectónica  
**PRIORITY:** Media  
**ESTIMATION:** 0 horas (Solo documentación)  
=============================================================

**TÍTULO:**
Documentar que las credenciales adicionales ya están soportadas

**DESCRIPCIÓN:**
Este ticket documenta que **US-012 ya está implementada**. El diseño de la relación 1:N entre Application y ApplicationSecurity permite agregar múltiples credenciales a una aplicación sin restricciones de código.

**Funcionalidad ya implementada:**
- ✅ Relación 1:N: `Application.Credentials` es una colección de `ApplicationSecurity`
- ✅ Una aplicación puede tener múltiples credenciales simultáneamente
- ✅ Cada credencial tiene su propio `client_id` único
- ✅ Validación: NO permite duplicar credenciales del **mismo tipo** para la **misma aplicación**
- ✅ Pero SÍ permite tener UNA credencial CODE y UNA ClientCredentials para la misma app
- ✅ Ambas credenciales se registran en Keycloak correctamente

**Evidencia de implementación:**

En `Application.cs`:
```csharp
/// <summary>
/// Colección de credenciales OAuth2 para esta aplicación
/// Una aplicación puede tener múltiples credenciales (frontend CODE + backend ClientCredentials)
/// </summary>
public virtual ICollection<ApplicationSecurity> Credentials { get; set; }
```

En `ApplicationSecurityService.cs` (validación que previene duplicados del mismo tipo):
```csharp
// Validación: No permitir crear credencial del mismo tipo para la misma aplicación
var sameTypeExists = await Repository.ExistsAsync(
    s => s.ApplicationId == view.ApplicationId 
         && s.CredentialType == view.CredentialType 
         && s.Id != view.Id 
         && s.AuditDeletionDate == null,
    cancellationToken);

if (sameTypeExists)
{
    AddError($"Ya existe una credencial de tipo {view.CredentialType} para esta aplicación");
    return false;
}
```

**Ejemplo de uso:**
1. Crear Application "CRM" con ID 1
2. Crear ApplicationSecurity CODE para Application ID 1 → `crm-frontend`
3. Crear ApplicationSecurity ClientCredentials para Application ID 1 → `crm-api`
4. Resultado: CRM tiene 2 credenciales activas simultáneamente

**Comportamiento actual:**
- ✅ Permitido: 1 credencial CODE + 1 credencial ClientCredentials por aplicación
- ❌ Rechazado: 2 credenciales CODE para la misma aplicación
- ❌ Rechazado: 2 credenciales ClientCredentials para la misma aplicación

**NOTA IMPORTANTE:**
Si en el futuro se necesita permitir MÚLTIPLES credenciales del mismo tipo (ej: 2 clients CODE con diferentes RedirectURIs), simplemente eliminar la validación `sameTypeExists` de `ApplicationSecurityService.cs`.

**ARCHIVOS RELEVANTES:**
- `InfoportOneAdmon.DataModel/Entities/Application.cs` - Relación 1:N
- `InfoportOneAdmon.Services/Services/ApplicationSecurityService.cs` - Validación

**DEFINITION OF DONE:**
- [ ] Documentación actualizada confirmando que las credenciales múltiples funcionan
- [ ] Equipo informado del comportamiento actual

**RECURSOS:**
- TASK-009-BE - Implementación completa
- User Story: `userStories.md#us-012`

=============================================================

---

### US-013: Rotar secreto de aplicación backend

**Resumen de tickets generados:**
- TASK-013-BE: Implementar rotación de client_secret con actualización en Keycloak

---

#### TASK-013-BE: Implementar rotación de client_secret con actualización en Keycloak

=============================================================
**TICKET ID:** TASK-013-BE  
**EPIC:** Administración de Aplicaciones del Ecosistema  
**USER STORY:** US-013 - Rotar secreto de aplicación backend  
**COMPONENT:** Backend  
**PRIORITY:** Media  
**ESTIMATION:** 3 horas  
=============================================================

**TÍTULO:**
Implementar rotación de client_secret con actualización en Keycloak

**DESCRIPCIÓN:**
Crear endpoint POST `/application-credentials/{id}/rotate-secret` que permite rotar el `client_secret` de una credencial de tipo ClientCredentials. El proceso incluye:
1. Generar nuevo secret criptográficamente seguro
2. Hashear con bcrypt
3. Actualizar en BD (tabla APPLICATION_SECURITY)
4. Actualizar en Keycloak Admin API
5. Registrar log de auditoría
6. Devolver el nuevo secret UNA SOLA VEZ (igual que en creación)

**CONTEXTO TÉCNICO:**
- **Seguridad**: Solo permitir rotar secrets de credenciales ClientCredentials (no CODE)
- **Downtime**: Opcionalmente, permitir "período de gracia" donde ambos secrets funcionan temporalmente (24h)
- **Auditoría**: Registrar quién y cuándo rotó el secret

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] Endpoint POST `/application-credentials/{id}/rotate-secret` implementado
- [ ] Generación de nuevo secret con la misma lógica de creación
- [ ] Hash bcrypt del nuevo secret
- [ ] Actualización en BD (ClientSecretHash)
- [ ] Actualización en Keycloak mediante KeycloakAdminService
- [ ] Nuevo secret se devuelve UNA VEZ en la respuesta
- [ ] Log de auditoría con fecha y usuario
- [ ] Tests unitarios e integración

**GUÍA DE IMPLEMENTACIÓN:**

**Paso 1: Crear Método en ApplicationSecurityService**

Modificar: `InfoportOneAdmon.Services/Services/ApplicationSecurityService.cs`

```csharp
/// <summary>
/// Rota el client_secret de una credencial ClientCredentials
/// </summary>
public async Task<ApplicationSecurityView> RotateSecretAsync(int credentialId, CancellationToken cancellationToken)
{
    // 1. Obtener credencial
    var credential = await Repository.GetByIdAsync(credentialId, cancellationToken);
    if (credential == null)
    {
        AddError("Credencial no encontrada");
        return null;
    }

    // 2. Validar que sea ClientCredentials
    if (credential.CredentialType != "ClientCredentials")
    {
        AddError("Solo se pueden rotar secretos de credenciales de tipo ClientCredentials");
        return null;
    }

    // 3. Generar nuevo secret
    var newSecret = GenerateSecureSecret(32);
    
    // 4. Hashear
    credential.ClientSecretHash = BCrypt.Net.BCrypt.HashPassword(newSecret, 12);
    credential.AuditModificationDate = DateTime.UtcNow;
    credential.AuditModificationUser = GetCurrentUserId(); // Método de Helix6 BaseService

    // 5. Actualizar en BD
    await Repository.UpdateAsync(credential, cancellationToken);

    // 6. Actualizar en Keycloak
    await _keycloakService.UpdateConfidentialClientSecretAsync(credential.ClientId, newSecret);

    // 7. Registrar log de auditoría
    Logger.LogWarning($"Secret rotado para credencial {credential.ClientId} por usuario {GetCurrentUserId()}");

    // 8. Mapear a View y devolver con el nuevo secret (UNA VEZ)
    var view = MapEntityToView(credential);
    view.ClientSecret = newSecret; // ÚNICO momento en que se puede ver

    return view;
}
```

**Paso 2: Crear Endpoint**

Modificar: `InfoportOneAdmon.Api/Endpoints/ApplicationEndpoints.cs`

```csharp
public static void MapApplicationEndpoints(this IEndpointRouteBuilder app)
{
    // ... endpoints existentes ...

    // Endpoint de rotación de secreto
    var group = app.MapGroup("application-credentials")
        .WithTags("ApplicationCredentials")
        .RequireAuthorization();

    group.MapPost("/{id}/rotate-secret", async (
        [FromRoute] int id,
        [FromServices] ApplicationSecurityService service,
        CancellationToken ct) =>
    {
        var result = await service.RotateSecretAsync(id, ct);
        
        if (result == null)
        {
            return Results.BadRequest(new { errors = service.Errors });
        }

        return Results.Ok(result);
    })
    .WithName("RotateClientSecret")
    .WithSummary("Rota el client_secret de una credencial ClientCredentials")
    .WithDescription("Genera un nuevo secret, lo hashea, actualiza en BD y Keycloak. El nuevo secret se devuelve UNA SOLA VEZ.")
    .Produces<ApplicationSecurityView>(StatusCodes.Status200OK)
    .Produces<ProblemDetails>(StatusCodes.Status400BadRequest)
    .Produces(StatusCodes.Status401Unauthorized)
    .Produces(StatusCodes.Status404NotFound);
}
```

**Paso 3: Tests Unitarios**

Archivo: `InfoportOneAdmon.Services.Tests/Services/ApplicationSecurityServiceTests.cs`

Añadir al archivo existente:

```csharp
[Fact]
public async Task RotateSecretAsync_WithValidCredential_GeneratesNewSecretAndUpdatesKeycloak()
{
    // Arrange
    var credential = new ApplicationSecurity
    {
        Id = 1,
        ApplicationId = 1,
        CredentialType = "ClientCredentials",
        ClientId = "crm-api",
        ClientSecretHash = BCrypt.Net.BCrypt.HashPassword("old-secret", 12)
    };

    _repositoryMock.Setup(r => r.GetByIdAsync(1, It.IsAny<CancellationToken>()))
        .ReturnsAsync(credential);

    _repositoryMock.Setup(r => r.UpdateAsync(It.IsAny<ApplicationSecurity>(), It.IsAny<CancellationToken>()))
        .Returns(Task.CompletedTask);

    var keycloakServiceMock = new Mock<KeycloakAdminService>();
    keycloakServiceMock.Setup(k => k.UpdateConfidentialClientSecretAsync(
        It.IsAny<string>(),
        It.IsAny<string>()))
        .ReturnsAsync(true);

    var service = new ApplicationSecurityService(
        _loggerMock.Object,
        _repositoryMock.Object,
        _applicationRepositoryMock.Object,
        keycloakServiceMock.Object);

    // Act
    var result = await service.RotateSecretAsync(1, CancellationToken.None);

    // Assert
    result.Should().NotBeNull();
    result.ClientSecret.Should().NotBeNullOrEmpty();
    result.ClientSecret.Should().HaveLength(32);
    result.ClientSecret.Should().NotBe("old-secret");

    // Verificar que el hash cambió
    credential.ClientSecretHash.Should().NotBeNull();
    BCrypt.Net.BCrypt.Verify("old-secret", credential.ClientSecretHash).Should().BeFalse(); // Old secret ya no funciona

    // Verificar que se llamó a Keycloak
    keycloakServiceMock.Verify(k => k.UpdateConfidentialClientSecretAsync(
        "crm-api",
        It.IsAny<string>()),
        Times.Once);
}

[Fact]
public async Task RotateSecretAsync_WithCODECredential_ReturnsError()
{
    // Arrange
    var credential = new ApplicationSecurity
    {
        Id = 2,
        CredentialType = "CODE", // Public client, no tiene secret
        ClientId = "crm-frontend"
    };

    _repositoryMock.Setup(r => r.GetByIdAsync(2, It.IsAny<CancellationToken>()))
        .ReturnsAsync(credential);

    var service = new ApplicationSecurityService(
        _loggerMock.Object,
        _repositoryMock.Object,
        _applicationRepositoryMock.Object,
        Mock.Of<KeycloakAdminService>());

    // Act
    var result = await service.RotateSecretAsync(2, CancellationToken.None);

    // Assert
    result.Should().BeNull();
    service.Errors.Should().Contain(e => e.Contains("Solo se pueden rotar secretos de credenciales de tipo ClientCredentials"));
}
```

**Paso 4: Test de Integración**

Archivo: `InfoportOneAdmon.Api.Tests/Endpoints/ApplicationCredentialsEndpointsTests.cs`

```csharp
[Fact]
public async Task RotateSecret_ValidCredential_ReturnsNewSecret()
{
    // Arrange: Crear aplicación y credencial ClientCredentials
    var application = new ApplicationView
    {
        Name = "Test App",
        RolePrefix = "TST",
        DatabasePrefix = "test"
    };
    var appResponse = await _client.PostAsJsonAsync("/applications", application);
    var createdApp = await appResponse.Content.ReadFromJsonAsync<ApplicationView>();

    var credential = new ApplicationSecurityView
    {
        ApplicationId = createdApp.Id,
        CredentialType = "ClientCredentials"
    };
    var credResponse = await _client.PostAsJsonAsync("/application-credentials", credential);
    var createdCred = await credResponse.Content.ReadFromJsonAsync<ApplicationSecurityView>();
    var originalSecret = createdCred.ClientSecret;

    // Act: Rotar secret
    var rotateResponse = await _client.PostAsync($"/application-credentials/{createdCred.Id}/rotate-secret", null);

    // Assert
    rotateResponse.StatusCode.Should().Be(System.Net.HttpStatusCode.OK);
    var rotatedCred = await rotateResponse.Content.ReadFromJsonAsync<ApplicationSecurityView>();
    
    rotatedCred.ClientSecret.Should().NotBeNullOrEmpty();
    rotatedCred.ClientSecret.Should().HaveLength(32);
    rotatedCred.ClientSecret.Should().NotBe(originalSecret); // Nuevo secret diferente
    rotatedCred.ClientSecret.Should().NotBe("***"); // Se muestra en texto plano UNA VEZ

    // Verificar que en consultas posteriores se oculta
    var getResponse = await _client.GetAsync($"/application-credentials/{createdCred.Id}");
    var queriedCred = await getResponse.Content.ReadFromJsonAsync<ApplicationSecurityView>();
    queriedCred.ClientSecret.Should().Be("***");
}
```

**ARCHIVOS A CREAR/MODIFICAR:**
- `InfoportOneAdmon.Services/Services/ApplicationSecurityService.cs` - Método RotateSecretAsync
- `InfoportOneAdmon.Api/Endpoints/ApplicationEndpoints.cs` - Endpoint POST rotate-secret
- `InfoportOneAdmon.Services.Tests/Services/ApplicationSecurityServiceTests.cs` - Tests unitarios
- `InfoportOneAdmon.Api.Tests/Endpoints/ApplicationCredentialsEndpointsTests.cs` - Test de integración

**DEPENDENCIAS:**
- TASK-009-BE - ApplicationSecurityService existe
- TASK-009-KC - KeycloakAdminService existe

**DEFINITION OF DONE:**
- [ ] Método RotateSecretAsync implementado
- [ ] Endpoint POST /application-credentials/{id}/rotate-secret funcional
- [ ] Nuevo secret generado y hasheado correctamente
- [ ] Keycloak actualizado con nuevo secret
- [ ] Nuevo secret se devuelve UNA VEZ
- [ ] Log de auditoría registrado
- [ ] Tests unitarios pasando
- [ ] Test de integración validando rotación end-to-end
- [ ] Validación: solo ClientCredentials pueden rotar
- [ ] Code review aprobado

**RECURSOS:**
- User Story: `userStories.md#us-013`

=============================================================

---

### US-014: Listar catálogo de aplicaciones

**Resumen de tickets generados:**
- TASK-014-NOTE: Listado CRUD ya implementado en TASK-009-BE
- TASK-014-FE: Añadir columnas calculadas (conteo de módulos/roles) en frontend

---

#### TASK-014-NOTE: Listado CRUD ya implementado en TASK-009-BE

=============================================================
**TICKET ID:** TASK-014-NOTE  
**EPIC:** Administración de Aplicaciones del Ecosistema  
**USER STORY:** US-014 - Listar catálogo de aplicaciones  
**COMPONENT:** Backend - Nota Arquitectónica  
**PRIORITY:** Media  
**ESTIMATION:** 0 horas (Solo documentación)  
=============================================================

**TÍTULO:**
Documentar que el listado de aplicaciones ya está implementado

**DESCRIPCIÓN:**
Este ticket documenta que **US-014 ya está implementada en gran parte**. El endpoint GET `/applications` generado por `EndpointHelper.MapCrudEndpoints` en TASK-009-BE proporciona el listado completo con filtros y ordenación.

**Funcionalidad ya implementada:**
- ✅ Endpoint POST `/applications/list` con KendoFilter
- ✅ Método GetAllKendoFilter hereda de BaseService
- ✅ Filtrado, ordenación y paginación automática mediante Kendo Grid
- ✅ Soporte para incluir relaciones (Credentials, Modules, Roles)

**Funcionalidad adicional requerida (TASK-014-FE):**
- Campos calculados: `ModuleCount`, `RoleCount` (se deben calcular en frontend o añadir endpoint custom)
- Filtro específico por Estado (Activa/Inactiva basado en AuditDeletionDate)

**Ejemplo de uso del endpoint existente:**

```http
POST /applications/list
Content-Type: application/json

{
  "skip": 0,
  "take": 50,
  "sort": [{"field": "Name", "dir": "asc"}],
  "filter": {
    "logic": "and",
    "filters": [
      {"field": "Name", "operator": "contains", "value": "CRM"}
    ]
  }
}
```

**Datos que retorna:**
```json
[
  {
    "Id": 1,
    "Name": "CRM Valenciaport",
    "RolePrefix": "CRM",
    "DatabasePrefix": "crm",
    "Description": "Sistema de gestión de clientes",
    "AuditCreationDate": "2026-01-15T10:00:00Z",
    "AuditDeletionDate": null,
    "Credentials": [...],
    "Modules": [...],
    "Roles": [...]
  }
]
```

**Lo que falta (implementar en frontend o endpoint custom):**
1. Calcular `ModuleCount` = Credentials.Modules.Count(m => m.AuditDeletionDate == null)
2. Calcular `RoleCount` = Credentials.Roles.Count(r => r.AuditDeletionDate == null)
3. Calcular `Estado` = AuditDeletionDate == null ? "Activa" : "Inactiva"

**ARCHIVOS RELEVANTES:**
- `InfoportOneAdmon.Api/Endpoints/ApplicationEndpoints.cs` - Endpoint GET ya existe
- `InfoportOneAdmon.Services/Services/ApplicationService.cs` - Servicio de listado

**DEFINITION OF DONE:**
- [ ] Documentación actualizada
- [ ] Equipo frontend informado sobre campos calculados

**RECURSOS:**
- TASK-009-BE - Endpoints CRUD implementados
- User Story: `userStories.md#us-014`

=============================================================

---

#### TASK-014-FE: Añadir columnas calculadas en listado de aplicaciones

=============================================================
**TICKET ID:** TASK-014-FE  
**EPIC:** Administración de Aplicaciones del Ecosistema  
**USER STORY:** US-014 - Listar catálogo de aplicaciones  
**COMPONENT:** Frontend Angular  
**PRIORITY:** Media  
**ESTIMATION:** 3 horas  
=============================================================

**TÍTULO:**
Implementar listado de aplicaciones con conteo de módulos/roles y filtros

**DESCRIPCIÓN:**
Crear página Angular que muestre el catálogo de aplicaciones con:
- Kendo Grid con columnas: Nombre, Prefijo, Nº Módulos, Nº Roles, Estado, Fecha de Registro
- Filtros por Nombre y Estado (Activa/Inactiva)
- Ordenación por columnas
- Paginación server-side mediante KendoFilter
- Clic en fila navega a detalle de aplicación
- Indicador visual de aplicaciones inactivas (soft delete)

**CONTEXTO TÉCNICO:**
- **Backend**: POST `/applications/list` con KendoFilter (automático desde Kendo Grid)
- **Kendo Grid**: Usa `kendoGridBinding` con server-side paging/filtering/sorting
- **Cálculo**: ModuleCount y RoleCount se calculan en backend con proyección
- **Estado**: Se determina por AuditDeletionDate (null = Activa, not null = Inactiva)

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] Componente ApplicationListComponent creado
- [ ] Tabla Material con columnas especificadas
- [ ] Conteo de módulos/roles calculado localmente
- [ ] Filtro por nombre funcional
- [ ] Filtro por estado funcional
- [ ] Ordenación por columnas
- [ ] Navegación a detalle al hacer clic
- [ ] Aplicaciones inactivas con estilo diferenciado

**GUÍA DE IMPLEMENTACIÓN:**

**Paso 1: Crear Servicio**

Archivo: `SintraportV4.Front/src/app/modules/admin/services/application.service.ts`

```typescript
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

export interface ApplicationListItem {
  id: number;
  name: string;
  rolePrefix: string;
  databasePrefix: string;
  moduleCount: number;
  roleCount: number;
  status: 'Activa' | 'Inactiva';
  createdAt: Date;
  auditDeletionDate?: Date;
}

@Injectable({
  providedIn: 'root'
})
export class ApplicationService {
  private apiUrl = '/api/applications/list';

  constructor(private http: HttpClient) {}

  // Método compatible con Kendo Grid DataSource
  getApplications(state: DataSourceRequestState): Observable<GridDataResult> {
    return this.http.post<GridDataResult>(this.apiUrl, state);
  }
}
```

**Paso 2: Crear Componente**

Archivo: `SintraportV4.Front/src/app/modules/admin/pages/application-list/application-list.component.ts`

```typescript
import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { ApplicationService } from '../../services/application.service';
import { GridDataResult, DataSourceRequestState } from '@progress/kendo-data-query';
import { Observable } from 'rxjs';

@Component({
  selector: 'app-application-list',
  templateUrl: './application-list.component.html',
  styleUrls: ['./application-list.component.scss']
})
export class ApplicationListComponent implements OnInit {
  public gridData: Observable<GridDataResult>;
  public gridState: DataSourceRequestState = {
    skip: 0,
    take: 50,
    sort: [{ field: 'Name', dir: 'asc' }]
  };

  constructor(
    private applicationService: ApplicationService,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.loadApplications();
  }

  loadApplications(): void {
    this.gridData = this.applicationService.getApplications(this.gridState);
  }

  // Manejador del evento dataStateChange de Kendo Grid
  public dataStateChange(state: DataSourceRequestState): void {
    this.gridState = state;
    this.loadApplications();
  }

  onRowClick(dataItem: any): void {
    this.router.navigate(['/admin/applications', dataItem.Id]);
  }

  getRowClass(dataItem: any): string {
    return dataItem.AuditDeletionDate ? 'inactive-row' : '';
  }
}
```

**Paso 3: Template**

Archivo: `SintraportV4.Front/src/app/modules/admin/pages/application-list/application-list.component.html`

```html
<div class="application-list-container">
  <div class="header">
    <h1>Catálogo de Aplicaciones</h1>
    <button class="k-button k-button-md k-rounded-md k-button-solid k-button-solid-primary" 
            routerLink="/admin/applications/new">
      <span class="k-icon k-i-plus"></span>
      Nueva Aplicación
    </button>
  </div>

  <kendo-grid
    [data]="gridData | async"
    [pageSize]="gridState.take"
    [skip]="gridState.skip"
    [sort]="gridState.sort"
    [sortable]="true"
    [pageable]="{
      buttonCount: 5,
      info: true,
      type: 'numeric',
      pageSizes: [10, 25, 50, 100],
      previousNext: true
    }"
    [filterable]="true"
    (dataStateChange)="dataStateChange($event)"
    (cellClick)="onRowClick($event.dataItem)"
    [rowClass]="getRowClass">
    
    <!-- Nombre -->
    <kendo-grid-column 
      field="Name" 
      title="Nombre" 
      [width]="200">
    </kendo-grid-column>

    <!-- Prefijo -->
    <kendo-grid-column 
      field="RolePrefix" 
      title="Prefijo" 
      [width]="100">
      <ng-template kendoGridCellTemplate let-dataItem>
        <span class="prefix-badge">{{ dataItem.RolePrefix }}</span>
      </ng-template>
    </kendo-grid-column>

    <!-- Nº Módulos -->
    <kendo-grid-column 
      field="ModuleCount" 
      title="Nº Módulos" 
      [width]="120"
      [filterable]="false">
      <ng-template kendoGridCellTemplate let-dataItem>
        <span class="count-badge">{{ dataItem.ModuleCount }}</span>
      </ng-template>
    </kendo-grid-column>

    <!-- Nº Roles -->
    <kendo-grid-column 
      field="RoleCount" 
      title="Nº Roles" 
      [width]="120"
      [filterable]="false">
      <ng-template kendoGridCellTemplate let-dataItem>
        <span class="count-badge">{{ dataItem.RoleCount }}</span>
      </ng-template>
    </kendo-grid-column>

    <!-- Estado -->
    <kendo-grid-column 
      field="Status" 
      title="Estado" 
      [width]="120">
      <ng-template kendoGridCellTemplate let-dataItem>
        <span class="status-badge" 
              [class.active]="!dataItem.AuditDeletionDate" 
              [class.inactive]="dataItem.AuditDeletionDate">
          {{ dataItem.AuditDeletionDate ? 'Inactiva' : 'Activa' }}
        </span>
      </ng-template>
    </kendo-grid-column>

    <!-- Fecha de Registro -->
    <kendo-grid-column 
      field="AuditCreationDate" 
      title="Fecha de Registro" 
      [width]="150"
      filter="date"
      format="{0:dd/MM/yyyy}">
    </kendo-grid-column>

  </kendo-grid>
</div>
```

**Paso 4: Estilos**

Archivo: `SintraportV4.Front/src/app/modules/admin/pages/application-list/application-list.component.scss`

```scss
.application-list-container {
  padding: 24px;

  .header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;

    h1 {
      margin: 0;
    }
  }

  .filters {
    display: flex;
    gap: 16px;
    margin-bottom: 16px;

    mat-form-field {
      flex: 1;
      max-width: 300px;
    }
  }

  .applications-table {
    width: 100%;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);

    .clickable-row {
      cursor: pointer;
      transition: background-color 0.2s;

      &:hover {
        background-color: #f5f5f5;
      }

      &.inactive-row {
        opacity: 0.6;
        background-color: #ffebee;

        &:hover {
          background-color: #ffcdd2;
        }
      }
    }

    .prefix-badge {
      display: inline-block;
      padding: 4px 12px;
      background-color: #1976d2;
      color: white;
      border-radius: 12px;
      font-weight: 600;
      font-size: 12px;
    }

    .count-badge {
      display: inline-block;
      padding: 4px 8px;
      background-color: #e0e0e0;
      border-radius: 8px;
      font-weight: 500;
    }

    .status-badge {
      display: inline-block;
      padding: 4px 12px;
      border-radius: 12px;
      font-weight: 500;
      font-size: 12px;

      &.active {
        background-color: #c8e6c9;
        color: #2e7d32;
      }

      &.inactive {
        background-color: #ffccbc;
        color: #d84315;
      }
    }
  }

  .no-results {
    text-align: center;
    padding: 48px;
    color: #999;

    mat-icon {
      font-size: 64px;
      width: 64px;
      height: 64px;
      margin-bottom: 16px;
    }
  }
}
```

**Paso 5: Tests**

Archivo: `SintraportV4.Front/src/app/modules/admin/pages/application-list/application-list.component.spec.ts`

```typescript
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ApplicationListComponent } from './application-list.component';
import { ApplicationService } from '../../services/application.service';
import { of } from 'rxjs';

describe('ApplicationListComponent', () => {
  let component: ApplicationListComponent;
  let fixture: ComponentFixture<ApplicationListComponent>;
  let mockApplicationService: jasmine.SpyObj<ApplicationService>;

  beforeEach(() => {
    mockApplicationService = jasmine.createSpyObj('ApplicationService', ['getAll']);

    TestBed.configureTestingModule({
      declarations: [ApplicationListComponent],
      providers: [
        { provide: ApplicationService, useValue: mockApplicationService }
      ]
    });

    fixture = TestBed.createComponent(ApplicationListComponent);
    component = fixture.componentInstance;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should load applications on init', () => {
    const mockApps = [
      { id: 1, name: 'CRM', rolePrefix: 'CRM', moduleCount: 5, roleCount: 3, status: 'Activa' as const, createdAt: new Date() }
    ];
    mockApplicationService.getAll.and.returnValue(of(mockApps));

    component.ngOnInit();

    expect(component.applications.length).toBe(1);
    expect(component.filteredApplications.length).toBe(1);
  });

  it('should filter by name', () => {
    component.applications = [
      { id: 1, name: 'CRM', rolePrefix: 'CRM', moduleCount: 5, roleCount: 3, status: 'Activa', createdAt: new Date() },
      { id: 2, name: 'ERP', rolePrefix: 'ERP', moduleCount: 10, roleCount: 5, status: 'Activa', createdAt: new Date() }
    ];

    component.nameFilter = 'CRM';
    component.applyFilters();

    expect(component.filteredApplications.length).toBe(1);
    expect(component.filteredApplications[0].name).toBe('CRM');
  });

  it('should filter by status', () => {
    component.applications = [
      { id: 1, name: 'CRM', rolePrefix: 'CRM', moduleCount: 5, roleCount: 3, status: 'Activa', createdAt: new Date() },
      { id: 2, name: 'Old App', rolePrefix: 'OLD', moduleCount: 0, roleCount: 0, status: 'Inactiva', createdAt: new Date(), auditDeletionDate: new Date() }
    ];

    component.statusFilter = 'active';
    component.applyFilters();

    expect(component.filteredApplications.length).toBe(1);
    expect(component.filteredApplications[0].status).toBe('Activa');
  });
});
```

**ARCHIVOS A CREAR/MODIFICAR:**
- `SintraportV4.Front/src/app/modules/admin/services/application.service.ts`
- `SintraportV4.Front/src/app/modules/admin/pages/application-list/application-list.component.ts`
- `SintraportV4.Front/src/app/modules/admin/pages/application-list/application-list.component.html`
- `SintraportV4.Front/src/app/modules/admin/pages/application-list/application-list.component.scss`
- `SintraportV4.Front/src/app/modules/admin/pages/application-list/application-list.component.spec.ts`

**DEPENDENCIAS:**
- TASK-009-BE - Endpoint GET /applications existe

**DEFINITION OF DONE:**
- [ ] ApplicationService implementado
- [ ] ApplicationListComponent creado
- [ ] Tabla Material con columnas especificadas funcional
- [ ] Conteo de módulos/roles correcto
- [ ] Filtros por nombre y estado funcionales
- [ ] Ordenación por columnas funcional
- [ ] Navegación a detalle funcional
- [ ] Aplicaciones inactivas con estilo diferenciado
- [ ] Tests del componente pasando
- [ ] UX review aprobado

**DEPENDENCIAS ADICIONALES:**
- `@progress/kendo-angular-grid` - Grid de Telerik Kendo
- `@progress/kendo-data-query` - Modelos de KendoFilter y DataSourceRequestState
- `@progress/kendo-angular-buttons` - Botones de Kendo
- `@progress/kendo-angular-icons` - Iconos de Kendo

**RECURSOS:**
- Kendo Grid Angular: https://www.telerik.com/kendo-angular-ui/components/grid/
- Helix6 GetAllKendoFilter documentation
- User Story: `userStories.md#us-014`

=============================================================

---

### US-015: Desactivar aplicación temporalmente

**Resumen de tickets generados:**
- TASK-015-BE: Endpoint DELETE con soft delete y deshabilitación en Keycloak

---

#### TASK-015-BE: Endpoint DELETE con soft delete y deshabilitación en Keycloak

=============================================================
**TICKET ID:** TASK-015-BE  
**EPIC:** Administración de Aplicaciones del Ecosistema  
**USER STORY:** US-015 - Desactivar aplicación temporalmente  
**COMPONENT:** Backend  
**PRIORITY:** Media  
**ESTIMATION:** 2 horas  
=============================================================

**TÍTULO:**
Implementar desactivación de aplicación con soft delete y sincronización a Keycloak

**DESCRIPCIÓN:**
El endpoint `DeleteUndeleteLogicById` ya está generado automáticamente por Helix6 y realiza soft delete estableciendo `AuditDeletionDate`. Este ticket añade lógica específica en `PostActions` para aplicaciones:
1. Deshabilitar todos los clients asociados en Keycloak cuando se desactiva
2. Reactivar clients en Keycloak cuando se reactiva
3. Publicar `ApplicationEvent` con `IsDeleted: true/false`

**CONTEXTO TÉCNICO:**
- **Endpoint automático**: POST `/applications/DeleteUndeleteLogicById` ya existe (generado por Helix6)
- **Soft delete**: Helix6 gestiona automáticamente el AuditDeletionDate
- **Keycloak**: Deshabilitar/reactivar clients en el hook PostActions
- **Evento**: ApplicationEvent con IsDeleted para sincronizar apps satélite

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] PostActions implementado en ApplicationService
- [ ] Deshabilitación de clients en Keycloak al borrar (delete=true)
- [ ] Reactivación de clients en Keycloak al restaurar (delete=false)
- [ ] Publicación de ApplicationEvent con IsDeleted correcto
- [ ] Tests unitarios e integración

**GUÍA DE IMPLEMENTACIÓN:**

**Paso 1: Implementar PostActions para Desactivación/Reactivación**

Modificar: `InfoportOneAdmon.Services/Services/ApplicationService.cs`

```csharp
private readonly IMessagePublisher _messagePublisher;
private readonly IConfiguration _configuration;
private readonly KeycloakAdminService _keycloakService;

public ApplicationService(
    ILogger<ApplicationService> logger,
    IRepository<Application> repository,
    IMessagePublisher messagePublisher,
    IConfiguration configuration,
    KeycloakAdminService keycloakService)
    : base(logger, repository)
{
    _messagePublisher = messagePublisher;
    _configuration = configuration;
    _keycloakService = keycloakService;
}

/// <summary>
/// PostActions: Sincronizar con Keycloak después de desactivar/reactivar
/// </summary>
protected override async Task PostActions(
    ApplicationView view,
    EnumActionType actionType,
    CancellationToken cancellationToken)
{
    // Si es Delete o Undelete lógico, sincronizar con Keycloak
    if (actionType == EnumActionType.DeleteUndelete)
    {
        var application = await Repository.GetByIdAsync(view.Id, cancellationToken);
        if (application != null)
        {
            bool isDeleted = application.AuditDeletionDate.HasValue;
            
            // Gestionar clients en Keycloak según estado
            foreach (var credential in application.Credentials.Where(c => c.AuditDeletionDate == null))
            {
                if (isDeleted)
                {
                    // Desactivar: deshabilitar client en Keycloak
                    await _keycloakService.DisableClientAsync(credential.ClientId);
                    Logger.LogInformation($"Client {credential.ClientId} deshabilitado en Keycloak");
                }
                else
                {
                    // Reactivar: habilitar client en Keycloak
                    if (credential.CredentialType == "CODE")
                    {
                        var uris = System.Text.Json.JsonSerializer.Deserialize<List<string>>(credential.RedirectUris);
                        await _keycloakService.UpdateClientAsync(credential.ClientId, uris);
                    }
                    Logger.LogInformation($"Client {credential.ClientId} reactivado en Keycloak");
                }
            }
            
            // Publicar evento con IsDeleted correcto
            await PublishApplicationEventAsync(application, cancellationToken);
            
            var action = isDeleted ? "desactivada" : "reactivada";
            Logger.LogWarning($"Aplicación {application.Name} {action} por usuario {GetCurrentUserId()}");
        }
    }
    
    await base.PostActions(view, actionType, cancellationToken);
}
```
    application.AuditDeletionDate = null;
    application.AuditModificationDate = DateTime.UtcNow;
    application.AuditModificationUser = GetCurrentUserId();

    await Repository.UpdateAsync(application, cancellationToken);

    // 2. Reactivar clients en Keycloak
    foreach (var credential in application.Credentials.Where(c => c.IsActive))
    {
        // Keycloak no tiene método "Enable", se hace actualizando el client
        if (credential.CredentialType == "CODE")
        {
            var uris = System.Text.Json.JsonSerializer.Deserialize<List<string>>(credential.RedirectUris);
            await _keycloakService.UpdateClientAsync(credential.ClientId, uris);
        }
        // Los confidential clients se reactivan automáticamente al actualizar
        Logger.LogInformation($"Client {credential.ClientId} reactivado en Keycloak");
    }

    // 3. Publicar evento con IsDeleted=false
    await PublishApplicationEventAsync(application, cancellationToken);

    Logger.LogInformation($"Aplicación {application.Name} reactivada por usuario {GetCurrentUserId()}");
    
    return true;
}
```

**Paso 2: Uso del Endpoint Automático**

**NO es necesario crear endpoints personalizados**. Helix6 ya genera:

```csharp
// Generado automáticamente en ApplicationEndpoints.cs
EndpointHelper.GenerateDeleteUndeleteLogicByIdEndpoint<IApplicationService>(
    group, SecurityLevel.Modify);
```

**Uso del endpoint:**

```http
# Desactivar aplicación (soft delete)
POST /applications/DeleteUndeleteLogicById
Content-Type: application/json

{
  "id": 1,
  "delete": true
}

# Reactivar aplicación
POST /applications/DeleteUndeleteLogicById
Content-Type: application/json

{
  "id": 1,
  "delete": false
}
```

**Paso 3: Tests Unitarios**

Archivo: `InfoportOneAdmon.Services.Tests/Services/ApplicationServiceTests.cs`

Añadir:

```csharp
[Fact]
public async Task PostActions_DeleteUndelete_DesactivatesApplicationAndDisablesClientsInKeycloak()
{
    // Arrange
    var keycloakServiceMock = new Mock<KeycloakAdminService>();
    var application = new Application
    {
        Id = 1,
        Name = "Test App",
        RolePrefix = "TST",
        AuditDeletionDate = DateTime.UtcNow, // Ya desactivada
        Credentials = new List<ApplicationSecurity>
        {
            new ApplicationSecurity { ClientId = "test-frontend", CredentialType = "CODE" },
            new ApplicationSecurity { ClientId = "test-api", CredentialType = "ClientCredentials" }
        }
    };

    _repositoryMock.Setup(r => r.GetByIdAsync(1, It.IsAny<CancellationToken>()))
        .ReturnsAsync(application);

    var service = new ApplicationService(
        _loggerMock.Object,
        _repositoryMock.Object,
        Mock.Of<IMessagePublisher>(),
        Mock.Of<IConfiguration>(),
        keycloakServiceMock.Object);

    var view = new ApplicationView { Id = 1 };

    // Act
    await service.PostActions(view, EnumActionType.DeleteUndelete, CancellationToken.None);

    // Assert: Verificar que se deshabilitaron ambos clients
    keycloakServiceMock.Verify(k => k.DisableClientAsync("test-frontend"), Times.Once);
    keycloakServiceMock.Verify(k => k.DisableClientAsync("test-api"), Times.Once);
}

[Fact]
public async Task PostActions_Undelete_ReactivatesApplicationAndClients()
{
    // Arrange
    var keycloakServiceMock = new Mock<KeycloakAdminService>();
    var application = new Application
    {
        Id = 1,
        Name = "Test App",
        RolePrefix = "TST",
        AuditDeletionDate = null, // Reactivada
        Credentials = new List<ApplicationSecurity>
        {
            new ApplicationSecurity 
            { 
                ClientId = "test-frontend", 
                CredentialType = "CODE",
                RedirectUris = "[\"https://test.com/*\"]",
                IsActive = true
            }
        }
    };

    _repositoryMock.Setup(r => r.GetByIdAsync(1, It.IsAny<CancellationToken>()))
        .ReturnsAsync(application);

    var service = new ApplicationService(
        _loggerMock.Object,
        _repositoryMock.Object,
        Mock.Of<IMessagePublisher>(),
        Mock.Of<IConfiguration>(),
        keycloakServiceMock.Object);

    var view = new ApplicationView { Id = 1 };

    // Act
    await service.PostActions(view, EnumActionType.DeleteUndelete, CancellationToken.None);

    // Assert: Verificar que se reactivó el client
    keycloakServiceMock.Verify(k => k.UpdateClientAsync(
        "test-frontend", 
        It.IsAny<List<string>>()), 
        Times.Once);
}
```

**ARCHIVOS A CREAR/MODIFICAR:**
- `InfoportOneAdmon.Services/Services/ApplicationService.cs` - PostActions para DeleteUndelete
- `InfoportOneAdmon.Services.Tests/Services/ApplicationServiceTests.cs` - Tests

**DEPENDENCIAS:**
- TASK-009-BE - ApplicationService existe
- TASK-009-KC - KeycloakAdminService existe
- TASK-009-EV-PUB - PublishApplicationEventAsync existe
- Helix6 endpoint DeleteUndeleteLogicById ya generado automáticamente

**DEFINITION OF DONE:**
- [ ] PostActions implementado con lógica de Keycloak
- [ ] Deshabilitación de clients al borrar (delete=true)
- [ ] Reactivación de clients al restaurar (delete=false)
- [ ] Endpoint POST /applications/DeleteUndeleteLogicById funcional (ya existe)
- [ ] ApplicationEvent publicado con IsDeleted correcto
- [ ] Tests unitarios pasando
- [ ] Log de auditoría registrado
- [ ] Code review aprobado

**RECURSOS:**
- User Story: `userStories.md#us-015`

=============================================================

---

## Resumen Épica 2: Administración de Aplicaciones del Ecosistema

**Total de tickets generados:** 8 tickets  
**Estimación total:** 24 horas

**Desglose:**
- TASK-009-BE (8h): Entidades Application y ApplicationSecurity con endpoints CRUD automáticos
- TASK-009-KC (6h): Integración Keycloak Admin API
- TASK-009-EV-PUB (3h): Publicación de ApplicationEvent
- TASK-010-UX (2h): Modal de secret único
- TASK-013-BE (3h): Rotación de secrets (método personalizado)
- TASK-014-FE (3h): Listado de aplicaciones con Kendo Grid
- TASK-015-BE (2h): Desactivación/reactivación con PostActions
- Notas documentales (0h): US-010, US-011, US-012, US-014

**Endpoints CRUD generados automáticamente por Helix6:**
- POST `/applications/GetNewEntity` - Inicializar nueva aplicación
- POST `/applications/GetById` - Obtener aplicación por ID
- POST `/applications/Insert` - Crear nueva aplicación
- POST `/applications/Update` - Actualizar aplicación existente
- POST `/applications/DeleteUndeleteLogicById` - Desactivar/Reactivar aplicación (soft delete)
- POST `/applications/list` - Listado con KendoFilter (paginación, filtros, ordenación)

**Métodos personalizados adicionales:**
- POST `/application-credentials/{id}/rotate-secret` - Rotación de client_secret (TASK-013-BE)

**Épica 2 completada ✅**

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

