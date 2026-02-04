# TASK-001-BE-EXT: Implementar OrganizationModuleService con auto-baja

=============================================================
**TICKET ID:** TASK-001-BE-EXT  
**EPIC:** Gestión del Portfolio de Organizaciones Clientes  
**USER STORY:** US-009 - Asignar módulos/aplicaciones a organización  
**COMPONENT:** Backend - Service Extension  
**PRIORITY:** Alta  
**ESTIMATION:** 5 horas  
=============================================================

## TÍTULO
Implementar OrganizationModuleService para gestionar asignación de módulos con auto-baja y eventos diferidos

## DESCRIPCIÓN
Crear servicio especializado para gestionar la relación entre organizaciones y módulos/aplicaciones. Este servicio es **CRÍTICO** en la arquitectura de eventos diferidos porque:

1. **Publica el PRIMER OrganizationEvent** cuando se asignan módulos a una organización nueva (US-009)
2. **Implementa la lógica de auto-baja** cuando ModuleCount llega a 0 (US-010)
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

(Contenido del servicio y guías similares al ticket original, ajustado a US-009.)
