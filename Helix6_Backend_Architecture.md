# Documentación de Arquitectura Backend - Helix6 Framework

Este documento describe la arquitectura técnica, estructura y patrones de diseño para proyectos Web API basados en el framework **Helix6** (versión .NET 8).

## 1. Arquitectura General del Framework Helix6

### 1.1 Descripción de la Arquitectura

La arquitectura Helix6 implementa una variante de **Arquitectura en N-Capas (N-Layer Architecture)** con fuerte influencia de **Clean Architecture** y principios de **Diseño Orientado al Dominio (DDD)**. El objetivo principal es la separación de responsabilidades, facilitando la mantenibilidad, testabilidad y escalabilidad.

El sistema se organiza de tal manera que las dependencias fluyen hacia las capas base y de dominio, protegiendo la lógica de negocio de los detalles de infraestructura y presentación.

**Diagrama Conceptual de Capas:**

```mermaid
graph TD
    API[Capa Presentación (Api)] --> Services
    API --> Entities
    API --> Base
    
    Services[Capa Lógica (Services)] --> Data
    Services --> Entities
    Services --> Base
    
    Data[Capa Datos (Data)] --> DataModel
    Data --> Base
    
    DataModel[Capa Modelo (DataModel)] --> Domain
    Entities[Capa Vistas (Entities)] --> Domain
    
    Base[Helix6.Base] --> Domain
    Base --> Utils
    
    Domain[Helix6.Base.Domain]
    Utils[Helix6.Base.Utils]
```

*   **Presentación (Api):** Punto de entrada RESTful (ASP.NET Core). Maneja la inyección de dependencias, configuración, autenticación y exposición de endpoints.
*   **Lógica de Negocio (Services):** Núcleo de la aplicación. Responsable de la orquestación, validaciones de negocio, reglas del dominio y transformación de datos (Mapeo Entity-View).
*   **Entidades de Transferencia (Entities):** Contiene los DTOs (llamados `Views`) que se utilizan para la comunicación entre la API y el cliente, desacoplando el modelo de base de datos de la vista.
*   **Acceso a Datos (Data):** Implementación de repositorios y patrón Unit of Work. Abstrae el acceso a la base de datos utilizando Entity Framework Core y Dapper.
*   **Modelo de Datos (DataModel):** Representación fiel de las tablas de la base de datos.
*   **Base & Domain (Core):** Infraestructura transversal que contiene contratos, interfaces, clases base abstractas, configuraciones y utilidades.

### 1.2 Filosofía y Principios del Framework

