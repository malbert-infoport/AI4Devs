````markdown
#### US-801: Auditar asignación/remoción de módulos a una organización

**Épica:** Auditoría de Cambios Críticos
**Rol:** ApplicationManager / SecurityManager
**Prioridad:** Alta | **Estimación:** 3 Story Points

**Historia:**
```
Como ApplicationManager,
quiero que cada asignación o remoción de módulos a una organización quede registrada como un registro de auditoría,
para poder investigar cambios de acceso sin almacenar valores JSON completos.
```

**Contexto adicional:**

Registrar entradas `ModuleAssigned` y `ModuleRemoved` con `UserId` y `CorrelationId` al modificar `MODULE_ACCESS`.

**Criterios de aceptación:**

- Se genera un registro en `AUDIT_LOG` con Action="ModuleAssigned" al asignar módulo.
- Se genera un registro en `AUDIT_LOG` con Action="ModuleRemoved" al remover módulo.
- `UserId` no es nulo para acciones iniciadas por usuario; `CorrelationId` presente para operaciones batch.
- Tests unitarios/verificables que confirman persistencia y contenidos del registro.

**Requisitos no funcionales:**

- Latencia adicional por logging < 200ms en operaciones típicas.
- Indices adecuados en `AUDIT_LOG` para consultas por `EntityType`+`EntityId`.

**Definición de hecho (DoD):**

- Implementación en `OrganizationModuleService.AssignModule/RemoveModule`.
- Tests unitarios e integración que validan creación de entradas.
- Documentación breve en ActiveMQ_Events.md o sección correspondiente.

**Dependencias:** US-009 (Asignar módulos tras crear organización)

**Notas técnicas:**

- Usar DTO `AuditEntry` con campos (Action, EntityType, EntityId, UserId, Timestamp, CorrelationId).
- Persistir en tabla `AUDIT_LOG` mediante `IAuditLogService.LogAsync`.

````
