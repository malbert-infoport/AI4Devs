# Tickets Técnicos - Épica 2: Administración de Aplicaciones del Ecosistema

**Generado desde:** User Stories (userStories.md)  
**Fecha de generación:** 31 de enero de 2026  
**Arquitecturas de referencia:**
- Backend: Helix6_Backend_Architecture.md
- Frontend: Helix6_Frontend_Architecture.md
- Eventos: ActiveMQ_Events.md

---

## Resumen de la Épica

Esta épica gestiona el catálogo de aplicaciones del ecosistema InfoportOne, permitiendo registrar y administrar tanto aplicaciones frontend (SPAs) como backend (APIs). Incluye la integración con Keycloak para la gestión automática de clients OAuth2, con soporte para PKCE en aplicaciones públicas y client credentials para APIs. Las aplicaciones se identifican mediante prefijos únicos y pueden tener múltiples credenciales de seguridad. El sistema soporta rotación de secretos y desactivación temporal de aplicaciones.

**Tecnologías principales:**
- Backend: .NET 8 con Helix6 Framework, Entity Framework Core 9.0, PostgreSQL 16
- Frontend: Angular 20 con Standalone Components, @cl/common-library
- Seguridad: Keycloak Admin API, OAuth2 PKCE, bcrypt para hashing
- Eventos: ActiveMQ Artemis con IPVInterchangeShared

---

## Índice de Tickets - Épica 2

### US-009: Registrar aplicación frontend (SPA)
- [TASK-009-BE: Implementar entidades Application y ApplicationSecurity con CRUD](#task-009-be-implementar-entidades-application-y-applicationsecurity-con-crud)
- [TASK-009-KC: Integrar con Keycloak Admin API para crear public clients con PKCE](#task-009-kc-integrar-con-keycloak-admin-api-para-crear-public-clients-con-pkce)
- [TASK-009-EV-PUB: Publicar ApplicationEvent al crear/modificar aplicaciones](#task-009-ev-pub-publicar-applicationevent-al-crearmodificar-aplicaciones)

### US-010: Registrar aplicación backend (API)
- [TASK-010-NOTE: Backend de aplicación API ya implementado en TASK-009-BE](#task-010-note-backend-de-aplicación-api-ya-implementado-en-task-009-be)
- [TASK-010-UX: Modal "Copiar secreto una sola vez" en frontend](#task-010-ux-modal-copiar-secreto-una-sola-vez-en-frontend)

### US-011: Definir prefijo único de aplicación
- [TASK-011-NOTE: Prefijo único ya implementado en TASK-009-BE](#task-011-note-prefijo-único-ya-implementado-en-task-009-be)

### US-012: Agregar credencial adicional a aplicación
- [TASK-012-NOTE: Credenciales adicionales ya soportadas en TASK-009-BE](#task-012-note-credenciales-adicionales-ya-soportadas-en-task-009-be)

### US-014: Listar catálogo de aplicaciones
- [TASK-014-NOTE: Listado CRUD ya implementado en TASK-009-BE](#task-014-note-listado-crud-ya-implementado-en-task-009-be)
- [TASK-014-FE: Añadir columnas calculadas en listado de aplicaciones](#task-014-fe-añadir-columnas-calculadas-en-listado-de-aplicaciones)

### US-015: Desactivar aplicación temporalmente
- [TASK-015-BE: Endpoint DELETE con soft delete y deshabilitación en Keycloak](#task-015-be-endpoint-delete-con-soft-delete-y-deshabilitación-en-keycloak)

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

**Total de tickets generados:** 7 tickets  
**Estimación total:** 21 horas

**Desglose:**
- TASK-009-BE (8h): Entidades Application y ApplicationSecurity con endpoints CRUD automáticos
- TASK-009-KC (6h): Integración Keycloak Admin API
- TASK-009-EV-PUB (3h): Publicación de ApplicationEvent
- TASK-010-UX (2h): Modal de secret único
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

**Épica 2 completada ✅**

---