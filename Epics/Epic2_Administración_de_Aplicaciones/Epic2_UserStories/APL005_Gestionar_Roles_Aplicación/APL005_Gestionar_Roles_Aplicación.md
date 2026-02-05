# APL005 - Gestionar Roles de Aplicación

**ID:** APL005
**EPIC:** Administración de Aplicaciones

**RESUMEN:** Proveer interfaz para administrar `ApplicationRole` a nivel de aplicación (CRUD), definir permisos por role y permitir asignación/importación mínima. Debe integrarse con `application-form` y garantizar trazabilidad y tests.

## Objetivos
- CRUD de `ApplicationRole` (Name, Key, Description, Permissions[]).
- Selector de permisos reutilizable (permiso global vs permisos específicos por aplicación).
- Import/Export CSV básico para plantillas de roles.

## Prioridad
Media — Estimación 1.5 días

## Contrato Backend
- `ApplicationRoleClient.getAllKendoFilter(filter)` → `FilterResult<ApplicationRoleView>`
- `ApplicationRoleClient.getById(id)` → `ApplicationRoleView`
- `ApplicationRoleClient.insert(view)` → `ApplicationRoleView`
- `ApplicationRoleClient.update(view)` → `ApplicationRoleView`
- `ApplicationRoleClient.deleteById(id)` → `void` or `ProblemDetails` on conflict

## UI
- `application-roles` componente (ruta/diálogo) con `ClGrid` y `ClModal` para create/edit. Columnas: `Name`, `Key`, `Permissions (summary)`, `Actions`.
- `application-form` → pestaña `Roles`: lista de roles asignados, botón `Añadir rol` que abre selector global/creación rápida.

## Tests
- Unit: create/edit/delete role, permisos asignados correctamente, import CSV mínima.

***
