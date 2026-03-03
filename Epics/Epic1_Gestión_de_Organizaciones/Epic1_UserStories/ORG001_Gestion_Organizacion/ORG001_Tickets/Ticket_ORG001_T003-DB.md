# ORG001-T003-DB: Crear tablas y migraciones necesarias para organización

=============================================================

**TICKET ID:** ORG001-T003-DB  
**EPIC:** Gestión del Portfolio de Organizaciones Clientes  
**USER STORY:** ORG-001 - Crear y editar organización cliente  
**COMPONENT:** Base de Datos  
**PRIORITY:** Alta  
**ESTIMATION:** 6 horas  

=============================================================

## TÍTULO
Crear tablas y migraciones necesarias para el proceso de creación/edición de `ORGANIZATION`

## DESCRIPCIÓN

Implementar la estructura completa de base de datos necesaria para soportar el CRUD de organizaciones clientes siguiendo el estándar del Framework Helix6 con PostgreSQL como motor de base de datos.

**Tablas a crear**:

1. **ORGANIZATIONGROUP**: Agrupaciones lógicas de organizaciones (holdings, consorcios)
2. **ORGANIZATION**: Entidad principal de organizaciones clientes con `SecurityCompanyId` como identificador de negocio
3. **APPLICATION**: Catálogo de aplicaciones satélite del ecosistema
4. **APPLICATIONMODULE**: Módulos funcionales de cada aplicación
5. **ORGANIZATION_APPLICATIONMODULE**: Relación N:M que define qué organizaciones tienen acceso a qué módulos
6. **AUDITLOG**: Registro inmutable de acciones críticas (sin campos JSON de OldValue/NewValue en esta fase)

**Características clave del diseño**:

- **Estándar Helix6**: Todas las tablas usan `Id` como PK autonumérica y campos de auditoría (`AuditCreationUser`, `AuditCreationDate`, `AuditModificationUser`, `AuditModificationDate`, `AuditDeletionDate`)
- **Soft Delete**: Todas las entidades soportan eliminación lógica mediante `AuditDeletionDate`
- **Identificador de Negocio**: `SecurityCompanyId` es índice único en ORGANIZATION (independiente de `Id`)
- **Prefijos de Aplicación**: El campo `RolePrefix` en APPLICATION se usa para nomenclatura de roles y módulos
- **Índices Únicos**: Para garantizar unicidad de nombres, TaxId, SecurityCompanyId, etc.

**Despliegue con DBUp (scripts embebidos)**:
- Se creará un script SQL embebido en `InfoportOneAdmon.Back.DB/Scripts` con el nombre `01020004_OrganizationInfrastructure.sql`
- El script debe registrarse como `EmbeddedResource` en el `.csproj` del proyecto `Back.DB`
- DBUp aplicará el script automáticamente en orden numérico en el siguiente despliegue
- Se incluirá un segundo script opcional `01020005_OrganizationSeedData.sql` para datos de prueba

## ESQUEMA DE TABLAS

### Tabla 1: ORGANIZATIONGROUP

**Propósito**: Agrupaciones lógicas de organizaciones (holdings, consorcios, franquicias).

**Campos**:

| Nombre Campo | Tipo PostgreSQL | Restricciones | Descripción |
|--------------|-----------------|---------------|-------------|
| Id | INTEGER | PK, SERIAL, NOT NULL | Identificador único técnico del grupo |
| GroupName | VARCHAR(200) | UNIQUE, NOT NULL | Nombre del grupo (ej: "Holding Norte") |
| Description | VARCHAR(500) | NULL | Descripción opcional del grupo |
| AuditCreationUser | VARCHAR(255) | NULL | Email del usuario que creó el grupo |
| AuditCreationDate | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Fecha de creación |
| AuditModificationUser | VARCHAR(255) | NULL | Email del usuario que modificó |
| AuditModificationDate | TIMESTAMP | NULL | Fecha de última modificación |
| AuditDeletionDate | TIMESTAMP | NULL | Soft delete - fecha de eliminación lógica |

**Índices**:
```sql
PK: Id
UK: UX_OrganizationGroup_GroupName (GroupName)
```

**DDL PostgreSQL**:
```sql
CREATE TABLE "ORGANIZATIONGROUP" (
    "Id" SERIAL PRIMARY KEY,
    "GroupName" VARCHAR(200) NOT NULL,
    "Description" VARCHAR(500),
    "AuditCreationUser" VARCHAR(255),
    "AuditCreationDate" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditModificationUser" VARCHAR(255),
    "AuditModificationDate" TIMESTAMP,
    "AuditDeletionDate" TIMESTAMP,
    
    CONSTRAINT "UX_OrganizationGroup_GroupName" UNIQUE ("GroupName")
);
```

### Tabla 2: ORGANIZATION

