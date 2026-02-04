````markdown
#### US-802: Auditar activación/desactivación de organizaciones

**Épica:** Auditoría de Cambios Críticos
**Rol:** SecurityManager
**Prioridad:** Alta | **Estimación:** 2 Story Points

**Historia:**
```
Como SecurityManager,
quiero que las bajas y altas (manuales y automáticas) de organizaciones generen registros de auditoría claros,
para poder trazar quién (o el sistema) desactivó o reactivó una organización.
```

**Contexto adicional:**

Registrar acciones `OrganizationDeactivatedManual`, `OrganizationAutoDeactivated`, `OrganizationReactivatedManual` con `UserId` o `NULL` según origen.

**Criterios de aceptación:**

- Al ejecutar una baja manual, se registra `OrganizationDeactivatedManual` con `UserId`.
- Cuando la auto-baja se aplica por sistema, se registra `OrganizationAutoDeactivated` con `UserId=NULL`.
- Al reactivar manualmente, se registra `OrganizationReactivatedManual` con `UserId`.
- Tests que validen persistencia y semántica de `UserId`.

**Requisitos no funcionales:**

- Registro debe incluir `CorrelationId` para trazabilidad en operaciones compuestas.

**Definición de hecho (DoD):**

- Hooks en los flujos de baja/alta que llaman a `IAuditLogService`.
- Tests unitarios e integración pasados.

**Dependencias:** US-003, US-003v2

**Notas técnicas:**

- Asegurarse de que `AuditDeletionDate` y la entrada de `AUDIT_LOG` se mantengan consistentes; UserId NULL para acciones del sistema.

````
