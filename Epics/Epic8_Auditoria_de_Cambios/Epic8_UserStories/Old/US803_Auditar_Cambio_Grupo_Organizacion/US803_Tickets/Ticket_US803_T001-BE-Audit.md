```markdown
# TASK-US803-BE-AUDIT: Registrar GroupChanged en AUDIT_LOG

=============================================================
**TICKET ID:** TASK-US803-BE-AUDIT  
**EPIC:** Auditoría de Cambios Críticos  
**USER STORY:** US-803 - Auditar cambios de grupo de organización  
**COMPONENT:** Backend - Service Integration  
**PRIORITY:** Alta  
**ESTIMATION:** 3 horas  
=============================================================

## TÍTULO
Instrumentar el flujo de cambio de grupo para crear registros `GroupChanged` en `AUDIT_LOG`.

## DESCRIPCIÓN
Al cambiar la propiedad de grupo de una organización, crear entrada `GroupChanged` con `UserId`, `EntityId` y `CorrelationId`.

## CRITERIOS TÉCNICOS
- `GroupChanged` persistido en `AUDIT_LOG` con datos correctos.
- Tests unitarios e integración que verifiquen persistencia.

```
