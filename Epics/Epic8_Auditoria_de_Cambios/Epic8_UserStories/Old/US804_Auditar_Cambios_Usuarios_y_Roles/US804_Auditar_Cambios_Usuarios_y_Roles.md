````markdown
#### US-804: Auditar cambios críticos en usuarios y roles

**Épica:** Auditoría de Cambios Críticos
**Rol:** Admin
**Prioridad:** Alta | **Estimación:** 3 Story Points

**Historia:**
```
Como Admin,
quiero que las asignaciones de roles, cambios de permisos y activaciones/desactivaciones de usuarios generen entradas de auditoría,
para disponer de trazabilidad sobre quién modificó privilegios y cuándo.
```

**Contexto adicional:**

Registrar acciones como `RoleAssigned`, `RoleRemoved`, `UserDeactivated`, `UserActivated` con `UserId` del actor y `CorrelationId` cuando proceda.

**Criterios de aceptación:**

- `RoleAssigned` y `RoleRemoved` creados en `AUDIT_LOG` con UserId.
- `UserDeactivated`/`UserActivated` creados en `AUDIT_LOG` con UserId.
- Tests que verifiquen persistencia y contenidos.

**Requisitos no funcionales:**

- Logging no debe exponer contraseñas ni datos sensibles.

**Definición de hecho (DoD):**

- Integración con servicios de gestión de usuarios y roles.
- Tests unitarios e integración añadidos.

**Dependencias:** flujos de gestión de usuarios y UI de permisos.

**Notas técnicas:**

- Evitar incluir datos sensibles en `CorrelationId` o campos públicos; mantener referencia a IDs.

````
