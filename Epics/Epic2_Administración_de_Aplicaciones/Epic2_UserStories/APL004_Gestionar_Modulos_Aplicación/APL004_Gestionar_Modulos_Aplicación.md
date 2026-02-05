# APL004 - Gestionar Módulos de Aplicación (CRUD y asignación)

**ID:** APL004
**EPIC:** Administración de Aplicaciones

**RESUMEN:** Implementar la UI y contrato frontend para administrar `ApplicationModule` (CRUD) y permitir su asignación/desasignación en el formulario de `Application`. La solución debe reutilizar clientes NSwag (`ApplicationModuleClient`, `ApplicationClient`), incluir trazabilidad (`X-Correlation-Id`) y pruebas unitarias.

## Objetivos
- Implementar CRUD completo de `ApplicationModule` (Name, Key, Description, DisplayOrder, ApplicationId).
- Añadir gestión de asignaciones desde `application-form` (pestaña Módulos): multiselect + creación in-place.
- Validaciones: key único por aplicación (si aplica), bloqueo/confirmación en eliminación si el módulo está en uso.

## Prioridad
Alta — Estimación 2 días

## Contrato Backend (esperado)
La `application-form` y los flujos de edición completa NO deben invocar directamente endpoints de `ApplicationModule`. En su lugar, deben usar el contrato de la entidad `Application` con la configuración de carga completa `ApplicationComplete`.

- `GET /api/Application/GetById?id={id}&configuration=ApplicationComplete` → `ApplicationView` que incluye `ApplicationModules`.
- `POST /api/Application/Insert` / `POST /api/Application/Update` → aceptar `ApplicationView` completo con `ApplicationModules` y aplicar insert/update/delete de manera atómica.

Headers esperados para mutaciones:
- `Authorization: Bearer <token>`
- `Accept-Language`
- `X-Correlation-Id: <uuid>` (si disponible)

Notas:
- Los endpoints específicos de `ApplicationModule` pueden existir para administración global, pero la `application-form` deberá sincronizar mediante el `ApplicationClient` y no usará `ApplicationModuleClient` directamente.

## UI / Flujo
- `modules-management` (standalone) — grid `ClGrid` con columnas: `Name`, `Key`, `ApplicationId` (si aplica), `DisplayOrder`, `Actions` (edit/delete).
	- Toolbar: `Crear módulo`, filtros y export CSV.
	- Crear/Editar usan `ClModal` con formulario validado (Name required, Key required, DisplayOrder numeric).
- `application-form` → pestaña `Módulos`:
	- Mostrar multiselect/lista de módulos asignados.
	- Botón `Crear módulo` abre `modules-management` modal en modo creación; al guardar, asigna automáticamente al `Application` actual y refresca view.
	- Al eliminar módulo desde grid, si backend responde `409 Conflict`, mostrar lista de aplicaciones afectadas y bloquear eliminación hasta resolución.

## UX / Mensajería
- Modal con validaciones inline; mensajes de error traducidos (usar `SharedMessageService` y `ProblemDetails` mapping).
- Toast/snackbar en operaciones exitosas. Confirmación explícita para borrado.

## Ejemplo de implementación (TypeScript)
modules-management.service.ts (wrapper mínimo):

```typescript
import { inject } from '@angular/core';
import { ApplicationModuleClient } from 'src/webServicesReferences/api';
import { HttpHeaders } from '@angular/common/http';
import { CorrelationService } from 'src/app/core/correlation.service';

const api = inject(ApplicationModuleClient);
const correlation = inject(CorrelationService);

function createModule(view: any) {
	const corr = correlation?.get() ?? '';
	return api.insert(view, { headers: new HttpHeaders({ 'X-Correlation-Id': corr }) });
}

function deleteModule(id: number) {
	const corr = correlation?.get() ?? '';
	return api.deleteById(id, { headers: new HttpHeaders({ 'X-Correlation-Id': corr }) });
}
```

Componente `application-form` snippet para asignación:

```typescript
// Al crear módulo desde modal
this.modulesModalService.openCreate().afterClosed().subscribe(result => {
	if (!result) return;
	this.modulesService.createModule(result).subscribe(() => {
		this.snackBar.open('Módulo creado y asignado', 'Cerrar', { duration: 3000 });
		this.loadApplication(); // GetById ApplicationComplete
	}, err => this.handleError(err));
});
```

## Casos de borde
- Conflicto al eliminar: backend devuelve 409 con lista de aplicaciones; mostrar modal con detalle y acciones (desasignar primero).
- Validación de clave duplicada: mostrar error en formulario.

## Tests recomendados
- Unit tests (Jasmine/Karma):
	- Grid muestra datos y acciones según permisos (mock `AccessService`).
	- Modal create/save invoca `ApplicationModuleClient.insert` y refresca grid.
	- Eliminación maneja 200 / 409 / 403 correctamente.

## Criterios de aceptación
- [ ] `modules-management` con CRUD funcionando y tests unitarios añadidos.
- [ ] `application-form` pestaña Módulos permite asignar/desasignar y crear módulos in-place.
- [ ] Manejo de `X-Correlation-Id` en peticiones mutantes.

## Notas de implementación
- Usar `inject()` en componentes standalone.
- Registrar permisos nuevos si son necesarios en `Access` enum y usar `AccessService`.
- Reutilizar `ApplicationModuleClient` generado por NSwag (`src/webServicesReferences/api`).

***
