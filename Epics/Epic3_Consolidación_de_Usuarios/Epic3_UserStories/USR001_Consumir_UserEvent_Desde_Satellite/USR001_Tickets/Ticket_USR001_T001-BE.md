```markdown
# USR001-T001-BE: Backend — Consumidor background de UserEvents

**TICKET ID:** USR001-T001-BE
**EPIC:** Consolidación de Usuarios
**COMPONENT:** Backend - Helix6 (.NET 8)
**PRIORITY:** Alta
**ESTIMATION:** 2 días

## OBJETIVO
Implementar un servicio background que se suscriba de forma durable a la cola/tema `UserEvents` del broker (Artemis/ActiveMQ), valide eventos de usuario, persista metadatos en `EVENTHASH` y encole/ejecute la tarea de consolidación.

## ALCANCE
- Servicio `UserEventConsumerService` registrado como `IHostedService`/background worker en `Program.cs`.
- Suscripción durable a `UserEvents`; manejo de reconexiones y DLQ.
- Validación mínima del evento: `EventId`, `Email`, `Timestamp`, `Payload`.
- Escritura en tabla `EVENTHASH` (ver USR002-DB) con hash del payload y timestamp de ingestión.
- Emisión de tarea de procesamiento: push a queue interna (p.ej. `UserConsolidationQueue`) o llamada directa a `UserConsolidationService.Enqueue`.

## DISEÑO
- `UserEventConsumerService`:
  - `StartAsync`: abre conexión y suscripción durable.
  - `OnMessage`: valida y transforma mensaje; si válido: `UpsertEventHash(eventId, email, hash, receivedAt)` y `EnqueueConsolidation(email, eventId)`.
  - `ErrorHandling`: retry/backoff y enviar a DLQ tras N intentos.

- Configuración en `appsettings.json`:
  - `UserEvents:BrokerUrl`, `UserEvents:QueueName`, `UserEvents:RetryCount`, `UserEvents:DLQ`.

## MIGRACIÓN / DEPENDENCIAS
- Tabla `EVENTHASH` creada por `USR002-T002-DB` (ticket DB). No crearla aquí.

## TESTS
- Unit: validar transformación de mensaje y que `UpsertEventHash` sea llamado con hash correcto.
- Integration: test contra broker local (o mock) que el servicio recoge mensajes y encola tareas.

## CRITERIOS DE ACEPTACIÓN
- [ ] Servicio background suscribe y procesa mensajes correctamente.
- [ ] Mensajes inválidos van a DLQ y se registran con detalle.
- [ ] Se inserta/actualiza registro en `EVENTHASH` por cada evento procesado.

***
```
