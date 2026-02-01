=============================================================
**TICKET ID:** TASK-018-BE  
**EPIC:** Configuración de Módulos y Permisos de Acceso  
**USER STORY:** US-018 - Configurar acceso masivo de módulos  
**COMPONENT:** Backend  
**PRIORITY:** Media  
**ESTIMATION:** 4 horas  
=============================================================

**TÍTULO:**
Implementar endpoint de asignación masiva de módulos a múltiples organizaciones

**DESCRIPCIÓN:**
Crear endpoint `POST /api/module-access/bulk-assign` que permita asignar un conjunto de módulos a múltiples organizaciones en una sola transacción atómica. Publicar `OrganizationEvent` para cada organización afectada.

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] DTO `BulkModuleAssignRequest` creado
- [ ] Endpoint POST `/api/module-access/bulk-assign` implementado
- [ ] Transacción atómica implementada
- [ ] Validaciones de existencia de organizaciones y módulos
- [ ] No crear duplicados
- [ ] Publicar `OrganizationEvent` para cada organización
- [ ] Tests de integración

**ARCHIVOS A CREAR/MODIFICAR:**
- `InfoportOneAdmon.Entities/DTOs/BulkModuleAssignRequest.cs`
- `InfoportOneAdmon.Services/Services/ModuleAccessService.cs` (método `BulkAssignAsync`)
- `InfoportOneAdmon.Api/Endpoints/ModuleAccessEndpoints.cs`
- Tests
