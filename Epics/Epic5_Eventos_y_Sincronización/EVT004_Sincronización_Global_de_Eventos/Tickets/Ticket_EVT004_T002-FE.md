```markdown
# EVT004-T002-FE: Frontend — Interfaz para iniciar Sincronización Global de Eventos

**TICKET ID:** EVT004-T002-FE
**EPIC:** Eventos y Sincronización
**COMPONENT:** Frontend (Angular)
**PRIORITY:** Alta
**ESTIMATION:** 1 día

## Resumen
Implementar la UI que permita al administrador iniciar una sincronización global de `OrganizationEvent` o `ApplicationEvent` desde las grids de Organizaciones y Aplicaciones. La UI invocará la API backend `POST /api/Sync/Publish` y mostrará progreso/resultado de la operación.

## UX / Comportamiento
- En las vistas de grid (`ClGrid`) de Organizaciones y Aplicaciones añadir un botón: **Sincronizar global** (visible sólo con permiso `Sync.Publish`).
- Al pulsar el botón abrir un `ClModal` de confirmación con opciones:
  - `EntityType`: `Organization` | `Application` (preseleccionado según la grid)
  - `Ids`: (checkbox para seleccionar filas; si vacío se enviará todo)
  - `PageSize`: number (por defecto 200)
  - `Force`: boolean (forzar republishing incluso si EventHash coincide)
- Al confirmar, la UI llamará al backend y mostrará `OperationId` y estado `Encolado` / `Procesando` / `Completado`.
- Proporcionar feedback inmediato y link a `Sync Operations` (opcional) para ver logs.

## Contrato Backend (API)
- Endpoint: `POST /api/Sync/Publish`
- Body: 

```json
{
  "EntityType": "Organization|Application",
  "Ids": [123,456],
  "PageSize": 200,
  "Force": true
}
```

- Response: `202 Accepted` { "OperationId": "uuid" }

### Headers
- Incluir `X-Correlation-Id` en la llamada, tomado de `CorrelationService`.

## Ejemplo TypeScript (Angular, standalone component)

```ts
import { inject } from '@angular/core';
import { ClModalService } from '@cl/common-library';

const syncClient = inject(SyncClient); // NSwag-generated client or wrapper
const correlation = inject(CorrelationService);

async function publishSync(request: PublishSyncRequest) {
  const headers = { 'X-Correlation-Id': correlation.id };
  const res = await syncClient.publish(request, headers);
  // mostrar OperationId en UI
}
```

## Snippet de componente (esqueleto)

HTML: botón en la toolbar del grid

```html
<button *ngIf="accessService.has('Sync.Publish')" (click)="openSyncModal()" class="btn btn-primary">
  Sincronizar global
</button>
```

TS (handler de modal)

```ts
openSyncModal() {
  this.modal.open(SyncModalComponent, { data: { entityType: 'Organization', selected: this.grid.selectedRows } });
}
```

## Modal: `SyncModalComponent` (resumen)
- Mostrar `EntityType`, selectable Ids (listado de filas seleccionadas), `PageSize`, `Force`.
- Botón `Iniciar sincronización` deshabilitado mientras request en curso.
- Al confirmar: llamar `SyncClient.publish(...)`, mostrar toast con `OperationId`.

## Permisos
- UI controlada por permiso `Sync.Publish` (enum `Access.SyncPublish`) y `AccessService`.

## Tests
- Unit tests (Jasmine/Karma) para `SyncModalComponent`:
  - Validar que se forma el request correcto según entradas.
  - Mock `SyncClient` para verificar llamada y manejo de `OperationId`.
- E2E test (Protractor/Cypress): flujo de abrir modal, confirmar y ver toast con `OperationId`.

## Criterios de Aceptación
- [ ] Botón aparece en grids solo para usuarios con permiso `Sync.Publish`.
- [ ] Modal permite personalizar `PageSize` y `Force` y seleccionar filas.
- [ ] Llamada a `POST /api/Sync/Publish` con `X-Correlation-Id` y se muestra `OperationId` en UI.
- [ ] Tests unitarios y E2E básicos añadidos.

## Notas de implementación
- Preferir usar un wrapper `SyncService` que utilice `SyncClient` NSwag y centralice headers (`X-Correlation-Id`).
- No almacenar credenciales ni Operation logs en el frontend; sólo mostrar `OperationId` y estado inicial.

```
