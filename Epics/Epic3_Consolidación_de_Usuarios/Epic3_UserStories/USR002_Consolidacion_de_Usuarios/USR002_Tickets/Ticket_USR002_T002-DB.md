```markdown
# USR002-T002-DB: Base de datos — Crear tablas `USERCACHE` y `EVENTHASH`

**TICKET ID:** USR002-T002-DB
**EPIC:** Consolidación de Usuarios
**COMPONENT:** Base de Datos (PostgreSQL)
**PRIORITY:** Alta
**ESTIMATION:** 4 horas

## RESUMEN
Crear las tablas `USERCACHE` y `EVENTHASH` necesarias para soportar la consolidación de usuarios. `USERCACHE` almacenará el estado consolidado por `email` y `EVENTHASH` permitirá detectar cambios y evitar reprocesos.

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

## MIGRACIONES EF CORE

```powershell
dotnet ef migrations add AddUserCacheAndEventHash --project Helix6.Back.Data --startup-project Helix6.Back.Api --context EntityModel
dotnet ef database update --project Helix6.Back.Data --startup-project Helix6.Back.Api --context EntityModel
```

## CRITERIOS DE ACEPTACIÓN
- [ ] Tablas `USERCACHE` y `EVENTHASH` creadas.
- [ ] Índices únicos y de búsqueda aplicados.
- [ ] Migración EF Core generada y script revisado.
- [ ] Se pueden insertar y consultar registros de prueba.

***
```
