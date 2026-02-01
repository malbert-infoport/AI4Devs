#### US-002: Editar información de organización existente

**Épica:** Gestión del Portfolio de Organizaciones Clientes
**Rol:** OrganizationManager
**Prioridad:** Alta | **Estimación:** 3 Story Points

**Historia:**
```
Como OrganizationManager responsable de mantener datos actualizados de clientes,
quiero modificar los datos básicos de una organización existente (nombre, dirección, contacto, grupo) desde la pestaña "Datos de Organización",
para garantizar que la información del ecosistema esté actualizada, mientras que un ApplicationManager gestiona de forma independiente los módulos y permisos desde otra pestaña.
```

**Criterios de aceptación:**
- Edición de campos básicos con validaciones
- `SecurityCompanyId` no editable
- Cambios en datos básicos NO publican `OrganizationEvent` ni `AuditLog`
- Cambio de `GroupId` SÍ publica `OrganizationEvent` si `ModuleCount > 0` y registra `AuditLog` Action="GroupChanged"
- Pestaña Módulos manejada por ApplicationManager (solo lectura para OrganizationManager)
- Auto-baja si se remueven todos los módulos (modal de confirmación, `AuditDeletionDate` y `OrganizationAutoDeactivated`)

**Dependencias:** US-001
