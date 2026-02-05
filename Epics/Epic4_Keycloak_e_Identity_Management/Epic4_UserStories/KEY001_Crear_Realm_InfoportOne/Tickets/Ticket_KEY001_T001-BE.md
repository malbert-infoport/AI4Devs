```markdown
# KEY001-T001-BE: Backend / Operaciones — Crear y versionar Realm `InfoportOne` en Keycloak

**TICKET ID:** KEY001-T001-BE
**EPIC:** Keycloak e Identity Management
**COMPONENT:** Infra / Backend
**PRIORITY:** Alta
**ESTIMATION:** 2 días

## Resumen
Definir, crear y versionar la configuración del Realm `InfoportOne` en Keycloak. Incluir export/import reproducible (realm JSON), configuración de mappers (`c_ids`), plantillas de clientes y roles base. Proveer scripts/ansible/helm para despliegue automatizado en entornos de desarrollo y staging.

## Requisitos técnicos
- Exportar el realm como JSON y almacenarlo en `infrastructure/keycloak/realms/InfoportOne.json`.
- Configurar protocol mapper `c_ids` como atributo multivalor en los usuarios (usado por los tokens JWT).
- Crear y versionar plantillas de cliente:
  - `infoportone-frontend` (public, Authorization Code + PKCE)
  - `infoportone-api` (confidential, Client Credentials)
- Documentar pasos para importar el realm en una instancia nueva de Keycloak.
- Añadir tests básicos de smoke (crear usuario, obtener token, verificar claim `c_ids`).

## Entregables
- `infrastructure/keycloak/realms/InfoportOne.json` (exportado y revisado)
- Script de import: `scripts/keycloak/import-realm.sh` o manifiesto Helm/Operator equivalente
- Documentación en `docs/keycloak.md` con comandos de admin (obtener token admin, importar realm)

## Acceptance Criteria
- [ ] Realm JSON exportado y commiteado (sin credenciales en claro).
- [ ] Import reproducible en entorno local con `docker-compose` o Helm.
- [ ] Protocol mapper `c_ids` presente y comprobado en token JWT de prueba.
- [ ] Plantillas de cliente creadas y documentadas.

## Notas operacionales
- Usar Keycloak Admin Client (client credentials) para automatizar import.
- Almacenar secrets de admin en Vault / Azure Key Vault.

```
