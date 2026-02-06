# KEY002 — Creación de usuario en Keycloak mediante API

## Resumen
Definir la API y el flujo backend para crear/actualizar usuarios en Keycloak usando la Admin REST API. La API interna debe abstraer los detalles de Keycloak y ofrecer un contrato sencillo: crear/actualizar por `email`, asignar `c_ids` (lista de `SecurityCompanyId`), roles (realm/client) y atributos (`firstName`, `lastName`, `email`, `attributes`).

## Objetivos
- Proveer un servicio backend idempotente que cree o actualice un usuario en Keycloak buscando por `email`.
- Asegurar que `c_ids` queda almacenado como atributo multivalor en Keycloak.
- Permitir asignación de roles (realm y client) durante la creación/actualización.

## Criterios de Aceptación
- [ ] API interna `IKeycloakUserService.CreateOrUpdateUser(UserDto)` implementada.
- [ ] Se puede crear un usuario nuevo y asignar `c_ids` y roles con una llamada de ejemplo.
- [ ] Documentación técnica con ejemplos de payload y secuencia de llamadas a Keycloak Admin REST.
