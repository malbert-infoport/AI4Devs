```markdown
# TASK-US802-BE-AUDIT: Persistir audit entries en bajas/altas de organización

=============================================================
**TICKET ID:** TASK-US802-BE-AUDIT  
**EPIC:** Auditoría de Cambios Críticos  
**USER STORY:** US-802 - Auditar activación/desactivación de organizaciones  
**COMPONENT:** Backend - Service Integration  
**PRIORITY:** Alta  
**ESTIMATION:** 3 horas  
=============================================================

## TÍTULO
Registrar entradas `OrganizationDeactivatedManual`, `OrganizationAutoDeactivated` y `OrganizationReactivatedManual` en `AUDIT_LOG`.

## DESCRIPCIÓN
Instrumentar los flujos de alta/baja (manual y automático) para crear entradas de auditoría con `UserId` null cuando sea acción del sistema.

## CRITERIOS TÉCNICOS
- Se crea `OrganizationAutoDeactivated` con `UserId=NULL` cuando aplica auto-baja.
- Se crea `OrganizationDeactivatedManual` con `UserId` al hacer baja manual.
- Se crea `OrganizationReactivatedManual` con `UserId` al reactivar manualmente.
- Tests unitarios e integración que validen los registros.

```
