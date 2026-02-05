```markdown
# APL005-T001-BE: Backend — CRUD ApplicationRole y gestión de permisos

**TICKET ID:** APL005-T001-BE
**EPIC:** Administración de Aplicaciones
**COMPONENT:** Backend - Helix6 (.NET 8)
**PRIORITY:** Media
**ESTIMATION:** 2 días

## OBJETIVO
Implementar repositorio y servicio para `ApplicationRole` permitiendo CRUD, asignación de permisos y export/import básico.

## DATAMODEL / ENTIDADES
- `ApplicationRole` view ya existente en `Entities` (ver Helix Generator). Si falta, añadir `ApplicationRole` en `DataModel` con auditoría.

## REPOSITORIO
- `IApplicationRoleRepository : IBaseRepository<ApplicationRole>` con métodos para obtener roles por `ApplicationId` y para export.

## SERVICE — `ApplicationRoleService`
- `ValidateView`: validar `Name` y `Key`, y que los permisos existan en catálogo.
- `PreviousActions`: al eliminar, comprobar referencias (usuarios/assignaciones) y bloquear si existen.
- `PostActions`: publicar evento `ApplicationRoleChanged` y manejar import mappings.

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

***
```