**Propósito**: Entidad principal de organizaciones clientes. Fuente de verdad para multi-tenancy.

**Campos**:

| Nombre Campo | Tipo PostgreSQL | Restricciones | Descripción |
|--------------|-----------------|---------------|-------------|
| Id | INTEGER | PK, SERIAL, NOT NULL | Identificador único técnico (PK Helix6) |
| SecurityCompanyId | INTEGER | UNIQUE, NOT NULL | Identificador de negocio inmutable (usado en JWT claim c_ids) |
| GroupId | INTEGER | FK → ORGANIZATIONGROUP(Id), NULL | Referencia opcional al grupo |
| Name | VARCHAR(200) | UNIQUE, NOT NULL | Nombre comercial de la organización |
| Acronym | VARCHAR(50) | NULL | Siglas o acrónimo de la organización (ej: ACME, IPO) |
| TaxId | VARCHAR(50) | UNIQUE, NOT NULL | Identificador fiscal (NIF/CIF/RFC) |
| Address | VARCHAR(300) | NULL | Dirección postal |
| City | VARCHAR(100) | NULL | Ciudad |
| PostalCode | VARCHAR(20) | NULL | Código postal |
| Country | VARCHAR(100) | NULL | País |
| ContactEmail | VARCHAR(255) | NULL | Email de contacto |
| ContactPhone | VARCHAR(50) | NULL | Teléfono de contacto |
| AuditCreationUser | VARCHAR(255) | NULL | Usuario que creó la organización |
| AuditCreationDate | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Fecha de creación (onboarding) |
| AuditModificationUser | VARCHAR(255) | NULL | Usuario que modificó |
| AuditModificationDate | TIMESTAMP | NULL | Fecha de última modificación |
| AuditDeletionDate | TIMESTAMP | NULL | Soft delete - fecha de eliminación |

**Índices**:
```sql
PK: Id
UK: UX_Organization_SecurityCompanyId (SecurityCompanyId)
UK: UX_Organization_Name (Name)
UK: UX_Organization_TaxId (TaxId)
IX: IX_Organization_GroupId (GroupId)
```

**DDL PostgreSQL**:
```sql
CREATE SEQUENCE "ORGANIZATION_SecurityCompanyId_seq" START WITH 1001;

CREATE TABLE "ORGANIZATION" (
    "Id" SERIAL PRIMARY KEY,
    "SecurityCompanyId" INTEGER NOT NULL DEFAULT nextval('"ORGANIZATION_SecurityCompanyId_seq"'),
    "GroupId" INTEGER,
    "Name" VARCHAR(200) NOT NULL,
    "Acronym" VARCHAR(50),
    "TaxId" VARCHAR(50) NOT NULL,
    "Address" VARCHAR(300),
    "City" VARCHAR(100),
    "PostalCode" VARCHAR(20),
    "Country" VARCHAR(100),
    "ContactEmail" VARCHAR(255),
    "ContactPhone" VARCHAR(50),
    "AuditCreationUser" VARCHAR(255),
    "AuditCreationDate" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditModificationUser" VARCHAR(255),
    "AuditModificationDate" TIMESTAMP,
    "AuditDeletionDate" TIMESTAMP,
    
    CONSTRAINT "UX_Organization_SecurityCompanyId" UNIQUE ("SecurityCompanyId"),
    CONSTRAINT "UX_Organization_Name" UNIQUE ("Name"),
    CONSTRAINT "UX_Organization_TaxId" UNIQUE ("TaxId"),
    CONSTRAINT "FK_Organization_OrganizationGroup" FOREIGN KEY ("GroupId") 
        REFERENCES "ORGANIZATIONGROUP"("Id") ON DELETE SET NULL
);

CREATE INDEX "IX_Organization_GroupId" ON "ORGANIZATION"("GroupId");
```

**Nota importante**: `SecurityCompanyId` se genera automáticamente mediante secuencia independiente, comenzando en 1001.

### Tabla 3: APPLICATION

**Propósito**: Catálogo de aplicaciones satélite del ecosistema (CRM, ERP, BI, etc.).

**Campos**:

| Nombre Campo | Tipo PostgreSQL | Restricciones | Descripción |
|--------------|-----------------|---------------|-------------|
| Id | INTEGER | PK, SERIAL, NOT NULL | Identificador único técnico |
| AppName | VARCHAR(100) | UNIQUE, NOT NULL | Nombre de la aplicación |
| Description | VARCHAR(500) | NULL | Descripción de la aplicación |
| RolePrefix | VARCHAR(10) | UNIQUE, NOT NULL | Prefijo para roles y módulos (ej: "STP", "CRM") |
| AuditCreationUser | VARCHAR(255) | NULL | Usuario que creó la aplicación |
| AuditCreationDate | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Fecha de creación |
| AuditModificationUser | VARCHAR(255) | NULL | Usuario que modificó |
| AuditModificationDate | TIMESTAMP | NULL | Fecha de modificación |
| AuditDeletionDate | TIMESTAMP | NULL | Soft delete |