*   **DRY (Don't Repeat Yourself):** El framework hace un uso intensivo de genéricos (`BaseService<T>`, `BaseRepository<T>`) para automatizar operaciones CRUD estándar, evitando la escritura de código repetitivo.
*   **Convención sobre Configuración:** Se aplican reglas estrictas de nomenclatura (`*Repository`, `*Service`, `*View`) que permiten el autodescubrimiento de clases y la inyección automática de dependencias.
*   **Extensibilidad:** Aunque el framework automatiza mucho, todos los métodos base (`Insert`, `Update`, `GetById`) invocan "hooks" virtuales (`PreviousActions`, `ValidateView`, `PostActions`) que permiten inyectar lógica personalizada en cualquier punto del ciclo de vida sin romper el flujo estándar.
*   **Gestión de la Complejidad:** La complejidad accidental se oculta en la librería `Helix6.Base`, dejando que los proyectos de negocio (`Api`, `Services`, `Data`) se enfoquen únicamente en la lógica del dominio específico.

---

## 2. Estructura de Capas y Proyectos

### 2.1 Helix6.Base (Librería Base)

**Propósito:** Proporcionar la infraestructura base reutilizable y agnóstica del dominio para todos los proyectos Helix6.

**Dependencias Principales:**
*   `Microsoft.EntityFrameworkCore` (9.0.2) - Gestión de ORM
*   `Dapper` (2.1.66) - Consultas SQL optimizadas
*   `Mapster` (7.4.0) - Mapeo de objetos de alto rendimiento
*   `System.Linq.Dynamic.Core` (1.6.0.2) - Consultas dinámicas

**Estructura de Carpetas:**

#### Repository/
Contiene las clases base e interfaces para el acceso a datos:
*   `IBaseRepository<TEntity>`: Interfaz que define el contrato para repositorios.
*   `IBaseEFRepository<TEntity>`: Interfaz específica para operaciones con Entity Framework.
*   `IBaseDapperRepository<TEntity>`: Interfaz específica para operaciones con Dapper.
*   `BaseRepository<TEntity>`: Clase que orquesta y delega a EF o Dapper según el tipo de operación.
*   `BaseEFRepository<TEntity>`: Implementación concreta usando EF Core para operaciones CRUD.
*   `BaseDapperRepository<TEntity>`: Implementación optimizada usando Dapper para consultas de lectura.
*   `BaseVersionRepository<TEntity>`: Repositorio especializado para entidades versionadas.
*   `BaseValidityRepository<TEntity>`: Repositorio especializado para entidades con vigencia temporal.

#### Service/
Contiene las clases base para la lógica de negocio:
*   `IBaseService<TView, TEntity, TMetadata>`: Interfaz de servicio.
*   `BaseService<TView, TEntity, TMetadata>`: Clase base abstracta que implementa el pipeline completo:
  - Validación de entrada (`ValidateView`)
  - Acciones previas (`PreviousActions`)
  - Llamada al repositorio
  - Acciones posteriores (`PostActions`)
  - Mapeo Entity ↔ View
*   `BaseVersionService<TView, TEntity, TMetadata>`: Servicio base para entidades versionadas.
*   `BaseValidityService<TView, TEntity, TMetadata>`: Servicio base para entidades con vigencia.

#### Endpoints/
Helpers para generación automática de endpoints:
*   `EndpointHelper`: Clase estática con métodos genéricos:
  - `GenerateGetByIdEndpoint<TService, TView>(...)`
  - `GenerateInsertEndpoint<TService, TView>(...)`
  - `GenerateUpdateEndpoint<TService, TView>(...)`
  - `GenerateDeleteByIdEndpoint<TService, TView>(...)`
  - `GenerateGetAllKendoFilterEndpoint<TService, TView>(...)`
  - Y más variantes para operaciones masivas y lógicas.

#### Middleware/
Middleware personalizado del framework:
*   `HelixExceptionsMiddleware`: Captura excepciones globales, las transforma en `ProblemDetails` y registra logs estructurados.

#### Helpers/
Utilidades auxiliares:
*   Helpers de conversión, formateo, validación genérica.

#### Extensions/
Métodos de extensión para:
*   Configuración de servicios (`IServiceCollection`)
*   Extensiones de `IQueryable` para filtros dinámicos
*   Extensiones de mapeo

#### Security/
Componentes de seguridad transversales:
*   Helpers de encriptación
*   Validadores de tokens
*   Gestión de claims

#### Attachments/
Sistema de archivos adjuntos:
*   `IAttachmentSource<TAttachment>`: Interfaz para abstracción de almacenamiento (DB o disco).
*   `AttachmentDBSource<TAttachment>`: Implementación para almacenar en base de datos.
*   `AttachmentDriveSource<TAttachment>`: Implementación para almacenar en sistema de archivos.

**Interfaces Principales:**

```csharp
public interface IBaseRepository<TEntity> where TEntity : class, IEntityBase
{
    Task<TEntity?> GetById(int id, string? configurationName = null);
    Task<List<TEntity>> GetByIds(List<int> ids, string? configurationName = null);
    Task<TEntity?> Insert(TEntity entity);
    Task<List<TEntity>> InsertMany(List<TEntity> entities);
    Task<TEntity?> Update(TEntity entity);
    Task<List<TEntity>> UpdateMany(List<TEntity> entities);
    Task<bool> DeleteById(int id);
    Task<bool> DeleteByIds(List<int> ids);
    Task<bool> DeleteUndeleteLogicById(int id, bool delete);
    Task<bool> DeleteUndeleteLogicByIds(List<int> ids, bool delete);
    Task<List<TEntity>> GetAll(string? configurationName = null);
    Task<FilterResult<TEntity>> GetAllFilter(IGenericFilter filter, string? configurationName = null);
}

public interface IBaseService<TView, TEntity, TMetadata>
    where TView : class, IViewBase
    where TEntity : class, IEntityBase
    where TMetadata : class
{
    Task<TView?> GetById(int id, string? configurationName = null);
    Task<List<TView>> GetByIds(List<int> ids, string? configurationName = null);
    Task<TView?> GetNewEntity();
    Task<TView?> Insert(TView view, string? configurationName = null);
    Task<List<TView>> InsertMany(List<TView> views, string? configurationName = null);
    Task<TView?> Update(TView view, string? configurationName = null);
    Task<List<TView>> UpdateMany(List<TView> views, string? configurationName = null);
    Task<bool> DeleteById(int id, string? configurationName = null);
    Task<bool> DeleteByIds(List<int> ids, string? configurationName = null);
    Task<bool> DeleteUndeleteLogicById(int id, bool delete, string? configurationName = null);
    Task<bool> DeleteUndeleteLogicByIds(List<int> ids, bool delete, string? configurationName = null);
    Task<List<TView>> GetAll(string? configurationName = null);
    Task<FilterResult<TView>> GetAllKendoFilter(IGenericFilter filter, string? configurationName = null);
}

public interface IUserContext
{
    int UserId { get; }
    string UserName { get; }
    List<string> Roles { get; }
    string Language { get; }
    bool IsAuthenticated { get; }
}

public interface IApplicationContext
{
    string ApplicationName { get; }
    string HelixEntitiesXMLPath { get; }
    List<string> RolPrefixes { get; }
    int PermisionsMinutesCache { get; }
    EnumDBMSType DBMSType { get; }
}

public interface IUserPermissions
{
    Task<bool> HasPermission(string entityName, SecurityLevel level);
    Task<Dictionary<string, SecurityLevel>> GetAllPermissions();
}
```

### 2.2 Helix6.Base.Domain (Capa de Dominio Base)

**Propósito:** Definir contratos fundamentales, configuraciones, enumeraciones y objetos de valor compartidos. No tiene dependencias de lógica compleja ni de acceso a datos concreto.

**Contenido:**
*   `BaseInterfaces/`: 
    *   `IEntityBase`: Interfaz que deben implementar todas las entidades de DataModel.
    *   `IViewBase`: Interfaz que deben implementar todos los DTOs/Views.
*   `Configuration/`: 
    *   `AppSettings`, `ConnectionStrings`: Binding tipado de `appsettings.json`.
    *   `HelixConfiguration`: Configuraciones generales del framework.
    *   `HelixAuthentication`: Parámetros de autenticación (Issuer, Audience, Claims).
    *   `AttachmentDriveSource`: Configuraciones de almacenamiento en disco.
    *   `ApplicationContext`: Datos de contexto (nombre app, rutas, DBMS, prefijos de rol).
*   `Security/`: 
    *   `IUserContext`: Interfaz para acceder a los datos del usuario autenticado (Id, Roles).
    *   `EndpointAccess`: Define niveles de seguridad (`Read`, `Modify`) requeridos por endpoint.
    *   `IUserPermissions`: Cálculo de permisos efectivos por entidad/método.
*   `Endpoints/`:
    *   `HelixFilterMapping`: Mapeo de filtros genéricos a expresiones LINQ/SQL.
    *   `IGenericFilter`: Contrato de filtros para endpoints de listados.
*   `Parameters/`: Parámetros comunes para repositorios/servicios.
*   `Validations/`: Clases de validación (`HelixValidationProblem`, excepciones de validación).
*   `Resources/`: Recursos multiidioma para mensajes de validación y UI.
*   `HelixEnums.cs`: Enumeraciones del sistema (`EnumActionType`, `SecurityLevel`, `EnumDBMSType`).
*   `HelixConsts.cs`: Constantes globales del framework.

### 2.3 Helix6.Base.Utils (Utilidades Base)

**Propósito:** Proporcionar funciones auxiliares puras y helpers estáticos.
*   `FileHelper`: Gestión segura de archivos y directorios.
*   `MailHelper`: Utilidad para envío de correos electrónicos.

### 2.4 [Proyecto].Api (Capa de Presentación - Web API)

**Propósito:** Punto de entrada de la aplicación. Responsable del bootstrapping, configuración de dependencias y exposición de endpoints HTTP.

**Tecnología:** ASP.NET Core Web API (.NET 8).

**Estructura de Carpetas:**
*   `Endpoints/`:
    *   `Base/Generator/`: Endpoints generados automáticamente por Helix Generator para cada entidad.
    *   `Base/GenericEndpoints.cs`: Clase de extensión `MapGenericEndpoints` que registra todos los endpoints generados.
    *   `Endpoints.cs`: Espacio para definir endpoints manuales/customizados.
*   `Extensions/`:
    *   `DependencyInjection.cs`: Método `AddServicesRepositories` que usa reflexión para registrar automáticamente todos los Servicios y Repositorios del proyecto.
    *   `SwaggerConfiguration.cs`: Configuración de OpenApi/Swagger.
    *   `AuthConfiguration.cs`: Configuración de JWT y Autenticación.
*   `Security/`: Implementaciones de mapeo de claims por proveedor de identidad:
    *   `KeyCloakUserClaimsMapping.cs`: Mapeo de claims para KeyCloak (JWT con realm_access y resource_access).
    *   `APVClaimsMapping.cs`: Mapeo de claims para APV (Reference Token con grupos).
    *   `APVReferenceTokenValidation.cs`: Validación de tokens de referencia mediante introspección.
    *   Otras implementaciones personalizadas según el proveedor (Azure AD, IdentityServer4, etc.).
*   `Resources/`: Archivos `.resx` para soportar multiidioma en textos.
*   `Properties/`: Metadatos del proyecto.
*   `wwwroot/`: Archivos estáticos públicos.
*   `logs/`: Carpeta de logs (Serilog).
*   `Program.cs`: Configuración del pipeline de ASP.NET Core, Serilog, CORS, y Middleware.
*   `appsettings.json`: Configuración principal (ConnectionStrings, Auth, Logging).
*   `appsettings.Development.json`, `appsettings.CI.json`: Configuraciones por ambiente.
*   `web.config`: Configuración de IIS para despliegues on-prem.
*   `Dockerfile`: Containerización para despliegue en contenedores.
*   `ApiConsts.cs`: Constantes propias de la API.

**Dependencias NuGet principales:**
*   `Helix6.Base`, `Helix6.Base.Domain`, `Helix6.Base.Utils`
*   `Serilog.AspNetCore`, `Serilog.Settings.Configuration`, `Serilog.Sinks.File`
*   `Swashbuckle.AspNetCore`
*   `Microsoft.Identity.Web`, `Microsoft.AspNetCore.Authentication.JwtBearer`

### 2.5 [Proyecto].DataModel (Capa de Modelo de Datos)

**Propósito:** Definir las entidades de persistencia que mapean a la base de datos (Entity Framework Core).

**Características:**
*   Clases POCO (Plain Old CLR Objects) que implementan `IEntityBase`.
*   Mapeo directo a tablas de base de datos.
*   **Auditoría Automática:** Todas las entidades incluyen propiedades de auditoría gestionadas por el framework:
    *   `AuditCreationUser`, `AuditModificationUser`
    *   `AuditCreationDate`, `AuditModificationDate`
    *   `AuditDeletionDate` (para Soft Delete)
*   Uso de Data Annotations (`[Key]`, `[Table]`, `[Column]`, `[ForeignKey]`) para configuración de EF.

**Convenciones de Nomenclatura:**
*   Nombre de clase: Singular (ej: `Worker`, `Course`, `Project`)
*   Propiedades de FK: `[Entidad]Id` (ej: `WorkerTypeId`)
*   Propiedades de navegación: Nombre de la entidad relacionada (ej: `WorkerType`)
*   Colecciones: Plural del nombre de entidad (ej: `Courses`, `Projects`)

**Ejemplo Completo de Entidad:**

```csharp
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;

namespace Helix6.Back.DataModel
{
    [Table("Workers")]
    public class Worker : IEntityBase
    {
        // Clave primaria
        [Key]
        public int Id { get; set; }
        
        // Propiedades básicas
        [Required]
        [StringLength(100)]
        [Column("WorkerName")]
        public string Name { get; set; } = string.Empty;
        
        [Required]
        [StringLength(100)]
        public string LastName { get; set; } = string.Empty;
        
        [Required]
        [StringLength(20)]
        public string Code { get; set; } = string.Empty;
        
        [StringLength(200)]
        public string? Email { get; set; }
        
        [Column(TypeName = "decimal(18,2)")]
        public decimal Salary { get; set; }
        
        public DateTime HireDate { get; set; }
        
        public bool Active { get; set; }
        
        // Relaciones - Clave foránea
        [ForeignKey(nameof(WorkerType))]
        public int WorkerTypeId { get; set; }
        
        // Relaciones - Navegación
        public virtual WorkerType? WorkerType { get; set; }
        
        // Relaciones - Colecciones
        [InverseProperty(nameof(Worker_Course.Worker))]
        public virtual ICollection<Worker_Course>? Courses { get; set; }
        
        [InverseProperty(nameof(Worker_Project.Worker))]
        public virtual ICollection<Worker_Project>? Projects { get; set; }
        
        // Auditoría (Implementación de IEntityBase)
        public int AuditCreationUser { get; set; }
        public DateTime AuditCreationDate { get; set; }
        public int AuditModificationUser { get; set; }
        public DateTime AuditModificationDate { get; set; }
        public DateTime? AuditDeletionDate { get; set; }
    }
}
```

**Entidad con Versionado:**

```csharp
[Table("VersionedDocuments")]
public class VersionedDocument : IEntityBase
{
    [Key]
    public int Id { get; set; }
    
    // Campos de versionado
    public int VersionKey { get; set; }  // Agrupa versiones de un mismo documento
    public int VersionNumber { get; set; }  // Número de versión
    public bool IsActiveVersion { get; set; }  // Versión actual activa
    
    // Contenido del documento
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    
    // Auditoría
    public int AuditCreationUser { get; set; }
    public DateTime AuditCreationDate { get; set; }
    public int AuditModificationUser { get; set; }
    public DateTime AuditModificationDate { get; set; }
    public DateTime? AuditDeletionDate { get; set; }
}
```

**Entidad con Vigencia Temporal:**

```csharp
[Table("Contracts")]
public class Contract : IEntityBase
{
    [Key]
    public int Id { get; set; }
    
    // Campos de vigencia
    public DateTime StartDate { get; set; }  // Inicio de vigencia
    public DateTime? EndDate { get; set; }   // Fin de vigencia (null = indefinido)
    
    // Contenido
    public string ContractNumber { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    
    // Auditoría
    public int AuditCreationUser { get; set; }
    public DateTime AuditCreationDate { get; set; }
    public int AuditModificationUser { get; set; }
    public DateTime AuditModificationDate { get; set; }
    public DateTime? AuditDeletionDate { get; set; }
}
```

**Atributos Comunes:**
*   `[Key]`: Marca la clave primaria
*   `[Required]`: Campo obligatorio
*   `[StringLength(n)]`: Longitud máxima de texto
*   `[Column(TypeName)]`: Tipo de columna en BD
*   `[ForeignKey]`: Define clave foránea
*   `[InverseProperty]`: Define la propiedad inversa en relación
*   `[NotMapped]`: Excluye propiedad del mapeo
*   `[Table("nombre")]`: Especifica nombre de tabla

### 2.6 [Proyecto].Data (Capa de Acceso a Datos)

**Propósito:** Implementación concreta de los repositorios y configuración del DbContext.

**Tecnologías:**
*   Entity Framework Core 9.0.2
*   Dapper 2.1.66
*   Soporte para SQL Server, PostgreSQL, MySQL

**Estructura:**
*   `DataModel/`:
    *   `EntityModel.cs`: DbContext principal de EF Core.
    *   Configuraciones Fluent API si se requiere.
*   `Repository/`:
    *   `Interfaces/`: Interfaces específicas de repositorios (ej: `IWorkerRepository`).
    *   Implementaciones concretas para cada entidad.

**Patrón de Implementación de Repositorios:**

Cada entidad tiene:
1. Una interfaz que hereda de `IBaseRepository<TEntity>`
2. Una implementación que hereda de `BaseRepository<TEntity>`

```csharp
// Interface
public interface IWorkerRepository : IBaseRepository<Worker>
{
    // Métodos personalizados adicionales
    Task<List<Worker>> GetActiveWorkers();
    Task<Worker?> GetByCode(string code);
}

// Implementación
public class WorkerRepository : BaseRepository<Worker>, IWorkerRepository
{
    public WorkerRepository(
        IApplicationContext appCtx, 
        IUserContext userCtx, 
        IBaseEFRepository<Worker> efRepo, 
        IBaseDapperRepository<Worker> dapperRepo)
        : base(appCtx, userCtx, efRepo, dapperRepo) 
    { 
    }
    
    // Implementación de métodos personalizados
    public async Task<List<Worker>> GetActiveWorkers()
    {
        return await ExecuteQuery(
            "SELECT * FROM Workers WHERE AuditDeletionDate IS NULL"
        );
    }
    
    public async Task<Worker?> GetByCode(string code)
    {
        var result = await ExecuteQuery(
            "SELECT * FROM Workers WHERE Code = @Code",
            new { Code = code }
        );
        return result.FirstOrDefault();
    }
}
```

**DbContext (EntityModel.cs):**
```csharp
public class EntityModel : DbContext
{
    private readonly IUserContext _userContext;
    
    public EntityModel(DbContextOptions<EntityModel> options, IUserContext userContext) 
        : base(options)
    {
        _userContext = userContext;
    }
    
    // DbSets
    public DbSet<Worker> Workers { get; set; }
    public DbSet<Course> Courses { get; set; }
    public DbSet<Project> Projects { get; set; }
    // ... más entidades
    
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        
        // Configuraciones globales
        foreach (var entityType in modelBuilder.Model.GetEntityTypes())
        {
            // Convenciones de nomenclatura de tablas
            // Configuración de índices
            // Configuración de restricciones
        }
        
        // Configuraciones específicas por entidad si es necesario
    }
    
    public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        // Auditoría automática antes de guardar
        var entries = ChangeTracker.Entries()
            .Where(e => e.Entity is IEntityBase && 
                       (e.State == EntityState.Added || e.State == EntityState.Modified));
        
        foreach (var entry in entries)
        {
            var entity = (IEntityBase)entry.Entity;
            
            if (entry.State == EntityState.Added)
            {
                entity.AuditCreationUser = _userContext.UserId;
                entity.AuditCreationDate = DateTime.UtcNow;
            }
            
            entity.AuditModificationUser = _userContext.UserId;
            entity.AuditModificationDate = DateTime.UtcNow;
        }
        
        return base.SaveChangesAsync(cancellationToken);
    }
}
```

### 2.7 [Proyecto].Entities (Capa de Entidades/DTOs)

**Propósito:** Definir los modelos de vista (Views) utilizados para la transferencia de datos hacia y desde la API.

**Estructura:**
*   `Views/`: Clases parciales (partial classes) generadas por Helix Generator. Implementan `IViewBase`.
*   `Views/Metadata/`: Clases de metadatos (`[MetadataType]`) que permiten añadir atributos de validación o configuración de UI sin modificar la clase generada.
*   `Views/Base/`: Views base compartidas (`AttachmentView`, `SecurityUserView`).

**Características:**
*   Separación clara entre el modelo de BD (`Worker`) y el modelo de API (`WorkerView`).
*   Uso de Mapster para la transformación entre capas.

**Ejemplo de View Generada:**

```csharp
// WorkerView.cs (Generado automáticamente)
namespace Helix6.Back.Entities.Views
{
    [MetadataType(typeof(WorkerViewMetadata))]
    public partial class WorkerView : IViewBase
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string Code { get; set; } = string.Empty;
        public string? Email { get; set; }
        public decimal Salary { get; set; }
        public DateTime HireDate { get; set; }
        public bool Active { get; set; }
        
        // Relaciones
        public int WorkerTypeId { get; set; }
        public WorkerTypeView? WorkerType { get; set; }
        
        // Colecciones
        public List<WorkerCourseView>? Courses { get; set; }
        
        // Auditoría
        public int AuditCreationUser { get; set; }
        public DateTime AuditCreationDate { get; set; }
        public int AuditModificationUser { get; set; }
        public DateTime AuditModificationDate { get; set; }
        public DateTime? AuditDeletionDate { get; set; }
    }
}
```

**Ejemplo de Metadata:**

```csharp
// WorkerViewMetadata.cs (Creado manualmente, no regenerado)
namespace Helix6.Back.Entities.Views.Metadata
{
    public partial class WorkerViewMetadata
    {
        [Required(ErrorMessage = "El nombre es obligatorio")]
        [StringLength(100, ErrorMessage = "El nombre no puede exceder 100 caracteres")]
        public string Name { get; set; }
        
        [Required(ErrorMessage = "El apellido es obligatorio")]
        [StringLength(100, ErrorMessage = "El apellido no puede exceder 100 caracteres")]
        public string LastName { get; set; }
        
        [Required(ErrorMessage = "El código es obligatorio")]
        [StringLength(20, ErrorMessage = "El código no puede exceder 20 caracteres")]
        public string Code { get; set; }
        
        [EmailAddress(ErrorMessage = "El formato del email no es válido")]
        public string? Email { get; set; }
        
        [Range(0, 999999.99, ErrorMessage = "El salario debe estar entre 0 y 999999.99")]
        public decimal Salary { get; set; }
    }
}
```

**Extensión de Views con Propiedades Calculadas:**

```csharp
// WorkerView.Custom.cs (Archivo parcial personalizado)
namespace Helix6.Back.Entities.Views
{
    public partial class WorkerView
    {
        // Propiedades calculadas no mapeadas
        [NotMapped]
        public string? FullName { get; set; }
        
        [NotMapped]
        public int? YearsOfService { get; set; }
        
        [NotMapped]
        public string? WorkerTypeName { get; set; }
        
        [NotMapped]
        public bool IsDeleted => AuditDeletionDate.HasValue;
    }
}
```

### 2.8 [Proyecto].Services (Capa de Lógica de Negocio)

**Propósito:** Contener toda la lógica de negocio, reglas de validación y orquestación de llamadas a datos.

**Estructura:**
*   Un servicio por entidad que hereda de `BaseService<TView, TEntity, TMetadata>`
*   `Base/`: Servicios base del framework (AttachmentService, PermissionsService)
*   `ServiceConsts.cs`: Constantes para mensajes de validación y claves de error

**Patrón de Implementación Completo:**

```csharp
public class WorkerService : BaseService<WorkerView, Worker, WorkerViewMetadata>
{
    private readonly IWorkerRepository _workerRepository;
    private readonly ICourseRepository _courseRepository; // Si necesita otras dependencias
    
    public WorkerService(
        IApplicationContext appCtx, 
        IUserContext userCtx, 
        IWorkerRepository repo,
        ICourseRepository courseRepository) 
        : base(appCtx, userCtx, repo)
    {
        _workerRepository = repo;
        _courseRepository = courseRepository;
    }
    
    /// <summary>
    /// Inicializa una nueva entidad con valores por defecto
    /// </summary>
    public override async Task<WorkerView?> GetNewEntity()
    {
        var view = new WorkerView
        {
            Id = 0,
            Active = true,
            CreatedDate = DateTime.UtcNow,
            WorkerTypeId = 1 // Valor por defecto
        };
        return await Task.FromResult(view);
    }
    
    /// <summary>
    /// Validaciones de negocio personalizadas
    /// </summary>
    public override async Task ValidateView(
        HelixValidationProblem validations, 
        WorkerView? view, 
        EnumActionType actionType, 
        string? configurationName = null)
    {
        if (view != null)
        {
            // Validación de campo requerido
            if (string.IsNullOrWhiteSpace(view.Name))
            {
                validations.Add("Name", "El nombre es requerido");
            }
            
            // Validación de longitud
            if (view.Name?.Length < 3)
            {
                validations.Add("Name", "El nombre debe tener al menos 3 caracteres");
            }
            
            // Validación de unicidad
            if (actionType == EnumActionType.Insert || actionType == EnumActionType.Update)
            {
                var existing = await _workerRepository.GetByCode(view.Code);
                if (existing != null && existing.Id != view.Id)
                {
                    validations.Add("Code", "Ya existe un trabajador con este código");
                }
            }
            
            // Validación de regla de negocio compleja
            if (view.WorkerTypeId == 2 && view.Salary < 1000)
            {
                validations.Add("Salary", "El salario mínimo para este tipo de trabajador es 1000");
            }
        }
        
        // Llamar a la validación base
        await base.ValidateView(validations, view, actionType, configurationName);
    }
    
    /// <summary>
    /// Acciones previas a la operación (ej: eliminar entidades relacionadas)
    /// </summary>
    public override async Task PreviousActions(
        WorkerView? view, 
        EnumActionType actionType, 
        string? configurationName = null)
    {
        if (view != null && actionType == EnumActionType.Delete)
        {
            // Eliminar cursos asociados antes de eliminar el trabajador
            var courses = await _courseRepository.GetByWorkerId(view.Id);
            if (courses.Any())
            {
                await _courseRepository.DeleteByIds(courses.Select(c => c.Id).ToList());
            }
        }
        
        if (view != null && actionType == EnumActionType.Insert)
        {
            // Generar código automático si no se proporcionó
            if (string.IsNullOrEmpty(view.Code))
            {
                view.Code = await GenerateWorkerCode();
            }
        }
        
        await base.PreviousActions(view, actionType, configurationName);
    }
    
    /// <summary>
    /// Acciones posteriores a la operación (ej: notificaciones, eventos)
    /// </summary>
    public override async Task PostActions(
        WorkerView? view, 
        EnumActionType actionType, 
        string? configurationName = null)
    {
        if (view != null && actionType == EnumActionType.Insert)
        {
            // Enviar notificación de bienvenida
            await SendWelcomeEmail(view.Email);
            
            // Registrar evento en log de auditoría
            _logger.Information("Nuevo trabajador creado: {WorkerId} - {WorkerName}", 
                view.Id, view.Name);
        }
        
        await base.PostActions(view, actionType, configurationName);
    }
    
    /// <summary>
    /// Mapeo personalizado de Entity a View
    /// </summary>
    public override async Task<WorkerView?> MapEntityToView(
        Worker? entity, 
        string? configurationName = null, 
        WorkerView? view = null)
    {
        // Usar el mapeo base de Mapster
        var workerView = await base.MapEntityToView(entity, configurationName, view);
        
        if (workerView != null && entity != null)
        {
            // Agregar propiedades calculadas que no están en la entidad
            workerView.FullName = $"{entity.Name} {entity.LastName}";
            workerView.YearsOfService = CalculateYearsOfService(entity.HireDate);
            
            // Cargar datos relacionados si es necesario
            if (entity.WorkerType != null)
            {
                workerView.WorkerTypeName = entity.WorkerType.Name;
            }
        }
        
        return workerView;
    }
    
    /// <summary>
    /// Mapeo personalizado de View a Entity
    /// </summary>
    public override async Task<Worker?> MapViewToEntity(
        WorkerView? view, 
        string? configurationName = null, 
        Worker? entity = null)
    {
        var worker = await base.MapViewToEntity(view, configurationName, entity);
        
        if (worker != null && view != null)
        {
            // Lógica personalizada de mapeo
            // Por ejemplo, normalizar datos
            worker.Name = view.Name?.Trim().ToUpper();
        }
        
        return worker;
    }
    
    // Métodos privados auxiliares
    private async Task<string> GenerateWorkerCode()
    {
        var count = await _workerRepository.GetCount();
        return $"WRK-{(count + 1):D6}";
    }
    
    private int CalculateYearsOfService(DateTime hireDate)
    {
        return (DateTime.Now - hireDate).Days / 365;
    }
    
    private async Task SendWelcomeEmail(string email)
    {
        // Implementación de envío de email
        await Task.CompletedTask;
    }
}
```

**Métodos Sobrescribibles del Ciclo de Vida:**

1. **GetNewEntity()**: Inicializar nueva entidad con valores por defecto
2. **ValidateView()**: Validaciones de negocio personalizadas
3. **PreviousActions()**: Lógica previa a la acción (preparación, validaciones complejas)
4. **PostActions()**: Lógica posterior a la acción (notificaciones, eventos)
5. **MapEntityToView()**: Mapeo personalizado Entity → View
6. **MapViewToEntity()**: Mapeo personalizado View → Entity

### 2.9 [Proyecto].Services.Tests (Pruebas de Servicios)

**Propósito:** Ejecutar pruebas unitarias sobre servicios de negocio.

**Framework:** xUnit/NUnit con `Moq` para mocks.

**Estructura:**
*   `TestInitialization.cs`: Inicialización y utilidades de pruebas.
*   `ServiceFixtures`: Fixtures para construir `IServiceProvider` y dependencias.
*   Tests por entidad: validaciones, hooks, mapeos.

### 2.10 [Proyecto].Data.Tests (Pruebas de Repositorios)

**Propósito:** Pruebas de integración de repositorios con BD real o in-memory.

**Estructura:**
*   `appsettings.Test.json`: Configuración de prueba.
*   `BaseRepositoryTest.cs`: Casos comunes (CRUD, filtros, transacciones).
*   `Mock/`: Datos simulados.

### 2.11 [Proyecto].HelixGenerator (Generador de Código)

**Propósito:** Herramienta de automatización (Scaffolding).

**Funcionalidad:**
Analiza el archivo de configuración `HelixEntities.xml` y los modelos en `DataModel` para generar automáticamente:
1.  Clases `View` en el proyecto `Entities`.
2.  Clases `ViewMetadata` en el proyecto `Entities`.
3.  Archivos de Endpoints (`WorkerEndpoints.cs`) en el proyecto `Api`.
4.  Actualización de `GenericEndpoints.cs`.

Esto elimina la necesidad de escribir código boilerplate manual para operaciones CRUD estándar.

---

## 3. Archivo HelixEntities.xml

### 3.1 Propósito y Función

El archivo `HelixEntities.xml` actúa como el archivo de configuración central para la generación de código. Define de manera declarativa qué entidades deben exponerse en la API, qué campos de vista deben generarse y qué endpoints deben crearse.

### 3.2 Estructura XML Detallada

El esquema XML permite definir múltiples entidades con gran granularidad:

```xml
<HelixEntities>
  <Entities>
    <EntityName>Worker</EntityName>                  <!-- Nombre de la clase Entity en DataModel -->
    <ViewName>WorkerView</ViewName>                  <!-- Nombre de la clase View a generar -->
    <DefaultFilterField>Name</DefaultFilterField>    <!-- Campo por defecto para búsquedas simples -->
    
    <Fields>
      <EntityFieldName>Name</EntityFieldName>        <!-- Propiedad en el DataModel -->
      <ViewFieldName>Name</ViewFieldName>            <!-- Propiedad en la View -->
      <EntityFieldTypeDB>String</EntityFieldTypeDB>  <!-- Tipo de dato .NET -->
      <IsEntidadBase>false</IsEntidadBase>           <!-- Si es una propiedad compleja de navegación -->
      <IsList>false</IsList>                         <!-- Si es una colección -->
    </Fields>
    <!-- Más campos... -->

    <Configurations>
        <!-- Configuraciones para filtros, ordenamiento, etc. -->
    </Configurations>

    <Endpoints>
      <Methods>
        <Method>GetAll</Method>
        <Method>GetById</Method>
        <Method>Insert</Method>
        <Method>Update</Method>
        <Method>DeleteUndeleteLogicById</Method>
        <Method>GetAllKendoFilter</Method>
      </Methods>
    </Endpoints>

    <IsVersionEntity>false</IsVersionEntity>
    <IsValidityEntity>false</IsValidityEntity>
  </Entities>
</HelixEntities>
```

### 3.3 Configuraciones Soportadas

*   **Endpoints Methods:** Controla qué operaciones se exponen en la API.
    *   CRUD Básico: `Insert`, `Update`, `DeleteById`, `GetById`.
    *   Colecciones: `InsertMany`, `UpdateMany`, `DeleteByIds`, `GetByIds`.
    *   Lógica Avanzada: `DeleteUndeleteLogicById` (Soft Delete), `GetAllKendoFilter` (Paginación/Filtros).
    *   Attachments: `GetAllAttachments`, `GetNewAttachmentEntity`.
*   **Tipos de Entidad:**
    *   `IsVersionEntity`: Genera repositorios/servicios base de versionado.
    *   `IsValidityEntity`: Genera soporte para vigencia temporal.

---

## 4. Flujo de Datos y Control

### 4.1 Flujo de una Petición HTTP

El ciclo de vida de una petición típica (ej: `POST /api/Worker/Insert`) sigue este estricto flujo:

1.  **Entrada:** La petición llega al Endpoint generado (`WorkerEndpoints.cs`).
2.  **Seguridad:** El `Middleware` de autenticación valida el JWT. Se verifica el `EndpointAccess` (ej: `SecurityLevel.Modify`).
3.  **Servicio:** El Endpoint invoca `WorkerService.Insert(view)`.
4.  **Validación:**
    *   El servicio ejecuta `ValidateView`. Si hay errores, se lanza `HelixValidationException` y se devuelve HTTP 400.
5.  **Pre-Proceso:** Se ejecuta `PreviousActions` (ej: validaciones complejas de estado, preparación de datos).
6.  **Mapeo (View -> Entity):** `Mapster` convierte `WorkerView` a `Worker`.
7.  **Repositorio:** `WorkerRepository.Insert(entity)` inicia la transacción.
8.  **Persistencia:** `BaseEFRepository` añade la entidad al `DbSet`. EF Core genera el SQL. `SaveChanges` confirma la transacción.
9.  **Post-Proceso:** Se ejecuta `PostActions` (ej: notificaciones, eventos de dominio).
10. **Mapeo (Entity -> View):** La entidad persistida (con ID generado) se convierte de nuevo a View.
11. **Salida:** El Endpoint devuelve la View en formato JSON con código HTTP 200.

### 4.2 Manejo de Errores

El framework utiliza un sistema centralizado de manejo de excepciones:
*   **HelixExceptionsMiddleware:** Envuelve toda la ejecución. Captura excepciones no controladas.
*   **HelixValidationException:** Para errores de regla de negocio/validación. Se transforma en un `ValidationProblemDetails` (RFC 7807) con errores agrupados por campo.
*   **ProblemDetails:** Formato estándar de respuesta para errores.

---

### 4.3 Transacciones y Unidad de Trabajo

*   **DbContext como Unit of Work:** `EntityModel` (EF Core) gestiona el ciclo de vida de las entidades y las transacciones.
*   **Transacciones:** Operaciones de modificación (`Insert/Update/Delete`) se realizan dentro de transacciones; operaciones masivas usan una transacción compartida.
*   **Consistencia:** `SaveChanges` confirma cambios; en caso de excepción, se hace rollback.
*   **Dapper:** Lecturas optimizadas fuera de transacción cuando no es requerido, o dentro si se necesita consistencia con EF.

## 5. Tecnologías y Dependencias

La arquitectura se construye sobre un stack moderno y robusto:

### 5.1 Framework y Runtime
*   **.NET 8.0**: Runtime principal.
*   **C# 12**: Lenguaje (Nullable Reference Types habilitados).

### 5.2 Persistencia de Datos
*   **Entity Framework Core 9.0.2**: ORM principal. Soporta Migrations y Code First.
*   **Dapper 2.1.66**: Micro-ORM para consultas de lectura de alto rendimiento.
*   **Multi-DBMS**: Abstracción preparada para SQL Server, PostgreSQL y MySQL.

### 5.3 Autenticación
*   **Microsoft.Identity.Web 3.7.1**: Integración con identity providers.
*   **JWT Bearer**: Estándar de tokens.

### 5.4 Mapeo
*   **Mapster 7.4.0**: Librería de mapeo objeto-objeto de alto rendimiento, evitando el overhead de AutoMapper.

### 5.5 Logging
*   **Serilog 4.2.0**: Logging estructurado. Configurable via `appsettings`. Sinks para Archivo y Consola.

### 5.6 Documentación
*   **Swagger (Swashbuckle 7.3.1)**: Generación automática de especificación OpenAPI y UI interactiva.

---

### 5.7 Serialización
*   **System.Text.Json (9.0.2):** Serializer por defecto. Opciones recomendadas:
    * `DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull`
    * `PropertyNamingPolicy = null` (conservar PascalCase en DTOs)
    * Soporte para `DateTime` en UTC.
*   **Newtonsoft.Json (13.0.1):** Opcional para compatibilidad; habilitar solo si se requiere características específicas (polimorfismo avanzado, converters personalizados).

### 5.8 Otras Dependencias Importantes
*   **System.Linq.Dynamic.Core 1.6.0.2:** Construcción de consultas LINQ dinámicas desde filtros.
*   **Microsoft.Extensions.DependencyInjection 9.0.2:** DI.
*   **Microsoft.Extensions.Logging 9.0.2:** Logging.

## 6. Configuración de la Aplicación

### 6.1 Estructura de AppSettings.json

La configuración es fuertemente tipada y jerárquica:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=...;Database=...;"   // Cadena principal EF Core
  },
  "HelixConfiguration": {
    "ApplicationName": "Helix6Back",
    "RolPrefixes": ["ADMIN_", "USER_"],               // Prefijos para mapeo de roles
    "PermisionsMinutesCache": 10,
    "DBMSType": 1                                     // 1: SQLServer, 2: Postgres ...
  },
  "AttachmentDriveSource": {
    "Folder": "C:\\HelixAttachments",                 // Ruta física para adjuntos
    "UseSubFolders": true
  },
  "Authentication": { ... },                          // Configuración Azure AD / JWT
  "Serilog": { ... }                                  // Niveles de log y sinks
}
```

### 6.2 Variables de Entorno
El soporte de configuración permite sobreescritura mediante variables de entorno con prefijo `HELIX6_` (ej: `HELIX6_ConnectionStrings__DefaultConnection`), facilitando despliegues en contenedores/Azure DevOps.

---

### 6.3 Configuración por Ambiente
*   `appsettings.json`: Configuración base.
*   `appsettings.Development.json`: Desarrollo local.
*   `appsettings.CI.json`: Integración continua.
*   `appsettings.Production.json`: Producción (generalmente no versionado).
*   Variable `ASPNETCORE_ENVIRONMENT` selecciona ambiente.
*   `AllowedOrigins`: Lista de orígenes permitidos para CORS.

## 7. Bootstrapping y Program.cs

El archivo `Program.cs` orquesta el inicio de la aplicación.

### 7.1 Secuencia de Configuración en Program.cs
1. **Crear WebApplicationBuilder**
2. **Configurar settings y variables de entorno**
    - Leer `appsettings.json`
    - Leer `appsettings.{environment}.json`
    - Leer variables de entorno con prefijo `HELIX6_`
3. **Configurar Serilog**
    - `UseSerilog` en el host
4. **Configurar Localización**
    - `AddCultures` con culturas soportadas y `RequestLocalizationOptions`
5. **Bindear AppSettings**
    - Crear instancia de `AppSettings` y registrar como singleton
6. **Configurar Autenticación**
    - `AddAuthentication`/`AddJwtBearer` con `HelixAuthentication`
7. **Configurar Inyección de Dependencias**
    - `AddDependencyInjection` (DbContext, IDbConnection, contextos)
    - `AddServicesRepositories` (auto-registro de servicios y repositorios)
8. **Configurar Mapster**
    - `AddMapster` para mapeos Entity↔View
9. **Configurar Serialización**
    - `Configure<JsonOptions>` para ignorar nulos y conservar naming
10. **Configurar CORS**
     - `AddCors` con `AllowedOrigins`
11. **Configurar Swagger**
     - `AddSwagger` con culturas
12. **Configurar Problem Details**
     - `AddProblemDetails`
13. **Build de la aplicación**
14. **Configurar Middleware Pipeline**
     - `UseStaticFiles`
     - `UseExceptionHandler`
     - `UseStatusCodePages`
     - `UseSerilogRequestLogging`
     - `UseAuthentication` / `UseAuthorization`
     - `UseMiddleware<HelixExceptionsMiddleware>`
15. **Mapear Endpoints**
     - `MapGenericEndpoints` (generados)
     - `MapSpecificEndpoints` (personalizados)
16. **Configurar Swagger UI**
17. **Run de la aplicación**

---

## 8. Generación Automática de Código

### 8.1 Helix Generator
El generador es un componente externo al runtime que toma `HelixEntities.xml` y produce código fuente C#.

**Entrada:**
*   `HelixEntities.xml`: Archivo de configuración XML
*   Ensamblado del proyecto `DataModel` con las entidades compiladas

**Salida:**
*   Clases `View` en `[Proyecto].Entities/Views/`
*   Clases `ViewMetadata` en `[Proyecto].Entities/Views/Metadata/`
*   Archivos de Endpoints en `[Proyecto].Api/Endpoints/Base/Generator/`
*   Actualización de `GenericEndpoints.cs`

### 8.2 Componentes Generados Automáticamente

#### Views
Clases parciales con todas las propiedades mapeadas desde la entidad:

```csharp
// Ejemplo: WorkerView.cs
namespace Helix6.Back.Entities.Views
{
    /// <summary>
    /// View generada automáticamente para Worker
    /// </summary>
    [MetadataType(typeof(WorkerViewMetadata))]
    public partial class WorkerView : IViewBase
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        // ... propiedades según HelixEntities.xml
    }
}
```

#### ViewMetadata
Clases parciales **solo iniciales** (no se sobrescriben):

```csharp
// Ejemplo: WorkerViewMetadata.cs
namespace Helix6.Back.Entities.Views.Metadata
{
    /// <summary>
    /// Metadata inicial para WorkerView
    /// Personalizar según necesidades sin regenerar
    /// </summary>
    public partial class WorkerViewMetadata
    {
        // Atributos de validación personalizados
    }
}
```

#### Endpoints
Archivos estáticos con métodos de extensión:

```csharp
// Ejemplo: WorkerEndpoints.cs
namespace Helix6.Back.Api.Endpoints.Base.Generator
{
    public static class WorkerEndpoints
    {
        public static void MapWorkerEndpoints(this IEndpointRouteBuilder app)
        {
            var group = app.MapGroup("/api/Worker").WithTags("Worker");
            
            // GetNewEntity
            EndpointHelper.GenerateGetNewEntityEndpoint<IWorkerService, WorkerView>(
                group, SecurityLevel.Read);
            
            // GetById
            EndpointHelper.GenerateGetByIdEndpoint<IWorkerService, WorkerView>(
                group, SecurityLevel.Read);
            
            // Insert
            EndpointHelper.GenerateInsertEndpoint<IWorkerService, WorkerView>(
                group, SecurityLevel.Modify);
            
            // Update
            EndpointHelper.GenerateUpdateEndpoint<IWorkerService, WorkerView>(
                group, SecurityLevel.Modify);
            
            // DeleteUndeleteLogicById
            EndpointHelper.GenerateDeleteUndeleteLogicByIdEndpoint<IWorkerService>(
                group, SecurityLevel.Modify);
            
            // GetAllKendoFilter
            EndpointHelper.GenerateGetAllKendoFilterEndpoint<IWorkerService, WorkerView>(
                group, SecurityLevel.Read);
        }
    }
}
```

#### GenericEndpoints.cs
Mapeo centralizado:

```csharp
namespace Helix6.Back.Api.Endpoints.Base
{
    public static class GenericEndpoints
    {
        public static void MapGenericEndpoints(this IEndpointRouteBuilder app)
        {
            // Generado automáticamente por Helix Generator
            app.MapWorkerEndpoints();
            app.MapCourseEndpoints();
            app.MapProjectEndpoints();
            // ... más entidades
        }
    }
}
```

### 8.3 Convenciones de Generación

**Partial Classes:**
*   **Views**: SIEMPRE se regeneran completamente. Las personalizaciones deben ir en archivos parciales adicionales (ej: `WorkerView.Custom.cs`).
*   **ViewMetadata**: Se crean solo si no existen. Una vez creadas, no se sobrescriben.
*   **Endpoints**: Se regeneran completamente en cada ejecución.

**Nomenclatura:**
*   View: `[Entidad]View`
*   Metadata: `[Entidad]ViewMetadata`
*   Endpoint: `[Entidad]Endpoints`
*   Service Interface: `I[Entidad]Service`
*   Repository Interface: `I[Entidad]Repository`

**Comentarios de Código Generado:**
```csharp
/// <summary>
/// CÓDIGO GENERADO AUTOMÁTICAMENTE POR HELIX GENERATOR
/// No modificar manualmente. Los cambios se perderán en la próxima generación.
/// Fecha de generación: [timestamp]
/// </summary>
```

**Proceso de Generación:**
1. Leer `HelixEntities.xml`
2. Cargar ensamblado de `DataModel` mediante reflexión
3. Para cada `<Entities>` en el XML:
   - Obtener la clase Entity correspondiente
   - Generar archivo `View` con propiedades mapeadas
   - Generar archivo `ViewMetadata` si no existe
   - Generar archivo `Endpoints` con métodos según configuración
4. Actualizar `GenericEndpoints.cs` con todas las llamadas
5. Guardar archivos en disco

**Personalización Post-Generación:**
```csharp
// WorkerView.Custom.cs
public partial class WorkerView
{
    // Propiedades calculadas personalizadas
    public string FullName => $"{Name} {LastName}";
}

