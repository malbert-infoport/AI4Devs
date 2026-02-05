```markdown
# EVT002 — ApplicationEvent

## Resumen
Definir el contrato de evento `ApplicationEvent` que publica InfoportOneAdmon cuando cambia la definición de una aplicación (catalogo de módulos, roles, credenciales). El evento transmite el estado completo de la aplicación para que las aplicaciones satélite y otros consumidores puedan actualizar catálogos y permisos.

## Objetivo
- Proveer un payload completo con `ApplicationId`, `RolePrefix`, `Modules`, `Roles` y `Credentials` (sin secrets en claro).

## Criterios de Aceptación
- [ ] Especificación del payload y topic `infoportone.events.application` documentada.
- [ ] Ticket backend creado para publicar eventos desde `ApplicationService` en `PostActions`.

## Publisher / Triggers / Subscribers / Processing

- **Publisher:** `InfoportOneAdmon` — `ApplicationService` (PostActions) y repositorios que actualicen catálogo (`ApplicationModule`, `ApplicationRole`).
- **Triggers:** Creación/actualización/baja de `Application`, cambios en `ApplicationModule` o `ApplicationRole`, rotación de credenciales (sin incluir secrets). También operaciones manuales de reprovisionamiento y la sincronización global (`EVT004`).
- **Subscribers:** Aplicaciones satélite que consumen catálogo (`infoportone.events.application`), procesos de provisioning de clientes, dashboards administrativos y servicios de guardado local de catálogo.
- **Processing (suscriptor):** Validar esquema, actualizar o reemplazar catálogo local, reconciliar roles (añadir/quitar), no persistir `ClientSecret` en payload.

```
