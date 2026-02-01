=============================================================
**TICKET ID:** TASK-016-EV-PUB  
**EPIC:** Configuración de Módulos y Permisos de Acceso  
**USER STORY:** US-016 - Definir módulos funcionales de una aplicación  
**COMPONENT:** Backend - Event Publishing  
**PRIORITY:** Alta  
**ESTIMATION:** 2 horas  
=============================================================

**TÍTULO:**
Actualizar `ApplicationEvent` para incluir la lista completa de módulos activos

**DESCRIPCIÓN:**
Modificar `PublishApplicationEventAsync` en `ApplicationService` para incluir `Modules: ModuleInfo[]` con los módulos activos de la aplicación. Asegurar que los PostActions en `ModuleService` republican el evento al crear/editar/eliminar módulos.

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] `ApplicationEvent.Modules` incluye solo módulos activos (`AuditDeletionDate == null`)
- [ ] PostActions en `ModuleService` republica `ApplicationEvent`
- [ ] Tests verifican que módulos eliminados no se incluyen

**ARCHIVOS A MODIFICAR:**
- `InfoportOneAdmon.Entities/Events/ApplicationEvent.cs`
- `InfoportOneAdmon.Services/Services/ApplicationService.cs`
- `InfoportOneAdmon.Services/Services/ModuleService.cs`
- Tests
