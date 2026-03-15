# Integration Test Plan (Testcontainers)

## Objetivo

Validar comportamiento real de la API con PostgreSQL efimero en Docker, sin mocks de infraestructura y aplicando esquema mediante DBUp.

## Fase 0 - Fundacion

- Proyecto `InfoportOneAdmon.Back.Api.IntegrationTests`.
- Fixture de `PostgreSqlContainer` compartida por coleccion.
- `WebApplicationFactory` con cadena de conexion del contenedor.
- `Respawn` para reset de datos entre tests (ignorando journal DBUp).

## Fase 1 - Smoke Critico

- Arranque API contra contenedor.
- DBUp ejecutado y tablas base disponibles.
- Seguridad basica: endpoint protegido sin token devuelve `401`.
- Seguridad basica: endpoint protegido con auth de test devuelve `200`.

## Fase 2 - CRUD Organizaciones

- `Organization/Insert` crea registro con auditoria.
- `Organization/GetById` devuelve entidad persistida.
- `Organization/Update` persiste cambios.
- `Organization/DeleteUndeleteLogicById` alterna estado logico.

## Fase 3 - Seguridad Funcional

- `Security/GetPermissions` carga configuracion de usuario.
- `SecurityUserConfiguration/GetUserConfiguration` devuelve defaults y cambios.
- `SecurityUserGridConfiguration` insert/update/list/default.
- `Security/CleanCache` autorizado y no autorizado.

## Fase 4 - Query/Kendo

- Endpoints `GetAllKendoFilter` con ordenacion, filtro y paginacion.
- Cobertura de `IncludeDeleted` en endpoints compatibles.

## Fase 5 - Adjuntos

- `Attachment/Insert` y `Attachment/GetAttachmentContent`.
- Validacion de permisos en operaciones de adjuntos.

## Reglas de implementacion

- Esquema con DBUp, no con EF migrations.
- Semillas minimas por test para aislamiento.
- Evitar dependencia de IdP externo: autenticacion de test en `WebApplicationFactory`.
