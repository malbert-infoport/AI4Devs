# APL005 - Gestionar Roles de Aplicación

**ID:** APL005
**EPIC:** Administración de Aplicaciones

**RESUMEN:** CRUD de roles específicos de cada aplicación, con asignación de permisos y export/import básico.

## Objetivos
- CRUD de `ApplicationRole` (Name, Key, Description, Permissions[]).
- Asignación de permisos (lista de permisos disponibles por aplicación y global).
- Opcional: Importar roles desde plantilla o CSV.

## Prioridad
Media — Estimación 1.5 días

## Contrato Backend
- `ApplicationRoleClient` CRUD endpoints y `GetAllKendoFilter` para grid.

## UI
- `application-roles` componente con `ClGrid` y `ClModal` para create/edit.
- En `application-form` pestaña Roles mostrar roles asignados y permitir añadir desde global o crear nuevo.

## Tests
- Unit: create/edit/delete role, assign permissions.

***
