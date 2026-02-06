# APL006 - Gestionar Credenciales de Aplicación (OAuth / ClientCredentials)

**ID:** APL006
**EPIC:** Administración de Aplicaciones

**RESUMEN:** Implementar UI y contratos frontend para gestionar credenciales de tipo client credentials: creación (secret generado por backend), rotación, eliminación y listado con auditoría. Garantizar seguridad: secret mostrado solo una vez, copia segura y logs de auditoría.

## Objetivos
- Crear credencial (clientId + clientSecret generado por backend) y mostrar secret solo una vez al crear/rotar.
- Rotación de secret con confirmación y registro de auditoría (userId, timestamp).
- Eliminación con confirmación crítica si credencial está en uso.

## Prioridad
Alta — Estimación 1.5 días

## Contrato Backend (esperado)
La `application-form` y los flujos de edición completa NO deben invocar directamente endpoints de `ApplicationCredential`. En su lugar, deben usar el contrato de la entidad `Application` con la configuración de carga completa `ApplicationComplete`.

- `GET /api/Application/GetById?id={id}&configuration=ApplicationComplete` → `ApplicationView` que incluye `ApplicationCredentials`.
- `POST /api/Application/Insert` / `POST /api/Application/Update` → aceptar `ApplicationView` completo con `ApplicationCredentials` y aplicar insert/update/delete de manera atómica.

Headers: `Authorization`, `Accept-Language`, `X-Correlation-Id`.

Notas:
- Para flujos administrativos o integraciones puntuales, pueden existir endpoints específicos de credenciales, pero la `application-form` debe sincronizar mediante `ApplicationClient`.

## UI / Flujo
- `application-credentials` en `application-form` → lista con columnas: `Name`, `ClientId`, `CreatedAt`, `LastRotationAt`, `CreatedBy`, `Actions`.
	- Acción `Create` abre modal para nombre/roles/scopes; tras crear mostrar `clientSecret` en modal con aviso "copiar ahora: secret mostrado solo una vez".
	- Acción `Rotate` similar (confirma y muestra nuevo secret una vez).
	- Acción `Delete` muestra modal crítico; si credencial en uso backend devuelve 409 con detalle.
	- `Copy` button copia a clipboard de forma segura; no persistir secret en UI state más de lo necesario.

## Seguridad
- No almacenar `clientSecret` en localStorage o logs.
- Mostrar secret en modal con botón `Copiar` y contador visual indicando que será ocultado.

## Ejemplo de implementación (TS)

```typescript
import { inject } from '@angular/core';
import { ApplicationCredentialClient } from 'src/webServicesReferences/api';
import { CorrelationService } from 'src/app/core/correlation.service';

const client = inject(ApplicationCredentialClient);
const correlation = inject(CorrelationService);

async function createCredential(applicationId: number, name?: string) {
	const corr = correlation?.get() ?? '';
	const result = await client.create({ applicationId, name }, { headers: { 'X-Correlation-Id': corr } } as any).toPromise();
	// result contains clientId and clientSecret (secret only here)
	return result;
}
```

## Tests recomendados
- Unit:
	- Crear credencial muestra modal con secret y permite copia.
	- Rotación actualiza `LastRotationAt` y muestra nuevo secret.
	- Eliminación maneja 200/409 correctamente.

## Criterios de aceptación
- [ ] CRUD/rotación/eliminación de credenciales implementado y testeado.
- [ ] Secret mostrado solo en create/rotate y no persistido.
- [ ] Auditoría visible (CreatedBy/CreatedAt/LastRotationAt).

## Notas de implementación
- Evitar almacenar secrets en el estado largo del componente; mantener en memoria hasta cerrar modal.
- Registrar `X-Correlation-Id` en mutaciones.
