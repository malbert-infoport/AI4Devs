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
La `application-form` debe usar únicamente el contrato de `Application` cuando trabaje con la vista completa:

- `ApplicationClient.getById(id, configurationName = 'ApplicationComplete')` → `ApplicationView` con `ApplicationModules`, `ApplicationRoles`, `ApplicationCredentials`.
- `ApplicationClient.insert(applicationView, { configurationName: 'ApplicationComplete' })` → Insert completo.
- `ApplicationClient.update(applicationView, { configurationName: 'ApplicationComplete' })` → Update completo.

Nota: Los endpoints específicos de `ApplicationModule` pueden existir para paneles de administración independientes, pero la `application-form` debe sincronizar siempre vía `ApplicationClient`.
 - `ApplicationClient.getById(id, configurationName = 'ApplicationComplete')` → `ApplicationView` con `ApplicationModules`, `ApplicationRoles`, `ApplicationCredentials`

Headers: `Authorization`, `Accept-Language`, `X-Correlation-Id` (usar `CorrelationService` si disponible).

## EJEMPLOS DE IMPLEMENTACIÓN (TypeScript)
Service wrapper (minimal):
```typescript
import { inject } from '@angular/core';
import { ApplicationClient } from 'src/webServicesReferences/api';
import { CorrelationService } from 'src/app/core/correlation.service';

const api = inject(ApplicationClient);
const correlation = inject(CorrelationService);

function loadApplicationComplete(id: number) {
	const corr = correlation?.get() ?? '';
	return api.getById(id, 'ApplicationComplete', { headers: { 'X-Correlation-Id': corr } } as any);
}

function saveApplicationComplete(applicationView: any, isInsert = false) {
	const corr = correlation?.get() ?? '';
	if (isInsert) return api.insert(applicationView, { headers: { 'X-Correlation-Id': corr }, queryParams: { configurationName: 'ApplicationComplete' } } as any);
	return api.update(applicationView, { headers: { 'X-Correlation-Id': corr }, queryParams: { configurationName: 'ApplicationComplete' } } as any);
}
```

Grid action (snippet):

```typescript
onCreateModule() {
	const modal = this.clModalService.open(ModuleFormComponent, { width: '600px' });
	modal.afterClosed().subscribe(result => {
		if (!result) return;
		// Prefer to create via admin flow or include in ApplicationView and save full application
		// Here we trigger a full application reload to keep UI consistent
		this.loadApplication(); // will call ApplicationClient.getById(..., 'ApplicationComplete')
	});
}

onSaveApplication(applicationView) {
	const isNew = !applicationView.id;
	this.modulesService.saveApplicationComplete(applicationView, isNew).subscribe(() => this.loadApplication());
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
