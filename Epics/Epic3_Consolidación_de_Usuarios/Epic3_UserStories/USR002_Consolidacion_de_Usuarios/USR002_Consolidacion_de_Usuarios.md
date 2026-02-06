```markdown
```markdown
# USR002 - Consolidación de Usuarios

**ID:** USR002_Consolidacion_de_Usuarios
**EPIC:** Consolidación de Usuarios

**RESUMEN:** Definir el proceso que, tras la recepción de eventos de usuario, consolida información de usuarios por `email`, agregando `c_ids` (organizaciones) y roles en la caché de usuario. Incluye ticket backend para la lógica de consolidación y ticket DB para tablas `USERCACHE` y `EVENTHASH`.

## OBJETIVOS
- Detectar existencia de usuario por `email` y consolidar organizaciones (c_ids) y roles recibidos en eventos.
- Mantener `USERCACHE` con el estado consolidado del usuario (emails, organizaciones, roles, lastEventAt).
- Mantener `EVENTHASH` con el hash de último evento procesado por `eventId`/`email` para evitar reprocesos redundantes.

## ACEPTACIÓN
- [ ] Tras procesar un evento, `USERCACHE` contiene la combinación actualizada del usuario de organizaciones y roles para el `email`.
- [ ] Eventos duplicados (mismo hash) son ignorados.
- [ ] Existe migración SQL que crea `USERCACHE` y `EVENTHASH`.

## TICKETS RELACIONADOS
- `Ticket_USR002_T001-BE.md` — implementación del servicio de consolidación.
- `Ticket_USR002_T002-DB.md` — migración y DDL para `USERCACHE` y `EVENTHASH`.

```
```
