# APL005-T001-FE: Frontend — CRUD Roles de Aplicación y asignación de permisos

**TICKET ID:** APL005-T001-FE
**EPIC:** Administración de Aplicaciones
**COMPONENT:** Frontend - Angular
**PRIORITY:** Media
**ESTIMATION:** 1 día

## TÍTULO
Implementar `application-roles` con CRUD, selección de permisos por role y asignación dentro de `application-form`.

## DESCRIPCIÓN
- `application-roles` lista roles con `ClGrid`, `ClModal` para crear/editar y selector de permisos (checkbox list).
- Al eliminar role: comprobar uso y pedir confirmación.
- Export/import roles (CSV) opción mínima.

## CONTRATO
- `ApplicationRoleClient.getAllKendoFilter`, `create`, `update`, `delete`.

## TESTS
- Unit: permisos, crear/editar role, asignación.

## CRITERIOS
- [ ] CRUD roles implementado y testeado.

***
