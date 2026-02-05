```markdown
# APL004-T001-FE: Frontend — CRUD de Módulos y Asignación en Aplicación

**TICKET ID:** APL004-T001-FE
**EPIC:** Administración de Aplicaciones
**COMPONENT:** Frontend - Angular (SintraportV4.Front)
**PRIORITY:** Alta
**ESTIMATION:** 1.5 días

## TÍTULO
Implementar `modules-management` (CRUD) y la integración en `application-form` (pestaña Módulos) para asignación in-place.

## OBJETIVO
Permitir a administradores gestionar módulos globales y asignarlos a aplicaciones desde el formulario de aplicación, con validaciones y UX consistente.

## DESCRIPCIÓN DETALLADA
- `modules-management` (ruta/diálogo): `ClGrid` con columnas `Name`, `Key`, `ApplicationId` (opcional), `DisplayOrder`, `Actions`.
	- Toolbar: `Crear módulo`, filtro por `ApplicationId` y export CSV.
	- Acciones por fila: `Editar` (abre `ClModal`), `Eliminar` (modal confirm, manejar conflictos).
- `application-form` → pestaña `Módulos`:
	- Multiselect/lista de módulos asignados.
	- Importante: la `application-form` debe cargar la `Application` completa mediante `ApplicationClient.getById(id, configurationName = 'ApplicationComplete')` para obtener `Application` junto con sus `ApplicationModules`, `ApplicationRoles` y `ApplicationCredentials` en una sola llamada. No se deberá depender de múltiples llamadas separadas desde la UI para poblar las colecciones de la `application-form`.
	- Botón `Crear módulo` abre modal global; al guardar, el flujo esperado es:
		1. Preferir crear el módulo por la API administrativa (`ApplicationModuleClient.insert`) cuando se gestiona módulos globales.
		2. Para la edición/guardado del formulario de `Application` completo, usar `ApplicationClient.update(applicationView, { configurationName: 'ApplicationComplete' })` que incluya la colección `ApplicationModules` y deje que el backend orqueste insert/update/delete en una sola transacción.
	- Soportar búsqueda e incorporación rápida de módulos (en modal) pero sincronizar siempre con la `ApplicationClient` en la operación de guardado de la `application-form`.

## CONTRATO BACKEND (CLIENTS NSWAG)
- `ApplicationModuleClient.getAllKendoFilter(filter)` → `FilterResult<ApplicationModuleView>`
- `ApplicationModuleClient.getById(id)` → `ApplicationModuleView`
- `ApplicationModuleClient.insert(view)` → `ApplicationModuleView`
- `ApplicationModuleClient.update(view)` → `ApplicationModuleView`
- `ApplicationModuleClient.deleteById(id)` → `void` or `ProblemDetails` on conflict
- `ApplicationClient.getById(id, configurationName = 'ApplicationComplete')` → `ApplicationView` con `ApplicationModules`
 - `ApplicationClient.getById(id, configurationName = 'ApplicationComplete')` → `ApplicationView` con `ApplicationModules`, `ApplicationRoles`, `ApplicationCredentials`

Headers: `Authorization`, `Accept-Language`, `X-Correlation-Id` (usar `CorrelationService` si disponible).

## EJEMPLOS DE IMPLEMENTACIÓN (TypeScript)
Service wrapper (minimal):

```typescript
import { inject } from '@angular/core';
import { ApplicationModuleClient } from 'src/webServicesReferences/api';
import { CorrelationService } from 'src/app/core/correlation.service';

const api = inject(ApplicationModuleClient);
const correlation = inject(CorrelationService);

function createModule(view: any) {
	const corr = correlation?.get() ?? '';
	return api.insert(view, { headers: { 'X-Correlation-Id': corr } } as any);
}

function deleteModule(id: number) {
	const corr = correlation?.get() ?? '';
	return api.deleteById(id, { headers: { 'X-Correlation-Id': corr } } as any);
}
```

Grid action (snippet):

```typescript
onCreateModule() {
	const modal = this.clModalService.open(ModuleFormComponent, { width: '600px' });
	modal.afterClosed().subscribe(result => {
		if (!result) return;
		this.modulesService.createModule(result).subscribe(() => this.loadGrid());
	});
}

onDeleteModule(row) {
	const corr = this.correlation.get();
	this.modulesService.deleteModule(row.id).subscribe({
		next: () => this.loadGrid(),
		error: err => this.handleDeleteError(err)
	});
}
```

## UX / MENSAJERÍA
- Modal de confirmación con lista de aplicaciones afectadas cuando el backend devuelve conflicto (409).
- Toast en operaciones exitosas y `ProblemDetails` mappeado para errores.

## CASOS DE BORDE
- Eliminación con dependencias → mostrar listado y bloquear hasta desasignación.
- Duplicidad de `Key` → mostrar validación de formulario.

## TESTS RECOMENDADOS
- Unit tests (Jasmine):
	- `modules-management` muestra toolbar y acciones según permisos (mock `AccessService`).
	- Crear módulo invoca `ApplicationModuleClient.insert` y refresca grid.
	- Manejo de error 409 muestra modal con aplicaciones afectadas.

## CRITERIOS DE ACEPTACIÓN
- [ ] `modules-management` CRUD completo con tests unitarios.
- [ ] `application-form` pestaña Módulos permite asignar y crear módulos in-place.
- [ ] `X-Correlation-Id` incluido en peticiones mutantes.

## CHECKLIST PR
- [ ] Nuevo componente `modules-management` y `ModuleFormComponent`.
- [ ] Wrapper `modules.service.ts` que use `ApplicationModuleClient`.
- [ ] Tests unitarios añadidos y pasan.

***
```
