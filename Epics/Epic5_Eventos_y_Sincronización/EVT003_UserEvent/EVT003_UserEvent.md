# EVT003 — UserEvent

## Resumen
Documentar y definir el `UserEvent` consumido por InfoportOneAdmon desde aplicaciones satélite y el evento publicado por InfoportOneAdmon tras consolidación (opcional). El `UserEvent` incluye el estado del usuario desde la aplicación origen (email, SecurityCompanyId, roles, attributes, IsDeleted).

## Objetivo
- Permitir que InfoportOneAdmon consuma `UserEvent` y consolide usuarios multi-organización, alimentando `USERCACHE` y publicando sincronizaciones a Keycloak.

## Criterios de Aceptación
- [ ] Contrato `infoportone.events.user` documentado con payload y ejemplo.
- [ ] Ticket backend creado para el consumidor y la integración con `USERCACHE`/`EVENTHASH`.

## Publisher / Triggers / Subscribers / Processing

- **Publisher:** Aplicaciones satélite (origins) publican `UserEvent` en `infoportone.events.user`. InfoportOneAdmon también puede publicar eventos derivados tras consolidación.
- **Triggers:** Creación/actualización/baja de usuario en la aplicación origen, cambios de roles o de `SecurityCompanyId`, y acciones de reconciliación iniciadas por admins o procesos automáticos.
- **Subscribers:** `InfoportOneAdmon` consumer (Background Worker), auditoría, procesos de análisis y, tras consolidación, `KeycloakSyncService`.
- **Processing (suscriptor):** calcular hash del payload para idempotencia (`EVENTHASH`), merge/upsert en `USERCACHE` (merge de `Cids` y `Roles`), encolar sincronización a Keycloak si cambia `Cids` o roles, ack al broker y registro de `EVENTHASH`/estado.
