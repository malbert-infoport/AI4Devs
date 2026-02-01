#### US-027: Consolidar organizaciones en claim c_ids

**Épica:** Sincronización y Consolidación de Usuarios Multi-Organización
**Rol:** Sistema (Background Worker)
**Prioridad:** Alta | **Estimación:** 8 Story Points

**Historia:**
```
Como el Background Worker,
quiero construir el array completo de SecurityCompanyIds de todas las organizaciones a las que pertenece un usuario,
para generar el claim c_ids que viajará en su token JWT y le permitirá acceder a datos de todas sus organizaciones con un solo login.
```

**Criterios de aceptación:**
- Obtener SecurityCompanyIds activos y construir array `c_ids`
- Almacenar en `UserConsolidationCache.ConsolidatedCompanyIds`
- Excluir organizaciones inactivas

**Notas técnicas:**
- Query eficiente JOIN entre eventos de usuario y tabla Organizations
- Considerar límite de tamaño de claim si usuarios tienen muchas orgs
