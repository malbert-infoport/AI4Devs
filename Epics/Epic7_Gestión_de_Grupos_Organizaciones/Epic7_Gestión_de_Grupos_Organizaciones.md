# Epic9 - Gestión de Grupos de Organizaciones

Objetivo: Proveer mantenimiento completo de los grupos de organizaciones (crear, editar, listar, ver detalle, dar de baja/alta) replicando la estructura y convenciones de la Épica 1 para Organizaciones.

Alcance:
- CRUD de `OrganizationGroup` mediante Helix6 y endpoints generados.
- Listado con paginación (GetAllKendoFilter).
- `GetById` para detalle que devuelve lista de `Organizations` en modo solo lectura.
- Migraciones DB y tests asociados.

Convenciones:
- Carpetas y nombres siguen el patrón: `Epics/Epic9_Gestión_de_Grupos_Organizaciones/Epic9_UserStories/US###_Title/US###_Tickets/Ticket_US###_T00N-<TYPE>.md`.
- `HelixEntities` LoadConfiguration recomendada: `GroupBasicWithOrganizationsReadOnly`.

Prioridad: Alta

Stakeholders: Product Owner, OrganizationManager, Backend Team, Frontend Team
