=============================================================
**TICKET ID:** TASK-014-FE  
**EPIC:** Administración de Aplicaciones del Ecosistema  
**USER STORY:** US-014 - Listar catálogo de aplicaciones  
**COMPONENT:** Frontend Angular  
**PRIORITY:** Media  
**ESTIMATION:** 3 horas  
=============================================================

**TÍTULO:**
Implementar listado de aplicaciones con conteo de módulos/roles y filtros

**DESCRIPCIÓN:**
Crear página Angular que muestre el catálogo de aplicaciones con:
- Kendo Grid con columnas: Nombre, Prefijo, Nº Módulos, Nº Roles, Estado, Fecha de Registro
- Filtros por Nombre y Estado (Activa/Inactiva)
- Ordenación por columnas
- Paginación server-side mediante KendoFilter
- Clic en fila navega a detalle de aplicación
- Indicador visual de aplicaciones inactivas (soft delete)

**CONTEXTO TÉCNICO:**
- **Backend**: POST `/applications/list` con KendoFilter (automático desde Kendo Grid)
- **Kendo Grid**: Usa `kendoGridBinding` con server-side paging/filtering/sorting
- **Cálculo**: ModuleCount y RoleCount se calculan en backend con proyección
- **Estado**: Se determina por AuditDeletionDate (null = Activa, not null = Inactiva)

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] Componente ApplicationListComponent creado
- [ ] Tabla Material con columnas especificadas
- [ ] Conteo de módulos/roles calculado localmente
- [ ] Filtro por nombre funcional
- [ ] Filtro por estado funcional
- [ ] Ordenación por columnas
- [ ] Navegación a detalle al hacer clic
- [ ] Aplicaciones inactivas con estilo diferenciado

**GUÍA DE IMPLEMENTACIÓN:**
(Ver `tickets_epica2.md` TASK-014-FE para el esqueleto de servicio, componente, template y estilos sugeridos.)
