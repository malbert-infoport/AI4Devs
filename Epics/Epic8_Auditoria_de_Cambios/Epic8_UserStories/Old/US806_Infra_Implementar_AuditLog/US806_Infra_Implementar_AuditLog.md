````markdown
#### US-806: Implementar infraestructura AUDIT_LOG y servicio IAuditLogService

**Épica:** Auditoría de Cambios Críticos
**Rol:** Backend Developer
**Prioridad:** Alta | **Estimación:** 5 Story Points

**Historia:**
```
Como Backend Developer,
quiero la entidad `AuditLog`, el DTO `AuditEntry`, la interfaz `IAuditLogService` y la migración EF Core que cree la tabla `AUDIT_LOG`,
para soportar la auditoría selectiva de cambios críticos en las entidades del sistema.
```

**Contexto adicional:**

Implementar `AUDIT_LOG` con campos mínimos (Id, Action, EntityType, EntityId, UserId nullable, Timestamp, CorrelationId) y los índices requeridos.

**Criterios de aceptación:**

- Entidad `AuditLog` creada y registrada en `InfoportOneAdmon.DataModel`.
- Migración EF Core generada que crea la tabla `AUDIT_LOG` y los índices (EntityType+EntityId, Timestamp, UserId).
- DTO `AuditEntry` y `IAuditLogService` con método `LogAsync(AuditEntry)` implementados y registrados en DI.
- Tests unitarios e integración que validan la persistencia y las consultas básicas.

**Requisitos no funcionales:**

- La tabla debe soportar insertes de alto volumen; índices diseñados para consultas por entidad y tiempo.

**Definición de hecho (DoD):**

- Entidad, migración, servicio y tests creados y revisados.
- Servicio registrado en `DependencyInjection` y disponible para ser invocado por otros servicios.

**Dependencias:** Ninguna (fundacional)

**Notas técnicas:**

- Usar EF Core migrations; marcar script SQL si es necesario. CorrelationId como string.

````
