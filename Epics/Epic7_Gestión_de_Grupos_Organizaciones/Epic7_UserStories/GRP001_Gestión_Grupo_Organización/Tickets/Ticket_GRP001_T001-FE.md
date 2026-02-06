```markdown
# GRP001-T001-FE: Frontend — Gestión Grupo Organización (formulario sencillo + grid readonly de organizaciones)

=============================================================

**TICKET ID:** GRP001-T001-FE
**EPIC:** Gestión de Grupos de Organizaciones (Epic7)
**COMPONENT:** Frontend - Angular (SintraportV4.Front)
**PRIORITY:** Media
**ESTIMATION:** 6 horas

=============================================================

## TÍTULO
Crear `group-organization-form` standalone con campos básicos (Name, Key, Description, Active) y pestaña `Organizaciones` que muestra un `ClGrid` en modo solo lectura con las organizaciones del grupo.

## DESCRIPCIÓN
- Componente standalone `group-organization-form` usando `inject()` y patrones de `Helix6_Frontend_Architecture.md`.
- Cargar vista completa con `GroupOrganizationClient.getById(id, 'GroupOrganizationComplete')` para obtener `Organizations` embebidas en modo read-only.
- Guardar con `GroupOrganizationClient.insert(view)` / `GroupOrganizationClient.update(view, 'GroupOrganizationComplete', true)`.

## ROLES Y PERMISOS
- `GroupOrganization data modification` — permite crear/editar grupos.
- `GroupOrganization data query` — permite ver listado y detalle.

## CONTRATO BACKEND (NSWAG)
- `GroupOrganizationClient.getById(id, 'GroupOrganizationComplete')` — devuelve `GroupOrganizationView` con `Organizations` (readonly subset: `Id, Name, Cid`).
- `GroupOrganizationClient.insert(view)`
- `GroupOrganizationClient.update(view, 'GroupOrganizationComplete', true)`

Headers recomendados: `Authorization`, `Accept-Language`, `X-Correlation-Id`.

## EJEMPLO DE IMPLEMENTACIÓN (TypeScript)
```typescript
import { inject } from '@angular/core';
import { GroupOrganizationClient } from 'src/webServicesReferences/api';
import { ClGridService, ClModalService } from '@cl/common-library';
import { AccessService } from 'src/app/theme/access/access';

const groupClient = inject(GroupOrganizationClient);
const clGrid = inject(ClGridService);
const accessService = inject(AccessService);

async function loadGroup(id: number) {
	const view = await groupClient.getById(id, 'GroupOrganizationComplete').toPromise();
	return view;
}
```

## UX / FLUJOS
- En detalle: pestaña `Datos` editable; pestaña `Organizaciones` solo lectura.
- En creación: `Organizaciones` mostrado vacío y no editable hasta que el grupo tenga `Id`.

## TESTS RECOMENDADOS
- Unit: `loadGroup` invoca `getById` con `GroupOrganizationComplete`; `ClGrid` renderiza items en modo readonly; permisos controlados por `AccessService`.

## CRITERIOS DE ACEPTACIÓN
- [ ] `group-organization-form` implementado y exportado en rutas
- [ ] Pestaña `Organizaciones` muestra `ClGrid` readonly cargado desde `GroupOrganizationClient`
- [ ] Tests unitarios añadidos

```
