#### US-017: Asignar módulos a organización

**Épica:** Configuración de Módulos y Permisos de Acceso
**Rol:** ApplicationManager
**Prioridad:** Alta | **Estimación:** 5 Story Points

**Historia:**
```
Como ApplicationManager responsable de configurar permisos,
quiero asignar módulos específicos de una aplicación a una organización cliente,
para que sus usuarios solo puedan acceder a las funcionalidades que han contratado.
```

**Criterios de aceptación:**
- Checklist de módulos por aplicación en detalle de organización
- Crear/eliminar registros en `MODULE_ACCESS` (soft delete para revocar)
- Publicar `OrganizationEvent` con `Apps` y `AccessibleModules`
- Apps satélite respetan permisos sin consultar InfoportOneAdmon

**Dependencias:** US-001, US-016

**Notas técnicas:**
- Soft delete en `MODULE_ACCESS` con `AuditDeletionDate`
- Evento incluye solo módulos activos
