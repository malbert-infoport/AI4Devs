# KEY003 — Creación de clientes en Keycloak por aplicación

## Resumen
Definir y automatizar la creación de clientes (clients) en Keycloak para cada aplicación del ecosistema. Cada aplicación debe disponer de al menos dos plantillas de cliente:

- `public` (SPA) — Authorization Code Flow con PKCE (sin client secret)
- `confidential` (API/backend) — Client Credentials (con `client_secret` almacenado de forma segura)

La historia debe incluir convenciones de nombres, configuración mínima (redirect URIs, web origins, access type, token settings), mappers relevantes y la forma de versionar y desplegar clientes (realm JSON / kcadm / operator / Helm chart).

## Objetivos
- Definir plantilla de cliente `public` (PKCE) y `confidential` (Client Credentials).
- Establecer convenciones de nombres: `appPrefix-frontend` y `appPrefix-api` o `appPrefix-client`.
- Documentar pasos para crear/actualizar clientes mediante Admin REST API, `kcadm.sh` y realm JSON import.
- Asegurar que `client_id` y `client_secret` se gestionan mediante secrets manager; `client_secret` no se almacena en repositorio.

## Requisitos mínimos de configuración por plantilla

- Public (SPA - PKCE):
  - Access Type: `public`
  - Standard Flow Enabled: true
  - Direct Access Grants: false
  - Valid Redirect URIs: configurable por app (ej: `https://app.example.com/*`)
  - Web Origins: `+` o lista específica
  - Implicit Flow: disabled

- Confidential (API - Client Credentials):
  - Access Type: `confidential`
  - Service Accounts Enabled: true
  - Client Authentication: client secret
  - Roles: client-level or realm-level según convención

## Criterios de Aceptación
- [ ] Plantillas de cliente definidas y exportadas (realm JSON fragment o scripts).
- [ ] Documentación con ejemplos `kcadm.sh` y Admin REST API.
- [ ] Guía para rotación de `client_secret` y almacenamiento seguro en Vault/KeyVault.
- [ ] Ejemplo de provisioning automatizado para `infoportone-<app>-frontend` y `infoportone-<app>-api`.

## Entregables sugeridos
- `infrastructure/keycloak/clients/templates/public-client.json`
- `infrastructure/keycloak/clients/templates/confidential-client.json`
- `scripts/keycloak/create-client.sh` (usa kcadm.sh o Admin REST)
- Documentación `docs/keycloak-clients.md`