**Índices**:
```sql
PK: Id
UK: UX_Application_AppName (AppName)
UK: UX_Application_RolePrefix (RolePrefix)
```

**DDL PostgreSQL**:
```sql
CREATE TABLE "APPLICATION" (
    "Id" SERIAL PRIMARY KEY,
    "AppName" VARCHAR(100) NOT NULL,
    "Description" VARCHAR(500),
    "RolePrefix" VARCHAR(10) NOT NULL,
    "AuditCreationUser" VARCHAR(255),
    "AuditCreationDate" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditModificationUser" VARCHAR(255),
    "AuditModificationDate" TIMESTAMP,
    "AuditDeletionDate" TIMESTAMP,
    
    CONSTRAINT "UX_Application_AppName" UNIQUE ("AppName"),
    CONSTRAINT "UX_Application_RolePrefix" UNIQUE ("RolePrefix")
);
```

### Tabla 4: APPLICATIONMODULE

**Propósito**: Módulos funcionales de cada aplicación. Permite habilitar/deshabilitar funcionalidades por organización.

**Campos**:

| Nombre Campo | Tipo PostgreSQL | Restricciones | Descripción |
|--------------|-----------------|---------------|-------------|
| Id | INTEGER | PK, SERIAL, NOT NULL | Identificador único del módulo |
| ApplicationId | INTEGER | FK → APPLICATION(Id), NOT NULL | Aplicación a la que pertenece |
| ModuleName | VARCHAR(100) | NOT NULL | Nombre del módulo (ej: "MSTP_Trafico") |
| Description | VARCHAR(500) | NULL | Descripción de funcionalidades |
| DisplayOrder | INTEGER | DEFAULT 0 | Orden de visualización |
| AuditCreationUser | VARCHAR(255) | NULL | Usuario que creó el módulo |
| AuditCreationDate | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Fecha de creación |
| AuditModificationUser | VARCHAR(255) | NULL | Usuario que modificó |
| AuditModificationDate | TIMESTAMP | NULL | Fecha de modificación |
| AuditDeletionDate | TIMESTAMP | NULL | Soft delete |

**Índices**:
```sql
PK: Id
UK: UX_ApplicationModule_AppId_ModuleName (ApplicationId, ModuleName)
IX: IX_ApplicationModule_ApplicationId (ApplicationId)
```

**DDL PostgreSQL**:
```sql
CREATE TABLE "APPLICATIONMODULE" (
    "Id" SERIAL PRIMARY KEY,
    "ApplicationId" INTEGER NOT NULL,
    "ModuleName" VARCHAR(100) NOT NULL,
    "Description" VARCHAR(500),
    "DisplayOrder" INTEGER DEFAULT 0,
    "AuditCreationUser" VARCHAR(255),
    "AuditCreationDate" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditModificationUser" VARCHAR(255),
    "AuditModificationDate" TIMESTAMP,
    "AuditDeletionDate" TIMESTAMP,
    
    CONSTRAINT "UX_ApplicationModule_AppId_ModuleName" UNIQUE ("ApplicationId", "ModuleName"),
    CONSTRAINT "FK_ApplicationModule_Application" FOREIGN KEY ("ApplicationId") 
        REFERENCES "APPLICATION"("Id") ON DELETE CASCADE
);

CREATE INDEX "IX_ApplicationModule_ApplicationId" ON "APPLICATIONMODULE"("ApplicationId");
```

### Tabla 6: ORGANIZATION_APPLICATIONMODULE

**Propósito**: Relación N:M que define qué organizaciones tienen acceso a qué módulos.

**Campos**:

| Nombre Campo | Tipo PostgreSQL | Restricciones | Descripción |
|--------------|-----------------|---------------|-------------|
| Id | INTEGER | PK, SERIAL, NOT NULL | Identificador único |
| ApplicationModuleId | INTEGER | FK → APPLICATIONMODULE(Id), NOT NULL | Módulo al que se concede acceso |
| OrganizationId | INTEGER | FK → ORGANIZATION(Id), NOT NULL | Organización que recibe acceso |
| AuditCreationUser | VARCHAR(255) | NULL | Usuario que concedió el acceso |
| AuditCreationDate | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Fecha de concesión |
| AuditModificationUser | VARCHAR(255) | NULL | Usuario que modificó |
| AuditModificationDate | TIMESTAMP | NULL | Fecha de modificación |
| AuditDeletionDate | TIMESTAMP | NULL | Soft delete (revocación) |

**Índices**:
```sql
PK: Id
UK: UX_OrgAppModule_ModuleId_OrgId (ApplicationModuleId, OrganizationId)
IX: IX_OrgAppModule_OrganizationId (OrganizationId)
```

