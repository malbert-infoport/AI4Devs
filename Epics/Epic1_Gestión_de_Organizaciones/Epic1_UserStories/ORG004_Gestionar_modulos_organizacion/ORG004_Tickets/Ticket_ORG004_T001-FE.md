# ORG004-T001-FE: Implementar UI para asignación y gestión de módulos en organización

=============================================================

**TICKET ID:** ORG004-T001-FE
**EPIC:** Gestión del Portfolio de Organizaciones Clientes
**USER STORY:** ORG-004 - Gestionar módulos y permisos de organización
**COMPONENT:** Frontend - Angular (SintraportV4.Front)
**PRIORITY:** Alta
**ESTIMATION:** 6 horas

=============================================================

## TÍTULO
Crear la pestaña «Módulos y Permisos de Acceso» para el formulario de organización: grid master-detail de aplicaciones y multiselect de módulos, con control de permisos y modal crítico para auto-baja.

## DESCRIPCIÓN
Implementar la UI para asignar y remover módulos en la ficha de organización siguiendo `Helix6_Frontend_Architecture.md` y la user story ORG-004.

Requisitos principales:
- Grid master-detail donde el master muestra aplicaciones (`ApplicationClient.getAllKendoFilter`) y el detalle permite seleccionar/desseleccionar módulos de cada aplicación.
- Inline edit / save actions que envíen la colección `ApplicationModules` dentro de `OrganizationView` al endpoint `Organization.Update` o `Organization.Insert` con `configurationName=OrganizationComplete`.
- Mostrar modal crítico cuando la eliminación de módulos deje la organización sin módulos (solo para organizaciones con Id > 0). Tras confirmación la UI llamará al backend (Update) para persistir y backend se encargará de auto-baja.
- Controlar visibilidad y edición según permisos: `Organization modules modification` & `Organization modules query` usando `AccessService`.
- Incluir `X-Correlation-Id` en requests que modifican estado.

## ROLES Y PERMISOS
- `Organization modules modification` (202): permite editar módulos y ver botones de asignar/remover.
- `Organization modules query` (203): permite ver la pestaña y el grid en modo solo lectura.

## CONTRATO BACKEND
- `GET /api/Application/GetAllKendoFilter` (configurationName: `ApplicationWithModules`) para popular grid master con módulos.
- `GET /api/Organization/GetById?id={id}&configurationName=OrganizationComplete` para cargar organización con `ApplicationModules`.
- `PUT /api/Organization/Update` body: `OrganizationView`, query: `configurationName=OrganizationComplete&reloadView=true` para guardar módulos.

Headers recomendados:
- `Accept-Language`: idioma
- `Authorization`: Bearer token
- `X-Correlation-Id`: uuid

## UX / FLUJOS
- Al abrir la pestaña, si `organizationId > 0` cargar `GetById(OrganizationComplete)`; si `organizationId == 0` permitir asignación pero no auto-baja.
- Al intentar eliminar el último módulo en organización existente, mostrar modal crítico: "Eliminar el último módulo provocará la desactivación automática de la organización. Desea continuar?".
- Mensajes: snackbar para éxito/error; refrescar vista tras éxito.

## EJEMPLO DE IMPLEMENTACIÓN (TypeScript)

- Inyección y servicios:
```typescript
private readonly organizationClient = inject(OrganizationClient);
private readonly applicationClient = inject(ApplicationClient);
private readonly clModalService = inject(ClModalService);
private readonly accessService = inject(AccessService);
```

- Lógica simplificada para guardar módulos:
```typescript
async saveModules(applicationModules: ApplicationModuleView[]) {
  const payload = { ...this.organizationView, applicationModules };
  const headers = new HttpHeaders({ 'X-Correlation-Id': this.correlationService.get() || '' });
  await this.organizationClient.update(payload, 'OrganizationComplete', true).toPromise();
  this.snackBar.open('Módulos guardados', 'Cerrar', { duration: 3000 });
  this.loadOrganization();
}
```

## CASOS DE BORDE
- Usuario sin permiso → pestaña oculta o readonly según permiso.
- Backend devuelve 403/404 → mostrar `ProblemDetails` friendly.
- Red sin conexión → permitir reintento.

## TESTS RECOMENDADOS
- Unit: visibilidad de pestaña según `AccessService` (mock), modal crítico aparece cuando procede, `saveModules` invoca `organizationClient.update`.
- E2E: flow asignar módulo en organización nueva y editar módulos en organización existente.

## CRITERIOS DE ACEPTACIÓN
- [ ] Grid master-detail implementado y mostrando aplicaciones y módulos.
- [ ] Inline add/remove módulos que persisten en backend y disparan auditoría/eventos backend.
- [ ] Modal crítico y flujo de auto-baja implementado.
- [ ] Tests unitarios mínimos añadidos.

## SIGUIENTES PASOS
- Implementar componente standalone `organization-modules.component.ts` y tests.
- Coordinar con backend para validar `Organization.Update` comportamiento de auto-baja.

***
