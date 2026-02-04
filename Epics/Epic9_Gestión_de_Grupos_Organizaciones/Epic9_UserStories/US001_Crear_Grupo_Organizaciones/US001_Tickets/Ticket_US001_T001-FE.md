# TASK-001-FE: Formulario crear Grupo de Organizaciones

=============================================================
**TICKET ID:** TASK-001-FE  
**EPIC:** Gestión de Grupos de Organizaciones  
**USER STORY:** US-001 - Crear Grupo de Organizaciones  
**COMPONENT:** Frontend - Angular  
**PRIORITY:** Alta  
**ESTIMATION:** 4 horas  
=============================================================

## TÍTULO
Implementar formulario para crear `OrganizationGroup` (Name, Description)

## DESCRIPCIÓN
Crear componente Angular `organization-group-form` con validaciones reactivas. Usar Helix6 `Insert` para persistir solo los campos básicos (`GroupBasic` configuration).

CRITERIOS DE ACEPTACIÓN
- [ ] Formulario con campos `Name` y `Description` implementado
- [ ] Validaciones (Name obligatorio, max length)
- [ ] Llamada a endpoint Helix6 `Insert` documentada y usable
- [ ] Tests unitarios FE para validaciones

ARCHIVOS A CREAR/MODIFICAR
- `src/app/modules/groups/components/organization-group-form/*`
- `src/app/modules/groups/services/organization-group.service.ts` (create)