// WorkerViewMetadata.cs (ya existe, no se regenera)
public partial class WorkerViewMetadata
{
    [Required]
    [StringLength(100)]
    public string Name { get; set; }
}
```

---

## 9. Sistema de Endpoints

### 9.1 EndpointHelper

Clase estática central en `Helix6.Base`. Contiene métodos genéricos (`GenerateGetByIdEndpoint<TService...>`, `GenerateInsertEndpoint<TService...>`) que encapsulan la lógica repetitiva de exponer un método de servicio como HTTP endpoint.

### 9.2 Tipos de Endpoints

*   **Estándar:** `GetById`, `Insert`, `Update`, `Delete`.
*   **Masivos:** `InsertMany`, `UpdateMany`, `DeleteByIds`.
*   **Lógicos:** `DeleteUndeleteLogicById` (Cambia estado de `AuditDeletionDate` en lugar de borrar).
*   **Consultas:** `GetAllKendoFilter` (Soporta estructura de filtros complejos JSON compatible con Kendo UI DataSource).

### 9.3 EndpointAccess y Seguridad

Cada endpoint generado se configura con un nivel de acceso:
*   `GenerateGet...` -> `SecurityLevel.Read`
*   `GenerateInsert/Update/Delete...` -> `SecurityLevel.Modify`

Estos niveles se validan contra los permisos del usuario en tiempo de ejecución.

---

### 9.4 Estructura de URL
*   Patrón: `/api/[Entidad]/[Método]`
*   Ejemplos:
    - `/api/Worker/GetById`
    - `/api/Worker/GetAll`
    - `/api/Worker/GetAllKendoFilter`
    - `/api/Worker/DeleteUndeleteLogicById`

## 10. Sistema de Seguridad

### 10.1 Autenticación
Basada en **JWT Bearer**. Interactúa con `Microsoft.Identity.Web` para validar tokens emitidos por proveedores de identidad (Azure AD).

### 10.2 Autorización y Roles
*   **Roles:** Se leen del token JWT. (ej: `roles` claim).
*   **Prefijos:** Se filtran roles usando `RolPrefixes` configurado.
*   **Permisos (`IUserPermissions`):** Servicio inyectable que determina si un usuario tiene acceso a una entidad específica y con qué nivel (`Read`/`Modify`).
*   **Cache:** Los permisos se calculan y cachean por un tiempo definido (`PermisionsMinutesCache`) para rendimiento óptimo.

### 10.3 UserContext
Interfaz `IUserContext` inyectable en cualquier servicio/repositorio. Proporciona acceso inmediato a:
*   `UserId`
*   `UserName`
*   `Roles`
*   `Language`

### 10.4 ApplicationContext
*   Mantiene datos globales de la aplicación: `ApplicationName`, `RolPrefixes`, `DBMSType`.
*   Define la ruta al `HelixEntities.xml` y otras rutas relevantes.
*   Expone helpers para leer el usuario actual y cultura.

### 10.5 Mapeo de Claims según Identity Server

El framework Helix6 soporta múltiples proveedores de identidad (Identity Servers) mediante un sistema de mapeo de claims personalizable. Cada proveedor puede tener una estructura diferente de claims en el token JWT, por lo que se implementan adaptadores específicos.

#### Interfaces de Abstracción

**IUserClaimsMapping:** Mapea los claims del token a la información del usuario del framework.

```csharp
public interface IUserClaimsMapping
{
    int GetSecurityCompanyId(ClaimsPrincipal? principalUser);
    string? GetUserId(ClaimsPrincipal? principalUser);
    string? GetUserName(ClaimsPrincipal? principalUser);
    string? GetDisplayName(ClaimsPrincipal? principalUser);
    string? GetLogin(ClaimsPrincipal? principalUser);
    string? GetMail(ClaimsPrincipal? principalUser);
    string? GetOrganizationCif(ClaimsPrincipal? principalUser);
    string? GetOrganizationCode(ClaimsPrincipal? principalUser);
    string? GetOrganizationName(ClaimsPrincipal? principalUser);
    bool GetIsAdmin(ClaimsPrincipal? principalUser, string? rolPrefixesString = null);
    List<string> GetRoles(ClaimsPrincipal? principalUser, string? rolPrefixesString = null);
    bool GetSendClaimsToFront();
}
```

**IReferenceTokenValidation:** Para tokens de referencia (opaque tokens) que requieren validación contra el servidor de autenticación.

```csharp
public interface IReferenceTokenValidation
{
    Task<bool> ValidateReferenceToken(string? referenceToken, string scheme);
    Task<ClaimsPrincipal?> CompleteUserInfoFromReferenceToken(string? referenceToken, string scheme);
}
```

#### Implementación para KeyCloak

KeyCloak utiliza una estructura compleja con roles en `realm_access` y `resource_access`:

```csharp
public class KeyCloakUserClaimsMapping : IUserClaimsMapping
{
    const string REALM_ROLES_CLAIM = "realm_access";
    const string RESOURCE_ROLES_CLAIM = "resource_access";
    const string CLIENT_NAME = "angularclient";
    const string NODE_ROLES = "roles";
    const string ISADMIN_CLAIM = "HLX_IsAdmin";
    const string SECURITY_COMPANY_ID_CLAIM = "c_id";
    const string ORGANIZATION_CIF_CLAIM = "o_cif";
    const string ORGANIZATION_CODE_CLAIM = "o_code";
    const string ORGANIZATION_NAME_CLAIM = "o_name";
    
