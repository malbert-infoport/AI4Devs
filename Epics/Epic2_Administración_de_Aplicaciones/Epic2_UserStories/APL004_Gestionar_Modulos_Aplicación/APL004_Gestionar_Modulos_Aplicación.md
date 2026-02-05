# APL004 - Gestionar Módulos de Aplicación (CRUD y asignación)

**ID:** APL004
**EPIC:** Administración de Aplicaciones

**RESUMEN:** Permitir crear/editar/eliminar módulos globales y asignarlos a aplicaciones. Diferencia clave respecto a ORG004: aquí se permite CRUD de módulos desde UI.

## Objetivos
- CRUD de `ApplicationModule` (Name, Key, Description, DisplayOrder, ApplicationId).
- Asignación por aplicación mediante `Application.ApplicationModules` (N:M si aplica).
- Validaciones y confirmaciones al eliminar módulos que están en uso.

## Prioridad
Alta — Estimación 2 días

## Contrato Backend
- `ApplicationModuleClient` con endpoints CRUD y `GetAllKendoFilter('ModuleList')`.
- `ApplicationClient` con `GetById('ApplicationComplete')` que incluye `ApplicationModules`.

## UI
- Componente global `modules-management` con `ClGrid` para módulos (crear/editar/eliminar) y `ClModal` para formularios de módulo.
- En `application-form` pestaña Módulos permitir asignar módulos existentes o crear uno nuevo (abrir modal global y al guardar asignarlo a la aplicación).

## Tests
- Unit: crear/editar/eliminar módulo, asignación a aplicación.

***
