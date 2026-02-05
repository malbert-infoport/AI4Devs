# ORG005-T001-FE: Frontend — Consultar Auditoría de Cambios en Organización

=============================================================

**TICKET ID:** ORG005-T001-FE
**EPIC:** Gestión del Portfolio de Organizaciones Clientes
**USER STORY:** ORG005 - Consultar Auditoría de Cambios en Organización
**COMPONENT:** Frontend - Angular (SintraportV4.Front)
**PRIORITY:** Media
**ESTIMATION:** 1 día

=============================================================

## TÍTULO
Agregar pestaña "Auditoría" en la ficha de organización con grid de eventos, filtros, detalle modal y export CSV.

## DESCRIPCIÓN
Implementar la interfaz que permita consultar el historial de cambios relacionados con una organización. Debe ser accesible solo para roles con permiso `Organization audit query`.

## ROLES Y PERMISOS
- `Organization audit query` (permite ver y exportar auditoría)

## CONTRATO BACKEND (PROPUESTO)
- GET `/api/Audit/GetByOrganizationId?organizationId={id}&page={page}&pageSize={pageSize}&from={from}&to={to}&actionType={actionType}`
  - Retorna: `{ TotalCount: int, Items: AuditEventView[] }`
  - `AuditEventView`:
    - `Id`, `OrganizationId`, `Entity`, `ActionType`, `ChangedByUserId`, `ChangedByUserName`, `ChangedAt`, `CorrelationId`, `PropertyChanges` (array of `{ PropertyName, OldValue, NewValue }`)

Headers:
- `Authorization`, `Accept-Language`, `X-Correlation-Id`

## UX / FLUJOS
- La pestaña aparece en la ficha de organización si `accessService.has(Access.OrganizationAuditQuery)`.
- `ClGrid` muestra columnas: `ChangedAt`, `ActionType`, `ChangedByUserName`, `Entity`, `CorrelationId` y acciones para `Ver detalle` y `Exportar CSV`.
- Filtros disponibles: rango de fechas, tipo de acción (Insert/Update/Delete), búsqueda por `ChangedByUserName`.
- Al abrir `Ver detalle` mostrar `ClModal` con lista de `PropertyChanges` y opción de copiar `CorrelationId`.

## EJEMPLO DE IMPLEMENTACIÓN (TypeScript)
```typescript
import { inject } from '@angular/core';
import { AuditClient } from 'src/webServicesReferences/api';
import { ClGridService, ClModalService } from '@cl/common-library';
import { AccessService, Access } from '../../theme/access/access';

const auditClient = inject(AuditClient);
const clModal = inject(ClModalService);
const accessService = inject(AccessService);

// cargar datos
async function loadAudit(organizationId: number, page = 1) {
  const resp = await auditClient.getByOrganizationId(organizationId, page, 20, null, null, null).toPromise();
  return resp;
}

// abrir detalle
function openDetail(event: AuditEventView) {
  clModal.open({
    title: 'Detalle auditoría',
    data: event
  });
}
```

## CASOS DE BORDE
- Usuario sin permiso → pestaña no visible.
- Backend devuelve `ProblemDetails` → mostrar snackbar con mensaje traducido.
- Eventos con `PropertyChanges` muy largos → truncar y mostrar `Ver más`.

## TESTS RECOMENDADOS
- Unit: mostrar/ocultar pestaña según `AccessService` (mock), grid carga usando `AuditClient` (mock), `openDetail` abre modal con datos.
- E2E: navegar a ficha de organización, abrir pestaña auditoría, aplicar filtro y abrir detalle.

## CRITERIOS DE ACEPTACIÓN
- [ ] Pestaña `Auditoría` visible sólo para usuarios con permiso.
- [ ] Grid con paginación y filtros funcionando contra `AuditClient`.
- [ ] Modal de detalle muestra `PropertyChanges` y `CorrelationId`.
- [ ] Export CSV con filtros seleccionados.

## SIGUIENTES PASOS
- Crear `AuditClient` NSwag contract si no existe o coordinar con backend para `Audit/GetByOrganizationId`.
- Implementar componente `organization-audit.component.ts` standalone y tests.

***
