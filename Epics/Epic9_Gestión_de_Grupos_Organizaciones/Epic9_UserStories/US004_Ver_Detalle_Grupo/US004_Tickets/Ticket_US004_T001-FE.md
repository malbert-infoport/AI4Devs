# TASK-001-FE: Ficha detalle Grupo (General / Organizaciones read-only / Auditoría)

=============================================================
**TICKET ID:** TASK-001-FE  
**EPIC:** Gestión de Grupos de Organizaciones  
**USER STORY:** US-004 - Ver Detalle Grupo de Organizaciones  
**COMPONENT:** Frontend - Angular  
**PRIORITY:** Alta  
**ESTIMATION:** 5 horas  
=============================================================

## DESCRIPCIÓN
Implementar componente `organization-group-detail` con pestañas: General (editable según rol), Organizaciones (lista read-only), Auditoría (read-only). Al abrir la ficha se invoca `organizationGroupService.getById(id)`.

CRITERIOS
- [ ] Pestañas implementadas y datos mostrados correctamente
- [ ] Organizaciones listadas en modo solo lectura
- [ ] Auditoría mostrada en tab read-only