    public string? GetUserId(ClaimsPrincipal? principalUser)
    {
        return principalUser.GetClaimValue(JwtClaimTypes.Subject);
    }
    
    public string? GetUserName(ClaimsPrincipal? principalUser)
    {
        return principalUser.GetClaimValue(JwtClaimTypes.GivenName);
    }
    
    public List<string> GetRoles(ClaimsPrincipal? principalUser, string? rolPrefixesString = null)
    {
        List<string> roles = new();
        
        // Roles de Realm
        var realm_access = principalUser.GetClaimValue(REALM_ROLES_CLAIM);
        if (realm_access != null && realm_access.Contains(NODE_ROLES))
        {
            using (JsonDocument document = JsonDocument.Parse(realm_access))
            {
                JsonElement root = document.RootElement;
                JsonElement propertyRoles = root.GetProperty(NODE_ROLES);
                foreach (JsonElement element in propertyRoles.EnumerateArray())
                {
                    if (element.ValueKind == JsonValueKind.String)
                    {
                        var rol = element.GetString();
                        if (rol != null)
                            roles.Add(rol);
                    }
                }
            }
        }
        
        // Roles de Resource (Client específico)
        var resource_access = principalUser.GetClaimValue(RESOURCE_ROLES_CLAIM);
        if (resource_access != null && resource_access.Contains(CLIENT_NAME))
        {
            using (JsonDocument document = JsonDocument.Parse(resource_access))
            {
                JsonElement root = document.RootElement;
                JsonElement propertyClient = root.GetProperty(CLIENT_NAME);
                JsonElement propertyRoles = propertyClient.GetProperty(NODE_ROLES);
                foreach (JsonElement element in propertyRoles.EnumerateArray())
                {
                    var rol = element.GetString();
                    if (rol != null)
                        roles.Add(rol);
                }
            }
        }
        
        // Filtrar por prefijos si se especificaron
        if (rolPrefixesString != null)
        {
            roles = FilterRolesByPrefixes(rolPrefixesString, roles);
        }
        
        return roles;
    }
    
