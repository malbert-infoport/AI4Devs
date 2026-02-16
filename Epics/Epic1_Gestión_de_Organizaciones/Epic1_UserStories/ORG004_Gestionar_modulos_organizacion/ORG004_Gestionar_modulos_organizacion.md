#### ORG-004: Gestionar módulos y permisos de una organización

**Épica:** Gestión del Portfolio de Organizaciones Clientes
**Roles:** Application Manager, Organization Manager
**Prioridad:** Alta | **Estimación:** 8 Story Points

**Historia:**
Como ApplicationManager u Organization Administrator,
quiero poder asignar aplicaciones y módulos a una organización al crearla y también añadir/quitar módulos en organizaciones existentes,
para que los permisos reflejen el contrato y, en caso de quedar sin módulos, el sistema gestione la auto-baja con aviso y registro de auditoría/eventos.

## Criterios de aceptación
- Desde la pestaña «Módulos y Permisos de Acceso» en el formulario de organización poder:
  - Asignar uno o varios módulos por aplicación (master-detail grid con multi-select de módulos).
  - Remover módulos existentes (soft-delete en la relación N:M `ORGANIZATION_APPLICATIONMODULE`).
- Al asignar el primer módulo a una organización recién creada se publica el primer `OrganizationEvent` con `IsDeleted=false`.
- Al añadir o remover módulos se registra `AUDITLOG` con `ModuleAssigned` / `ModuleRemoved` y se publica `OrganizationEvent` cuando proceda.
- Si en una organización existente se remueven todos los módulos, mostrar modal crítico informando de la auto-baja; tras confirmación: establecer `AuditDeletionDate`, registrar `OrganizationAutoDeactivated` y publicar evento con `IsDeleted=true`.
- Control de permisos UI:
  - `Organization modules modification` permite editar módulos.
  - `Organization modules query` permite ver módulos en modo solo lectura.
- Paginación y filtros server-side en los listados de aplicaciones y auditoría según `Helix6_Frontend_Architecture.md`.

## Definición de hecho
- Interfaz (ClGrid + ClModal) funcional para asignar/remover módulos.
- Auditoría registrada y eventos publicados en los cambios críticos.
- Tests unitarios para lógica de UI y servicios esenciales.

## Dependencias
- Endpoints backend: `Organization.GetById (OrganizationComplete)`, `Organization.Update`, `Organization.Insert`, `Application.GetAllKendoFilter`, `AuditLog.GetAllKendoFilter`.
- Permisos y claims provistos por `GetPermissions` del `AuthenticationService`.

## Notas técnicas
- Implementar grid master-detail usando `ClGrid` (Applications como master; módulos en detalle con multiselect). Cargar aplicaciones con `ApplicationClient.getAllKendoFilter` (configuration `ApplicationWithModules`).
- Los cambios en módulos se envían como colección `ApplicationModules` dentro de `OrganizationView` en `OrganizationClient.update/insert` con `configurationName=OrganizationComplete` y `reloadView=true`.
- El primer módulo asignado a una organización publica evento `OrganizationEvent` (responsabilidad backend). Frontend debe enviar X-Correlation-Id en headers cuando esté disponible.
- UX: modal de confirmación para eliminación de módulos y modal crítico cuando la operación deje la organización sin módulos.

## Tests recomendados
- Unit: validar que el grid hace las llamadas correctas al servicio y que el modal crítico se muestra cuando procede.
- Integration (opcional): flujo asignar/modificar módulos y validación de eventos/auditoría en backend.
