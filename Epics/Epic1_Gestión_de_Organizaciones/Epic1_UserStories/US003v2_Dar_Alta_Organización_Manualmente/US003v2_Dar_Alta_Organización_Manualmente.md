#### US-003v2: Dar de alta organización manualmente

**Épica:** Gestión del Portfolio de Organizaciones Clientes
**Rol:** SecurityManager
**Prioridad:** Media | **Estimación:** 3 Story Points

**Historia:**
```
Como SecurityManager,
quiero reactivar (dar de alta) una organización previamente dada de baja que ha regularizado su situación,
para restaurar el acceso de sus usuarios sin tener que recrear toda la configuración de módulos y permisos.
```

**Criterios de aceptación:**
- Validar `ModuleCount > 0` antes de reactivar
- Establecer `AuditDeletionDate = NULL`, publicar `OrganizationEvent` con `IsDeleted:false` y registrar `AuditLog` Action="OrganizationReactivatedManual" con UserId
- Si `ModuleCount = 0`, mostrar error y botón para ir a configuración de módulos

**Dependencias:** US-003, US-001v2
