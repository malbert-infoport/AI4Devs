```markdown
# USR003-T001-BE: Servicio de sincronización con Keycloak

**TICKET ID:** USR003-T001-BE
**EPIC:** Consolidación de Usuarios
**COMPONENT:** Backend (Servicios, Repositorios)
**PRIORITY:** Alta
**ESTIMATION:** 2-3 días

## RESUMEN
Implementar un servicio backend que sincronice el estado consolidado de usuarios (`USERCACHE`) hacia Keycloak cuando el `EVENTHASH` indique que hubo cambios relevantes. El flujo será: detectar `EVENTHASH` nuevo/procesado → obtener `USERCACHE` por `Email` → transformar a payload Keycloak → llamar API Keycloak → registrar resultado en `KEYCLOAK_SYNC_LOG` y actualizar `USERCACHE.LastKeycloakSyncAt`.

## REQUISITOS
- Respetar las reglas de Helix6 (Services → Repositories → DataModel).
- Implementar idempotencia y reintentos con backoff en caso de errores transitorios.
- Publicar un evento interno (`UserSyncedToKeycloak`) en `PostActions` tras éxito.

## DISEÑO

### Clases a crear
- `IKeycloakSyncService` + `KeycloakSyncService` (IHostedService/Worker para procesar en batch)
- `IUserCacheRepository` (si no existe) y su implementación si hace falta; usar `USERCACHE` table
- `IKeycloakSyncLogRepository` / `KeycloakSyncLogRepository`

### Servicio principal
`KeycloakSyncService` debe:
- Leer `EVENTHASH` filas con `Status = 'Processed'` y `ProcessedAt > LastSyncCheck` (marcar lote en transacción).
- Para cada `EventHash`, obtener `USERCACHE` por `Email` y preparar payload.
- Llamar API Keycloak (configurable via settings): crear/actualizar usuario, asignar roles/realm/client roles según `USERCACHE.Roles`.
- Registrar intento en `KEYCLOAK_SYNC_LOG` con `Status`, `Response`, `AttemptAt`, `Attempts`.
- En éxito: actualizar `USERCACHE.LastKeycloakSyncAt` y publicar evento `UserSyncedToKeycloak` (IEventPublisher).

### Manejo de errores
- Reintentos exponenciales (3 intentos por defecto) para errores 5xx/timeout.
- Para errores permanentes (4xx), marcar `KEYCLOAK_SYNC_LOG.Status = 'Error'` y no reintentar automáticamente.

## Repositorios
- `KeycloakSyncLogRepository` con métodos: `AddLog`, `SetStatus`, `GetPendingRetries`.

## Endpoints
- No es necesario un endpoint HTTP principal; sin embargo exponer un endpoint admin para reintentos manuales es recomendado:
  - `POST /api/KeycloakSync/RetryFailed` (requires authorization)

## MIGRACIONES / DB
- Ver `Ticket_USR003_T002-DB.md` para DDL (añade columna a `USERCACHE` y crea `KEYCLOAK_SYNC_LOG`).

## PRUEBAS
- Tests unitarios para `KeycloakSyncService` con mocks de `IUserCacheRepository` y `IKeycloakClient`.
- Tests de integración que ejecuten el worker contra una base de datos en memoria/Postgres testcontainer y un Mock Keycloak HTTP server.

## CRITERIOS DE ACEPTACIÓN
- [ ] Worker procesa `EVENTHASH` procesados y llama a Keycloak.
- [ ] `KEYCLOAK_SYNC_LOG` guarda intentos y status correctos.
- [ ] `USERCACHE.LastKeycloakSyncAt` se actualiza tras sincronización exitosa.
- [ ] Retries funcionan y errores permanentes no se reintentan.
- [ ] Se publican eventos `UserSyncedToKeycloak` en caso de éxito.

```
