#### US-004: Listar organizaciones con filtros y paginación

**Épica:** Gestión del Portfolio de Organizaciones Clientes
**Rol:** OrganizationManager
**Prioridad:** Media | **Estimación:** 5 Story Points

**Historia:**
```
Como OrganizationManager que gestiona cientos de organizaciones clientes,
quiero visualizar el listado de organizaciones con opciones de filtrado (por nombre, estado, grupo) y paginación,
para encontrar rápidamente la organización que busco sin tener que desplazarme por listas interminables.
```

**Criterios de aceptación:**
- Kendo Grid con columnas: SecurityCompanyId, Nombre, CIF, Email, Teléfono, Grupo, Nº Apps, Nº Módulos, Acciones
- Filtros: Nombre, Estado, Grupo, Aplicación accesible, Sin módulos asignados
- Paginación server-side y ordenación multi-columna
- Acciones contextual Dar de alta/baja con modales

**Dependencias:** US-001

**Notas técnicas:**
- Usar VW_ORGANIZATION con campos calculados `ModuleCount` y `AppCount`
- Query params en URL para estado de filtros
