#### US-007: Asignar organizaciones a un grupo

**Épica:** Gestión del Portfolio de Organizaciones Clientes
**Rol:** OrganizationManager
**Prioridad:** Media | **Estimación:** 2 Story Points

**Historia:**
```
Como OrganizationManager,
quiero asignar (o reasignar) una organización a un grupo específico,
para reflejar la estructura empresarial real de holdings o consorcios en el sistema.
```

**Criterios de aceptación:**
- Dropdown en detalle de org para seleccionar grupo
- Opción "Sin grupo"
- Publicar `OrganizationEvent` con nuevo `GroupId` al cambiar

**Dependencias:** US-001, US-002
