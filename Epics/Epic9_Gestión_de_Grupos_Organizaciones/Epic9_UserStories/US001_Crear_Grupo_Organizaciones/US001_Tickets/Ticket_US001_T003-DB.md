# TASK-003-DB: Migración tabla OrganizationGroup

=============================================================
**TICKET ID:** TASK-003-DB  
**EPIC:** Gestión de Grupos de Organizaciones  
**USER STORY:** US-001 - Crear Grupo de Organizaciones  
**COMPONENT:** Base de Datos  
**PRIORITY:** Alta  
**ESTIMATION:** 3 horas  
=============================================================

## TÍTULO
Crear tabla `OrganizationGroup` con columnas básicas y auditoría

## DESCRIPCIÓN
Crear migración EF Core / SQL para `OrganizationGroup` con columnas mínimas: Id (PK), SecurityCompanyId, Name, Description, AuditCreatedAt, AuditCreatedBy, AuditUpdatedAt, AuditUpdatedBy, AuditDeletionDate.

ENTREGABLES
- `Migrations/2026xxxx_Create_OrganizationGroup_Table.*`
- Documentación de despliegue y pruebas de migración

CRITERIOS
- [ ] Tabla creada correctamente en entorno local de pruebas
- [ ] FK/índices definidos si aplica
