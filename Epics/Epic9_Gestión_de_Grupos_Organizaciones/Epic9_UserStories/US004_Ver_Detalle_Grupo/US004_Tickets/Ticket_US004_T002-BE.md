# TASK-002-BE: GetById para OrganizationGroup con Organizations read-only

=============================================================
**TICKET ID:** TASK-002-BE  
**EPIC:** Gestión de Grupos de Organizaciones  
**USER STORY:** US-004 - Ver Detalle Grupo de Organizaciones  
**COMPONENT:** Backend - Helix6  
**PRIORITY:** Alta  
**ESTIMATION:** 6 horas  
=============================================================

## DESCRIPCIÓN
Configurar `HelixEntities.xml` con `GroupBasicWithOrganizationsReadOnly` y asegurar que `GetById` devuelva:
- `General`: campos básicos del grupo
- `Organizations[]`: lista de organizaciones con campos resumen (read-only)
- `AuditLog` / auditoría (read-only)

CRITERIOS
- [ ] `GetById` devuelve payload conforme a `GroupBasicWithOrganizationsReadOnly`
- [ ] Documentación de la LoadConfiguration añadida en ticket
- [ ] Tests unitarios y de integración

ARCHIVOS A MODIFICAR
- `backend/Helix/HelixEntities.xml` — añadir `GroupBasicWithOrganizationsReadOnly`
- `backend/Services/OrganizationGroupService.cs` — mapping y permisos
