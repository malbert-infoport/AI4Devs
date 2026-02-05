#### US-026: Detectar usuarios duplicados por email

**Épica:** Sincronización y Consolidación de Usuarios Multi-Organización
**Rol:** Sistema (Background Worker)
**Prioridad:** Alta | **Estimación:** 5 Story Points

**Historia:**
```
Como el Background Worker,
quiero detectar automáticamente cuando un usuario ya existe en otra organización (por email duplicado),
para iniciar el proceso de consolidación multi-organización en lugar de crear cuentas separadas.
```

**Criterios de aceptación:**
- Buscar en `UserConsolidationCache` por email (case-insensitive)
- Crear entrada nueva si no existe, iniciar consolidación si existe
- Ventana de consolidación configurable

**Notas técnicas:**
- Índice único case-insensitive en `Email` de `UserConsolidationCache`
- Manejar race conditions con locks optimistas
