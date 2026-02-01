#### US-019: Revocar acceso a módulo de organización

**Épica:** Configuración de Módulos y Permisos de Acceso
**Rol:** SecurityManager
**Prioridad:** Media | **Estimación:** 2 Story Points

**Historia:**
```
Como SecurityManager,
quiero revocar inmediatamente el acceso de una organización a un módulo específico,
para bloquear funcionalidades cuando hay impago, downgrade de contrato o incidencia de seguridad.
```

**Criterios de aceptación:**
- Botón "Revocar" por módulo asignado en la matriz
- Modal de confirmación
- Soft delete en `MODULE_ACCESS` y publicar `OrganizationEvent` actualizado

**Dependencias:** US-017