    private List<string> FilterRolesByPrefixes(string rolPrefixesString, List<string> roles)
    {
        List<string> filteredRoles = new();
        List<string> rolPrefixes = rolPrefixesString.Split(",").ToList();
        foreach (var rolPrefix in rolPrefixes)
        {
            filteredRoles.AddRange(roles.Where(r => r.StartsWith(rolPrefix)).ToList());
        }
        return filteredRoles;
    }
}
```

**Estructura de Token KeyCloak:**
```json
{
  "sub": "user-uuid",
  "given_name": "John",
  "name": "John Doe",
  "preferred_username": "johndoe",
  "email": "john@example.com",
  "c_id": "1",
  "o_cif": "B12345678",
  "o_code": "ORG001",
  "o_name": "My Organization",
  "realm_access": {
    "roles": ["user", "HLX_IsAdmin"]
  },
  "resource_access": {
    "angularclient": {
      "roles": ["WORKER_READ", "WORKER_MODIFY"]
    }
  }
}
```

#### Implementación para APV (Reference Token)

APV utiliza tokens de referencia (opaque) que requieren validación mediante introspección:

```csharp
public class APVClaimsMapping : IUserClaimsMapping
{
    const string USER_ID_CLAIM = "user_id";
    const string ORGANIZATION_CIF_CLAIM = "organizationcif";
    const string ORGANIZATION_NAME_CLAIM = "organization";
    const string ORGANIZATION_CODE_CLAIM = "organizationapvcode";
    const string ROLES_CLAIM = "groups";
    const string ISADMIN_CLAIM = "admin";
    
