#### US-003: Dar de baja organización manualmente (kill-switch)

**Épica:** Gestión del Portfolio de Organizaciones Clientes
**Rol:** SecurityManager
**Prioridad:** Alta | **Estimación:** 2 Story Points

**Historia:**
```
Como SecurityManager,
quiero dar de baja inmediatamente una organización cliente sin eliminar su información,
para bloquear su acceso a todas las aplicaciones del ecosistema en caso de impago, incidencia de seguridad o fin de contrato.
```

**Criterios de aceptación:**
- Modal de confirmación desde ficha o grid
- Establecer `AuditDeletionDate`, publicar `OrganizationEvent` con `IsDeleted:true`, y registrar `AuditLog` Action="OrganizationDeactivatedManual" con UserId
- No eliminar físicamente el registro (soft delete)

**Dependencias:** US-001

**Notas técnicas:**
- Usar DeleteUndeleteLogicById de Helix6 para grid
- NO usar DELETE físico
