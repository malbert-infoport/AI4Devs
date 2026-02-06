```markdown
#### AUD002: Auditoría — Aplicación

**Épica:** Auditoría de Cambios Críticos
**Rol:** ApplicationManager
**Prioridad:** Media | **Estimación:** 3 Story Points

**Historia:**
Como ApplicationManager,
quiero que los cambios críticos en las Applications queden registrados en el sistema de auditoría,
para disponer de historial y trazar modificaciones que puedan afectar integraciones o accesos.

## Acciones que desencadenan la auditoría (mínimo)
- `ApplicationConfigChanged` — cambio de configuración crítica (dbname, endpoints, flags)
- `ApplicationModulesChanged` — cambio en módulos accesibles
- `ApplicationDeactivated` / `ApplicationReactivated` — cambios de estado
- `ApplicationRoleAssigned` / `ApplicationRoleRemoved` — roles añadidos/quitar
- `ApplicationCredentialAdded` / `ApplicationCredentialRemoved` — credenciales añadidas/removidas (referencia sólo)

## Publisher / Quién publica
- `ApplicationService`, `ApplicationModuleService`, `ApplicationRoleService` deben llamar a `IAuditLogService` en los puntos relevantes.

## Subscribers / Procesamiento
- `AuditQueryService` y herramientas de reporting. Persistencia de `AUDIT_LOG` y posibilidad de exportar reportes PDF/CSV para auditoría.

## Criterios de Aceptación
- [ ] Cada acción listada genera entrada en `AUDIT_LOG` con `EntityType`="Application" y `EntityId`.
- [ ] No se almacenan secretos; sólo referencias a credenciales.
- [ ] Tests unitarios/integración incluidos.

```
