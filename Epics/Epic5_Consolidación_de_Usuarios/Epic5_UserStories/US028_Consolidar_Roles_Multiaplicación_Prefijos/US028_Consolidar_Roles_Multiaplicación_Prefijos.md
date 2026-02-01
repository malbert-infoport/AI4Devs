#### US-028: Consolidar roles multi-aplicación con prefijos

**Épica:** Sincronización y Consolidación de Usuarios Multi-Organización
**Rol:** Sistema (Background Worker)
**Prioridad:** Alta | **Estimación:** 8 Story Points

**Historia:**
```
Como el Background Worker,
quiero consolidar todos los roles asignados a un usuario desde todas las aplicaciones del ecosistema,
para que su token JWT incluya roles únicos con prefijos que identifiquen la aplicación de origen.
```

**Criterios de aceptación:**
- Fusionar roles de distintas apps con prefijos, eliminar duplicados
- Almacenar en `ConsolidatedRoles` en caché

**Notas técnicas:**
- Usar HashSet para eliminar duplicados
- Validar prefijos correctos
