APL003-T001-FE: Frontend — Alta/Baja lógica de Aplicación

=============================================================

**TICKET ID:** APL003-T001-FE
**EPIC:** Administración de Aplicaciones
**COMPONENT:** Frontend - Angular (SintraportV4.Front)
**PRIORITY:** Media
**ESTIMATION:** 1 día

=============================================================

## TÍTULO
Añadir las acciones `Activar` / `Desactivar` en `application-form` con modal crítico, `X-Correlation-Id` y manejo de errores/feedback.

## DESCRIPCIÓN
Extender el formulario de la aplicación para soportar baja lógica desde UI. Debe cubrir:
- Botón `Desactivar` visible sólo cuando la aplicación está activa y el usuario tiene `Application data modification`.
- Botón `Activar` visible cuando la aplicación está desactivada.
- Modal crítico con: título, descripción de consecuencias, campo opcional `Razón` (max 500 chars), y checkbox de confirmación.
-- En confirmación: llamar a `ApplicationClient.deleteUndeleteLogicById(id)` (preferible) o a `ApplicationClient.update` con `Active=false` si la ruta anterior no existe.
- Incluir `X-Correlation-Id` en la petición; usar `CorrelationService` si existe o generar UUID localmente.
- Mostrar snackbar/alerta con resultado y recargar la vista tras éxito.

## CONTRATO BACKEND
-- Preferido: `PUT /api/Application/DeleteUndeleteLogicById?id={id}`
  - (El endpoint maneja la lógica de baja/alta según la implementación del backend)
  - Response: `200 OK` con `ApplicationView` actualizado o `204 No Content`
- Fallback: `PUT /api/Application/Update` con `ApplicationView` donde `Active=false` y `configurationName=ApplicationComplete`

Headers esperados:
- `Authorization: Bearer {token}`
- `Accept-Language`
- `X-Correlation-Id` (obligatorio en mutaciones)

Eventos backend esperados (publicación por servicio):
- `ApplicationDeactivated` { applicationId, userId, correlationId }
- `ApplicationActivated` { applicationId, userId, correlationId }

## UX / FLUJOS
1. Usuario pulsa `Desactivar` → modal crítico se muestra.
2. Usuario completa (opcional) `Razón` y marca checkbox de confirmación.
3. Al confirmar, frontend envía petición con `X-Correlation-Id` y bloquea la UI (spinner).
4. En respuesta exitosa: mostrar notificación, actualizar formulario y registrar correlación en logs.
5. En error: mostrar `ProblemDetails` traducido y permitir reintento.

Comportamientos especiales:
- Si la aplicación tiene credenciales o integraciones activas, mostrar aviso adicional y requerir permiso extra o una confirmación explícita.

## EJEMPLO DE IMPLEMENTACIÓN (TypeScript)
```typescript
import { inject } from '@angular/core';
import { ApplicationClient } from 'src/webServicesReferences/api';
import { ClModalService, SharedMessageService } from '@cl/common-library';
import { CorrelationService } from 'src/app/core/correlation.service';

const applicationClient = inject(ApplicationClient);
const clModal = inject(ClModalService);
const messages = inject(SharedMessageService);
const correlation = inject(CorrelationService);

async function toggleActive(applicationId: number, toDelete: boolean) {
  const modalResult = await clModal.open({
    title: toDelete ? 'Confirmar desactivación' : 'Confirmar activación',
    data: { reason: '', requireConfirm: true },
    width: '520px'
  }).result;

  if (!modalResult) return;

  const corrId = correlation?.get() ?? generateUuid();
  try {
    await applicationClient.deleteUndeleteLogicById(applicationId).toPromise();
    messages.showSuccess('Operación completada correctamente');
    // recargar entidad / emitir evento local para refrescar
  } catch (error) {
    // mostrar ProblemDetails friendly
    messages.showError('No se pudo completar la operación');
  }
}
```

## CASOS DE BORDE
- Intento de desactivar una aplicación con credenciales activos: mostrar advertencia y bloquear/desautorizar según permisos.
- Error 403/409/500: mostrar `ProblemDetails` traducido y ofrecer reintento o contacto de soporte.

## TESTS RECOMENDADOS
- Unit tests:
  - Mostrar/ocultar botones según `application.active` y permisos (mock `AccessService`).
  - Asegurar que `toggleActive` abre modal y, al confirmar, llama a `deleteUndeleteLogicById` con `X-Correlation-Id`.
  - Manejo de errores `ProblemDetails` produce mensajes traducidos.

- Integration tests:
  - Validar que backend registra evento y entrada en `AUDITLOG` al completar la operación.

## CRITERIOS DE ACEPTACIÓN
- [ ] Botones `Activar` / `Desactivar` implementados y visibles según permisos.
- [ ] Modal de confirmación con campo `Razón` y checkbox implementado.
- [ ] Petición incluye `X-Correlation-Id` y refresca la vista tras éxito.
- [ ] Tests unitarios añadidos.

## CHECKLIST PR
- [ ] Actualizaciones en componente `application-form` y export en rutas
- [ ] Unit tests añadidos y pasan
- [ ] Contrato backend verificado o fallback implementado

***
