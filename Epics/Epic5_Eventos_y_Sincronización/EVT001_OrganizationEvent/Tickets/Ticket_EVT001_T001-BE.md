```markdown
# EVT001-T001-BE: Backend — Publicar `OrganizationEvent` en ActiveMQ

**TICKET ID:** EVT001-T001-BE
**EPIC:** Eventos y Sincronización
**COMPONENT:** Backend (Services / Events)
**PRIORITY:** Alta
**ESTIMATION:** 1-2 días

## Resumen
Implementar la publicación de `OrganizationEvent` en el tópico `infoportone.events.organization` cada vez que una organización se crea, actualiza o se marca como eliminada (`AuditDeletionDate`). El evento transporta el estado completo de la organización (State Transfer). Debe integrarse en `OrganizationService` usando `PostActions` o hooks equivalentes.

## Payload (ejemplo)

```json
{
  "EventId": "uuid",
  "EventType": "ORGANIZATION",
  "EventTimestamp": "2026-02-06T12:00:00Z",
  "OriginApplicationId": "infoportone-admon",
  "TraceId": "trace-xyz",
  "SchemaVersion": "1.0",
  "Payload": [
    {
      "SecurityCompanyId": 12345,
      "Name": "ACME Corp",
      "TaxId": "A12345678",
      "Address": "Calle Falsa 1",
      "IsDeleted": false,
      "GroupId": 10,
      "Apps": [ { "AppId": 5, "AccessibleModules": [10,11] } ]
    }
  ]
}
```

## Diseño
- Añadir llamada a `IEventPublisher.PublishAsync(topic, envelope)` en `OrganizationService.PostActions` tras insert/update/delete logic.
- Incluir `TraceId` en el envelope usando `CorrelationService`.
- Marcar evento como publicado y persistir `EventHash` en `EVENTHASH` para idempotencia.

## Endpoints / Operations
- No se requiere endpoint adicional; el flujo es triggered por operaciones CRUD sobre `Organization`.

## Tests
- Unit test: verificar que `PublishAsync` es llamado en `PostActions` con el envelope correcto.
- Integration test: levantar broker de pruebas (docker-compose Artemis) y consumir el mensaje.

## Acceptance Criteria
- [ ] `OrganizationEvent` es publicado automáticamente en `PostActions`.
- [ ] Payload match con la especificación y contiene `SecurityCompanyId` y `Apps`.
- [ ] Idempotencia garantizada mediante `EVENTHASH`.

```
