#### US-021: Definir catálogo de roles de una aplicación

**Épica:** Gobierno de Roles y Seguridad
**Rol:** SecurityManager
**Prioridad:** Alta | **Estimación:** 5 Story Points

**Historia:**
```
Como SecurityManager,
quiero definir el catálogo maestro de roles de una aplicación usando el prefijo de la aplicación (ej: CRM_Vendedor, CRM_Gerente),
para garantizar nomenclatura consistente y evitar conflictos de nombres cuando un usuario tiene roles en múltiples aplicaciones.
```

**Criterios de aceptación:**
- CRUD de roles desde detalle de aplicación
- Validación de nomenclatura `{RolePrefix}_{Nombre}`
- Campo `Active` para marcar roles deprecated
- Actualizar `ApplicationEvent` con lista de roles

**Dependencias:** US-009

**Notas técnicas:**
- Tabla `APP_ROLE_DEFINITION` con índice único en (`ApplicationId`, `RoleName`)
