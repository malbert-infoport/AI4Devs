# APL004-T001-FE: Frontend — CRUD de Módulos y Asignación en Aplicación

**TICKET ID:** APL004-T001-FE
**EPIC:** Administración de Aplicaciones
**COMPONENT:** Frontend - Angular
**PRIORITY:** Alta
**ESTIMATION:** 1.5 días

## TÍTULO
Crear `modules-management` para CRUD de módulos y añadir integración en `application-form` para asignación.

## DESCRIPCIÓN
- `modules-management` listará módulos con `ClGrid` (Name, Key, ApplicationId, DisplayOrder) y permitirá Crear/Editar/Eliminar con `ClModal`.
- En `application-form` pestaña Módulos: multiselect para asignación, botón `Crear módulo` que abre modal global; tras crear, asigna automáticamente a la aplicación.
- Confirmación al eliminar módulo en uso: mostrar lista de aplicaciones afectadas.

## CONTRATO BACKEND
- `ApplicationModuleClient.getAllKendoFilter`, `create`, `update`, `delete`.

## UX
- Modal de crear módulo con validaciones (Name, Key unique por aplicación si aplica).

## TESTS
- Unit: flows create/edit/delete, conflict on delete if module in use.

## CRITERIOS
- [ ] CRUD módulos implementado.
- [ ] Asignación en `application-form` funcional.

***
