````markdown
#### US-805: Auditar cambios críticos en Applications

**Épica:** Auditoría de Cambios Críticos
**Rol:** ApplicationManager
**Prioridad:** Media | **Estimación:** 3 Story Points

**Historia:**
```
Como ApplicationManager,
quiero que cambios críticos en la configuración de las aplicaciones que afectan accesos o sincronización generen entradas de auditoría,
para disponer de historial de cambios que puedan afectar integraciones.
```

**Contexto adicional:**

Registrar acciones `ApplicationConfigChanged` con `UserId` y `CorrelationId` cuando cambien campos relevantes (p.ej. DatabaseName, AccessibleModules).

**Criterios de aceptación:**

- `ApplicationConfigChanged` creado en `AUDIT_LOG` con metadata básica.
- Tests unitarios e integración verifican persistencia.

**Requisitos no funcionales:**

- No registrar secretos ni credenciales; sólo metadatos y referencias por ID.

**Definición de hecho (DoD):**

- Hooks en flujos de modificación de aplicaciones que llamen a `IAuditLogService`.
- Tests escritos y aprobados.

**Dependencias:** gestión de aplicaciones y documentación de integraciones.

**Notas técnicas:**

- Evitar payloads extensos; registrar referencia a cambios (campo, valor anterior opcional en ticket separado si necesario).

````
