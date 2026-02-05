```markdown
# KEY002-T001-BE: Backend — Implementar API para crear/actualizar usuarios en Keycloak

**TICKET ID:** KEY002-T001-BE
**EPIC:** Keycloak e Identity Management
**COMPONENT:** Backend (Servicios)
**PRIORITY:** Alta
**ESTIMATION:** 2 días

## Resumen
Implementar el servicio `KeycloakUserService` que abstrae llamadas al Keycloak Admin REST API para crear/actualizar usuarios, asignar atributos y roles. Debe ser idempotente y segura (credenciales almacenadas en secrets manager).

## Flujo técnico (secuencia de llamadas)
1. Obtener token admin: POST `/realms/master/protocol/openid-connect/token` con client credentials del admin-client.
2. Buscar usuario por email: GET `/admin/realms/{realm}/users?email={email}`.
   - Si existe: actualizar mediante PUT `/admin/realms/{realm}/users/{id}`.
   - Si no existe: crear mediante POST `/admin/realms/{realm}/users`.
3. Establecer credenciales (opcional): POST `/admin/realms/{realm}/users/{id}/reset-password` con body `{"type":"password","value":"...","temporary":false}`.
4. Asignar roles:
   - Obtener roleRepresentation (realm roles): GET `/admin/realms/{realm}/roles/{roleName}`
   - Asignar roles: POST `/admin/realms/{realm}/users/{id}/role-mappings/realm` con array de role representations
   - Para client roles: GET `/admin/realms/{realm}/clients/{clientId}/roles` y POST a `/role-mappings/clients/{clientUuid}`
5. Actualizar atributos: en el create/update payload incluir `attributes: { "c_ids": ["123","456"] }`.

## Payload de ejemplo (creación)

```json
{
  "username": "juan.perez@example.com",
  "email": "juan.perez@example.com",
  "firstName": "Juan",
  "lastName": "Pérez",
  "enabled": true,
  "attributes": {
    "c_ids": ["12345","67890"]
  }
}
```

## Requisitos de seguridad
- Guardar `admin-client` credentials en Key Vault / Vault.
- Usar TLS y validar certificados cuando se llame a Keycloak.

## Tests
- Unit tests para lógica de `CreateOrUpdateUser` con mocks HTTP.
- Integration test contra Keycloak de pruebas (docker-compose / testcontainer).

## Criterios de Aceptación
- [ ] Servicio crea/actualiza usuario por email correctamente.
- [ ] `c_ids` persiste como atributo multivalor en Keycloak y aparece en token.
- [ ] Roles asignados correctamente (realm y client roles).

```
