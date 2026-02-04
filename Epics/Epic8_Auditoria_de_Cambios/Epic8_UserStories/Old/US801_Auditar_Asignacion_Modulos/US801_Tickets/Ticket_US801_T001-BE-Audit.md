```markdown
# TASK-US801-BE-AUDIT: Persistir AuditLog en cambios de MODULE_ACCESS

=============================================================
**TICKET ID:** TASK-US801-BE-AUDIT  
**EPIC:** Auditoría de Cambios Críticos  
**USER STORY:** US-801 - Auditar asignación/remoción de módulos a una organización  
**COMPONENT:** Backend - Service Integration  
**PRIORITY:** Alta  
**ESTIMATION:** 4 horas  
=============================================================

## TÍTULO
Instrumentar `OrganizationModuleService` para registrar `ModuleAssigned`/`ModuleRemoved` en `AUDIT_LOG`.

## DESCRIPCIÓN
Al modificar `MODULE_ACCESS`, llamar a `IAuditLogService.LogAsync(AuditEntry)` con Action apropiada, UserId (nullable solo para sistema) y CorrelationId.

## CRITERIOS TÉCNICOS
- `IAuditLogService` invocado en `AssignModule` con Action="ModuleAssigned" y datos correctos.
- `IAuditLogService` invocado en `RemoveModule` con Action="ModuleRemoved".
- Tests unitarios verifican llamadas y contenido del `AuditEntry`.
- Tests de integración verifican persistencia en `AUDIT_LOG`.

```
