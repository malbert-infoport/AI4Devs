#### US-022: Validar nomenclatura de roles con prefijo

**Épica:** Gobierno de Roles y Seguridad
**Avatar:** Sistema InfoportOneAdmon
**Prioridad:** Alta | **Estimación:** 3 Story Points

**Historia:**
```
Como el sistema InfoportOneAdmon,
quiero validar automáticamente que todos los roles y módulos creados sigan la nomenclatura estándar basada en el prefijo de la aplicación,
para mantener coherencia en todo el ecosistema y rechazar nombres incorrectos con mensajes de error claros.
```

**Criterios de aceptación:**
- Validación backend para roles y módulos con mensajes HTTP 400 si no cumplen el patrón
- Mensajes claros indicando el formato esperado

**Definición de hecho:**
- Validadores implementados en capa de servicio
- Tests unitarios

**Dependencias:** US-011, US-021

**Notas técnicas:**
- Usar FluentValidation y regex `^{RolePrefix}_[A-Za-z0-9]+$` para roles y `^M{RolePrefix}_[A-Za-z0-9]+$` para módulos