**DDL PostgreSQL**:
```sql
CREATE TABLE "ORGANIZATION_APPLICATIONMODULE" (
    "Id" SERIAL PRIMARY KEY,
    "ApplicationModuleId" INTEGER NOT NULL,
    "OrganizationId" INTEGER NOT NULL,
    "AuditCreationUser" VARCHAR(255),
    "AuditCreationDate" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditModificationUser" VARCHAR(255),
    "AuditModificationDate" TIMESTAMP,
    "AuditDeletionDate" TIMESTAMP,
    
    CONSTRAINT "UX_OrgAppModule_ModuleId_OrgId" UNIQUE ("ApplicationModuleId", "OrganizationId"),
    CONSTRAINT "FK_OrgAppModule_ApplicationModule" FOREIGN KEY ("ApplicationModuleId") 
        REFERENCES "APPLICATIONMODULE"("Id") ON DELETE CASCADE,
    CONSTRAINT "FK_OrgAppModule_Organization" FOREIGN KEY ("OrganizationId") 
        REFERENCES "ORGANIZATION"("Id") ON DELETE CASCADE
);

CREATE INDEX "IX_OrgAppModule_OrganizationId" ON "ORGANIZATION_APPLICATIONMODULE"("OrganizationId");
```

### Tabla 7: AUDITLOG

**Propósito**: Registro inmutable de acciones críticas. **Nota**: En esta fase no se incluyen campos OldValue/NewValue JSON.

**Campos**:

| Nombre Campo | Tipo PostgreSQL | Restricciones | Descripción |
|--------------|-----------------|---------------|-------------|
| Id | BIGINT | PK, SERIAL, NOT NULL | Identificador único del log |
| EntityType | VARCHAR(50) | NOT NULL | Tipo de entidad (ej: "Organization") |
| EntityId | VARCHAR(50) | NOT NULL | ID de la entidad afectada |
| Action | VARCHAR(100) | NOT NULL | Acción realizada |
| UserId | INTEGER | NULL | ID del usuario que realizó la acción |
| Timestamp | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Momento de la acción |
| CorrelationId | VARCHAR(100) | NULL | ID de correlación para trazabilidad |
| AuditCreationUser | VARCHAR(255) | NULL | Usuario que creó el log |
| AuditCreationDate | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Fecha de creación |
| AuditModificationUser | VARCHAR(255) | NULL | Usuario que modificó (no aplica) |
| AuditModificationDate | TIMESTAMP | NULL | Fecha de modificación (no aplica) |
| AuditDeletionDate | TIMESTAMP | NULL | Soft delete (no aplica, tabla inmutable) |

**Índices**:
```sql
PK: Id
IX: IX_AuditLog_EntityType_EntityId (EntityType, EntityId)
IX: IX_AuditLog_Timestamp (Timestamp DESC)
IX: IX_AuditLog_UserId (UserId)
```

**DDL PostgreSQL**:
```sql
CREATE TABLE "AUDITLOG" (
    "Id" BIGSERIAL PRIMARY KEY,
    "EntityType" VARCHAR(50) NOT NULL,
    "EntityId" VARCHAR(50) NOT NULL,
    "Action" VARCHAR(100) NOT NULL,
    "UserId" INTEGER,
    "Timestamp" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "CorrelationId" VARCHAR(100),
    "AuditCreationUser" VARCHAR(255),
    "AuditCreationDate" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditModificationUser" VARCHAR(255),
    "AuditModificationDate" TIMESTAMP,
    "AuditDeletionDate" TIMESTAMP
);

CREATE INDEX "IX_AuditLog_EntityType_EntityId" ON "AUDITLOG"("EntityType", "EntityId");
CREATE INDEX "IX_AuditLog_Timestamp" ON "AUDITLOG"("Timestamp" DESC);
CREATE INDEX "IX_AuditLog_UserId" ON "AUDITLOG"("UserId");
```

**Nota importante**: Esta tabla es **append-only** (solo INSERT, no UPDATE ni DELETE). El campo `AuditDeletionDate` no se usa.

## SCRIPTS DBUP (DESPLIEGUE DE BASE DE DATOS)

> ⚠️ **Este proyecto NO usa EF Core Migrations**. Todos los cambios de esquema se gestionan mediante **DBUp** con scripts SQL embebidos en el proyecto `InfoportOneAdmon.Back.DB`.

### Script 1 — Estructura (obligatorio)

**Archivo**: `InfoportOneAdmon.Back.DB/Scripts/01020004_OrganizationInfrastructure.sql`

**Registro en `.csproj`** (añadir al `InfoportOneAdmon.Back.DB.csproj`):
```xml
<EmbeddedResource Include="Scripts\01020004_OrganizationInfrastructure.sql" />
```

