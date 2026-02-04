```markdown
# TASK-US802-BE-AUDIT: Auditar cambios en Applications

=============================================================
**TICKET ID:** TASK-US802-BE-AUDIT  
**EPIC:** Auditoría de Cambios Críticos  
**USER STORY:** US-802 - Auditar cambios críticos en Application  
**COMPONENT:** Backend - Service Integration  
**PRIORITY:** Media  
**ESTIMATION:** 4 horas  
=============================================================

## TÍTULO
Instrumentar el servicio de gestión de `Application` para generar entradas en `AUDIT_LOG` al modificar configuración crítica, módulos o estado.

## DESCRIPCIÓN
Añadir llamadas a `IAuditLogService.LogAsync(AuditEntry)` en los puntos donde se cambian configuraciones críticas, la lista de módulos accesibles o el estado de la aplicación.

## CRITERIOS TÉCNICOS
- `ApplicationConfigChanged` registrado al modificar campos críticos (sin valores sensibles).
- `ApplicationModulesChanged` registrado al modificar módulos/accessible modules.
- `ApplicationDeactivated` / `ApplicationReactivated` registrados con `UserId` o `NULL` según origen.
- Tests unitarios que mockeen `IAuditLogService` y verifiquen payloads.
- Tests de integración que verifiquen persistencia.

## IMPLEMENTACIÓN / NOTAS
- Revisar controladores y servicios que exponen edición de Applications e instrumentarlos.
- Evitar inclusión de secrets en registros; solo referencias por ID y nombre de campo.

## AMPLIACIÓN: ROLES Y CREDENCIALES
- `ApplicationRoleAssigned` / `ApplicationRoleRemoved` deben registrarse al añadir/quitar roles asociados a la aplicación; incluir metadata del rol (nombre, id) y `UserId` del actor.
- `ApplicationCredentialAdded` / `ApplicationCredentialRemoved` deben registrarse al añadir/retirar credenciales de acceso. Registrar únicamente un identificador/alias de la credencial, tipo y metadatos (p.ej. expiración), nunca el secreto/clave en texto.

## IMPLEMENTACIÓN / NOTAS ADICIONALES
- Revisar los flujos donde se gestionan roles y credenciales en el servicio de `Application` y añadir llamadas a `IAuditLogService.LogAsync` con `EntityType`="Application" y acciones descritas.
- Usar el `CorrelationId` cuando el cambio forme parte de un despliegue o flujo mayor.
- Para credenciales, almacenar en `AUDIT_LOG` sólo un `CredentialAliasId`/referencia; si se necesita audit trail más completo (old/new) abrir ticket separado con almacenamiento seguro (no en AUDIT_LOG).
- Tests unitarios que verifiquen que no se persisten secretos y que las referencias a credenciales son consistentes.

```
