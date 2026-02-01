=============================================================
**TICKET ID:** TASK-016-BE  
**EPIC:** Configuración de Módulos y Permisos de Acceso  
**USER STORY:** US-016 - Definir módulos funcionales de una aplicación  
**COMPONENT:** Backend  
**PRIORITY:** Alta  
**ESTIMATION:** 5 horas  
=============================================================

**TÍTULO:**
Implementar entidad `Module` con validación de nomenclatura `M{RolePrefix}_<Nombre>`

**DESCRIPCIÓN:**
Crear la entidad `Module` que representa módulos funcionales de una aplicación. La nomenclatura debe seguir el patrón `M{RolePrefix}_{NombreDescriptivo}` (ej: `MCRM_Facturacion`). Implementar validaciones, índice único compuesto `(ApplicationId, ModuleName)` y regla de negocio para no eliminar el último módulo activo.

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] Entidad `Module` con campos: `ModuleName`, `Description`, `DisplayOrder`, `ApplicationId`
- [ ] Validación de nomenclatura en `ValidateView` (regex `^M{RolePrefix}_[A-Za-z0-9_]+$`)
- [ ] Índice único compuesto `(ApplicationId, ModuleName)`
- [ ] No permitir eliminar último módulo activo de una aplicación
- [ ] Endpoints CRUD automáticos generados por Helix6
- [ ] Tests unitarios e integración

**ARCHIVOS A CREAR/MODIFICAR:**
- `InfoportOneAdmon.DataModel/Entities/Module.cs`
- `InfoportOneAdmon.DataModel/Entities/Application.cs` (añadir relación `Modules`)
- `InfoportOneAdmon.DataModel/InfoportOneAdmonContext.cs` (índice único)
- `InfoportOneAdmon.Entities/Views/ModuleView.cs`
- `InfoportOneAdmon.Services/Services/ModuleService.cs`
- Tests y migración EF Core
