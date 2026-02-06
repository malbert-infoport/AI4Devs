```markdown
# GRP003-T001-FE: Frontend — Eliminar Grupo (confirmación y post-procesos)

**TICKET ID:** GRP003-T001-FE
**EPIC:** Gestión de Grupos de Organizaciones (Epic7)
**COMPONENT:** Frontend - Angular

## TÍTULO
Añadir acción `Eliminar` en el listado y en la ficha de grupo que invoque `GroupOrganizationClient.deleteById(id)` con modal de confirmación.

## DESCRIPCIÓN
- Mostrar modal crítico antes de eliminar explicando que las organizaciones vinculadas perderán su `GroupId`.
- Al confirmar, llamar a `GroupOrganizationClient.deleteById(id)` y refrescar listado.
- Incluir `X-Correlation-Id` en la petición; opcionalmente enviar `reason` en un header o payload si backend lo admite.

## EJEMPLO DE IMPLEMENTACIÓN (TypeScript)
```typescript
import { inject } from '@angular/core';
import { GroupOrganizationClient } from 'src/webServicesReferences/api';
import { ClModalService, SharedMessageService } from '@cl/common-library';
import { CorrelationService } from 'src/app/core/correlation.service';

const client = inject(GroupOrganizationClient);
const modal = inject(ClModalService);
const messages = inject(SharedMessageService);
const correlation = inject(CorrelationService);

async function confirmDelete(id: number) {
	const result = await modal.open({ title: 'Confirmar eliminación', data: { requireConfirm: true } }).result;
	if (!result) return;
	const corr = correlation.get() || generateUuid();
	await client.deleteById(id).toPromise();
	messages.showSuccess('Grupo eliminado');
}
```

## UX / FLUJOS
- Modal con título, checkbox de confirmación y campo `Razón` opcional.
- Tras confirmación: bloquear UI, llamar `deleteById`, refrescar listado y mostrar snackbar.

## CRITERIOS DE ACEPTACIÓN
- [ ] Modal de confirmación implementado.
- [ ] Llamada a `deleteById` y refresco correcto del listado.

```
