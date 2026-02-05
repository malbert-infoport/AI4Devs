```markdown
# KEY003-T001-BE: Backend / Infra — Provisionamiento de clientes Keycloak por aplicación

**TICKET ID:** KEY003-T001-BE
**EPIC:** Keycloak e Identity Management
**COMPONENT:** Infra / Backend
**PRIORITY:** Alta
**ESTIMATION:** 1.5 días

## Resumen
Implementar las plantillas y scripts para provisionar clientes en Keycloak por aplicación: `public` (PKCE) para SPAs y `confidential` (Client Credentials) para APIs. Incluir ejemplos de `kcadm.sh`, Admin REST API y realm JSON fragment para importación.

## Requisitos técnicos
- Crear dos plantillas JSON en `infrastructure/keycloak/clients/templates/`:
  - `public-client.json` (PKCE)
  - `confidential-client.json` (Client Credentials)
- Script de provisioning: `scripts/keycloak/provision-client.sh` que:
  - obtiene token admin
  - crea el client si no existe
  - configura redirect URIs, web origins y `serviceAccountsEnabled` para confidential
  - imprime el `client_id` y, si aplica, devuelve el `client_secret` (solo en salida segura; no guardar en repo)
- Documentar convención de nombres: `infoportone-<appPrefix>-frontend`, `infoportone-<appPrefix>-api`.
- Añadir tests de smoke usando Keycloak docker y `kcadm.sh`.

## Ejemplo `kcadm.sh` (crear client confidential)

```bash
./kcadm.sh config credentials --server http://localhost:8080/auth --realm master --user admin --password secret
./kcadm.sh create clients -r InfoportOne -s clientId=infoportone-crm-api -s serviceAccountsEnabled=true -s publicClient=false
```

## Entregables
- `infrastructure/keycloak/clients/templates/public-client.json`
- `infrastructure/keycloak/clients/templates/confidential-client.json`
- `scripts/keycloak/provision-client.sh`
- `docs/keycloak-clients.md` con ejemplos y buenas prácticas

## Criterios de Aceptación
- [ ] Plantillas y script revisados y commiteados.
- [ ] Provisionamiento reproducible en entorno de development.
- [ ] Documentación de rotación y almacenamiento seguro de `client_secret`.

```
