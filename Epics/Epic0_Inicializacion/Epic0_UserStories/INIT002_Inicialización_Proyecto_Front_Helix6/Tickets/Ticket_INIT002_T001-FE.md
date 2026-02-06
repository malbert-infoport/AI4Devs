```markdown
# INIT002-T001-FE: Frontend — Scaffold Angular 20 + NSwag clients

**TICKET ID:** INIT002-T001-FE
**EPIC:** Epic0 - Inicialización de proyectos Helix6
**COMPONENT:** Frontend - Angular
**PRIORITY:** Alta

## OBJETIVO
Crear el proyecto Angular base y dejar configurados los NSwag clients, `@cl/common-library` y componentes de ejemplo para `GroupOrganization`.

## ALCANCE
- Scaffold Angular 20 app.
- Integración `@cl/common-library` y NSwag clients en `src/webServicesReferences`.
- Ejemplo de componentes y tests básicos.

## ENTREGABLES
- `SintraportV4.Front` con `package.json`, `angular.json`, `tsconfig` y `nswag` config.
- `src/webServicesReferences/api/apiClients.ts` con clientes de ejemplo.
- `group-organization-list` y `group-organization-form` components skeleton.

## CRITERIOS DE ACEPTACIÓN
- [ ] `npm install` y `npm run start` funcionan.
- [ ] NSwag generation documentada y `apiClients.ts` presente.

```
