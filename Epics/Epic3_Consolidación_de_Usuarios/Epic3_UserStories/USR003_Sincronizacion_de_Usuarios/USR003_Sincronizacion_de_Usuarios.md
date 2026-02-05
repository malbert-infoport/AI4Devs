```markdown
# USR003 — Sincronización de usuarios hacia Keycloak

## Resumen
Cuando el sistema detecte cambios consolidados en `USERCACHE` (a partir de `EVENTHASH` procesados), debe sincronizar el usuario con Keycloak para asegurar que roles y estado estén replicados en el proveedor de identidad.

## Objetivos
- Sincronizar usuarios consolidados con Keycloak.
- Registrar intentos y resultados en `KEYCLOAK_SYNC_LOG`.
- Garantizar idempotencia y políticas de reintento.

## Tickets
- `Ticket_USR003_T001-BE.md` — Servicio de sincronización y worker.
- `Ticket_USR003_T002-DB.md` — Migraciones y tablas (`LastKeycloakSyncAt`, `KEYCLOAK_SYNC_LOG`).

## Notas de implementación
- Keycloak URL/realm/credentials deben leerse desde `appsettings.*` y protegerse con Secrets.
- Considerar compatibilidad con creación y actualización de usuarios por `email`.

```
