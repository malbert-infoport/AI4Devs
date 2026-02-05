```markdown
# EVT002-T001-BE: Backend — Publicar `ApplicationEvent` en ActiveMQ

**TICKET ID:** EVT002-T001-BE
**EPIC:** Eventos y Sincronización
**COMPONENT:** Backend (Services / Events)
**PRIORITY:** Alta
**ESTIMATION:** 1-2 días

## Resumen
Implementar la publicación de `ApplicationEvent` en el tópico `infoportone.events.application` cuando cambien `Application`, `ApplicationModule` o `ApplicationRole`. El evento debe contener el catálogo completo sin exponer secrets (`ClientSecret` nunca en clear).

## Payload (ejemplo)

```json
{
  "EventId": "uuid",
  "EventType": "APPLICATION",
  "EventTimestamp": "2026-02-06T12:00:00Z",
  "OriginApplicationId": "infoportone-admon",
  "SchemaVersion": "1.0",
  "Payload": [
    {
      "ApplicationId": 5,
      "AppName": "CRM",
      "RolePrefix": "CRM",
      "Modules": [ { "ModuleId": 10, "Name": "Ventas" } ],
      "Roles": [ "CRM_Vendedor", "CRM_Gerente" ]
    }
  ]
}
```

## Diseño
- Llamada a `IEventPublisher.PublishAsync("infoportone.events.application", envelope)` desde `ApplicationService.PostActions` y desde repositorios que cambien catálogo.
- Incluir metadata que indique si el event payload contiene cambios en `Modules` o `Roles`.

## Seguridad
- No incluir `ClientSecret` en el payload. En su lugar, incluir `HasClientCredentials: true`.

## Tests
- Unit test y integration test contra broker de pruebas.

## Acceptance Criteria
- [ ] Eventos `ApplicationEvent` publicados al cambiar catálogo.
- [ ] Payload revisado y sin secretos.

```
