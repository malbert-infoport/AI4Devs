=============================================================
**TICKET ID:** TASK-017-BE  
**EPIC:** Configuración de Módulos y Permisos de Acceso  
**USER STORY:** US-017 - Asignar módulos de una aplicación a una organización  
**COMPONENT:** Backend  
**PRIORITY:** Alta  
**ESTIMATION:** 5 horas  
=============================================================

**TÍTULO:**
Implementar entidad `ModuleAccess` (N:M) con publicación de `OrganizationEvent`

**DESCRIPCIÓN:**
Crear la tabla `MODULE_ACCESS` que conecta `Organization` con `Module` (N:M) usando soft delete. Al otorgar/revocar acceso se debe republicar `OrganizationEvent` con `Apps[].AccessibleModules` actualizado.

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] Entidad `ModuleAccess` con `OrganizationId`, `ModuleId`, soft delete
- [ ] Validaciones: organización y módulo existen y están activos
- [ ] Índice único compuesto `(OrganizationId, ModuleId, AuditDeletionDate)`
- [ ] PostActions: republicar `OrganizationEvent` con módulos accesibles
- [ ] Tests verifican publicación correcta

**ARCHIVOS A CREAR/MODIFICAR:**
- `InfoportOneAdmon.DataModel/Entities/ModuleAccess.cs`
- `InfoportOneAdmon.DataModel/Entities/Organization.cs` (añadir relación `ModuleAccesses`)
- `InfoportOneAdmon.DataModel/InfoportOneAdmonContext.cs` (índice)
- `InfoportOneAdmon.Entities/Views/ModuleAccessView.cs`
- `InfoportOneAdmon.Services/Services/ModuleAccessService.cs`
- `InfoportOneAdmon.Entities/Events/OrganizationEvent.cs` (añadir Apps/AppAccessInfo)
- Tests y migración
