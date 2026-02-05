# APL002 - Listar Aplicaciones con Filtros, Orden y Paginación (Grid)

**ID:** APL002
**EPIC:** Administración de Aplicaciones

**RESUMEN:**
Crear la vista de listado de aplicaciones (`applications-list`) con capacidades avanzadas de filtrado server-side, sorting, paginación, export CSV y acciones rápidas (Ver, Editar, Activar/Desactivar). Debe seguir el patrón y nivel de detalle de `ORG002` (Organization list).

## OBJETIVOS
- Implementar un `ClGrid` con filtros server-side (Kendo-like), sorting y paginación eficiente.
- Añadir toolbar con filtros rápidos, búsqueda por texto y export CSV que respete filtros aplicados.
- Proveer acciones por fila: `Ver` (navegar a formulario), `Editar` (si tiene permiso), `Activar/Desactivar` (baja lógica con confirmación).

## PRIORIDAD
Media — Estimación: 1 día (incluye tests unitarios básicos y documentación)

## ROLES Y PERMISOS
- `Application data query` (301): Permite listar y ver detalles.
- `Application data modification` (300): Permite acciones Edit/Activate/Deactivate.

> Nota: `Access` enum ya debe contener 300/301; si no existe, coordinar añadir en `src/app/theme/access/access.ts`.

## CONTRATO BACKEND (ESPECIFICACIÓN)
- Endpoint principal (server-side paging/filtering):
	- POST `/api/Application/GetAllKendoFilter`
		- Query: `configurationName=ApplicationList`, `includeDeleted=false`
		- Body: KendoGridFilter (data: { filter, sort, skip, take })
		- Returns: `{ TotalCount: int, Items: ApplicationListView[] }` (PagingResponse)

- Endpoint toggle baja lógica:
	- PUT `/api/Application/DeleteUndeleteLogicById?id={id}&delete={true|false}`

Headers requeridos:
- `Authorization: Bearer {token}`
- `Accept-Language`
- `X-Correlation-Id` (cuando la acción modifica estado)

Payload/View (ApplicationListView) esperado por cada item:
```typescript
interface ApplicationListView {
	id: number;
	name: string;
	key: string;
	rolePrefix?: string;
	active: boolean;
	createdAt?: string;
}
```

## UX / FLUJO
- Página `applications-list` con `ClGrid` y toolbar superior.
- Toolbar: buscador por texto (Name/Key), filtros desplegables (`Active`), botón `Export CSV`, botón `Nuevo` (si tiene permiso).
- Grid columns: `Name` (sortable), `Key`, `RolePrefix`, `Active` (badge), `CreatedAt` (fecha), `Actions` (Ver/Editar/Toggle).
- Paginación server-side con tamaños [10,20,50]. Orden por `CreatedAt` desc por defecto.
- Export CSV: realiza la misma query que el grid pero solicita un CSV (backend o frontend streaming).

## EJEMPLO DE REQUEST (Kendo-style)
```json
{
	"data": {
		"filter": { "logic": "and", "filters": [ { "field": "name", "operator": "contains", "value": "test" } ] },
		"sort": [{ "field": "createdAt", "dir": "desc" }],
		"skip": 0,
		"take": 20
	}
}
```

## IMPLEMENTACIÓN (Frontend) — Guía paso a paso
1. Crear componente `src/app/modules/applications/components/applications-list/application-list.component.ts` como standalone.
2. Inyectar `ApplicationClient` (NSwag), `ClGridService`, `AccessService`, `SharedMessageService` usando `inject()`.
3. Definir `ClGridConfig`:
	 - `idGrid: 'applicationsList'`
	 - columnas: `name`, `key`, `rolePrefix`, `active`, `createdAt`, `actions`
	 - `pageable.server = true`, `sortable.server = true`, `filterable.server = true`
4. Implementar método `loadData(state)` que construya `KendoGridFilter` y llame a `applicationClient.getAllKendoFilter(filter, 'ApplicationList', false)`.
5. Implementar `onToggleActive(id, currentState)` que muestre modal de confirmación y llame a `applicationClient.deleteUndeleteLogicById(id, !currentState)`.
6. Implementar `exportCsv()` que re-use el filtro actual para solicitar CSV (backend) o convertir server response a CSV client-side.

## EJEMPLO TS (snippet)
```typescript
const applicationClient = inject(ApplicationClient);
const accessService = inject(AccessService);

async function loadApplications(kendoFilter) {
	const resp = await applicationClient.getAllKendoFilter(kendoFilter, 'ApplicationList', false).toPromise();
	return { data: resp.items, total: resp.totalCount };
}
```

## CASOS DE BORDE
- Filtros vacíos → retornar primeras N páginas sin penalización.
- Usuario sin permiso 301 → mostrar mensaje "No tiene permisos para ver aplicaciones".
- Export con muchos registros → backend debe soportar streaming o límite por request.

## TESTS
- Unit tests (Jasmine/Karma):
	- `applications-list` monta correctamente y llama a `getAllKendoFilter` con filtros transformados.
	- `onToggleActive` llama endpoint y muestra mensajes según respuesta.
	- Toolbar filtros afectan la petición.

- E2E (opcional): búsqueda, paginación y export.

## CRITERIOS DE ACEPTACIÓN
- [ ] `ClGrid` implementado y muestra datos reales desde `ApplicationClient`.
- [ ] Paginación, sorting y filtros server-side funcionan.
- [ ] Export CSV respeta filtros aplicados.
- [ ] Botones Ver/Editar/Toggle funcionan según permisos.

## DEPENDENCIAS
- `@cl/common-library` para `ClGrid`.
- NSwag generated `ApplicationClient` en `src/webServicesReferences/api`.
- `AccessService` para permisos.

***
