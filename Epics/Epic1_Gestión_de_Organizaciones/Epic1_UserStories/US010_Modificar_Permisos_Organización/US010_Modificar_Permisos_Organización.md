#### US-010: Modificar permisos de organización existente con auto-baja

**Épica:** Gestión del Portfolio de Organizaciones Clientes
**Rol:** ApplicationManager
**Prioridad:** Alta | **Estimación:** 5 Story Points

**Historia:**
```
Como ApplicationManager,
quiero añadir o remover módulos de una organización existente,
para ajustar dinámicamente los permisos según los cambios en el contrato, con advertencia clara si la eliminación de todos los módulos causará auto-baja de la organización.
```

**Criterios de aceptación:**
- Añadir módulos: insert en `MODULE_ACCESS`, `AuditLog` Action="ModuleAssigned", publicar `OrganizationEvent`.
- Remover módulos: soft delete en `MODULE_ACCESS`, `AuditLog` Action="ModuleRemoved", publicar `OrganizationEvent`.
- Si se remueven todos los módulos: mostrar modal crítico y, tras confirmación, establecer `AuditDeletionDate` en la organización, registrar `OrganizationAutoDeactivated` y publicar evento con `IsDeleted:true`.

**Dependencias:** US-002, US-009

**Notas técnicas:**
- Auto-baja aplica solo a organizaciones existentes (Id > 0).
- Organizaciones nuevas sin módulos no sufren auto-baja.
