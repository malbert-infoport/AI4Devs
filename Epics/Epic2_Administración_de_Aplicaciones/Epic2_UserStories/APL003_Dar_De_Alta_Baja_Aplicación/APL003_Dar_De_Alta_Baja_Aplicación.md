## APL003 - Alta / Baja Lógica de Aplicación (Activar / Desactivar)

**ID:** APL003
**EPIC:** Administración de Aplicaciones

**RESUMEN:**
Agregar en la ficha de `Application` las acciones para activar y desactivar aplicaciones con confirmación crítica, registro de auditoría y publicación de eventos. Debe seguir el mismo detalle y calidad que `ORG003` para organizaciones.

## OBJETIVOS
- Permitir activar o desactivar una aplicación desde la UI con confirmación y justificación opcional.
- Ejecutar la baja lógica en backend (soft-delete / toggle Active) y garantizar auditoría y publicación de eventos (`ApplicationDeactivated`, `ApplicationActivated`).
- Control de permisos para mostrar/ejecutar acciones.

## PRIORIDAD
Media — Estimación: 1 día (FE + coordinación BE + tests)

## ROLES Y PERMISOS
- `Application data modification` (300): Permite ejecutar activar/desactivar.
- `Application data query` (301): Permite ver la ficha y estado.

## CONTRATO BACKEND (ESPECIFICACIÓN)
-- Toggle baja lógica (recomendado usar rutina base existente):
	- PUT `/api/Application/DeleteUndeleteLogicById?id={id}`
	- Response: `200 OK` con entidad actualizada o `204 No Content`.
- Alternativa (si no existe rutina):
	- PUT `/api/Application/Update` con `ApplicationView` editado (campo `Active=false`) y `configurationName=ApplicationComplete`.
Headers esperados:
- `Authorization: Bearer {token}`
- `Accept-Language`
- `X-Correlation-Id` (obligatorio en mutaciones)
Eventos auditados publicados por backend:
- `ApplicationDeactivated` { applicationId, userId, correlationId }
- `ApplicationActivated` { applicationId, userId, correlationId }
## UX / FLUJOS
- En la ficha `application-form` mostrar botón `Desactivar` cuando `application.active === true` y el usuario tiene permiso `Application data modification`.
- Si `application.active === false`, mostrar botón `Activar`.
- Al pulsar `Desactivar`:
	1. Mostrar modal crítico con título: "Confirmar desactivación" y texto que explique consecuencias (ej: revocar credenciales, inaccesibilidad para usuarios).
	2. Campo opcional `Razón` (texto libre) y checkbox para confirmar que entiende las consecuencias.
	3. Botón `Confirmar`: llama al endpoint de baja lógica con `X-Correlation-Id` generado.
	4. Mostrar spinner y deshabilitar UI hasta respuesta.
	5. En caso de éxito: mostrar snackbar success, refrescar la ficha y registrar correlación en logs.
	6. En caso de error: mostrar `ProblemDetails` friendly (mensajes traducidos).
    
## EJEMPLO DE IMPLEMENTACIÓN (TypeScript)
```typescript
import { inject } from '@angular/core';
import { ApplicationClient } from 'src/webServicesReferences/api';
import { ClModalService, SharedMessageService } from '@cl/common-library';
import { CorrelationService } from 'src/app/core/correlation.service';
const applicationClient = inject(ApplicationClient);
const modal = inject(ClModalService);
const messages = inject(SharedMessageService);
const correlation = inject(CorrelationService);
async function confirmToggleActive(applicationId: number, toDelete: boolean) {
	const result = await modal.open({
	title: toDelete ? 'Confirmar desactivación' : 'Confirmar activación',
	data: { reason: '', requireConfirm: true },
	width: '480px'
	}).result;
	if (!result) return;
	const corrId = correlation.get() || generateUuid();
	try {
	await applicationClient.deleteUndeleteLogicById(applicationId).toPromise();
	messages.showSuccess('La aplicación ha sido actualizada');
	// recargar entidad
	} catch (err) {
	messages.showError('Error al actualizar la aplicación');
	}
}
## VALIDACIONES Y CONSIDERACIONES DEL NEGOCIO
- Si la aplicación tiene credenciales activas o integraciones en producción: mostrar advertencia adicional y, opcionalmente, bloquear la desactivación a menos que se cumplan condiciones (configurable).
- Registrar la `Razón` si es proporcionada — backend debería aceptarla como parte del `AuditLog`.
## TESTS RECOMENDADOS
- Unit tests:
	- `application-form` muestra el botón correcto según `active` y permisos.
	- `confirmToggleActive` abre modal y, al confirmar, llama al client con `X-Correlation-Id`.
	- Manejo de errores `ProblemDetails` muestra mensajes traducidos.
- Integration tests (servicio):
	- Verificar que backend registra evento y entrada en `AUDITLOG` tras la operación.
## CRITERIOS DE ACEPTACIÓN
- [ ] Botón `Activar/Desactivar` visible según permisos y estado.
- [ ] Modal de confirmación implementado con campo `Razón` y checkbox de confirmación.
- [ ] Llamada al endpoint usa `X-Correlation-Id` y refresca la vista al completar.
- [ ] Backend publica evento y registra auditoría (coordinación BE necesaria).
- [ ] Tests unitarios añadidos y pasan.
## CHECKLIST PR
- [ ] Component changes added and exported in routes
- [ ] Unit tests for UI and toggle flow
- [ ] Backend contract verified (DeleteUndeleteLogicById exists) or fallback implemented
- [ ] Documentation updated in story and ticket
***
# APL003 - Dar de Alta / Baja Lógica de Aplicación

**ID:** APL003
**EPIC:** Administración de Aplicaciones

**RESUMEN:** Añadir acciones para activar/desactivar aplicaciones con confirmaciones, auditoría y publicación de evento `ApplicationActivated` / `ApplicationDeactivated`.

## Objetivos
- Botones en la ficha de aplicación para `Activar`/`Desactivar` teniendo en cuenta permisos y estado actual.
- Confirmación y justificación (opcional) en modal crítico.
- Registrar auditoría y publicar evento.

## Prioridad
Media — Estimación 4 horas

## Contrato Backend
- `PUT /api/Application/DeleteUndeleteLogicById?id={id}&delete=true|false` (usar rutina base si existe)
- `ApplicationService` debe registrar en `AUDITLOG` y publicar evento.

## Criterios
- [ ] Acciones solo visibles según permiso `Application data modification`.
- [ ] Auditoría registrada con CorrelationId.

***