**Contenido**: el DDL completo de la sección "Script SQL Completo" de este ticket. El script debe ser **idempotente** usando bloques `DO $$ ... $$` o `CREATE TABLE IF NOT EXISTS` / `CREATE INDEX IF NOT EXISTS` según sea necesario para PostgreSQL.

**Convención de nombre**: `NNNNNNNN_NombreDescriptivoPascalCase.sql` donde `NNNNNNNN` es el número de secuencia de 8 dígitos. DBUp aplica los scripts en orden alfanumérico estricto.

### Script 2 — Seed data (opcional)

**Archivo**: `InfoportOneAdmon.Back.DB/Scripts/01020005_OrganizationSeedData.sql`

**Registro en `.csproj`**:
```xml
<EmbeddedResource Include="Scripts\01020005_OrganizationSeedData.sql" />
```

**Contenido**: los `INSERT` de la sección "DATOS DE PRUEBA" de este ticket. Usar `INSERT ... ON CONFLICT DO NOTHING` para garantizar idempotencia.

### Verificación post-despliegue

DBUp aplica los scripts al iniciar la API. Para verificar manualmente:

```powershell
# Arrancar la API en local (DBUp se ejecuta durante el startup)
dotnet run --project InfoportOneAdmon.Back.Api
```

O ejecutar las queries de verificación de la sección correspondiente de este ticket directamente contra la BD.

### Rollback

DBUp no genera rollback automático. Para revertir:
- Crear un nuevo script `01020006_RollbackOrganizationInfrastructure.sql` que elimine los objetos en orden inverso (respetando FKs):

```sql
DROP TABLE IF EXISTS "ORGANIZATION_APPLICATIONMODULE";
DROP TABLE IF EXISTS "AUDITLOG";
DROP TABLE IF EXISTS "APPLICATIONMODULE";
DROP TABLE IF EXISTS "APPLICATION";
DROP TABLE IF EXISTS "ORGANIZATION";
DROP TABLE IF EXISTS "ORGANIZATIONGROUP";
DROP SEQUENCE IF EXISTS "ORGANIZATION_SecurityCompanyId_seq";
```

### Script SQL Completo (PostgreSQL)

