```markdown
# EVT003-T001-BE: Backend — Consumir `UserEvent` y consolidar usuarios

**TICKET ID:** EVT003-T001-BE
**EPIC:** Eventos y Sincronización
**COMPONENT:** Backend (Workers / Services / DB)
**PRIORITY:** Alta
**ESTIMATION:** 2-3 días

## Resumen
Implementar el consumidor de `infoportone.events.user` que procese eventos publicados por aplicaciones satélite, calcule la consolidación por `email`, actualice/creará registros en `USERCACHE`, registre `EVENTHASH` para idempotencia y publique (si procede) sincronizaciones hacia Keycloak mediante el worker de sincronización.

## Payload esperado (UserEvent)
```json
{
  "EventId": "uuid",
  "EventType": "USER",
  "EventTimestamp": "2026-02-06T12:00:00Z",
  "OriginApplicationId": "crm-app",
  "SchemaVersion": "1.0",
  "Payload": [
    {
      "Email": "juan.perez@example.com",
      "FirstName": "Juan",
      "LastName": "Pérez",
      "SecurityCompanyId": 12345,
      "IsDeleted": false,
      "Roles": ["CRM_Vendedor"],
      "Attributes": {"Phone":"..."}
    }
  ]
}
```

## Diseño
- Consumer (IHostedService) que:
  - Recibe evento -> calcula hash SHA-256 del payload -> verifica `EVENTHASH` para idempotencia
  - Inserta/actualiza `USERCACHE` (merge de `Cids` y `Roles`)
  - Actualiza `EVENTHASH` con `ProcessedAt` y `PayloadHash`
  - Encola trabajo para `KeycloakSyncService` si la consolidación cambia `Cids` o roles
- Garantizar transacciones DB donde proceda para evitar estados intermedios.

## Tests
- Unit tests para lógica de merge de `USERCACHE`.
- Integration tests con broker y base de datos de pruebas.

## Acceptance Criteria
- [ ] Consumer procesa eventos y actualiza `USERCACHE` correctamente.
- [ ] `EVENTHASH` evita reprocesos.
- [ ] Worker encola sincronización a Keycloak cuando cambia consolidación.

```
