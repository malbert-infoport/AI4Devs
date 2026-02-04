# TASK-002-BE: Backend Update para OrganizationGroup (Helix6)

=============================================================
**TICKET ID:** TASK-002-BE  
**EPIC:** Gestión de Grupos de Organizaciones  
**USER STORY:** US-002 - Modificar Grupo de Organizaciones  
**COMPONENT:** Backend - Helix6  
**PRIORITY:** Alta  
**ESTIMATION:** 6 horas  
=============================================================

## DESCRIPCIÓN
- Asegurar `Update` Helix6 para `OrganizationGroup` usando `GroupBasic`.
- `GetById` debe usar `GroupBasicWithOrganizationsReadOnly` para la ficha.
- Validar permisos y defender cambios no autorizados (SecurityCompanyId inmutable).

CRITERIOS
- [ ] `Update` persiste campos básicos
- [ ] `GetById` devuelve auditoría y organizations (read-only)
- [ ] Tests unitarios e integración
