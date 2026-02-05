```markdown
# AUD002-T001-BE: Backend — Implementar auditoría para Application

**TICKET ID:** AUD002-T001-BE
**EPIC:** Auditoría de Cambios Críticos
**COMPONENT:** Backend - Services / Database
**PRIORITY:** Media
**ESTIMATION:** 6 horas

## Resumen
Instrumentar los puntos críticos de `Application`, `ApplicationModule`, `ApplicationRole` y `ApplicationSecurity` para generar entradas de auditoría en `AUDIT_LOG` según las acciones definidas en la historia `AUD002`.

## Requisitos técnicos
- Llamadas a `IAuditLogService.LogAsync` en: UpdateApplicationConfig, ChangeModules, Deactivate/Reactivate Application, Assign/Remove Role, Add/Remove Credential (guardar sólo referencia/alias).
- `AuditEntry` con `Action`, `EntityType`="Application", `EntityId`, `UserId` nullable, `CorrelationId`, `Details`.

## Tests
- Tests unitarios que mockeen `IAuditLogService`.
- Integration tests que verifiquen inserción en `AUDIT_LOG`.

## Criterios de Aceptación
- [ ] Hooks instrumentados y llamadas verificadas.
- [ ] No se almacenan secretos.

```
