```markdown
#### AUD003: Auditoría — Usuario

**Épica:** Auditoría de Cambios Críticos
**Rol:** Admin / IdentityManager
**Prioridad:** Alta | **Estimación:** 3 Story Points

**Historia:**
```
Como Admin o IdentityManager,
quiero que los cambios críticos en usuarios sean auditados y, cuando proceda, se sincronice con Keycloak,
para garantizar trazabilidad y consistencia entre la plataforma y el proveedor de identidad.
```

## Acciones que desencadenan la auditoría y/o sincronización
- `RoleAssigned` / `RoleRemoved`
- `UserDeactivated` / `UserActivated`
- `UserUpdated` (cambios en email, username)
- `UserPasswordResetRequested` (registrar solicitud, no la contraseña)

## Publisher / Quién publica
- `UserService`, `RoleService` y adaptadores de Keycloak deben invocar `IAuditLogService` y `IKeycloakAdapter` cuando proceda.

## Subscribers / Procesamiento
- Auditoría: persistir en `AUDIT_LOG` con `EntityType`="User" y metadatos.
- Sincronización: cuando la acción afecta Keycloak, `IKeycloakAdapter` realiza operación idempotente y se registra la `CorrelationId` compartida.

## Criterios de Aceptación
- [ ] Entradas en `AUDIT_LOG` por cada acción listada.
- [ ] Sincronización a Keycloak invocada para las acciones que lo requieran y `CorrelationId` registrado.
- [ ] Tests unitarios e integración añadidos.

```
