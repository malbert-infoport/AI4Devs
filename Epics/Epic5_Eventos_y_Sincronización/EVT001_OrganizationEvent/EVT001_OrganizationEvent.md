# EVT001 — OrganizationEvent

## Resumen
Definir el contrato de evento `OrganizationEvent` publicado por InfoportOneAdmon cuando una organización cambia (alta, baja, modificación). El evento seguirá el patrón State-Transfer: payload con el estado completo de la organización.

## Objetivo
- Garantizar que las aplicaciones satélite puedan consumir el estado completo de una organización y sincronizar su propia copia.

## Criterios de Aceptación
- [ ] Especificación del payload y topic `infoportone.events.organization` documentada.
- [ ] Ticket backend creado para producir eventos desde Services cuando cambian las organizaciones.
- [ ] Ejemplos de consumo y pruebas de integración proporcionadas.

## Publisher / Triggers / Subscribers / Processing

- **Publisher:** `InfoportOneAdmon` — concretamente `OrganizationService` (hook `PostActions`) o procesos de sincronización masiva (`SyncService`).
- **Triggers:** Alta de organización, actualización de datos relevantes (nombre, taxId, apps/modules, group), y soft-delete (`AuditDeletionDate` set). También puede originarse desde la operación de sincronización global (`EVT004`).
- **Subscribers:** Aplicaciones satélite (consumen `infoportone.events.organization`), servicios de auditoría/monitorización, procesos de onboarding automático en aplicaciones satélite.
- **Processing (suscriptor):** cada consumer realiza upsert local de la organización: validar esquema, mapear `SecurityCompanyId`, actualizar `Apps` y `AccessibleModules`, aplicar soft-delete si `IsDeleted=true`.