    public string? GetUserId(ClaimsPrincipal? principalUser)
    {
        return GetClaimValue(USER_ID_CLAIM, principalUser);
    }
    
    public List<string> GetRoles(ClaimsPrincipal? principalUser, string? rolPrefixesString = null)
    {
        List<string> roles = new();
        var rolesClaimValue = GetClaimValue(ROLES_CLAIM, principalUser);
        if (rolesClaimValue != null)
        {
            roles = rolesClaimValue.Split(",").ToList();
            
            // Filtrar por prefijos
            if (rolPrefixesString != null)
            {
                roles = FilterRolesByPrefixes(rolPrefixesString, roles);
            }
        }
        return roles;
    }
    
    private string? GetClaimValue(string claimType, ClaimsPrincipal? principalUser)
    {
        if (principalUser != null)
        {
            var claim = principalUser.Claims.FirstOrDefault(c => c.Type == claimType);
            if (claim != null)
                return claim.Value;
        }
        return null;
    }
}
```

**Validación de Reference Token (APV):**

```csharp
public class APVReferenceTokenValidation : IReferenceTokenValidation
{
    private readonly AppSettings _appSettings;
    
    public async Task<bool> ValidateReferenceToken(string? referenceToken, string scheme)
    {
        var referenceTokenScheme = GetReferenceTokenScheme(scheme);
        if (referenceTokenScheme != null && referenceToken != null)
        {
            using var client = new HttpClient();
            var byteArray = Encoding.ASCII.GetBytes(
                referenceTokenScheme.IntrospectionUser + ":" + 
                referenceTokenScheme.IntrospectionPassword);
            client.DefaultRequestHeaders.Authorization = 
                new AuthenticationHeaderValue("Basic", Convert.ToBase64String(byteArray));
            
            var url = referenceTokenScheme.IntrospectionEndpoint.TrimEnd('/');
            var data = new List<KeyValuePair<string, string>>
            {
                new KeyValuePair<string, string>("token", referenceToken)
            };
            
            var req = new HttpRequestMessage(HttpMethod.Post, url) 
            { 
                Content = new FormUrlEncodedContent(data) 
            };
            var response = await client.SendAsync(req);
            
            if (response.IsSuccessStatusCode && response.Content != null)
            {
                string jsonResult = await response.Content.ReadAsStringAsync();
                var jsonDocument = JsonDocument.Parse(jsonResult);
                bool active = jsonDocument.RootElement.GetProperty("active").GetBoolean();
                return active;
            }
        }
        return false;
    }
    
    public async Task<ClaimsPrincipal?> CompleteUserInfoFromReferenceToken(
        string? referenceToken, string scheme)
    {
        var referenceTokenScheme = GetReferenceTokenScheme(scheme);
        if (referenceTokenScheme != null && !string.IsNullOrEmpty(referenceTokenScheme.UserInfoEndpoint))
        {
            using var client = new HttpClient();
            client.DefaultRequestHeaders.Authorization = 
                new AuthenticationHeaderValue("Bearer", referenceToken);
            
            var response = await client.GetAsync(referenceTokenScheme.UserInfoEndpoint);
            if (response.IsSuccessStatusCode)
            {
                string jsonResult = await response.Content.ReadAsStringAsync();
                return MapUserInfo(scheme, jsonResult, referenceTokenScheme.MinutesCache ?? 5);
            }
        }
        return null;
    }
    
