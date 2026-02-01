#### US-024: Sincronizar roles en ApplicationEvent

**Épica:** Gobierno de Roles y Seguridad
**Avatar:** Sistema InfoportOneAdmon
**Prioridad:** Alta | **Estimación:** 3 Story Points

**Historia:**
```
Como el sistema InfoportOneAdmon,
quiero incluir automáticamente la lista completa de roles en cada ApplicationEvent,
para garantizar que las aplicaciones satélite siempre tengan el catálogo actualizado sin eventos separados.
```

**Criterios de aceptación:**
- `ApplicationEvent` incluye array `Roles` con RoleId, RoleName, Description, Active
- Republishing del `ApplicationEvent` al crear/editar/deprecar roles

**Definición de hecho:**
- Estructura de evento actualizada
- Apps satélite procesan correctamente

**Dependencias:** US-021