```sql
-- =====================================================
-- Script de creación de estructura de BD
-- InfoportOneAdmon - Epic1 Organization Management
-- Motor: PostgreSQL 15+
-- =====================================================

-- 1. Crear secuencia para SecurityCompanyId
CREATE SEQUENCE "ORGANIZATION_SecurityCompanyId_seq" START WITH 1001;

-- 2. Tabla ORGANIZATIONGROUP
CREATE TABLE "ORGANIZATIONGROUP" (
    "Id" SERIAL PRIMARY KEY,
    "GroupName" VARCHAR(200) NOT NULL,
    "Description" VARCHAR(500),
    "AuditCreationUser" VARCHAR(255),
    "AuditCreationDate" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditModificationUser" VARCHAR(255),
    "AuditModificationDate" TIMESTAMP,
    "AuditDeletionDate" TIMESTAMP,
    
    CONSTRAINT "UX_OrganizationGroup_GroupName" UNIQUE ("GroupName")
);

-- 3. Tabla ORGANIZATION
CREATE TABLE "ORGANIZATION" (
    "Id" SERIAL PRIMARY KEY,
    "SecurityCompanyId" INTEGER NOT NULL DEFAULT nextval('"ORGANIZATION_SecurityCompanyId_seq"'),
    "GroupId" INTEGER,
    "Name" VARCHAR(200) NOT NULL,
    "Acronym" VARCHAR(50),
    "TaxId" VARCHAR(50) NOT NULL,
    "Address" VARCHAR(300),
    "City" VARCHAR(100),
    "PostalCode" VARCHAR(20),
    "Country" VARCHAR(100),
    "ContactEmail" VARCHAR(255),
    "ContactPhone" VARCHAR(50),
    "AuditCreationUser" VARCHAR(255),
    "AuditCreationDate" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditModificationUser" VARCHAR(255),
    "AuditModificationDate" TIMESTAMP,
    "AuditDeletionDate" TIMESTAMP,
    
    CONSTRAINT "UX_Organization_SecurityCompanyId" UNIQUE ("SecurityCompanyId"),
    CONSTRAINT "UX_Organization_Name" UNIQUE ("Name"),
    CONSTRAINT "UX_Organization_TaxId" UNIQUE ("TaxId"),
    CONSTRAINT "FK_Organization_OrganizationGroup" FOREIGN KEY ("GroupId") 
        REFERENCES "ORGANIZATIONGROUP"("Id") ON DELETE SET NULL
);

CREATE INDEX "IX_Organization_GroupId" ON "ORGANIZATION"("GroupId");

-- 4. Tabla APPLICATION
CREATE TABLE "APPLICATION" (
    "Id" SERIAL PRIMARY KEY,
    "AppName" VARCHAR(100) NOT NULL,
    "Description" VARCHAR(500),
    "RolePrefix" VARCHAR(10) NOT NULL,
    "AuditCreationUser" VARCHAR(255),
    "AuditCreationDate" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditModificationUser" VARCHAR(255),
    "AuditModificationDate" TIMESTAMP,
    "AuditDeletionDate" TIMESTAMP,
    
    CONSTRAINT "UX_Application_AppName" UNIQUE ("AppName"),
    CONSTRAINT "UX_Application_RolePrefix" UNIQUE ("RolePrefix")
);

-- 5. Tabla APPLICATIONMODULE
CREATE TABLE "APPLICATIONMODULE" (
    "Id" SERIAL PRIMARY KEY,
    "ApplicationId" INTEGER NOT NULL,
    "ModuleName" VARCHAR(100) NOT NULL,
    "Description" VARCHAR(500),
    "DisplayOrder" INTEGER DEFAULT 0,
    "AuditCreationUser" VARCHAR(255),
    "AuditCreationDate" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditModificationUser" VARCHAR(255),
    "AuditModificationDate" TIMESTAMP,
    "AuditDeletionDate" TIMESTAMP,
    
    CONSTRAINT "UX_ApplicationModule_AppId_ModuleName" UNIQUE ("ApplicationId", "ModuleName"),
    CONSTRAINT "FK_ApplicationModule_Application" FOREIGN KEY ("ApplicationId") 
        REFERENCES "APPLICATION"("Id") ON DELETE CASCADE
);

CREATE INDEX "IX_ApplicationModule_ApplicationId" ON "APPLICATIONMODULE"("ApplicationId");

-- 6. Tabla ORGANIZATION_APPLICATIONMODULE
CREATE TABLE "ORGANIZATION_APPLICATIONMODULE" (
    "Id" SERIAL PRIMARY KEY,
    "ApplicationModuleId" INTEGER NOT NULL,
    "OrganizationId" INTEGER NOT NULL,
    "AuditCreationUser" VARCHAR(255),
    "AuditCreationDate" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditModificationUser" VARCHAR(255),
    "AuditModificationDate" TIMESTAMP,
    "AuditDeletionDate" TIMESTAMP,
    
    CONSTRAINT "UX_OrgAppModule_ModuleId_OrgId" UNIQUE ("ApplicationModuleId", "OrganizationId"),
    CONSTRAINT "FK_OrgAppModule_ApplicationModule" FOREIGN KEY ("ApplicationModuleId") 
        REFERENCES "APPLICATIONMODULE"("Id") ON DELETE CASCADE,
    CONSTRAINT "FK_OrgAppModule_Organization" FOREIGN KEY ("OrganizationId") 
        REFERENCES "ORGANIZATION"("Id") ON DELETE CASCADE
);

CREATE INDEX "IX_OrgAppModule_OrganizationId" ON "ORGANIZATION_APPLICATIONMODULE"("OrganizationId");

-- 7. Tabla AUDITLOG
CREATE TABLE "AUDITLOG" (
    "Id" BIGSERIAL PRIMARY KEY,
    "EntityType" VARCHAR(50) NOT NULL,
    "EntityId" VARCHAR(50) NOT NULL,
    "Action" VARCHAR(100) NOT NULL,
    "UserId" INTEGER,
    "Timestamp" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "CorrelationId" VARCHAR(100),
    "AuditCreationUser" VARCHAR(255),
    "AuditCreationDate" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditModificationUser" VARCHAR(255),
    "AuditModificationDate" TIMESTAMP,
    "AuditDeletionDate" TIMESTAMP
);

CREATE INDEX "IX_AuditLog_EntityType_EntityId" ON "AUDITLOG"("EntityType", "EntityId");
CREATE INDEX "IX_AuditLog_Timestamp" ON "AUDITLOG"("Timestamp" DESC);
CREATE INDEX "IX_AuditLog_UserId" ON "AUDITLOG"("UserId");

-- =====================================================
-- Fin del script de creación
-- =====================================================
```

## DATOS DE PRUEBA (SEED DATA)

Script SQL opcional para poblar la base de datos con datos de prueba:

