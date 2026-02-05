```markdown
# EVT004-T001-BE: Backend — Sincronización Global de Eventos (API + Worker)

**TICKET ID:** EVT004-T001-BE
**EPIC:** Eventos y Sincronización
**COMPONENT:** Backend (API / Workers / Events)
**PRIORITY:** Alta
**ESTIMATION:** 3 días

## Resumen
Implementar una API backend y un worker que permita publicar en batch el estado completo de `Organization` o `Application` al tópico correspondiente (`infoportone.events.organization` / `infoportone.events.application`) para sincronización global. La API será consumida por el frontend (grid de organizaciones / aplicaciones) para iniciar la operación.

## API Backend
- `POST /api/Sync/Publish` — inicia una sincronización global.

Request body:

```json
{
  "EntityType": "Organization|Application",
  "Ids": [123,456],      // optional, si vacío => all
  "PageSize": 200,        // opcional, batch size
  "Force": true           // opcional, forzar republishing incluso si EventHash coincide
}
```

Response:
- `202 Accepted` con `OperationId` para seguimiento.

## Worker
- Consume solicitudes pendientes y publica eventos por lotes:
  - Consulta entidades por páginas
  - Por cada entidad construye envelope y publica en el tópico correspondiente
  - Respeta `EVENTHASH` y `Force` flag
  - Registra progreso y resultado en `SYNC_OPERATION_LOG` (simple table)

## Diseño Técnico
- Crear `SyncController` con endpoint `POST /api/Sync/Publish`.
- Crear `ISyncService` + `SyncService` que encola y controla la operación.
- Crear `SyncWorker` (IHostedService) que procesa la cola y publica eventos.
- Añadir tabla `SYNC_OPERATION_LOG` (Id, OperationId, EntityType, StartedAt, CompletedAt, Status, Details).

## Migrations
- Añadir EF Core migration para `SYNC_OPERATION_LOG`.

DDL sugerido:
```sql
CREATE TABLE "SYNC_OPERATION_LOG" (
  "Id" BIGSERIAL PRIMARY KEY,
  "OperationId" UUID NOT NULL,
  "EntityType" VARCHAR(50) NOT NULL,
  "StartedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "CompletedAt" TIMESTAMP,
  "Status" VARCHAR(50),
  "Details" TEXT
);
```

## Tests
- Unit tests para `SyncService` y controller.
- Integration tests: ejecutar worker y verificar que mensajes llegan al broker de pruebas y `SYNC_OPERATION_LOG` se actualiza.

## Acceptance Criteria
- [ ] API devuelve `OperationId` y encola la operación.
- [ ] Worker publica eventos para todas las entidades en batches.
- [ ] `SYNC_OPERATION_LOG` registra el resultado por operación.

```
