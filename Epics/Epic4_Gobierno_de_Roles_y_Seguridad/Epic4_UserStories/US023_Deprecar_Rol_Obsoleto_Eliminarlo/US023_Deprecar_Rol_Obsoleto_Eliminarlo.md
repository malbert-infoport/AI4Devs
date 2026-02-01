#### US-023: Deprecar rol obsoleto sin eliminarlo

**Épica:** Gobierno de Roles y Seguridad
**Rol:** SecurityManager
**Prioridad:** Media | **Estimación:** 2 Story Points

**Historia:**
```
Como SecurityManager,
quiero marcar un rol como "deprecated" sin eliminarlo físicamente,
para evitar que se asigne a nuevos usuarios pero permitir que usuarios existentes con ese rol mantengan su acceso.
```

**Criterios de aceptación:**
- Campo `Active` en `APP_ROLE_DEFINITION`
- Botón "Deprecar rol" que marca `Active=false` y establece `AuditDeletionDate`
- No permitir asignar roles inactivos a nuevos usuarios

**Dependencias:** US-021
