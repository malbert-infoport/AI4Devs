# TASK-002-BE: GetAllKendoFilter para OrganizationGroup

=============================================================
**TICKET ID:** TASK-002-BE  
**EPIC:** Gestión de Grupos de Organizaciones  
**USER STORY:** US-003 - Listar Grupos con filtros y paginación  
**COMPONENT:** Backend - Helix6 / Servicios  
**PRIORITY:** Alta  
**ESTIMATION:** 6 horas  
=============================================================

## DESCRIPCIÓN
Exponer/generated endpoint Helix6 `GetAllKendoFilter` para `OrganizationGroup` (PUT con objeto KendoFilter). Backend se encargará de paginación/orden/filtrado y devolverá `Nº Organizaciones` desde vista/consulta.

CRITERIOS
- [ ] Endpoint `GetAllKendoFilter` disponible y responde con `data` y `total`
- [ ] Tests de integración que validen filtros y paginación

ARCHIVOS
- `backend/Services/OrganizationGroupService.cs`
- `backend/Endpoints/OrganizationGroup/GetAllKendoFilter` (generado)
