#### US-020: Visualizar matriz de permisos organización-módulo

**Épica:** Configuración de Módulos y Permisos de Acceso
**Rol:** ApplicationManager
**Prioridad:** Media | **Estimación:** 5 Story Points

**Historia:**
```
Como ApplicationManager,
quiero visualizar una matriz completa que cruce organizaciones con módulos de todas las aplicaciones,
para tener una vista consolidada de qué cliente tiene acceso a qué funcionalidades y detectar inconsistencias fácilmente.
```

**Criterios de aceptación:**
- Matriz con organizaciones en filas y módulos por aplicación en columnas
- Celdas con ✓/✗, filtros por aplicación/organización/grupo, exportar a Excel
- Indicadores visuales para organizaciones inactivas

**Dependencias:** US-017

**Notas técnicas:**
- Render eficiente para 100+ organizaciones
- Exportación a Excel
