# USR001 - Consumir UserEvent desde Satelite

**ID:** USR001_Consumir_UserEvent_Desde_Satelite
**EPIC:** Consolidación de Usuarios

**RESUMEN:** Definir la historia que implementa el consumidor de eventos de usuario desde la cola/tema de eventos (satelite). El backend correrá un proceso en background que se suscribe a la cola de eventos de usuario y encola para procesamiento posterior.

## OBJETIVOS
- Implementar un servicio background en el backend que se suscriba a la cola `UserEvents` (broker: Artemis/ActiveMQ) y reciba eventos de usuario.
- Validar y normalizar el payload mínimo (email, eventId, timestamp, payload) y persistir un registro de ingestión en `EVENTHASH` (ver USR002-DB).
- Encolar tareas de procesamiento (ej: a un bus interno o marcar para proceso inmediato según configuración).

## ACEPTACIÓN
- [ ] Existe un servicio background registrado en `Program.cs` que inicia la suscripción a `UserEvents`.
- [ ] Mensajes inválidos son rechazados y logueados con `CorrelationId`.
- [ ] Para cada evento válido se crea/actualiza registro en `EVENTHASH` y se genera trabajo de consolidación (por ejemplo insert en tabla `USERCACHE` o push a queue interna).

## NOTAS TÉCNICAS / CONTRATO
- Broker: Artemis / ActiveMQ (configurar conexión desde `appsettings`).
- Cola/Topic: `UserEvents` (suscripción durable).
- Retries: política con backoff y DLQ en caso de fallo permanente.
- Seguridad: conexión con credenciales y trazabilidad `X-Correlation-Id` cuando aplique.

## TICKETS BACKEND RELACIONADOS
- `Ticket_USR001_T001-BE.md` — implementación del consumidor background y orquestación básica.
