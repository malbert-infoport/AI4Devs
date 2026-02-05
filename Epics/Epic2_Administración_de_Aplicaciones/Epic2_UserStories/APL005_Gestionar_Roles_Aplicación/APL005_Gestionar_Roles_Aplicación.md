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
La `application-form` y los flujos de edición completa NO deben invocar directamente endpoints de `ApplicationRole`. En su lugar, deben usar el contrato de la entidad `Application` con la configuración de carga completa `ApplicationComplete`.

- `GET /api/Application/GetById?id={id}&configuration=ApplicationComplete` → `ApplicationView` que incluye `ApplicationRoles`.
- `POST /api/Application/Insert` / `POST /api/Application/Update` → aceptar `ApplicationView` completo con `ApplicationRoles` y aplicar insert/update/delete de manera atómica.

Notas:
- Los endpoints de `ApplicationRole` pueden existir para administración independiente, pero la `application-form` debe sincronizar mediante el `ApplicationClient`.

## UI
- `application-roles` componente (ruta/diálogo) con `ClGrid` y `ClModal` para create/edit. Columnas: `Name`, `Key`, `Permissions (summary)`, `Actions`.
- `application-form` → pestaña `Roles`: lista de roles asignados, botón `Añadir rol` que abre selector global/creación rápida.

## Tests
- Unit: create/edit/delete role, permisos asignados correctamente, import CSV mínima.

***
