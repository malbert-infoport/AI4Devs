```markdown
# USR003-T002-DB: Base de datos — Añadir `LastKeycloakSyncAt` y crear `KEYCLOAK_SYNC_LOG`

**TICKET ID:** USR003-T002-DB
**EPIC:** Consolidación de Usuarios
**COMPONENT:** Base de Datos (PostgreSQL)
**PRIORITY:** Alta
**ESTIMATION:** 2 horas

## RESUMEN
Extender la tabla `USERCACHE` con una columna `LastKeycloakSyncAt` y crear la tabla `KEYCLOAK_SYNC_LOG` para auditar y controlar intentos de sincronización con Keycloak.

## DDL SUGERIDO

```sql
-- Añadir columna a USERCACHE
ALTER TABLE "USERCACHE"
ADD COLUMN "LastKeycloakSyncAt" TIMESTAMP;

-- Crear tabla KEYCLOAK_SYNC_LOG
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
dotnet ef migrations add AddKeycloakSyncLogAndUsercacheColumn --project Helix6.Back.Data --startup-project Helix6.Back.Api --context EntityModel
dotnet ef database update --project Helix6.Back.Data --startup-project Helix6.Back.Api --context EntityModel
```

## CRITERIOS DE ACEPTACIÓN
- [ ] Columna `LastKeycloakSyncAt` añadida a `USERCACHE`.
- [ ] Tabla `KEYCLOAK_SYNC_LOG` creada con índice sobre `Email`.
- [ ] Migración generada y aplicada en entorno de pruebas.

```
