# ORG003-T001-FE: Implementar UI para alta/baja manual con modal y grid trash

=============================================================

**TICKET ID:** ORG003-T001-FE
**EPIC:** Gestión del Portfolio de Organizaciones Clientes
**USER STORY:** ORG-003 - Dar de alta / baja organización manualmente
**COMPONENT:** Frontend - Angular (SintraportV4.Front)
**PRIORITY:** Alta
**ESTIMATION:** 6 horas

=============================================================

## TÍTULO
Acción de baja/alta manual de organizaciones: columna "papelera" en grid, modal de confirmación y botones en ficha. Llamada al endpoint genérico Helix6 `DeleteUndeleteLogicById`.

## OBJETIVO
Permitir a usuarios con permisos de seguridad (SecurityManager) activar o desactivar organizaciones desde la grid y desde la vista detalle, reutilizando el endpoint genérico del backend y garantizando trazabilidad (`X-Correlation-Id`) y UX coherente (confirmación, mensajes y refresco de vistas).

## DESCRIPCIÓN DETALLADA
- Grid de organizaciones:
  - Añadir una columna fija a la derecha con un botón/icono de papelera por fila (si la organización está activa mostrará "Dar de baja", si está desactivada mostrará "Dar de alta").
  - El botón abre un modal de confirmación (usar `ClModalService` o `ConfirmDialogComponent` según CommonLibrary).
  - Tras confirmación se ejecuta la llamada al backend: `DELETE /api/Organization/DeleteUndeleteLogicById?id=<id>`.
  - Incluir cabecera `X-Correlation-Id` cuando esté disponible (recuperada desde `CorrelationService` o similar). Manejar códigos 200, 403 y 404 mostrando mensajes apropiados.

- Ficha/Detalle de organización:
  - Añadir botones `Dar de baja` y `Dar de alta` (condicionales según `auditDeletionDate`) que abran el mismo modal de confirmación y ejecuten la misma llamada.
  - Después de completar la operación, recargar la vista con `GetById` (configuración `OrganizationComplete`) o refetch de la colección en la grid.

## CONTEXTO Y CONVENCIONES (referencias)
- UI: seguir patrones de `Helix6_Frontend_Architecture.md` para grids (`ClGrid`) y modales (`ClModalService`).
- Endpoints Helix6 genéricos y comportamiento de auditoría descritos en `Ticket_ORG001_T001-FE.md`.
- Proyecto: `SintraportV4.Front` — integrar servicios existentes de `OrganizationClient` o crear wrapper en `organization.service.ts`.

## ROLES Y PERMISOS
- Acción visible/ejecutable solo para rol/permiso `SecurityManager`.
- Validación UI: usar `AccessService.hasAccess(Access['SecurityManager'])` o el permiso concreto definido por seguridad. Si no existe, añadir permiso en el enum `Access` (por ejemplo `Organization delete/undelete`).

## CONTRATO BACKEND (API)
- Endpoint: `DELETE /api/Organization/DeleteUndeleteLogicById` (query param `id`)
- Parms: `id` (int, required), opcional `configurationName` (string)
- Headers: `Accept-Language`, `Authorization: Bearer <token>`, `X-Correlation-Id: <uuid>` (si disponible)
- Response: 200 OK on success; 403 Forbidden if user lacks rights; 404 Not Found if id not found; payload may be empty or contain result message.

Ejemplo HTTP:

DELETE /api/Organization/DeleteUndeleteLogicById?id=123
Headers:
- Authorization: Bearer <token>
- X-Correlation-Id: 0f8fad5b-d9cb-469f-a165-70867728950e

## UX / Mensajería
- Modal: título dinámico `Dar de baja` / `Dar de alta`, mensaje explicativo, botón confirmar y cancelar.
- Snackbar (toast): mostrar éxito (`Organización dada de baja/alta correctamente`) o error con texto del backend.
- Actualización inmediata: tras éxito, refrescar grid y detalle; optimizar con actualización local del item si es posible.

## EJEMPLO DE IMPLEMENTACIÓN (TypeScript)

organization.service.ts (wrapper mínimo):

```typescript
toggleDelete(id: number, configurationName?: string): Observable<void> {
  const url = `/api/Organization/DeleteUndeleteLogicById`;
  let params = new HttpParams().set('id', id.toString());
  if (configurationName) params = params.set('configurationName', configurationName);
  const headers = new HttpHeaders({ 'X-Correlation-Id': this.getCorrelationId() || '' });
  return this.http.delete<void>(url, { headers, params });
}
```

Componente grid (esquema con ClGrid / Angular):

```typescript
onTrashClick(row: OrganizationView) {
  const title = row.auditDeletionDate ? 'Dar de alta' : 'Dar de baja';
  const message = row.auditDeletionDate ? '¿Confirmar alta de la organización?' : '¿Confirmar baja de la organización?';
  const modal = this.clModalService.openConfirm({ title, message, confirmText: 'Confirmar' });
  modal.afterClosed().subscribe(confirmed => {
    if (!confirmed) return;
    this.orgService.toggleDelete(row.id).pipe(finalize(() => this.loadGrid())).subscribe({
      next: () => this.snackBar.open('Operación completada', 'Cerrar', { duration: 3000 }),
      error: err => this.snackBar.open(err?.error?.message || 'Error inesperado', 'Cerrar')
    });
  });
}
```

## CASOS DE BORDE
- Si la respuesta es 403: mostrar mensaje de permiso denegado.
- Si la respuesta es 404: indicar "Organización no encontrada" y refrescar grid.
- Conexión perdida: mostrar mensaje y permitir reintento.

## TESTS RECOMENDADOS
- Unit tests:
  - Visibilidad de la columna papelera según permiso (mock `AccessService`).
  - Modal se abre al pulsar papelera y la llamada al servicio se realiza tras confirmar.
  - Manejo de respuestas 200/403/404 y despliegue de mensajes.
- E2E (opcional): flujo de baja/alta en UI (mock backend o entorno de testing).

## CRITERIOS DE ACEPTACIÓN
- [ ] Columna de papelera visible siempre a la derecha en la grid para usuarios con permiso.
- [ ] Modal de confirmación obligatorio antes de ejecutar la acción.
- [ ] Llamada al endpoint `DeleteUndeleteLogicById` incluyendo `X-Correlation-Id` cuando esté disponible.
- [ ] UI muestra snackbar con resultado (éxito o error) y refresca grid/ficha tras éxito.
- [ ] Tests unitarios que cubran visibilidad, confirmación y manejo de respuestas (mínimo 3 tests).

## NOTAS DE IMPLEMENTACIÓN
- Reutilizar `ClGrid` toolbar/column patterns de `Helix6_Frontend_Architecture.md`.
- Reusar servicios y utilidades de `SintraportV4.Front` (p. ej. `apiClients.ts` o `OrganizationClient`) cuando sea posible.
- Registrar la nueva clave de permiso si no existe (añadir a `src/app/theme/access/access.ts`) y coordinar con backend para que el permiso exista.

## SIGUIENTES PASOS / ENTREGABLES
- Implementar cambios UI en `SintraportV4.Front` (componentes grid y detalle).
- Añadir/actualizar `organization.service.ts` (wrapper) y tests unitarios.
- Crear MR/PR con descripción y capturas de pantalla.

---

**Estimación ampliada:** 6 horas (incluye implementación y tests unitarios básicos).