```sql
-- Insertar grupos de organizaciones
INSERT INTO "ORGANIZATIONGROUP" ("GroupName", "Description", "AuditCreationUser", "AuditCreationDate")
VALUES 
    ('Holding Norte', 'Grupo de empresas del norte de España', 'admin@infoportone.com', CURRENT_TIMESTAMP),
    ('Grupo Logístico Peninsular', 'Consorcio de empresas de logística', 'admin@infoportone.com', CURRENT_TIMESTAMP),
    ('Franquicia Retail Sur', 'Red de franquicias comerciales', 'admin@infoportone.com', CURRENT_TIMESTAMP);

-- Insertar organizaciones de prueba
INSERT INTO "ORGANIZATION" ("Name", "TaxId", "Address", "City", "PostalCode", "Country", "ContactEmail", "ContactPhone", "GroupId", "AuditCreationUser", "AuditCreationDate")
VALUES 
    ('Transportes Rápidos S.L.', 'B12345678', 'Calle Principal 123', 'Barcelona', '08001', 'España', 'admin@transportesrapidos.com', '+34912345678', 1, 'admin@infoportone.com', CURRENT_TIMESTAMP),
    ('Logística Internacional S.A.', 'A98765432', 'Avenida del Puerto 456', 'Valencia', '46001', 'España', 'contacto@logisticaint.com', '+34923456789', 2, 'admin@infoportone.com', CURRENT_TIMESTAMP),
    ('Comercial Mediterráneo S.L.', 'B55555555', 'Plaza Mayor 1', 'Málaga', '29001', 'España', 'info@comercialmed.com', '+34955555555', 3, 'admin@infoportone.com', CURRENT_TIMESTAMP);

-- Insertar aplicaciones
INSERT INTO "APPLICATION" ("AppName", "Description", "RolePrefix", "AuditCreationUser", "AuditCreationDate")
VALUES 
    ('Sintraport', 'Sistema de gestión logística y portuaria', 'STP', 'admin@infoportone.com', CURRENT_TIMESTAMP),
    ('CRM Comercial', 'Sistema de gestión de relaciones con clientes', 'CRM', 'admin@infoportone.com', CURRENT_TIMESTAMP),
    ('ERP Financiero', 'Sistema de planificación de recursos empresariales', 'ERP', 'admin@infoportone.com', CURRENT_TIMESTAMP);

-- Insertar módulos
INSERT INTO "APPLICATIONMODULE" ("ApplicationId", "ModuleName", "Description", "DisplayOrder", "AuditCreationUser", "AuditCreationDate")
VALUES 
    (1, 'MSTP_Trafico', 'Módulo de gestión de tráfico y asignaciones', 10, 'admin@infoportone.com', CURRENT_TIMESTAMP),
    (1, 'MSTP_Almacen', 'Módulo de gestión de almacén', 20, 'admin@infoportone.com', CURRENT_TIMESTAMP),
    (1, 'MSTP_Facturacion', 'Módulo de facturación electrónica', 30, 'admin@infoportone.com', CURRENT_TIMESTAMP),
    (2, 'MCRM_Oportunidades', 'Módulo de gestión de oportunidades de venta', 10, 'admin@infoportone.com', CURRENT_TIMESTAMP),
    (2, 'MCRM_Facturacion', 'Módulo de facturación de ventas', 20, 'admin@infoportone.com', CURRENT_TIMESTAMP);

-- Asignar módulos a organizaciones
INSERT INTO "ORGANIZATION_APPLICATIONMODULE" ("ApplicationModuleId", "OrganizationId", "AuditCreationUser", "AuditCreationDate")
VALUES 
    (1, 1, 'admin@infoportone.com', CURRENT_TIMESTAMP), -- Transportes Rápidos tiene MSTP_Trafico
    (2, 1, 'admin@infoportone.com', CURRENT_TIMESTAMP), -- Transportes Rápidos tiene MSTP_Almacen
    (1, 2, 'admin@infoportone.com', CURRENT_TIMESTAMP), -- Logística Internacional tiene MSTP_Trafico
    (2, 2, 'admin@infoportone.com', CURRENT_TIMESTAMP), -- Logística Internacional tiene MSTP_Almacen
    (3, 2, 'admin@infoportone.com', CURRENT_TIMESTAMP), -- Logística Internacional tiene MSTP_Facturacion
    (4, 3, 'admin@infoportone.com', CURRENT_TIMESTAMP), -- Comercial Mediterráneo tiene MCRM_Oportunidades
    (5, 3, 'admin@infoportone.com', CURRENT_TIMESTAMP); -- Comercial Mediterráneo tiene MCRM_Facturacion
```

## VERIFICACIÓN DE LA IMPLEMENTACIÓN

### 1. Verificar que las tablas se crearon correctamente

```sql
-- Listar todas las tablas creadas
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'Admon' 
    AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Verificar constraints de cada tabla
SELECT 
    tc.table_name, 
    tc.constraint_name, 
    tc.constraint_type
FROM information_schema.table_constraints tc
WHERE tc.table_schema = 'Admon'
ORDER BY tc.table_name, tc.constraint_type;
```

### 2. Verificar índices creados

```sql
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'Admon'
ORDER BY tablename, indexname;
```

### 3. Verificar foreign keys

