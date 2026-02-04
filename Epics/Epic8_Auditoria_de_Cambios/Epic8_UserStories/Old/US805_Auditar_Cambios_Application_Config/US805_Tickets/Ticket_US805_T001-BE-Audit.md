```markdown
# TASK-US805-BE-AUDIT: Auditar cambios en configuración de Applications

=============================================================
**TICKET ID:** TASK-US805-BE-AUDIT  
**EPIC:** Auditoría de Cambios Críticos  
**USER STORY:** US-805 - Auditar cambios críticos en Applications  
**COMPONENT:** Backend - Service Integration  
**PRIORITY:** Media  
**ESTIMATION:** 3 horas  
=============================================================

## TÍTULO
Registrar `ApplicationConfigChanged` en `AUDIT_LOG` al modificar configuración crítica de aplicaciones.

## DESCRIPCIÓN
Instrumentar modificaciones en configuración de aplicaciones para generar entradas de auditoría con metadatos (campo, referencia de ID) sin valores sensibles.

## CRITERIOS TÉCNICOS
- `ApplicationConfigChanged` persistido en `AUDIT_LOG` con UserId y CorrelationId.
- No incluir credenciales ni secretos en el registro.
- Tests unitarios e integración que comprueben persistencia.

```
