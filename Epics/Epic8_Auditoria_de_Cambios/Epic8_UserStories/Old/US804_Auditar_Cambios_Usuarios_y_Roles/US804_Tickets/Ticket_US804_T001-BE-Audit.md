```markdown
# TASK-US804-BE-AUDIT: Auditar cambios en usuarios y roles

=============================================================
**TICKET ID:** TASK-US804-BE-AUDIT  
**EPIC:** Auditoría de Cambios Críticos  
**USER STORY:** US-804 - Auditar cambios críticos en usuarios y roles  
**COMPONENT:** Backend - Service Integration  
**PRIORITY:** Alta  
**ESTIMATION:** 4 horas  
=============================================================

## TÍTULO
Añadir hooks de auditoría en UserService/RoleService para registrar RoleAssigned/RoleRemoved y UserActivated/UserDeactivated.

## DESCRIPCIÓN
Instrumentar los métodos que modifican roles y el estado de usuarios para crear entradas en `AUDIT_LOG` con `UserId` del actor.

## CRITERIOS TÉCNICOS
- `RoleAssigned` y `RoleRemoved` registrados con UserId.
- `UserActivated`/`UserDeactivated` registrados con UserId.
- Tests unitarios e integración que verifiquen la persistencia.

```
