```markdown
```markdown
# APL005-T002-BE: Backend — CRUD ApplicationRole y gestión de permisos

**TICKET ID:** APL005-T002-BE
**EPIC:** Administración de Aplicaciones
**COMPONENT:** Backend - Helix6 (.NET 8)
**PRIORITY:** Media
**ESTIMATION:** 2 días

## OBJETIVO
Implementar repositorio y servicio para `ApplicationRole` permitiendo CRUD, asignación de permisos y export/import básico.

Importante (configuración de carga completa): las vistas y flujos que gestionan una `Application` completa deben usar un único `GetById` sobre `Application` que incluya `Roles` (junto a `Modules` y `Credentials`). Las operaciones de inserción/actualización que editen la `Application` completa se realizarán como una única operación sobre `Application` (con colecciones de `Roles` incluidas) gestionada por `ApplicationService` en una transacción atómica.

## DATAMODEL / ENTIDADES
- `ApplicationRole` view ya existente en `Entities` (ver Helix Generator). Si falta, añadir `ApplicationRole` en `DataModel` con auditoría.

## REPOSITORIO
- `IApplicationRoleRepository : IBaseRepository<ApplicationRole>` con métodos para obtener roles por `ApplicationId` y para export.
- Nota: Aunque el repositorio puede exponer consultas por `ApplicationId`, la respuesta completa para edición/visualización de la aplicación se debe orquestar desde `IApplicationRepository`/`ApplicationService` para cumplir la regla de carga completa.

## SERVICE — `ApplicationRoleService`
- `ValidateView`: validar `Name` y `Key`, y que los permisos existan en catálogo.
- `PreviousActions`: al eliminar, comprobar referencias (usuarios/assignaciones) y bloquear si existen.
- `PostActions`: publicar evento `ApplicationRoleChanged` y manejar import mappings.

Orquestación por `ApplicationService`:
- `ApplicationService` debe soportar `GetById` con configuración de carga que incluya `Roles`. Para operaciones de edición completa, `ApplicationService` recibirá el `ApplicationView` completo con la colección `Roles` y aplicará inserciones/updates/deletes de `ApplicationRole` internamente en una sola transacción.

## ENDPOINTS / CONTRATO
- Endpoints estándar generados por Helix: `GetAllKendoFilter`, `GetById`, `Insert`, `Update`, `DeleteById`.
- Endpoint adicional opcional para import CSV (`POST /api/ApplicationRole/Import`).

## MIGRACIONES / COMANDOS
- Crear migración solo si se añade entidad en DataModel.

## TESTS
- Services.Tests: ValidateView y deletion guard.
- Data.Tests: repositorio export/import scenarios.

## CRITERIOS DE ACEPTACIÓN
- [ ] CRUD roles implementado y endpoints generados.
- [ ] Selector de permisos soportado y tests añadidos.

```
```
