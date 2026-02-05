```markdown
# EVT002 — ApplicationEvent

## Resumen
Definir el contrato de evento `ApplicationEvent` que publica InfoportOneAdmon cuando cambia la definición de una aplicación (catalogo de módulos, roles, credenciales). El evento transmite el estado completo de la aplicación para que las aplicaciones satélite y otros consumidores puedan actualizar catálogos y permisos.

## Objetivo
- Proveer un payload completo con `ApplicationId`, `RolePrefix`, `Modules`, `Roles` y `Credentials` (sin secrets en claro).

## Criterios de Aceptación
- [ ] Especificación del payload y topic `infoportone.events.application` documentada.
- [ ] Ticket backend creado para publicar eventos desde `ApplicationService` en `PostActions`.

```
