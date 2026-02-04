````markdown
#### US-801: Auditar cambios críticos en la Organización

**Épica:** Auditoría de Cambios Críticos
**Rol:** SecurityManager / OrganizationManager
**Prioridad:** Alta | **Estimación:** 3 Story Points

**Historia:**
```
Como SecurityManager u OrganizationManager,
quiero que los cambios críticos en el mantenimiento de una organización queden registrados en el sistema de auditoría,
para poder investigar quién realizó cambios que afectan permisos, accesos o el estado de la organización.
```

**Contexto adicional:**

Se auditarán las siguientes acciones críticas (filosofía de auditoría selectiva):
1. `ModuleAssigned` - Se asignó un módulo/aplicación 
2. `ModuleRemoved` - Se removió un módulo/aplicación 
3. `OrganizationDeactivatedManual` - Baja manual por SecurityManager 
4. `OrganizationAutoDeactivated` - Baja automática por sistema 
5. `OrganizationReactivatedManual` - Alta manual por SecurityManager 
6. `GroupChanged` - Cambió el grupo de la organización 

**Criterios de aceptación:**

- Para cada acción crítica listada se crea una entrada en `AUDIT_LOG` con `Action` apropiado.
- `EntityType` = "Organization" y `EntityId` = id de la organización afectada.
- `UserId` debe estar poblado para acciones iniciadas por usuario.
- `CorrelationId` incluido cuando la operación forma parte de un flujo compuesto (p.ej. asignación masiva de módulos).
- Tests unitarios y de integración que verifiquen persistencia y contenidos mínimos de la entrada.

**Requisitos no funcionales:**

- Latencia adicional por logging < 200ms en operaciones vía servicio.
- Índices en `AUDIT_LOG` para consultas por `EntityType`+`EntityId` y por `Timestamp`.

**Definición de hecho (DoD):**

- Hooks/instrumentación en los puntos de mantenimiento (asignación/remoción de módulos, baja/alta, cambio de grupo).
- `IAuditLogService.LogAsync` invocado con `AuditEntry` correcto.
- Tests unitarios e integración añadidos y validados.
- Documentación breve en la épica y en `Ticket_US001_T001-Audit.md`.

**Dependencias:** US-006/US-009 (flujos de asignación de módulos / creación de organización)

**Notas técnicas:**

- Usar `AuditEntry` con campos (Action, EntityType="Organization", EntityId, UserId nullable, Timestamp, CorrelationId).
- No incluir datos sensibles en los campos públicos.

````
