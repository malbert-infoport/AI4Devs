```markdown
# USR002-T002-DB: Base de datos — Crear tablas `USERCACHE`, `EVENTHASH` y `KEYCLOAK_SYNC_LOG` (integrado)

**TICKET ID:** USR002-T002-DB
**EPIC:** Consolidación de Usuarios
**COMPONENT:** Base de Datos (PostgreSQL)
**PRIORITY:** Alta
**ESTIMATION:** 6 horas

## RESUMEN
Crear las tablas `USERCACHE` y `EVENTHASH` necesarias para soportar la consolidación de usuarios y, además, añadir la columna `LastKeycloakSyncAt` a `USERCACHE` y crear la tabla `KEYCLOAK_SYNC_LOG` para auditar sincronizaciones hacia Keycloak.

## DISEÑO

### Tabla: USERCACHE
Propósito: Caché consolidada por usuario (por email) con organizaciones y roles.

Campos sugeridos:
- `Id` BIGSERIAL PRIMARY KEY
- `Email` VARCHAR(320) NOT NULL -- soporta RFC
- `DisplayName` VARCHAR(200) NULL
- `Cids` INTEGER[] NULL -- lista de SecurityCompanyId (organizaciones)
- `Roles` JSONB NULL -- mapa o lista de roles por aplicación
- `LastEventAt` TIMESTAMP NULL
- `LastKeycloakSyncAt` TIMESTAMP NULL -- nueva columna para sincronización Keycloak
- Auditoría: `AuditCreationUser`, `AuditCreationDate`, `AuditModificationUser`, `AuditModificationDate`, `AuditDeletionDate`

Índices:
- UNIQUE(`Email`) -> UX_UserCache_Email

DDL SQL:

```sql
CREATE TABLE "USERCACHE" (
  "Id" BIGSERIAL PRIMARY KEY,
  "Email" VARCHAR(320) NOT NULL,
  "DisplayName" VARCHAR(200),
  "Cids" INTEGER[],
  "Roles" JSONB,
  "LastEventAt" TIMESTAMP,
  "LastKeycloakSyncAt" TIMESTAMP,
  "AuditCreationUser" VARCHAR(255),
  "AuditCreationDate" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "AuditModificationUser" VARCHAR(255),
  "AuditModificationDate" TIMESTAMP,
  "AuditDeletionDate" TIMESTAMP
);
CREATE UNIQUE INDEX "UX_UserCache_Email" ON "USERCACHE"("Email");
```

### Tabla: EVENTHASH
Propósito: Registrar el hash del último evento procesado por `email` y `eventId` para evitar reprocesos y detectar cambios.

Campos sugeridos:
- `Id` BIGSERIAL PRIMARY KEY
- `EventId` VARCHAR(200) NOT NULL
- `Email` VARCHAR(320) NOT NULL
- `PayloadHash` VARCHAR(100) NOT NULL
- `ReceivedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
- `ProcessedAt` TIMESTAMP NULL
- `Status` VARCHAR(50) NULL -- 'Pending'|'Processed'|'Error'
- Auditoría: campos Helix6

Índices:
- UNIQUE(`EventId`) -> UX_EventHash_EventId
- INDEX(`Email`) -> IX_EventHash_Email

DDL SQL:

```sql
CREATE TABLE "EVENTHASH" (
  "Id" BIGSERIAL PRIMARY KEY,
  "EventId" VARCHAR(200) NOT NULL,
  "Email" VARCHAR(320) NOT NULL,
  "PayloadHash" VARCHAR(100) NOT NULL,
  "ReceivedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "ProcessedAt" TIMESTAMP,
  "Status" VARCHAR(50),
  "AuditCreationUser" VARCHAR(255),
  "AuditCreationDate" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "AuditModificationUser" VARCHAR(255),
  "AuditModificationDate" TIMESTAMP,
  "AuditDeletionDate" TIMESTAMP
);
CREATE UNIQUE INDEX "UX_EventHash_EventId" ON "EVENTHASH"("EventId");
CREATE INDEX "IX_EventHash_Email" ON "EVENTHASH"("Email");
```

### Tabla: KEYCLOAK_SYNC_LOG
Propósito: Registrar intentos de sincronización hacia Keycloak y su resultado para auditoría y reintentos controlados.

Campos sugeridos:
- `Id` BIGSERIAL PRIMARY KEY
- `Email` VARCHAR(320) NOT NULL
- `AttemptAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
- `Status` VARCHAR(50) NOT NULL -- 'Pending'|'Processed'|'Error'
- `Response` TEXT NULL
- `Attempts` INT DEFAULT 1
- Auditoría mínima: `AuditCreationUser`, `AuditCreationDate`

DDL SQL:

```sql
CREATE TABLE "KEYCLOAK_SYNC_LOG" (
  "Id" BIGSERIAL PRIMARY KEY,
  "Email" VARCHAR(320) NOT NULL,
  "AttemptAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "Status" VARCHAR(50) NOT NULL,
  "Response" TEXT,
  "Attempts" INT DEFAULT 1,
  "AuditCreationUser" VARCHAR(255),
  "AuditCreationDate" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX "IX_KeycloakSyncLog_Email" ON "KEYCLOAK_SYNC_LOG"("Email");
```

## MIGRACIONES EF CORE

```powershell
dotnet ef migrations add AddUserCacheAndEventHashAndKeycloakSyncLog --project Helix6.Back.Data --startup-project Helix6.Back.Api --context EntityModel
dotnet ef database update --project Helix6.Back.Data --startup-project Helix6.Back.Api --context EntityModel
```

## CRITERIOS DE ACEPTACIÓN
- [ ] Tablas `USERCACHE`, `EVENTHASH` y `KEYCLOAK_SYNC_LOG` creadas.
- [ ] Índices únicos y de búsqueda aplicados.
- [ ] Columna `LastKeycloakSyncAt` añadida a `USERCACHE`.
- [ ] Migración EF Core generada y script revisado.
- [ ] Se pueden insertar y consultar registros de prueba.

```
```
