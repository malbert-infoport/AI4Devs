#### US-011: Definir prefijo único de aplicación

**Épica:** Administración de Aplicaciones del Ecosistema
**Rol:** ApplicationManager
**Prioridad:** Alta | **Estimación:** 2 Story Points

**Historia:**
```
Como ApplicationManager,
quiero asignar un prefijo único a cada aplicación (ej: "CRM", "STP", "BI"),
para establecer una nomenclatura consistente de roles y módulos que evite conflictos de nombres entre aplicaciones.
```

**Criterios de aceptación:**
- Campo `RolePrefix` obligatorio, 2-5 letras mayúsculas, único
- Validación regex `^[A-Z]{2,5}$`
- Prefijo inmutable una vez creado
- Validación de nomenclatura de roles y módulos usando el prefijo

**Dependencias:** US-009, US-010

**Notas técnicas:**
- Índice único en `RolePrefix` en BD
