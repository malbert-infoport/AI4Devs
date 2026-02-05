```markdown
# USR002-T001-BE: Backend — Servicio de Consolidación de Usuarios

**TICKET ID:** USR002-T001-BE
**EPIC:** Consolidación de Usuarios
**COMPONENT:** Backend - Helix6 (.NET 8)
**PRIORITY:** Alta
**ESTIMATION:** 3 días

## OBJETIVO
Implementar `UserConsolidationService` que procese eventos encolados por `UserEventConsumerService`, consolide usuarios por `email`, gestione `USERCACHE` y actualice `EVENTHASH` para evitar reprocesos.

## ALCANCE
- Servicio `UserConsolidationService` con método `ProcessEvent(UserEvent event)`.
- Lógica de consolidación:
  - Buscar `USERCACHE` por `email`.
  - Si no existe: crear entry con `email`, `c_ids` y roles desde el evento.
  - Si existe: unir `c_ids` (set union), merge de roles (set union) y actualizar `lastEventAt` si el evento es más reciente.
  - Guardar cambios en `USERCACHE` y actualizar `EVENTHASH` con nuevo hash/timestamp.
- Manejo de concurrencia: usar optimistic locking (RowVersion) o transacción serializable si necesario.

## API / Contratos internos
- No exponer endpoint público; proceso interno invocado por el consumer o por worker.
- Opcional: exponer `GET /api/UserCache/GetByEmail?email=...` para depuración/administración (Ticket separado si se desea).

## MIGRACIÓN / DEPENDENCIAS
- Requiere `Ticket_USR002_T002-DB.md` que crea tablas `USERCACHE` y `EVENTHASH`.

## TESTS
- Unit: consolidación merge de c_ids y roles para varios escenarios.
- Integration: flujo end-to-end desde `UserEventConsumerService` → `UserConsolidationService` con DB en memoria o container.

## CRITERIOS DE ACEPTACIÓN
- [ ] Eventos procesados actualizan `USERCACHE` correctamente.
- [ ] `EVENTHASH` refleja el último hash por `eventId`/`email` para evitar reprocesos.
- [ ] Casos de concurrencia manejados sin duplicación ni pérdida de datos.

***
```
