```markdown
# TASK-US801-BE-AUDIT: Implementar auditoría para mantenimiento de organizaciones

=============================================================
**TICKET ID:** TASK-US801-BE-AUDIT  
**EPIC:** Auditoría de Cambios Críticos  
**USER STORY:** US-801 - Auditar cambios críticos en la Organización  
**COMPONENT:** Backend - Services / Database  
**PRIORITY:** Alta  
**ESTIMATION:** 6 horas  
=============================================================

## TÍTULO
Instrumentar los puntos de mantenimiento de `Organization` para generar entradas `AUDIT_LOG` por las 6 acciones críticas.

## DESCRIPCIÓN
Al ejecutar operaciones críticas sobre una organización (asignación/remoción de módulos, baja/alta manual o automática, cambio de grupo) el backend deberá llamar a `IAuditLogService.LogAsync(AuditEntry)` con los campos mínimos requeridos.

## CRITERIOS TÉCNICOS
- `IAuditLogService.LogAsync` invocado en: AssignModule, RemoveModule, OrganizationDeactivate (manual y automática), OrganizationReactivate, ChangeGroup.
- `AuditEntry.Action` usa exactamente: `ModuleAssigned`, `ModuleRemoved`, `OrganizationDeactivatedManual`, `OrganizationAutoDeactivated`, `OrganizationReactivatedManual`, `GroupChanged`.
- `AuditEntry.EntityType`="Organization" y `EntityId` = id de organización.
- Tests unitarios que mockean `IAuditLogService` y verifican llamadas y payloads.
- Tests de integración que verifican inserción en `AUDIT_LOG`.

## IMPLEMENTACIÓN / NOTAS
- Añadir las llamadas al servicio de auditoría en `OrganizationModuleService`, `OrganizationService` y donde proceda.
- Usar el `CorrelationId` del request si está presente, o generar uno nuevo para la operación.
- No bloquear la operación principal por fallos de logging: manejar errores con retry y fallback (log a fichero y alerta si persiste).

```
