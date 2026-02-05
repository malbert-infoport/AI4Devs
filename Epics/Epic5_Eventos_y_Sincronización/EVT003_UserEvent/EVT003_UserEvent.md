```markdown
# EVT003 — UserEvent

## Resumen
Documentar y definir el `UserEvent` consumido por InfoportOneAdmon desde aplicaciones satélite y el evento publicado por InfoportOneAdmon tras consolidación (opcional). El `UserEvent` incluye el estado del usuario desde la aplicación origen (email, SecurityCompanyId, roles, attributes, IsDeleted).

## Objetivo
- Permitir que InfoportOneAdmon consuma `UserEvent` y consolide usuarios multi-organización, alimentando `USERCACHE` y publicando sincronizaciones a Keycloak.

## Criterios de Aceptación
- [ ] Contrato `infoportone.events.user` documentado con payload y ejemplo.
- [ ] Ticket backend creado para el consumidor y la integración con `USERCACHE`/`EVENTHASH`.

```
