# APL006-T001-FE: Frontend — Gestionar Credenciales OAuth / ClientCredentials

**TICKET ID:** APL006-T001-FE
**EPIC:** Administración de Aplicaciones
**COMPONENT:** Frontend - Angular
**PRIORITY:** Alta
**ESTIMATION:** 1 día

## TÍTULO
Desarrollar `application-credentials` para crear, rotar, eliminar y listar credenciales por aplicación.

```markdown
# APL006-T001-FE: Frontend — Gestionar Credenciales (Client Credentials)

**TICKET ID:** APL006-T001-FE
**EPIC:** Administración de Aplicaciones
**COMPONENT:** Frontend - Angular (SintraportV4.Front)
**PRIORITY:** Alta
**ESTIMATION:** 1.5 días

## TÍTULO
Implementar `application-credentials` en `application-form` para crear/rotar/eliminar y listar credenciales de tipo client credentials.

## OBJETIVO
Gestionar credenciales de aplicación con prácticas seguras: el `clientSecret` se muestra únicamente en creación/rotación y no se persiste en cliente; operaciones auditables y trazables.

## DESCRIPCIÓN DETALLADA
- `application-credentials` (pestaña Credenciales): tabla con `Name`, `ClientId`, `CreatedAt`, `LastRotationAt`, `CreatedBy`, `Actions` (`Create`, `Rotate`, `Delete`, `Copy`).
- `Create`: modal para introducir `name` y scopes; backend genera `{ clientId, clientSecret }` y frontend muestra `clientSecret` en modal con aviso "Copiar ahora — no se mostrará de nuevo".
- `Rotate`: confirmación y mostrar nuevo `clientSecret` una vez.
- `Delete`: modal crítico con confirmación; si backend responde `409 Conflict`, mostrar detalle y pasos (revocar, desasignar integraciones).
- `Copy`: copia segura al portapapeles; no almacenar secret en state persistente.

## CONTRATO BACKEND (NSWAG)
- `ApplicationCredentialClient.getAllByApplicationId(applicationId)` → `ApplicationCredentialView[]` (no incluye secret)
- `ApplicationCredentialClient.create(createRequest)` → `{ clientId: string, clientSecret: string }` (secret returned only here)
- `ApplicationCredentialClient.rotate(id)` → `{ clientId: string, clientSecret: string }`
- `ApplicationCredentialClient.deleteById(id)` → `void` / `ProblemDetails`

Headers: `Authorization`, `Accept-Language`, `X-Correlation-Id` (usar `CorrelationService` o generar UUID si no existe).

Nota de integración con `application-form`:
- La `application-form` deberá solicitar la `Application` completa mediante `ApplicationClient.getById(id, configurationName = 'ApplicationComplete')` para obtener `Credentials` junto a `Modules` y `Roles` en una sola llamada. Las operaciones de creación/rotación/eliminación de credenciales desde la `application-form` deberían reflejarse en el `ApplicationView` completo y enviarse al backend mediante `ApplicationClient.update` (configuración `ApplicationComplete`) cuando se trate de una edición/guardado del formulario completo; alternativamente se podrá usar los endpoints específicos (`ApplicationCredentialClient.create/rotate/delete`) para flujos directos, pero la sincronización con la `ApplicationView` completa será responsabilidad del frontend para mantener consistencia.

## EJEMPLO DE IMPLEMENTACIÓN (TypeScript)
```typescript
import { inject } from '@angular/core';
import { ApplicationCredentialClient } from 'src/webServicesReferences/api';
import { ClModalService, SharedMessageService } from '@cl/common-library';
import { CorrelationService } from 'src/app/core/correlation.service';

const credentialClient = inject(ApplicationCredentialClient);
const clModal = inject(ClModalService);
const messages = inject(SharedMessageService);
const correlation = inject(CorrelationService);

async function createCredential(applicationId: number, name?: string) {
	const corr = correlation?.get() ?? '';
	const result = await credentialClient.create({ applicationId, name }, { headers: { 'X-Correlation-Id': corr } } as any).toPromise();
	// result contains clientId and clientSecret
	clModal.open(ShowSecretModalComponent, { data: result, width: '640px' });
}

async function rotateCredential(id: number) {
	const corr = correlation?.get() ?? '';
	const result = await credentialClient.rotate(id, { headers: { 'X-Correlation-Id': corr } } as any).toPromise();
	clModal.open(ShowSecretModalComponent, { data: result, width: '640px' });
}
```

## UX / MENSAJERÍA
- Modal `ShowSecretModalComponent`: muestra `clientId` y `clientSecret`, botón `Copiar` y aviso claro de un único vistazo.
- Toast en éxito; mapear y mostrar `ProblemDetails` para errores.

## CASOS DE BORDE
- Usuario pierde secret tras creación → ofrecer rotación y revocación de la anterior.
- Intento de rotación/eliminación sin permisos → 403.

## TESTS RECOMENDADOS
- Unit:
	- Create flow muestra modal con secret y botón copiar.
	- Rotate flow muestra nuevo secret y actualiza metadata.
	- Delete handles 200/409 and shows helpful message.

## CRITERIOS DE ACEPTACIÓN
- [ ] Crear/rotar/eliminar credenciales implementado y testeado.
- [ ] `clientSecret` mostrado solo en create/rotate y no persistido en almacenamiento.
- [ ] Auditoría visible (CreatedBy, CreatedAt, LastRotationAt).

## CHECKLIST PR
- [ ] `application-credentials` component y `ShowSecretModalComponent` creados.
- [ ] Integración en `application-form` y tests unitarios añadidos.

***
```
