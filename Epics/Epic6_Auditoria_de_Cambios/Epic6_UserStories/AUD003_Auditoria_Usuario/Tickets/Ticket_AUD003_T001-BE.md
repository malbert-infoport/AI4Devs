```markdown
# AUD003-T001-BE: Backend — Implementar auditoría y sincronización para Usuario

**TICKET ID:** AUD003-T001-BE
**EPIC:** Auditoría de Cambios Críticos
**COMPONENT:** Backend - Services / Identity Adapter
**PRIORITY:** Alta
**ESTIMATION:** 1 día

## Resumen
Instrumentar `UserService` y `RoleService` para generar `AUDIT_LOG` y, cuando proceda, llamar a `IKeycloakAdapter` para sincronizar cambios críticos con Keycloak. Registrar `CorrelationId` para trazar ambas operaciones.

## Requisitos técnicos
- Llamar `IAuditLogService.LogAsync` con `Action` adecuado en RoleAssigned/RoleRemoved, UserDeactivated/UserActivated, UserUpdated.
- Para acciones que requieren sincronización con Keycloak: invocar `IKeycloakAdapter` de forma idempotente y registrar `CorrelationId` en `AUDIT_LOG`.
- Manejar retries/backoff o encolado si Keycloak no responde.

## Tests
- Unit tests que mockeen `IAuditLogService` y `IKeycloakAdapter`.
- Integration test con Keycloak mock o testcontainer.

## Criterios de Aceptación
- [ ] Auditoría creada y `IKeycloakAdapter` invocado cuando aplica.
- [ ] CorrelationId presente en ambos registros para facilitar trazabilidad.

```
