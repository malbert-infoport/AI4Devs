````markdown
#### US-803: Auditar cambios de grupo de organización

**Épica:** Auditoría de Cambios Críticos
**Rol:** SecurityManager / OrganizationManager
**Prioridad:** Alta | **Estimación:** 2 Story Points

**Historia:**
```
Como SecurityManager,
quiero que cualquier cambio de `OrganizationGroup` se registre en `AUDIT_LOG` con Action="GroupChanged",
para poder rastrear modificaciones que impactan políticas y accesos.
```

**Contexto adicional:**

Registrar `GroupChanged` con `UserId` y `CorrelationId` cuando se modifica la pertenencia o el grupo asignado a una organización.

**Criterios de aceptación:**

- Se crea un registro `GroupChanged` al modificar el grupo de una organización.
- Registro contiene `UserId`, `EntityId` (Organization.Id) y `CorrelationId`.
- Tests que verifiquen la entrada en `AUDIT_LOG` y contenidos.

**Requisitos no funcionales:**

- Operación de logging no debe bloquear la transacción principal (usar post-action/compensación si aplica).

**Definición de hecho (DoD):**

- Hooks en endpoints/servicios de cambio de grupo.
- Tests unitarios e integración creados.

**Dependencias:** historias relacionadas con gestión de grupos (referenciar según repositorio).

**Notas técnicas:**

- Incluir nombre anterior y nuevo del grupo en `CorrelationId` o en metadatos relacionados (si se requiere trazabilidad mayor, abrir ticket separado para payloads ampliados).

````
