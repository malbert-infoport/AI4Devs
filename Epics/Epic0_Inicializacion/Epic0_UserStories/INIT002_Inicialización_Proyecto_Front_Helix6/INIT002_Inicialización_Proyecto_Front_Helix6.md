#### INIT002 - Inicialización Proyecto Front Helix6 (Angular 20)

**ID:** INIT002_Inicialización_Proyecto_Front_Helix6
**EPIC:** Epic0 - Inicialización de proyectos Helix6

**RESUMEN:** Scaffold del proyecto frontend basado en Angular 20 siguiendo `Helix6_Frontend_Architecture.md`. Incluir estructura, integración con `@cl/common-library`, NSwag client generation, lint/test setup y scripts `npm` para dev/build/test.

## OBJETIVOS
- Crear proyecto Angular 20 (Angular CLI) con estructura recomendada para Helix6 Frontend.
- Integrar `@cl/common-library` y preparar carpetas: `app`, `assets`, `webServicesReferences` (NSwag clients).
- Añadir ejemplo de componente `group-organization-form` y `group-organization-list` siguiendo `ClGrid/ClModal` patrones.
- Configurar Karma/Jasmine o Jest para tests unitarios y storybook (opcional).

## ACEPTACIÓN
- [ ] `npm install` y `npm run start` levanta la app en desarrollo.
- [ ] `npm run test` ejecuta tests unitarios.
- [ ] NSwag generation documentado (`nswag.json` o script `npm run generate:clients`).

## TAREAS PRINCIPALES
1. Ejecutar `ng new SintraportV4.Front --standalone --routing` y configurar `tsconfig`, `angular.json` y `package.json`.
2. Añadir `@cl/common-library` en `package.json` y configurar path de `webServicesReferences`.
3. Generar NSwag clients (o copiar plantilla) y añadir `src/webServicesReferences/api/apiClients.ts`.
4. Crear componentes ejemplo `group-organization-list` y `group-organization-form` (standalone, `inject()` usage).
5. Configurar `CorrelationService`, `AccessService` y `ClGrid` usage patterns.
6. Documentar comandos: `npm install`, `npm run start`, `npm run test`, `npm run build`.

## EJEMPLOS DE COMANDOS
```bash
# Crear proyecto (local guidance)
ng new SintraportV4.Front --standalone --routing
cd SintraportV4.Front
npm install
npm run start
```

## TESTS RECOMENDADOS
- Unit tests para `group-organization-list` (mock `GroupOrganizationClient`) y `group-organization-form` (visibilidad de pestañas y readonly grid).

## CRITERIOS DE ACEPTACIÓN
- [ ] Proyecto Angular creado y reproducible localmente.
- [ ] NSwag clients integrados y ejemplo de uso en componentes.
