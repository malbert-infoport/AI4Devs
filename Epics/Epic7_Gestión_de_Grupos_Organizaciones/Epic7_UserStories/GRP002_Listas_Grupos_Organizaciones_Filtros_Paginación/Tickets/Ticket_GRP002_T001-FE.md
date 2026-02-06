```markdown
# GRP002-T001-FE: Frontend — Listado Grupos de Organizaciones (Filtros y Paginación)

**TICKET ID:** GRP002-T001-FE
**EPIC:** Gestión de Grupos de Organizaciones (Epic7)
**COMPONENT:** Frontend - Angular

## TÍTULO
Implementar la vista de listado de grupos con filtros por `Name`/`Key` y paginación server-side.

## DESCRIPCIÓN
- Componente standalone `group-organization-list` con `ClGrid` que llama a `GroupOrganizationClient.getAllKendoFilter`.
- Columnas: `Name`, `Key`, `Description`, `Active`, `OrganizationsCount`, acciones `Ver / Editar / Eliminar`.

## EJEMPLO DE IMPLEMENTACIÓN (TypeScript)
```typescript
import { inject } from '@angular/core';
import { GroupOrganizationClient } from 'src/webServicesReferences/api';
import { ClGridService } from '@cl/common-library';

const groupClient = inject(GroupOrganizationClient);

async function loadPage(filterPayload: any) {
	return await groupClient.getAllKendoFilter(filterPayload).toPromise();
}
```

## TESTS RECOMENDADOS
- Unit: parameters de `ClGrid` traducidos a payload Kendo; `getAllKendoFilter` mocked.
- Integration: endpoint devuelve `FilterResult` correcto para distintos filtros.

## CRITERIOS DE ACEPTACIÓN
- [ ] Grid con filtros y paginación funcional.

```
