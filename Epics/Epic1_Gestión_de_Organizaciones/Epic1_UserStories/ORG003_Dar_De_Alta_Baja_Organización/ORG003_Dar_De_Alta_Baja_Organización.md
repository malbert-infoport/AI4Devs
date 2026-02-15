##### ORG-003: Dar de alta / baja organización manualmente (toggle manual)

**Épica:** Gestión del Portfolio de Organizaciones Clientes
**Rol:** SecurityManager
**Prioridad:** Alta | **Estimación:** 2 Story Points

**Historia:**
```
Como SecurityManager, quiero poder dar de baja o dar de alta manualmente una organización cliente usando el mismo API genérico de Helix6, para bloquear o restaurar su acceso a las aplicaciones del ecosistema con trazabilidad y auditoría.

```

**Criterios de aceptación:**
- Desde la ficha y desde la grid poder invocar la acción de baja/alta mediante un modal de confirmación.
- El backend aplicará soft-delete / restore sobre `AuditDeletionDate` mediante el endpoint genérico Helix6 `DeleteUndeleteLogicById`.
- Registrar en `AUDIT_LOG` las acciones `OrganizationDeactivatedManual` y `OrganizationReactivatedManual` con `UserId` cuando correspondan.
- No eliminar físicamente el registro (soft delete).
- La grid debe mostrar una columna fija (a la derecha) con una papelera que permita abrir el modal y ejecutar la operación.

**Dependencias:** ORG-002

**Notas técnicas:**
- Usar el endpoint genérico Helix6 `DeleteUndeleteLogicById` (entidad `Organization`).
- No crear endpoints REST específicos; la misma operación realizará baja o alta según el payload (`delete: true|false`).
- Auditar ambas acciones y propagar `CorrelationId` en logs.
