# APL002-T001-FE: Frontend — Grid de Aplicaciones (Filtros, Paginación, Export)

=============================================================

**TICKET ID:** APL002-T001-FE
**EPIC:** Administración de Aplicaciones
**COMPONENT:** Frontend - Angular (SintraportV4.Front)
**PRIORITY:** Media
**ESTIMATION:** 1 día

=============================================================

## TÍTULO
Implementar `applications-list` standalone con `ClGrid` para listing avanzado: filtros server-side, sorting, paginación, export CSV y acciones por fila.

## DESCRIPCIÓN
Desarrollar un componente reutilizable que liste aplicaciones consumiendo `ApplicationClient.getAllKendoFilter` (config `ApplicationList`). Debe incluir:
- Toolbar con búsqueda global, filtros por `Active` y `RolePrefix`, y botón `Export CSV`.
- Grid con columnas configurables y server-side paging/sorting/filtering.
- Acciones por fila: `Ver` (navegar a `application-form`), `Editar` (si tiene permiso), `Activar/Desactivar` (modal de confirmación y llamada a `deleteUndeleteLogicById`).

## ROLES Y PERMISOS
- `Application data query` (`Access.ApplicationDataQuery` / value 301): ver listado.
- `Application data modification` (`Access.ApplicationDataModification` / value 300): ver/ejecutar acciones Edit y Toggle.

## CONTRATO BACKEND
- `POST /api/Application/GetAllKendoFilter` (configurationName=`ApplicationList`) → PagingResponse { TotalCount, Items[] }
- `PUT /api/Application/DeleteUndeleteLogicById?id={id}&delete={true|false}` → void

Headers:
- `Authorization`, `Accept-Language`, `X-Correlation-Id` (en mutaciones)

## UX / FLUJO
- Al cargar: solicitar página 1 con filtros por defecto (orden por `createdAt` desc).
- Toolbar: campo búsqueda (Name/Key), filtro `Active` (All/Active/Inactive), select `RolePrefix` (opcional), `Export CSV`.
- Paginación server-side con opciones [10,20,50]; control de cambio de página/sorting dispara recarga.
- Export CSV: reusar mismo `KendoGridFilter` y solicitar CSV (o descargar desde backend), mostrar snackbar en errores.

## EJEMPLO DE TRANSFORMACIÓN DE FILTROS (TS)
```typescript
function buildKendoFilter(search: string, active?: boolean, rolePrefix?: string, page=1, pageSize=20) {
	const filters = [];
	if (search) filters.push({ field: 'name', operator: 'contains', value: search });
	if (active !== undefined) filters.push({ field: 'active', operator: 'eq', value: active });
	if (rolePrefix) filters.push({ field: 'rolePrefix', operator: 'eq', value: rolePrefix });

	return { data: { filter: { logic: 'and', filters }, sort: [{ field: 'createdAt', dir: 'desc' }], skip: (page-1)*pageSize, take: pageSize } };
}
```

## IMPLEMENTACIÓN (pasos)
1. Crear componente standalone `application-list.component.ts` en `src/app/modules/applications/components/`.
2. Inyectar (`inject()`): `ApplicationClient`, `ClGridService`, `AccessService`, `ClModalService`, `SharedMessageService`.
3. Definir `ClGridConfig` y columnas: `name`, `key`, `rolePrefix`, `active` (badge), `createdAt`, `actions`.
4. Implementar `loadData(state)` que convierta `state` a `KendoGridFilter` y llame a `applicationClient.getAllKendoFilter`.
5. Implementar `onToggleActive(item)` con modal confirm y `applicationClient.deleteUndeleteLogicById(item.id, delete)`.
6. Añadir método `exportCsv()` que reuse el filtro actual y descargue CSV desde backend o convierta la respuesta.

## CASOS DE BORDE
- Export con más de N registros: backend debe ofrecer paginación o export por job.
- Usuario sin permisos: mostrar vista con mensaje `No tiene permisos` y botón oculto `Nuevo`.

## TESTS RECOMENDADOS
- Unit:
	- `application-list` carga y transforma filtros correctamente.
	- `onToggleActive` muestra modal y llama al client con el header `X-Correlation-Id`.
	- Toolbar filtra y refresca grid.

- E2E:
	- Búsqueda por nombre, cambio de página, export CSV y acción toggle active.

## CRITERIOS DE ACEPTACIÓN
- [ ] Grid implementado con `ClGrid` y configuraciones server-side.
- [ ] Búsqueda, filtros y paginación funcionan contra `ApplicationClient`.
- [ ] Export CSV respeta filtros aplicados.
- [ ] Acciones por fila (Ver/Editar/Toggle) funcionan según permisos.

## CHECKLIST PR
- [ ] Component created and exported in module routes
- [ ] Unit tests added (Jasmine/Karma)
- [ ] E2E test(s) added or noted
- [ ] Documentation updated (README or story file)

***
