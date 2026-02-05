#### US-030: Optimizar consolidación con caché

**Épica:** Sincronización y Consolidación de Usuarios Multi-Organización
**Rol:** Sistema (Background Worker)
**Prioridad:** Media | **Estimación:** 5 Story Points

**Historia:**
```
Como el Background Worker,
quiero utilizar la tabla UserConsolidationCache para evitar consultas costosas a BD en cada evento,
para procesar miles de eventos de usuario por segundo sin degradar el rendimiento.
```

**Criterios de aceptación:**
- Consultar caché primero por email
- Skip si `LastEventHash` coincide (SHA-256)
- Actualizar caché tras consolidación

**Notas técnicas:**
- Reducción de queries a BD, métricas antes/después
- `UserConsolidationCache` con índice único case-insensitive en Email
