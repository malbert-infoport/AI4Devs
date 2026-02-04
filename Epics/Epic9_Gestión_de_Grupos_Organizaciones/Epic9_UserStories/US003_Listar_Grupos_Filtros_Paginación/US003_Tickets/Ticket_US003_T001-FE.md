# TASK-001-FE: Grid de Grupos con Kendo y acciones

=============================================================
**TICKET ID:** TASK-001-FE  
**EPIC:** Gestión de Grupos de Organizaciones  
**USER STORY:** US-003 - Listar Grupos con filtros y paginación  
**COMPONENT:** Frontend - Angular  
**PRIORITY:** Alta  
**ESTIMATION:** 5 horas  
=============================================================

## DESCRIPCIÓN
Implementar Kendo Grid que usa `PUT /api/OrganizationGroup/GetAllKendoFilter` con objeto KendoFilter en el body. Mostrar columna con Nº Organizaciones (desde vista) y acciones (editar, dar de baja/alta).

CRITERIOS
- [ ] Grid implementado y paginación server-side funcionando
- [ ] Columnas y row styling implementados
- [ ] Acciones de alta/baja usan `DeleteUndeleteLogicById` Helix6
