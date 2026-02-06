```markdown
# APL001 - Gestión de Aplicación (Datos básicos, Módulos, Roles, Credenciales)

**ID:** APL001
**EPIC:** Administración de Aplicaciones
**RESUMEN:** Gestión completa del ciclo de vida de una `Application`: datos maestros, módulos disponibles y asignados, roles propios, y credenciales de seguridad OAuth/ClientCredentials.

## Objetivos
- Formulario de creación/edición de `Application` con pestañas: Datos, Módulos, Roles, Credenciales.
- Soportar CRUD de roles y credenciales desde UI.
- Permitir creación/edición de módulos globales y asignación por aplicación (ver APL004 para módulo global si se separa).
- Garantizar auditoría, validaciones y publicación de eventos relevantes (ApplicationCreated, ModuleChanged, RoleChanged, CredentialChanged).

## Prioridad
Alta — Estimación 3 días (FE + BE coordination)

## Alcance
- Frontend: componente `application-form` standalone con Material Tabs, reproducir patrón de `ORG001` (OrganizationForm) adaptado a `Application`.
- Backend: endpoints NSwag esperados: `Application.GetById/GetNewEntity/Insert/Update`, `ApplicationModule.*`, `ApplicationRole.*`, `ApplicationCredential.*` (coordinar si faltan).

## UX / Pestañas
- Pestaña 1 — Datos básicos: `Name`, `Key` (único), `Description`, `Active`, `RolePrefix`, `DefaultScopes`.
- Pestaña 2 — Módulos: grid master-detail con aplicaciones (origen global) y multiselect de módulos asignados.
- Pestaña 3 — Roles: grid con CRUD (crear/editar/eliminar) para roles propios de la aplicación.
- Pestaña 4 — Credenciales: gestión de credenciales (create/rotate/delete); mostrar secreto enmascarado y botón `Copy`.

## Permisos (añadir a `Access`)
- `Application data modification` (valor sugerido 300)
- `Application data query` (301)
- `Application modules modification` (302)
- `Application modules query` (303)
- `Application roles modification` (304)
- `Application credentials modification` (305)
- `Application audit query` (306)

## Contrato Backend (recomendado)
- `GET /api/Application/GetById?id={id}&configurationName=ApplicationComplete` → `ApplicationView` con `ApplicationModules`, `ApplicationRoles`, `ApplicationCredentials`.
- `GET /api/Application/GetNewEntity` → plantilla vacía.
- `POST /api/Application/Insert?configurationName=ApplicationComplete&reloadView=true` → inserta y retorna view.
- `PUT /api/Application/Update?configurationName=ApplicationComplete&reloadView=true` → actualiza y retorna view.
- Endpoints adicionales: `ApplicationModuleClient` (GetAll, Create/Edit/Delete), `ApplicationRoleClient` (CRUD), `ApplicationCredentialClient` (CRUD/Rotate).

Headers recomendados:
- `Authorization: Bearer {token}`
- `Accept-Language`
- `X-Correlation-Id`

## Validaciones
- `Name` y `Key` obligatorios; `Key` único (backend valida).
- Roles deben tener `Name`, `Description` opcional.
- Credenciales: secret generado en backend, mostrar solo en creación/rotación.

## Tests recomendados
- Unit (component): permisos toggles, llamadas a `ApplicationClient` mocked, modal create/edit flows para roles/credentials, copy/rotate credential flow.
- Integration: NSwag clients contract validation.
- E2E: crear aplicación completa con roles y credenciales, verificar publicación del evento si aplica.

## Criterios de aceptación
- [ ] `application-form` standalone con 4 pestañas implementado.
- [ ] Guardado `Insert/Update` funciona con `ApplicationComplete`.
- [ ] Roles y credenciales CRUD funcionan y llaman al backend correspondiente.
- [ ] Permisos respetados (301/300/304/305).
- [ ] Tests unitarios añadidos.

## Notas técnicas
- Usar `inject()` para dependencias: `ApplicationClient`, `ApplicationModuleClient`, `ApplicationRoleClient`, `ApplicationCredentialClient`, `AccessService`, `ClModalService`, `SharedMessageService`.
- Seguir patrones `ClGrid`/`ClModal` y `Helix6_Frontend_Architecture.md`.

```
