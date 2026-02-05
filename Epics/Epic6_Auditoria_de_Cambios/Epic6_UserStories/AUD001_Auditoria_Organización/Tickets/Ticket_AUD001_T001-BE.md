```markdown
# AUD001-T001-BE: Backend — Implementar auditoría para Organización

**TICKET ID:** AUD001-T001-BE
**EPIC:** Auditoría de Cambios Críticos
**COMPONENT:** Backend - Services / Database
**PRIORITY:** Alta
**ESTIMATION:** 6 horas

## Resumen
Instrumentar los puntos de mantenimiento de `Organization` y `OrganizationModule` para generar entradas en `AUDIT_LOG` por las acciones críticas listadas en la historia `AUD001`.

## Requisitos técnicos
- Invocar `IAuditLogService.LogAsync(AuditEntry)` en: AssignModule, RemoveModule, DeactivateOrganization (manual y automática), ReactivateOrganization, ChangeGroup.
- `AuditEntry` debe incluir: `Action`, `EntityType`="Organization", `EntityId`, `UserId` (nullable), `CorrelationId` (si aplica), `Timestamp`, `Details` (string breve).
- No incluir datos sensibles en `Details`.

## Tests
- Unit tests que mockeen `IAuditLogService` y verifiquen llamadas y payloads.
- Integration test que verifique inserción en `AUDIT_LOG`.

## Criterios de Aceptación
- [ ] Hooks instrumentados y `IAuditLogService` llamado con payload correcto por cada acción.
- [ ] Tests unitarios e integración añadidos.

```
