```markdown
# APL001-T003-DB: Base de datos — Crear tablas `APPLICATIONROLE` y `APPLICATIONSECURITY`

**TICKET ID:** APL001-T003-DB
**EPIC:** Administración de Aplicaciones
**COMPONENT:** Base de Datos (PostgreSQL)
**PRIORITY:** Alta
**ESTIMATION:** 6 horas

## RESUMEN
Crear las estructuras de base de datos necesarias para soportar la gestión de roles y configuración de seguridad de las aplicaciones: `APPLICATIONROLE` y `APPLICATIONSECURITY` (y tablas de apoyo necesarias). Las tablas `APPLICATION` y `APPLICATIONMODULE` ya fueron creadas por el ticket `ORG001-T003-DB` y **no deben duplicarse**.

Este ticket incluye: DDL PostgreSQL, indicaciones para migración con EF Core, índices, constraints, datos de prueba (seed) y scripts de verificación.

## OBJETIVOS
- Definir `APPLICATIONROLE` para almacenar roles por aplicación.
- Definir `APPLICATIONROLE_PERMISSION` para mapear permisos (catalog) a roles (opcional: `jsonb` para permisos compactos).
- Definir `APPLICATIONSECURITY` para almacenar asignaciones de roles a sujetos (users/groups) por aplicación y otros parámetros de seguridad.
- Garantizar compatibilidad con convenciones Helix6 (campos de auditoría y `AuditDeletionDate` para soft-delete).

## DISEÑO DE TABLAS

Nota: `APPLICATION` y `APPLICATIONMODULE` ya existen (ver `Ticket_ORG001_T003-DB.md`).

### Tabla: APPLICATIONROLE
Propósito: Roles definidos a nivel de aplicación. Un rol agrupa permisos aplicables sobre la aplicación.

Campos principales:
 - `Id` SERIAL PRIMARY KEY
 - `ApplicationId` INTEGER NOT NULL REFERENCES "APPLICATION"("Id") ON DELETE CASCADE
 - `Name` VARCHAR(150) NOT NULL
 - `Key` VARCHAR(100) NOT NULL -- clave única dentro de la aplicación
 - `Description` VARCHAR(500) NULL
 - `Permissions` JSONB NULL -- lista de permisos o referencia a catálogo
 - Auditoría: `AuditCreationUser`, `AuditCreationDate`, `AuditModificationUser`, `AuditModificationDate`, `AuditDeletionDate`

Índices/Constraints:
 - UNIQUE(`ApplicationId`, `Key`) -> UX_ApplicationRole_AppId_Key
 - INDEX on `ApplicationId` -> IX_ApplicationRole_ApplicationId

DDL PostgreSQL:

```sql
CREATE TABLE "APPLICATIONROLE" (
  "Id" SERIAL PRIMARY KEY,
  "ApplicationId" INTEGER NOT NULL,
  "Name" VARCHAR(150) NOT NULL,
  "Key" VARCHAR(100) NOT NULL,
  "Description" VARCHAR(500),
  "Permissions" JSONB,
  "AuditCreationUser" VARCHAR(255),
  "AuditCreationDate" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "AuditModificationUser" VARCHAR(255),
  "AuditModificationDate" TIMESTAMP,
  "AuditDeletionDate" TIMESTAMP,
  CONSTRAINT "FK_ApplicationRole_Application" FOREIGN KEY ("ApplicationId") REFERENCES "APPLICATION"("Id") ON DELETE CASCADE,
  CONSTRAINT "UX_ApplicationRole_AppId_Key" UNIQUE ("ApplicationId", "Key")
);
CREATE INDEX "IX_ApplicationRole_ApplicationId" ON "APPLICATIONROLE"("ApplicationId");
```

### Tabla: APPLICATIONROLE_PERMISSION (opcional)
Propósito: Normalizar permisos si se prefiere no usar `JSONB` en `APPLICATIONROLE`.

Campos:
 - `Id` SERIAL PK
 - `ApplicationRoleId` FK -> APPLICATIONROLE(Id)
 - `PermissionKey` VARCHAR(200) NOT NULL
 - Auditoría y soft-delete

DDL:

```sql
CREATE TABLE "APPLICATIONROLE_PERMISSION" (
  "Id" SERIAL PRIMARY KEY,
  "ApplicationRoleId" INTEGER NOT NULL,
  "PermissionKey" VARCHAR(200) NOT NULL,
  "AuditCreationUser" VARCHAR(255),
  "AuditCreationDate" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "AuditDeletionDate" TIMESTAMP,
  CONSTRAINT "FK_AppRolePerm_AppRole" FOREIGN KEY ("ApplicationRoleId") REFERENCES "APPLICATIONROLE"("Id") ON DELETE CASCADE
);
CREATE INDEX "IX_AppRolePerm_AppRoleId" ON "APPLICATIONROLE_PERMISSION"("ApplicationRoleId");
```

### Tabla: APPLICATIONSECURITY
Propósito: Almacenar asignaciones de roles (y otras reglas de seguridad) por sujeto (usuario/grupo/service) en el contexto de una aplicación.

Campos sugeridos:
 - `Id` SERIAL PRIMARY KEY
 - `ApplicationId` INTEGER NOT NULL REFERENCES "APPLICATION"("Id") ON DELETE CASCADE
 - `ApplicationRoleId` INTEGER NULL REFERENCES "APPLICATIONROLE"("Id") ON DELETE SET NULL
 - `SubjectType` VARCHAR(50) NOT NULL -- 'User' | 'Group' | 'Service'
 - `SubjectId` VARCHAR(100) NOT NULL -- id del sujeto (userId o groupId o clientId)
 - `EffectiveFrom` TIMESTAMP NULL
 - `EffectiveTo` TIMESTAMP NULL
 - Auditoría (`AuditCreationUser`, `AuditCreationDate`, `AuditModificationUser`, `AuditModificationDate`, `AuditDeletionDate`)

Índices/Constraints:
 - UNIQUE(`ApplicationId`, `SubjectType`, `SubjectId`, `ApplicationRoleId`) para evitar duplicados.
 - INDEX en (`SubjectType`,`SubjectId`) para búsquedas por sujeto.

DDL PostgreSQL:

```sql
CREATE TABLE "APPLICATIONSECURITY" (
  "Id" SERIAL PRIMARY KEY,
  "ApplicationId" INTEGER NOT NULL,
  "ApplicationRoleId" INTEGER,
  "SubjectType" VARCHAR(50) NOT NULL,
  "SubjectId" VARCHAR(100) NOT NULL,
  "EffectiveFrom" TIMESTAMP,
  "EffectiveTo" TIMESTAMP,
  "AuditCreationUser" VARCHAR(255),
  "AuditCreationDate" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "AuditModificationUser" VARCHAR(255),
  "AuditModificationDate" TIMESTAMP,
  "AuditDeletionDate" TIMESTAMP,
  CONSTRAINT "FK_ApplicationSecurity_Application" FOREIGN KEY ("ApplicationId") REFERENCES "APPLICATION"("Id") ON DELETE CASCADE,
  CONSTRAINT "FK_ApplicationSecurity_ApplicationRole" FOREIGN KEY ("ApplicationRoleId") REFERENCES "APPLICATIONROLE"("Id") ON DELETE SET NULL
);
CREATE UNIQUE INDEX "UX_ApplicationSecurity_App_Subject_Role" ON "APPLICATIONSECURITY"("ApplicationId","SubjectType","SubjectId","ApplicationRoleId");
CREATE INDEX "IX_ApplicationSecurity_Subject" ON "APPLICATIONSECURITY"("SubjectType","SubjectId");
```

## MIGRACIONES / COMANDOS EF CORE

Generar migración desde el proyecto Data (ajustar nombres de proyecto/context si difieren):

```powershell
dotnet ef migrations add AddApplicationRoleAndSecurity --project Helix6.Back.Data --startup-project Helix6.Back.Api --context EntityModel
dotnet ef database update --project Helix6.Back.Data --startup-project Helix6.Back.Api --context EntityModel
```

Verificar el script SQL generado antes de aplicar en entornos sensibles:

```powershell
dotnet ef migrations script --project Helix6.Back.Data --startup-project Helix6.Back.Api --context EntityModel -o Migrations/AddApplicationRoleAndSecurity.sql
```

## SEED DATA (ejemplo)

```sql
INSERT INTO "APPLICATIONROLE" ("ApplicationId","Name","Key","Permissions","AuditCreationUser","AuditCreationDate")
VALUES (1,'Administrador','ADMIN', '["APP_MANAGE","APP_USERS_MANAGE"]'::jsonb, 'dev@team', CURRENT_TIMESTAMP);

