```markdown
# APL005-T001-FE: Frontend — CRUD Roles de Aplicación y asignación de permisos

**TICKET ID:** APL005-T001-FE
**EPIC:** Administración de Aplicaciones
**COMPONENT:** Frontend - Angular (SintraportV4.Front)
**PRIORITY:** Media
**ESTIMATION:** 1 día

## TÍTULO
Crear `application-roles` para gestionar roles por aplicación y un selector de permisos reutilizable.

## OBJETIVO
Permitir definir roles por aplicación con un conjunto de permisos y asignarlos desde `application-form`.

## DESCRIPCIÓN DETALLADA
- `application-roles` componente con `ClGrid` mostrando `Name`, `Key`, `PermissionsSummary`, `Actions`.
	- `ClModal` para creación/edición: campos `Name`, `Key`, `Description` y checklist de permisos (grupos y permisos individuales).
	- Export/Import CSV mínimo: exportar la lista de roles; import validado en frontend (preview antes de aplicar).
- `application-form` → pestaña `Roles`: lista roles asignados y botón `Añadir rol` que abre selector global y opción para crear nuevo.

Nota de integración con `application-form`:
- La `application-form` deberá cargar la `Application` completa usando `ApplicationClient.getById(id, configurationName = 'ApplicationComplete')`, que incluye las colecciones `ApplicationRoles`, `ApplicationModules` y `ApplicationCredentials` en una sola llamada. Para guardar cambios que afectan a roles asignados dentro del formulario, la UI debe enviar el `ApplicationView` completo a `ApplicationClient.update`/`insert` con la configuración de carga completa y dejar que el backend orqueste las inserciones/actualizaciones/eliminaciones de `ApplicationRole` en una transacción atómica.
- Los endpoints `ApplicationRoleClient.*` siguen disponibles para uso administrativo (listados globales, import/export), pero no deberán usarse como fuente primaria para poblar las colecciones dentro de `application-form` en el flujo de edición completa.

## CONTRATO BACKEND
- `ApplicationRoleClient.getAllKendoFilter(filter)`
- `ApplicationRoleClient.getById(id)`
- `ApplicationRoleClient.insert(view)`
- `ApplicationRoleClient.update(view)`
- `ApplicationRoleClient.deleteById(id)`

Headers: `Authorization`, `Accept-Language`, `X-Correlation-Id`.

## EJEMPLO DE IMPLEMENTACIÓN (TS)
Selector de permisos (snippet):

```typescript
import { inject } from '@angular/core';
import { ApplicationRoleClient } from 'src/webServicesReferences/api';
const api = inject(ApplicationRoleClient);

async function loadRoles(filter) {
	return api.getAllKendoFilter(filter).toPromise();
}
```

## TESTS RECOMENDADOS
- Unit: mostrar/ocultar acciones según permisos, crear/editar role invoca client, import preview valida CSV.

## CRITERIOS DE ACEPTACIÓN
- [ ] CRUD roles implementado y testeado.
- [ ] Selector de permisos reutilizable y usado en `application-form`.

***
```
