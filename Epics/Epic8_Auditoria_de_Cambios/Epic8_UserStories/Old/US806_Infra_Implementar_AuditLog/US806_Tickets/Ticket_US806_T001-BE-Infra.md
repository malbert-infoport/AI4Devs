```markdown
# TASK-US806-BE-INFRA: Implementar entidad AUDIT_LOG, DTO y servicio

=============================================================
**TICKET ID:** TASK-US806-BE-INFRA  
**EPIC:** Auditoría de Cambios Críticos  
**USER STORY:** US-806 - Implementar infraestructura AUDIT_LOG y servicio IAuditLogService  
**COMPONENT:** Backend - Database / Services  
**PRIORITY:** Alta  
**ESTIMATION:** 8 horas  
=============================================================

## TÍTULO
Crear `AuditLog` entity, `AuditEntry` DTO, `IAuditLogService` y migración EF Core para `AUDIT_LOG`.

## DESCRIPCIÓN
Implementar la infraestructura de auditoría fundacional: entidad, migración, servicio e integración en DI. Añadir tests unitarios e integración.

## CRITERIOS TÉCNICOS
- `InfoportOneAdmon.DataModel/Entities/AuditLog.cs` creada con los campos requeridos.
- `AuditEntry` DTO y `IAuditLogService` implementados.
- Migración EF Core generada y verificada en entorno de pruebas.
- Tests unitarios e integración que validen insert y consultas básicas.

```
