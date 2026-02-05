```markdown
# KEY001 — Crear Realm `InfoportOne` en Keycloak

## Resumen
Instalar y configurar Keycloak (o su distribución compatible) con un único Realm llamado `InfoportOne` que actúe como proveedor de identidad central para todo el ecosistema InfoportOneAdmon. El realm debe incluir configuración estándar (políticas de contraseñas, tokens, timeouts), mappers para el claim `c_ids` (multivalor), plantillas de clientes (public + confidential) y roles base.

## Objetivos
- Proveer un realm replicable y versionado (JSON importable).
- Definir protocol mappers para `c_ids` (array de valores) y otros claims requeridos.
- Crear plantillas de cliente para SPAs (PKCE) y APIs (client credentials).
- Asegurar que la configuración pueda desplegarse automáticamente (helm/ansible/terraform).

## Criterios de Aceptación
- [ ] Realm `InfoportOne` creado y exportado como JSON en el repositorio de configuración.
- [ ] Protocol mapper `c_ids` disponible como atributo multivalor en usuarios.
- [ ] Clientes de ejemplo creados: `infoportone-frontend` (public, PKCE) y `infoportone-api` (confidential).
- [ ] Documentación de configuración y comandos de export/import añadida.

## Riesgos y notas
- Mantener credenciales admin fuera de repositorio (Key Vault / secrets manager).
- Pensar en estrategia de backup/restore y versión del servidor Keycloak al aplicar realm JSON.

```
