#### US-016: Definir módulos funcionales de una aplicación

**Épica:** Configuración de Módulos y Permisos de Acceso
**Rol:** ApplicationManager
**Prioridad:** Alta | **Estimación:** 5 Story Points

**Historia:**
```
Como ApplicationManager,
quiero definir los módulos funcionales de una aplicación usando la nomenclatura "M + Prefijo + Nombre" (ej: MCRM_Facturacion),
para establecer el catálogo de funcionalidades que se pueden vender y activar de forma granular por cliente.
```

**Criterios de aceptación:**
- Formulario "Agregar módulo" con Nombre, Descripción, DisplayOrder
- Nombre debe seguir `M{RolePrefix}_{Nombre}`
- Validación unicidad por aplicación
- Al menos un módulo por aplicación
- Actualizar `ApplicationEvent` con lista de módulos

**Dependencias:** US-009

**Notas técnicas:**
- Tabla `MODULE` con FK `ApplicationId`
- Índice único en (`ApplicationId`, `ModuleName`)
