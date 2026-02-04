```markdown
# TASK-US803-BE-AUDIT: Auditar cambios de usuario y orquestar sincronización con Keycloak

=============================================================
**TICKET ID:** TASK-US803-BE-AUDIT  
**EPIC:** Auditoría de Cambios Críticos  
**USER STORY:** US-803 - Auditar y sincronizar cambios críticos en Usuarios (Keycloak)  
**COMPONENT:** Backend - Identity Integration  
**PRIORITY:** Alta  
**ESTIMATION:** 6 horas  
=============================================================

## TÍTULO
Añadir auditoría y orquestación de sincronización con Keycloak para cambios críticos en usuarios y roles.

## DESCRIPCIÓN
Instrumentar `UserService` y `RoleService` para:
- crear entradas en `AUDIT_LOG` (actions: `RoleAssigned`, `RoleRemoved`, `UserDeactivated`, `UserActivated`, `UserUpdated`),
- y orquestar llamadas al adaptador Keycloak (`IKeycloakAdapter`) cuando la operación requiera sincronización.

## CRITERIOS TÉCNICOS
- `IAuditLogService.LogAsync` invocado con `EntityType`="User" y `Action` adecuado.
- `IKeycloakAdapter` invocado en los casos que requieren sincronización; usar `CorrelationId` compartido.
- Implementar idempotencia y retries para la integración con Keycloak; en fallo persistente, encolar evento para reintento.
- Tests unitarios que mockeen `IKeycloakAdapter` y `IAuditLogService`.
- Tests de integración / contract tests si hay entorno Keycloak de pruebas.

## IMPLEMENTACIÓN / NOTAS
- Reutilizar adaptadores existentes cuando sea posible; si no existen, crear `IKeycloakAdapter` con métodos: `SyncUserRolesAsync`, `UpdateUserAsync`, `SetUserActiveStateAsync`.
- Registrar métricas y alarms para fallos de sincronización.

```
