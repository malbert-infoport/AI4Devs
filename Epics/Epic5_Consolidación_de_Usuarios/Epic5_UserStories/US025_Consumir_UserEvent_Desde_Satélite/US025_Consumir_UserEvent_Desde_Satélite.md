#### US-025: Consumir UserEvent desde aplicaciones satélite

**Épica:** Sincronización y Consolidación de Usuarios Multi-Organización
**Rol:** Sistema (Background Worker)
**Prioridad:** Alta | **Estimación:** 5 Story Points

**Historia:**
```
Como el Background Worker de InfoportOneAdmon,
quiero suscribirme al tópico infoportone.events.user y consumir eventos de usuario publicados por aplicaciones satélite,
para centralizar la gestión de identidades y mantener Keycloak sincronizado sin que las apps accedan directamente a su Admin API.
```

**Criterios de aceptación:**
- Worker suscrito durablemente al tópico `infoportone.events.user`
- Idempotencia, validación de esquema, ack tras procesamiento exitoso
- Reintentos con backoff en caso de error

**Notas técnicas:**
- Usar Apache.NMS.ActiveMQ, consumer group, circuit breaker
