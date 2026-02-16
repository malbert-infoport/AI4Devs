#### AUD001: Auditoría — Organización

**Épica:** Auditoría de Cambios Críticos
**Rol:** Organization Manager
**Prioridad:** Alta | **Estimación:** 3 Story Points

**Historia:**
Como SecurityManager u OrganizationManager,
quiero que los cambios críticos en las organizaciones queden registrados en el sistema de auditoría,
para poder investigar quién realizó cambios que afectan permisos, accesos o el estado de la organización.

## Acciones que desencadenan la auditoría (mínimo)
- `ModuleAssigned` — asignación de módulo/aplicación a una organización
- `ModuleRemoved` — removido de módulo/aplicación
- `OrganizationDeactivatedManual` — baja manual iniciada por usuario
- `OrganizationAutoDeactivated` — baja automática por reglas del sistema
- `OrganizationReactivatedManual` — reactivación manual
- `GroupChanged` — cambio de `GroupId` o `GroupName`

## Publisher / Quién publica
- `OrganizationService` y `OrganizationModuleService` del backend deben publicar registros de auditoría mediante `IAuditLogService.LogAsync(AuditEntry)` en los hooks `PreviousActions` / `PostActions` apropiados.

## Subscribers / Procesamiento
- Consumers internos: `AuditQueryService` para investigación y `AuditRetentionJob` para políticas de retención. El procesamiento consiste en persistir `AUDIT_LOG` con campos mínimos (Action, EntityType="Organization", EntityId, UserId?, CorrelationId?, Timestamp, Details).

## Criterios de Aceptación
- [ ] Cada acción listada crea una entrada en `AUDIT_LOG` con `Action` exacto.
- [ ] `UserId` poblado para acciones iniciadas por usuario; `NULL` si originada por sistema.
- [ ] `CorrelationId` incluido cuando aplica.
- [ ] Tests unitarios e integración que verifiquen la persistencia y contenido.