    private static ClaimsPrincipal MapUserInfo(string scheme, string jsonResult, int minutesCache)
    {
        var jsonDocument = JsonDocument.Parse(jsonResult);
        
        List<Claim> claims = new()
        {
            new Claim(JwtClaimTypes.Locale, "es-ES"),
            new Claim(JwtClaimTypes.Expiration, 
                new DateTimeOffset(DateTime.UtcNow.AddMinutes(minutesCache), TimeSpan.Zero)
                    .ToUnixTimeSeconds().ToString())
        };
        
        // Mapear claims desde UserInfo
        AddClaimIfExists(claims, jsonDocument, JwtClaimTypes.Subject);
        AddClaimIfExists(claims, jsonDocument, "user_id");
        AddClaimIfExists(claims, jsonDocument, "organization");
        AddClaimIfExists(claims, jsonDocument, JwtClaimTypes.Name);
        AddClaimIfExists(claims, jsonDocument, "organizationapvcode");
        AddClaimIfExists(claims, jsonDocument, JwtClaimTypes.PreferredUserName);
        AddClaimIfExists(claims, jsonDocument, "organizationcif");
        
        // Procesar roles desde "groups"
        var claimGroups = GetStringProperty(jsonDocument, "groups");
        if (claimGroups != null)
        {
            var roles = claimGroups.Split(',')
                .Select(r => r.Split('/').Last().Split('\\').Last())
                .ToList();
            claims.Add(new Claim("groups", string.Join(",", roles)));
        }
        
        IIdentity identity = new ClaimsIdentity(claims, scheme);
        return new ClaimsPrincipal(identity);
    }
}
```

**Estructura de UserInfo APV:**
```json
{
  "sub": "user@domain.com",
  "user_id": "12345",
  "name": "John Doe",
  "preferred_username": "johndoe",
  "organization": "My Organization",
  "organizationcif": "B12345678",
  "organizationapvcode": "ORG001",
  "groups": "domain/admin,domain/users,domain/WORKER_READ"
}
```

#### Configuración en appsettings.json

**Para JWT (KeyCloak):**
```json
{
  "Authentication": {
    "Schemes": [
      {
        "AuthenticationScheme": "KeyCloak",
        "Authority": "https://keycloak.example.com/realms/myrealm",
        "Audience": "angularclient",
        "RequireHttpsMetadata": true,
        "SaveToken": true,
        "ValidateAudience": true,
        "ValidateIssuer": true,
        "ValidateLifetime": true
      }
    ]
  }
}
```

**Para Reference Token (APV):**
```json
{
  "Authentication": {
    "ReferenceTokenSchemes": [
      {
        "AuthenticationScheme": "APV",
        "IntrospectionEndpoint": "https://apv.example.com/oauth2/introspect",
        "UserInfoEndpoint": "https://apv.example.com/oauth2/userinfo",
        "IntrospectionUser": "client_id",
        "IntrospectionPassword": "client_secret",
        "AllowedClientIds": "web-client,mobile-client",
        "MinutesCache": 5,
        "DisableHttpsCertificate": false
      }
    ]
  }
}
```

#### Registro en DependencyInjection

En `Program.cs` o `AuthConfiguration.cs`:

```csharp
// Registrar el mapeo de claims apropiado según el proveedor
if (appSettings.Authentication.Provider == "KeyCloak")
{
    builder.Services.AddSingleton<IUserClaimsMapping, KeyCloakUserClaimsMapping>();
}
else if (appSettings.Authentication.Provider == "APV")
{
    builder.Services.AddSingleton<IUserClaimsMapping, APVClaimsMapping>();
    builder.Services.AddSingleton<IReferenceTokenValidation, APVReferenceTokenValidation>();
}
```

#### Ventajas del Sistema de Mapeo

1. **Abstracción:** El resto de la aplicación usa `IUserContext` sin conocer el proveedor de identidad.
2. **Extensibilidad:** Añadir soporte para nuevos proveedores solo requiere implementar las interfaces.
3. **Mantenibilidad:** Cambios en la estructura de claims se aíslan en una clase.
4. **Testabilidad:** Fácil crear mocks para pruebas unitarias.
5. **Multi-tenancy:** Soporta múltiples esquemas de autenticación simultáneamente.

---

## 11. Sistema de Auditoría

### 11.1 Campos de Auditoría Estándar
Todas las entidades incluyen campos administrados automáticamente:
*   `AuditCreationUser` / `AuditCreationDate`
*   `AuditModificationUser` / `AuditModificationDate`
*   `AuditDeletionDate` (para soft delete)
*   `AuditVersionKey` (cuando aplica a entidades versionadas)

### 11.2 Actualización Automática de Auditoría
Los repositorios base capturan el `IUserContext` y actualizan los campos al insertar/modificar/eliminar. `BaseService` propaga los valores usando `appCtx.GetCurrentUserId()` durante `Insert`/`Update`/`Delete`.

### 11.3 Auditoría en Transacciones
Las operaciones masivas (`InsertMany`, `UpdateMany`, `DeleteByIds`) envuelven múltiples escrituras dentro de una transacción EF Core para asegurar consistencia y se registra el mismo usuario para todos los registros afectados.

---

## 12. Sistema de Archivos Adjuntos (Attachments)

### 12.1 Implementaciones de `IAttachmentSource`
*   **AttachmentDBSource**: guarda binarios en tablas de base de datos `Attachment`. Controla metadatos y versiones.
*   **AttachmentDriveSource**: almacena archivos en disco (configurable vía `AttachmentDriveSource`). Usa subcarpetas por entidad y guarda la ruta física en BD.

### 12.2 Funcionalidad Expuesta
Los endpoints generados (`GetAllAttachments`, `GetNewAttachmentEntity`, `UploadAttachment`, `DownloadAttachment`) permiten:
*   Listar adjuntos disponibles y descargar binarios.
*   Asignar archivos a entidades usando `AttachmentReferenceId`.
*   Controlar permisos (solo `SecurityLevel.Modify` permite subir/eliminar).

### 12.3 Configuración
```json
"AttachmentDriveSource": {
  "Folder": "C:\\HelixAttachments",
  "UseSubFolders": true,
  "MaxFileSizeMB": 30
}
```
Se pueden reemplazar o extender implementando `IAttachmentSource<TAttachment>` y registrándolo en `DependencyInjection.cs`.

---

## 13. Sistema de Versionado y Vigencia

### 13.1 Entidades con Versionado (`IsVersionEntity`)
*   Heredan de `BaseVersionRepository<TEntity>` y `BaseVersionService<TView,...>`.
*   Mantienen `VersionKey`, `VersionNumber`, `IsActiveVersion`.
*   Soportan operaciones como `GetVersionHistory` y `SwitchActiveVersion`.
*   Hook `PreviousActions` asegura que nuevas versiones no invaliden referencias.

### 13.2 Entidades con Vigencia (`IsValidityEntity`)
*   Utilizan `BaseValidityRepository`/`Service` para aplicar rangos de fechas (`StartDate`, `EndDate`).
*   Los filtros automáticos usan `HelixFilterMapping` para incluir solo registros vigentes.
*   Endpoints soportan parámetros `validFrom`/`validTo` para consultar un snapshot temporal.

---

## 14. Internacionalización (i18n)

### 14.1 Configuración de Culturas
*   Soporta `es-ES`, `en-GB` por defecto pero es configurable en `LocalizationOptions`.
*   `RequestLocalizationMiddleware` en Program.cs detecta el header `Accept-Language` y ajusta `CultureInfo`.

### 14.2 Recursos
*   Archivos `.resx` bajo `Resources/` (`SharedResource.es-ES.resx`, `SharedResource.en-GB.resx`).
*   `ISharedResource` inyectable para acceder a textos localizados.
*   Validaciones y mensajes de error capturados en `HelixValidationProblem` usan recursos.

### 14.3 Swagger Multilenguaje
Swagger UI usa `ApplyRequestLocalization` para mostrar títulos/traducciones según el idioma seleccionado y se documentan múltiples idiomas con `SwaggerSettings.Culture<...>`.

---

## 15. Integración con Frontend (Kendo UI)

### 15.1 Endpoint `GetAllKendoFilter`
*   Diseñado para interoperar con `DataSourceRequest` de Kendo.
*   Recibe JSON con `Filters`, `Sort`, `Page`, `PageSize` y retorna `FilterResult<TView>` con `TotalCount` y `Items`.
*   Usa `HelixFilterMapping` para convertir filtros a expresiones LINQ.

### 15.2 `IGenericFilter` y `HelixFilterMapping`
*   `IGenericFilter` describe criterios estándar (campo, operador, valor).
*   `HelixFilterMapping` traduce esos criterios para EF Core y Dapper, soportando propiedades anidadas y colecciones.

---

## 16. Logging con Serilog

### 16.1 Configuración
```json
"Serilog": {
  "Using": ["Serilog.Sinks.Console", "Serilog.Sinks.File"],
  "MinimumLevel": {
    "Default": "Information",
    "Override": {
      "Microsoft": "Warning",
      "System": "Warning"
    }
  },
  "WriteTo": [
    { "Name": "Console" },
    {
      "Name": "File",
      "Args": { "path": "logs/helix6-.log", "rollingInterval": "Day" }
    }
  ]
}
```
`Program.cs` llama a `UseSerilog()` antes de construir la app y `UseSerilogRequestLogging()` para capturar peticiones.

### 16.2 Telemetría
*   Se registran contextos de `HelixTraceId` en `LogContext`.
*   Errores críticos se envían a Sentry/OpenTelemetry via sinks personalizados si se configura.

---

## 17. Testing

### 17.1 Tests de Servicios
*   Implementados con xUnit.
*   Fixtures (`TestInitialization`, `ServiceFixture`) preparan `IServiceProvider` y BD en memoria.
*   Mocks de repositorios (Moq) validan hooks `PreviousActions`, `ValidateView`, `PostActions`.

### 17.2 Tests de Repositorios
*   Ejecutan queries reales contra base de datos local o contenedor.
*   `HelixEntities.xml` se sincroniza antes de correr tests para asegurarse de que los endpoints generados reflejen los cambios.

---

## 18. Despliegue y Containerización

### 18.1 Dockerfile
*   Multi-stage build: .NET SDK para compilar y Runtime para publicar.
*   Expone el puerto configurado en `appsettings` y copia `logs/` y `wwwroot/`.

### 18.2 Azure Pipelines
*   `azure-pipelines.yml`: Build > Test > Publish artefactos.
*   `publish-template.yml`: Plantilla reutilizable configurada con parámetros (`HelixEntitiesFile`, `Environment`).
*   Variables definidas para `HELIX6_DBMS_TYPE`, `HELIX6_ENVIRONMENT` y `HELIX6_LOG_LEVEL`.

---

## 19. Patrones y Mejores Prácticas

### 19.1 Patrones Aplicados
*   **Repository Pattern**: `BaseRepository`, `IBaseRepository`.
*   **Service Layer Pattern**: `BaseService` y servicios específicos.
*   **Unit of Work**: `DbContext` y `BaseEFRepository`.
*   **Dependency Injection**: Autoregistro en `DependencyInjection.AddServicesRepositories`.
*   **DTO Pattern**: Entities/Views segregan modelo y comunicación.
*   **Partial Classes**: Para extender código generado.

### 19.2 Convenciones de Código
*   PascalCase para clases, métodos y propiedades.
*   camelCase para parámetros.
*   Interfaces prefijadas con `I`.
*   Clases generadas en `[Entidad]View`, `[Entidad]ViewMetadata`.
*   Nullable Reference Types activadas.

### 19.3 Organización del Repositorio
*   Un archivo por clase.
*   Carpetas agrupadas (`Services`, `Repository`, `Endpoints`).
*   Código generado vs personalizado claramente separado (`Views/Generated`, `Views/Custom`).

---

## 20. Extensibilidad y Personalización

### 20.1 Services
*   Hooks virtuales: `PreviousActions`, `ValidateView`, `PostActions`, `MapEntityToView`, `MapViewToEntity`, `GetNewEntity`.
*   Permiten modificar validaciones o inicializar datos antes/después de persistencia.

### 20.2 Repositorios
*   Métodos adicionales para consultas (ej: `GetByWorkerCode`).
*   Uso de `ExecuteQuery`/`ExecuteNonQuery` de `BaseRepository` para SQL raw.

### 20.3 Endpoints Personalizados
*   Archivo `Endpoints.cs` contiene `MapCustomEndpoints`.
*   Coexisten con endpoints generados, permitiendo lógica compuesta o BFFs.

### 20.4 Middleware
*   Se pueden insertar middlewares antes/ después de Helix (`UseMiddleware<HelixExceptionsMiddleware>` ya en pipeline).
*   `ProblemDetails` se configura como middleware para estandarizar errores.

---

## 21. Lista Completa de Métodos del Framework Base

### 21.1 `BaseService<TView, TEntity, TMetadata>`
```csharp
Task<TView?> GetById(int id, string? configurationName = null);
Task<List<TView>> GetByIds(List<int> ids, string? configurationName = null);
Task<TView?> GetNewEntity();
Task<TView?> Insert(TView view, string? configurationName = null);
Task<List<TView>> InsertMany(List<TView> views, string? configurationName = null);
Task<TView?> Update(TView view, string? configurationName = null);
Task<List<TView>> UpdateMany(List<TView> views, string? configurationName = null);
Task<bool> DeleteById(int id, string? configurationName = null);
Task<bool> DeleteByIds(List<int> ids, string? configurationName = null);
Task<bool> DeleteUndeleteLogicById(int id, bool delete, string? configurationName = null);
Task<bool> DeleteUndeleteLogicByIds(List<int> ids, bool delete, string? configurationName = null);
Task<List<TView>> GetAll(string? configurationName = null);
Task<FilterResult<TView>> GetAllKendoFilter(IGenericFilter filter, string? configurationName = null);

