````markdown
#### US-803: Auditar y sincronizar cambios críticos en Usuarios (Keycloak)

**Épica:** Auditoría de Cambios Críticos
**Rol:** Admin / IdentityManager
**Prioridad:** Alta | **Estimación:** 3 Story Points

**Historia:**
```
Como Admin o IdentityManager,
quiero que los cambios críticos en usuarios que implican sincronización con Keycloak (roles, estado, identificadores) sean auditados y sincronicen correctamente,
para garantizar consistencia entre la plataforma y el proveedor de identidad.
```

**Contexto adicional:**

Acciones a auditar y/o que disparan sincronización Keycloak:
- `RoleAssigned` / `RoleRemoved` (asignación/quitar roles)
- `UserDeactivated` / `UserActivated` (estado de usuario)
- `UserUpdated` (cambios en identificadores necesarios para Keycloak: username, email)

**Criterios de aceptación:**

- Para cada acción se crea una entrada en `AUDIT_LOG` con `Action` correspondiente y `EntityType`="User".
- Cuando la acción requiere sincronización con Keycloak, se invoca el adaptador de Keycloak para aplicar el cambio y se registra `CorrelationId` para trazar ambos lados.
- `UserId` poblado con el actor que inició el cambio.
- Tests unitarios que mockeen Keycloak adapter y `IAuditLogService`.
- Tests de integración (si procede) que validen el flujo completo (servicio -> Keycloak mock / entorno de pruebas).

**Requisitos no funcionales:**

- No incluir contraseñas ni datos sensibles en `AUDIT_LOG`.
- Sincronización con Keycloak debe ser idempotente y tolerante a errores (retries, colas si necesario).

**Definición de hecho (DoD):**

- Instrumentación en `UserService`/`RoleService` para llamar a `IAuditLogService` y a `IKeycloakAdapter` cuando proceda.
- Tests unitarios e integración añadidos.

**Dependencias:** servicios de identidad (Keycloak), adaptadores existentes.

**Notas técnicas:**

- Usar `CorrelationId` compartido entre el registro de auditoría y la operación de Keycloak para facilitar la trazabilidad.
- Implementar mecanismo de retry/backoff o encolar cambios si Keycloak no está disponible.

````
