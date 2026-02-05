# APL006 - Gestionar Credenciales de Aplicación (OAuth / ClientCredentials)

**ID:** APL006
**EPIC:** Administración de Aplicaciones

**RESUMEN:** Gestionar credenciales seguras para aplicaciones: creación (generación de secret), rotación, eliminación y listado con auditoría de rotaciones.

## Objetivos
- Crear credencial (clientId/clientSecret), mostrar secret solo una vez.
- Rotación de secret con confirmación y auditoría.
- Eliminar credenciales con modal crítico si están en uso.

## Prioridad
Alta — Estimación 1.5 días

## Contrato Backend
- `ApplicationCredentialClient.create`, `rotate`, `delete`, `getAllByApplicationId`.
- Backend debe generar secret seguro y retornar una única vez.

## UI
- `application-credentials` componente en `application-form` pestaña Credenciales con lista y acciones `Create/Rotate/Delete/Copy`.
- Mostrar fecha de creación, última rotación y auditor (userId) si aplica.

## Seguridad
- Mostrar secret enmascarado; solo desvelar una vez en creación/rotación.
- Registrar en auditoría quién rotó y cuándo.

## TESTS
- Unit: create/rotate/delete flows, copy secret clipboard.

***
