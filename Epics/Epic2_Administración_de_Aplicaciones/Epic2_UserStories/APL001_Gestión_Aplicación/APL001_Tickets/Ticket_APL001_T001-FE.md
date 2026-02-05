# APL001-T001-FE: Implementar formulario de creación/edición de `Application` con pestañas (Datos, Módulos, Roles, Credenciales)

=============================================================

**TICKET ID:** APL001-T001-FE
**EPIC:** Administración de Aplicaciones
**COMPONENT:** Frontend - Angular (SintraportV4.Front)
**PRIORITY:** Alta
**ESTIMATION:** 12 horas

=============================================================

## TÍTULO
Crear `application-form` standalone con 4 pestañas, validaciones y CRUDs auxiliares (roles, credenciales) siguiendo la guía `Helix6_Frontend_Architecture.md`.

## DESCRIPCIÓN
Desarrollar componente Angular para crear/editar aplicaciones. Debe replicar el nivel de detalle de `ORG001` (OrganizationForm) adaptado a la entidad `Application`.

### Pestañas y comportamiento
- Pestaña 1 — Datos básicos: editable si `Application data modification`.
  - Campos: `Name` (required), `Key` (required, unique), `Description`, `Active`, `RolePrefix`, `DefaultScopes` (multiselect).
  - `Key` en modo creación solo editable; en edición readonly.
- Pestaña 2 — Módulos: grid master-detail mostrando módulos globales y multiselect para asignación.
  - Mostrar mensaje si la aplicación no existe aún: "Guardela antes de asignar módulos".
- Pestaña 3 — Roles: grid con CRUD usando `ClModal` para crear/editar roles.
- Pestaña 4 — Credenciales: lista de credenciales con operaciones `Create` (genera secret), `Rotate` (genera nuevo secret), `Delete` (confirmación crítica). El secret se muestra solo una vez tras la creación/rotación.

## ROLES Y PERMISOS
- `Application data modification` (300)
- `Application data query` (301)
- `Application modules modification` (302)
- `Application roles modification` (304)
- `Application credentials modification` (305)

## CONTRATO BACKEND (NSWAG Clients)
- `ApplicationClient.getById(id, 'ApplicationComplete')`
- `ApplicationClient.getNewEntity()`
- `ApplicationClient.insert(view, 'ApplicationComplete', true)`
- `ApplicationClient.update(view, 'ApplicationComplete', true)`
- `ApplicationRoleClient.*` (CRUD)
- `ApplicationCredentialClient.*` (CRUD/Rotate)
- `ApplicationModuleClient.getAllKendoFilter('ApplicationWithModules')` para listar módulos globales

Headers:
- `Authorization`, `Accept-Language`, `X-Correlation-Id`

## EJEMPLO DE IMPLEMENTACIÓN (TypeScript)
```typescript
import { inject } from '@angular/core';
import { ApplicationClient, ApplicationRoleClient, ApplicationCredentialClient } from 'src/webServicesReferences/api';
import { ClGridService, ClModalService } from '@cl/common-library';
import { AccessService } from 'src/app/theme/access/access';

const appClient = inject(ApplicationClient);
const roleClient = inject(ApplicationRoleClient);
const credClient = inject(ApplicationCredentialClient);
const accessService = inject(AccessService);

async function saveApplication(view: ApplicationView) {
  const resp = await appClient.update(view, 'ApplicationComplete', true).toPromise();
  // mostrar notificación y refrescar
}
```

## UX / FLUJOS
- En creación: Pestaña 2/3/4 deshabilitadas hasta que se guarde la entidad (id generado).
- Al eliminar credencial/rol: mostrar modal crítico describiendo impacto.
- Mensajes toast para éxito/error y traducciones con `TranslateService`.

## CASOS DE BORDE
- Intentar crear `Key` duplicado → mostrar error traducido (backend devuelve ProblemDetails).
- Rotación de credencial en producción → requerir permiso especial y registro de auditoría.

## TESTS RECOMENDADOS
- Unit: permisos, formulario validation, llamar a `appClient.insert`/`update`, modals roles/credentials.
- E2E: crear app, añadir roles/credentials, rotar credencial.

## CRITERIOS DE ACEPTACIÓN
- [ ] Componente `application-form` con 4 pestañas implementado.
- [ ] Integración con NSwag clients comprobada.
- [ ] CRUD roles y credenciales funcionando y tests añadidos.

## SIGUIENTES PASOS
- Coordinar con backend para confirmar `ApplicationComplete` y endpoints de roles/credentials.
- Implementar tests unitarios y E2E.

***
