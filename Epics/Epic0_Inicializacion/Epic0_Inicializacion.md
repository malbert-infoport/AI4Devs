```markdown
# Epic0 - Inicialización de proyectos Helix6 (Backend + Front)

Objetivo: Preparar los proyectos base para iniciar el desarrollo. Se crearán las plantillas iniciales para el backend (Helix6 .NET 8) y frontend (Angular 20) siguiendo las convenciones de Helix6, además de una configuración inicial de contenedores para Keycloak y PostgreSQL usada en desarrollo.

Alcance:
- Scaffold del proyecto backend basado en la plantilla Helix6 (.NET 8): proyectos Api, Services, Data, DataModel, Entities, Tests y Helix Generator.
- Scaffold del proyecto frontend Angular 20 usando Angular CLI y adaptado a `Helix6_Frontend_Architecture.md`: integrando NSwag clients, `@cl/common-library` y patrones `ClGrid/ClModal`.
- Crear `docker-compose` de desarrollo con Keycloak y PostgreSQL y ejemplo de import de realm/seed.

Resultados esperados:
- Repositorio con carpetas y proyectos iniciales (solución backend y workspace frontend).
- Documentación `README.md` en cada proyecto con comandos de arranque, tests y generación de contratos NSwag.
- CI pipelines básicos: build/test para backend (.NET) y frontend (npm + tests).

Stakeholders: Backend Team, Frontend Team, DevOps, Product Owner.

Prioridad: Alta

```