virtual Task ValidateView(HelixValidationProblem validations, TView? view, EnumActionType actionType, string? configurationName = null);
virtual Task PreviousActions(TView? view, EnumActionType actionType, string? configurationName = null);
virtual Task PostActions(TView? view, EnumActionType actionType, string? configurationName = null);
virtual Task<TView?> MapEntityToView(TEntity? entity, string? configurationName = null, TView? view = null);
virtual Task<TEntity?> MapViewToEntity(TView? view, string? configurationName = null, TEntity? entity = null);
```

### 21.2 `BaseRepository<TEntity>`
```csharp
Task<TEntity?> GetById(int id, string? configurationName = null);
Task<List<TEntity>> GetByIds(List<int> ids, string? configurationName = null);
Task<TEntity?> Insert(TEntity entity);
Task<List<TEntity>> InsertMany(List<TEntity> entities);
Task<TEntity?> Update(TEntity entity);
Task<List<TEntity>> UpdateMany(List<TEntity> entities);
Task<bool> DeleteById(int id);
Task<bool> DeleteByIds(List<int> ids);
Task<bool> DeleteUndeleteLogicById(int id, bool delete);
Task<bool> DeleteUndeleteLogicByIds(List<int> ids, bool delete);
Task<List<TEntity>> GetAll(string? configurationName = null);
Task<FilterResult<TEntity>> GetAllFilter(IGenericFilter filter, string? configurationName = null);

Task<List<TEntity>> ExecuteQuery(string sql, object? parameters = null);
Task<int> ExecuteNonQuery(string sql, object? parameters = null);
```

---

## 22. Diagramas y Flujos (Descripción Textual)

### 22.1 Diagrama de Capas
```
┌─────────────────────────────────────────┐
│     [Proyecto].Api (Web API)            │  ← Endpoints HTTP
├─────────────────────────────────────────┤
│     [Proyecto].Entities (Views/DTOs)    │  ← Transferencia de datos
├─────────────────────────────────────────┤
│     [Proyecto].Services (Lógica)        │  ← Validaciones, reglas de negocio
├─────────────────────────────────────────┤
│     [Proyecto].Data (Repositorios)      │  ← Acceso a datos
├─────────────────────────────────────────┤
│   [Proyecto].DataModel (Entidades DB)   │  ← Modelo de datos
├─────────────────────────────────────────┤
│        Base de Datos (DBMS)             │  ← Persistencia
└─────────────────────────────────────────┘

Dependencias laterales:
- Helix6.Base (infraestructura)
- Helix6.Base.Domain (domain común)
- Helix6.Base.Utils (utilidades)
```

### 22.2 Flujo de Operación CRUD
```
Cliente HTTP
    ↓
Endpoint (MapXxxEndpoint)
    ↓
AuthN/AuthZ Middleware
    ↓
Service.Insert/Update/Delete/Get
    ↓
ValidateView (validaciones)
    ↓
PreviousActions (hooks previos)
    ↓
Repository.Insert/Update/Delete/Get
    ↓
BaseEFRepository / BaseDapperRepository
    ↓
DbContext (EF) / IDbConnection (Dapper)
    ↓
Base de Datos
    ↓
Repository devuelve Entity
    ↓
Service.PostActions (hooks posteriores)
    ↓
Service.MapEntityToView (mapeo)
    ↓
Service devuelve View
    ↓
Endpoint serializa respuesta
    ↓
Cliente recibe JSON
```

---

## 23. Escenarios de Uso y Ejemplos

### 23.1 Crear una Nueva Entidad
1.  Crear la clase en `DataModel/` implementando `IEntityBase` y agregando las propiedades de auditoría.
2.  Añadir `DbSet<Entidad>` en `EntityModel.cs`.
3.  Crear migración EF Core.
4.  Registrar la entidad en `HelixEntities.xml` y definir los endpoints y campos que se requieren.
5.  Ejecutar Helix Generator para regenerar `Views`, `ViewMetadata` y `Endpoints`.
6.  Crear `IEntidadRepository` e implementación en `Data/Repository/` heredando de `BaseRepository`.
7.  Crear `EntidadService` en `Services/` heredando de `BaseService`.
8.  Opcional: personalizar metadatos en `Views/Metadata`.
9.  Opcional: extender los endpoints en `Endpoints/Endpoints.cs`.

### 23.2 Agregar Validación Personalizada
```csharp
public override async Task ValidateView(HelixValidationProblem validations, WorkerView? view, EnumActionType actionType, string? configurationName = null)
{
    if (view != null && view.Name.Length < 3)
    {
        validations.Add("Name", "El nombre debe tener al menos 3 caracteres");
    }
    await base.ValidateView(validations, view, actionType, configurationName);
}
```

### 23.3 Agregar Lógica Pre/Post Acción
```csharp
public override async Task PreviousActions(WorkerView? view, EnumActionType actionType, string? configurationName = null)
{
    if (view != null && actionType == EnumActionType.Insert)
    {
        view.CreatedOn = DateTime.UtcNow;
    }
    await base.PreviousActions(view, actionType, configurationName);
}
```

### 23.4 Personalizar Mapeos
```csharp
public override async Task<WorkerView?> MapEntityToView(Worker? entity, string? configurationName = null, WorkerView? view = null)
{
    var workerView = await base.MapEntityToView(entity, configurationName, view);
    if (workerView != null)
    {
        workerView.FullName = $"{workerView.Name} {workerView.LastName}";
    }
    return workerView;
}
```

---

## 24. Glosario de Términos
*   **Entity**: Clase en `DataModel` mapeada a la base de datos.
*   **View**: DTO en `Entities` usado por los endpoints.
*   **Metadata**: Clases adicionales que agregan validaciones o atributos.
*   **Service**: Capa que contiene la lógica de negocio.
*   **Repository**: Capa de acceso a datos.
*   **Endpoint**: Método HTTP expuesto al cliente.
*   **HelixEntities.xml**: Archivo maestro para el generador de código.
*   **EndpointHelper**: Auxiliar que construye endpoints genéricos.
*   **UserContext**: Contexto del usuario actual.
*   **ApplicationContext**: Contexto de configuración global.
*   **BaseEFRepository**: Implementación de EF Core.
*   **BaseDapperRepository**: Implementación optimizada con Dapper.
*   **Soft Delete**: Eliminación lógica usando `AuditDeletionDate`.
*   **Version Entity**: Entidad con control de versiones.
*   **Validity Entity**: Entidad con vigencia temporal.
*   **Kendo Filter**: Filtros compatibles con Telerik Kendo UI.

