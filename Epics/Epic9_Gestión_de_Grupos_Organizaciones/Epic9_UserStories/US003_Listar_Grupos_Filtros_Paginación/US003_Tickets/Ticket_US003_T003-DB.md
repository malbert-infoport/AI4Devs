# TASK-003-DB: Vista e índices para Listado de Grupos

=============================================================
**TICKET ID:** TASK-003-DB  
**EPIC:** Gestión de Grupos de Organizaciones  
**USER STORY:** US-003 - Listar Grupos con filtros y paginación  
**COMPONENT:** Base de Datos  
**PRIORITY:** Media  
**ESTIMATION:** 3 horas  
=============================================================

## DESCRIPCIÓN
- Crear/actualizar vista `VW_ORGANIZATION_GROUP` que exponga `GroupId`, `GroupName` y `OrganizationCount` (AppCount equivalente) para el grid.
- Añadir índices para búsquedas por `Name`.

CRITERIOS
- [ ] Vista disponible y utilizada por `GetAllKendoFilter`