```sql
SELECT
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_schema = 'Admon'
ORDER BY tc.table_name;
```

### 4. Probar insert en ORGANIZATION y verificar SecurityCompanyId autogenerado

```sql
-- Insertar organización de prueba
INSERT INTO "ORGANIZATION" ("Name", "TaxId", "AuditCreationUser")
VALUES ('Test Organization', 'T99999999', 'test@test.com')
RETURNING "Id", "SecurityCompanyId";

-- Verificar que SecurityCompanyId se autogeneró correctamente (debe ser >= 1001)
SELECT "Id", "SecurityCompanyId", "Name", "TaxId" 
FROM "ORGANIZATION"
WHERE "TaxId" = 'T99999999';

-- Limpiar
DELETE FROM "ORGANIZATION" WHERE "TaxId" = 'T99999999';
```

### 5. Probar soft delete

```sql
-- Simular soft delete
UPDATE "ORGANIZATION" 
SET "AuditDeletionDate" = CURRENT_TIMESTAMP
WHERE "TaxId" = 'B12345678';

-- Verificar que se estableció AuditDeletionDate
SELECT "Id", "Name", "AuditDeletionDate"
FROM "ORGANIZATION"
WHERE "TaxId" = 'B12345678';

-- Reactivar
UPDATE "ORGANIZATION" 
SET "AuditDeletionDate" = NULL
WHERE "TaxId" = 'B12345678';
```

## CRITERIOS DE ACEPTACIÓN

- [ ] Todas las 7 tablas se crean correctamente en PostgreSQL
- [ ] El script `01020004_OrganizationInfrastructure.sql` está registrado como `EmbeddedResource` en `InfoportOneAdmon.Back.DB.csproj`
- [ ] DBUp aplica el script correctamente al arrancar la API (sin errores en los logs de startup)
- [ ] Todos los índices únicos (UK) están configurados correctamente
- [ ] Todos los índices de búsqueda (IX) están creados
- [ ] Todas las foreign keys (FK) están configuradas con el ON DELETE correcto
- [ ] La secuencia `ORGANIZATION_SecurityCompanyId_seq` se crea y comienza en 1001
- [ ] Los campos `SecurityCompanyId` se autogeneran correctamente al insertar organizaciones
- [ ] Los campos de auditoría Helix6 (`AuditCreationDate`, `AuditModificationDate`, `AuditDeletionDate`) funcionan correctamente
- [ ] El soft delete funciona (establecer `AuditDeletionDate` marca como eliminado, NULL reactiva)
- [ ] Las restricciones de unicidad previenen duplicados (Name, TaxId, SecurityCompanyId, etc.)
- [ ] La tabla AUDITLOG acepta inserts pero no se puede modificar (append-only)
- [ ] Los datos de prueba (seed data) se insertan correctamente
- [ ] Las queries de verificación retornan los resultados esperados
- [ ] No hay errores de constraints al insertar datos relacionados
- [ ] El script SQL es idempotente (`CREATE TABLE IF NOT EXISTS`, `CREATE INDEX IF NOT EXISTS`, bloques `DO $$`)
- [ ] La documentación de cada tabla está completa y clara
- [ ] Los comentarios en el DDL explican decisiones de diseño importantes

## DEPENDENCIAS

- **PostgreSQL 15+**: Base de datos instalada y ejecutándose
- **.NET 8 SDK**: Para compilar y ejecutar el proyecto
- **DBUp**: Librería de despliegue de scripts SQL (ya configurada en `InfoportOneAdmon.Back.DB`)
- **Npgsql.EntityFrameworkCore.PostgreSQL** (9.0.2): Provider de EF Core para consultas/scaffolding (NO para migrations)
- **Helix6.Base.Domain**: Para interfaces `IEntityBase` y atributos de auditoría
- **Acceso a base de datos**: Usuario con permisos CREATE TABLE, CREATE SEQUENCE, CREATE INDEX
- **DbContext configurado**: `EntityModel.cs` debe estar configurado con connection string de PostgreSQL

## RECURSOS

- **Documentación de PostgreSQL**: https://www.postgresql.org/docs/15/index.html
- **DBUp (despliegue de scripts)**: https://dbup.readthedocs.io/en/latest/
- **Npgsql Provider**: https://www.npgsql.org/efcore/
- **Convenciones de scripts Back.DB**: ver `Helix6Back.Database.agent.md` sección "Convenciones del proyecto"
- **Helix6 Backend Architecture**: [Helix6_Backend_Architecture.md](../../../Helix6_Backend_Architecture.md) - Sección 2.5 (DataModel)
- **Product Documentation**: [readme.md](../../../readme.md) - Sección 3 (Modelo de Datos)
- **User Story**: [ORG001_Gestion_Organizacion.md](../ORG001_Gestion_Organizacion.md)

=============================================================
