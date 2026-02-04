````markdown
#### US-802: Auditar cambios críticos en Application

**Épica:** Auditoría de Cambios Críticos
**Rol:** ApplicationManager
**Prioridad:** Media | **Estimación:** 3 Story Points

**Historia:**
```
Como ApplicationManager,
quiero que los cambios críticos en la configuración y mantenimiento de una Application queden registrados en el sistema de auditoría,
para disponer de historial y trazar modificaciones que puedan afectar integraciones o accesos.
```

**Contexto adicional:**

Acciones típicas a auditar (ejemplos):
- `ApplicationConfigChanged` - Cambio de configuración crítica (dbname, endpoints, flags de sincronización)
- `ApplicationModulesChanged` - Cambios en módulos accesibles o lista de aplicaciones asociadas
- `ApplicationDeactivated` / `ApplicationReactivated` - Cambios de estado que afectan disponibilidad
 - `ApplicationRoleAssigned` / `ApplicationRoleRemoved` - Añadido/removido roles asociados a la aplicación
 - `ApplicationCredentialAdded` / `ApplicationCredentialRemoved` - Añadidas/removidas credenciales de acceso (registrar referencia, no secretos)

**Criterios de aceptación:**

- Al modificar configuración crítica se registra `ApplicationConfigChanged` con `EntityType`="Application" y `EntityId` correspondiente.
- Al cambiar módulos o accesos se registra `ApplicationModulesChanged`.
- Al des/activar una aplicación se registran `ApplicationDeactivated`/`ApplicationReactivated` con `UserId` o `NULL` según origen.
 - Al añadir/quitar roles se registran `ApplicationRoleAssigned`/`ApplicationRoleRemoved` con `UserId` y metadata del rol.
 - Al añadir/quitar credenciales se registran `ApplicationCredentialAdded`/`ApplicationCredentialRemoved` con referencia a la credencial (NO incluir secretos), y `UserId` o `NULL` según origen.
- Tests unitarios e integración que verifiquen persistencia y campos mínimos.

**Requisitos no funcionales:**

- No registrar secretos ni credenciales; sólo metadatos y referencias por ID.
- Logging eficiente para evitar latencia en operaciones de configuración.

**Definición de hecho (DoD):**

- Hooks en servicios de gestión de Application que invocan `IAuditLogService`.
- Tests y documentación creados.

**Dependencias:** servicios de Applications y documentación de integraciones.

**Notas técnicas:**

- Incluir en `CorrelationId` cuando el cambio forma parte de un despliegue o flujo mayor.
- Si se requieren payloads ampliados (old/new) abrir ticket separado; la tabla `AUDIT_LOG` debe permanecer sin JSON por diseño.
 - Al registrar cambios de credenciales, almacenar únicamente un identificador/alias de la credencial y metadatos (por ejemplo, tipo y fecha de expiración). Nunca almacenar el secreto o password.

````