INSERT INTO "APPLICATIONSECURITY" ("ApplicationId","ApplicationRoleId","SubjectType","SubjectId","AuditCreationUser","AuditCreationDate")
VALUES (1, 1, 'User', '42', 'dev@team', CURRENT_TIMESTAMP);
```

## TESTS / VERIFICACIÓN

- Consultas para verificar creación:

```sql
SELECT * FROM "APPLICATIONROLE" WHERE "ApplicationId" = 1;
SELECT * FROM "APPLICATIONSECURITY" WHERE "SubjectType"='User' AND "SubjectId"='42';
```

- Validar constraints únicos y comportamiento de soft-delete (update `AuditDeletionDate` y comprobar que las consultas por defecto lo respetan en la capa de aplicación).

## CRITERIOS DE ACEPTACIÓN

- [ ] Tablas `APPLICATIONROLE` y `APPLICATIONSECURITY` creadas correctamente con campos de auditoría.
- [ ] Índices y constraints (UNIQUE/FK) aplicados según diseño.
- [ ] Migración EF Core generada y script revisado.
- [ ] Seed data de ejemplo insertado y verificado.
- [ ] Consultas de verificación devuelven resultados esperados.
- [ ] Documentación incluida y referencia a `Ticket_ORG001_T003-DB.md` indicando que `APPLICATION` y `APPLICATIONMODULE` ya existen.

## NOTAS Y RIESGOS

- Revisar tamaños de `VARCHAR` según uso real y requisitos de internacionalización.
- Considerar `jsonb` vs tabla normalizada para permisos según volumen y necesidad de consultas complejas.
- Coordinar con equipo de seguridad sobre gestión de roles y asignaciones (auditoría, retención).

***
```
