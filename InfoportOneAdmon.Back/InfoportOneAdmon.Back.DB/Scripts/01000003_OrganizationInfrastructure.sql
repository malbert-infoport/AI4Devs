-- =====================================================
-- Script   : 01020004_OrganizationInfrastructure.sql
-- Proyecto  : InfoportOneAdmon - Epic1 Organization Management
-- Motor     : PostgreSQL 15+
-- Nota      : Todos los campos de fecha usan TIMESTAMPTZ (timestamp with time zone)
-- Despliegue: DBUp (EmbeddedResource en InfoportOneAdmon.Back.DB)
-- Fecha     : 2026-03-02
-- Descripción:
--   Crea la infraestructura completa de tablas para la gestión
--   de organizaciones clientes: OrganizationGroup, Organization,
--   Application, ApplicationModule, Organization_ApplicationModule
--   y AuditLog.
--   El script es IDEMPOTENTE: puede ejecutarse múltiples veces
--   sin errores ni efectos secundarios.
-- =====================================================

-- -------------------------------------------------------
-- 0. Schema de la aplicación
-- -------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS "Admon";

-- -------------------------------------------------------
-- 1. Secuencia para SecurityCompanyId (comienza en 1001)
-- -------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_sequences
        WHERE schemaname = 'Admon'
          AND sequencename = 'Organization_SecurityCompanyId_seq'
    ) THEN
        CREATE SEQUENCE "Admon"."Organization_SecurityCompanyId_seq" START WITH 1001;
    END IF;
END
$$;

-- -------------------------------------------------------
-- 2. Tabla OrganizationGroup
--    Agrupaciones lógicas de organizaciones (holdings,
--    consorcios, franquicias).
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS "Admon"."OrganizationGroup" (
    "Id"                    SERIAL          PRIMARY KEY,
    "GroupName"             VARCHAR(200)    NOT NULL,
    "Description"           VARCHAR(500),
    "AuditCreationUser"     VARCHAR(255),
    "AuditCreationDate"     TIMESTAMPTZ     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditModificationUser" VARCHAR(255),
    "AuditModificationDate" TIMESTAMPTZ,
    "AuditDeletionDate"     TIMESTAMPTZ
);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'UX_OrganizationGroup_GroupName'
    ) THEN
        ALTER TABLE "Admon"."OrganizationGroup"
            ADD CONSTRAINT "UX_OrganizationGroup_GroupName" UNIQUE ("GroupName");
    END IF;
END
$$;

-- -------------------------------------------------------
-- 3. Tabla Organization
--    Entidad principal de organizaciones clientes.
--    SecurityCompanyId es el identificador de negocio
--    inmutable (usado en JWT claim c_ids).
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS "Admon"."Organization" (
    "Id"                    SERIAL          PRIMARY KEY,
    "SecurityCompanyId"     INTEGER         NOT NULL DEFAULT nextval('"Admon"."Organization_SecurityCompanyId_seq"'),
    "GroupId"               INTEGER,
    "Name"                  VARCHAR(200)    NOT NULL,
    "Acronym"               VARCHAR(50),
    "TaxId"                 VARCHAR(50)     NOT NULL,
    "Address"               VARCHAR(300),
    "City"                  VARCHAR(100),
    "PostalCode"            VARCHAR(20),
    "Country"               VARCHAR(100),
    "ContactEmail"          VARCHAR(255),
    "ContactPhone"          VARCHAR(50),
    "AuditCreationUser"     VARCHAR(255),
    "AuditCreationDate"     TIMESTAMPTZ     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditModificationUser" VARCHAR(255),
    "AuditModificationDate" TIMESTAMPTZ,
    "AuditDeletionDate"     TIMESTAMPTZ
);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'UX_Organization_SecurityCompanyId') THEN
        ALTER TABLE "Admon"."Organization" ADD CONSTRAINT "UX_Organization_SecurityCompanyId" UNIQUE ("SecurityCompanyId");
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'UX_Organization_Name') THEN
        ALTER TABLE "Admon"."Organization" ADD CONSTRAINT "UX_Organization_Name" UNIQUE ("Name");
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'UX_Organization_TaxId') THEN
        ALTER TABLE "Admon"."Organization" ADD CONSTRAINT "UX_Organization_TaxId" UNIQUE ("TaxId");
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'FK_Organization_OrganizationGroup') THEN
        ALTER TABLE "Admon"."Organization"
            ADD CONSTRAINT "FK_Organization_OrganizationGroup"
            FOREIGN KEY ("GroupId") REFERENCES "Admon"."OrganizationGroup"("Id") ON DELETE SET NULL;
    END IF;
END
$$;

CREATE INDEX IF NOT EXISTS "IX_Organization_GroupId" ON "Admon"."Organization"("GroupId");

-- -------------------------------------------------------
-- 4. Tabla Application
--    Catálogo de aplicaciones satélite del ecosistema.
--    RolePrefix se usa para nomenclatura de roles y módulos.
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS "Admon"."Application" (
    "Id"                    SERIAL          PRIMARY KEY,
    "AppName"               VARCHAR(100)    NOT NULL,
    "Description"           VARCHAR(500),
    "RolePrefix"            VARCHAR(10)     NOT NULL,
    "AuditCreationUser"     VARCHAR(255),
    "AuditCreationDate"     TIMESTAMPTZ     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditModificationUser" VARCHAR(255),
    "AuditModificationDate" TIMESTAMPTZ,
    "AuditDeletionDate"     TIMESTAMPTZ
);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'UX_Application_AppName') THEN
        ALTER TABLE "Admon"."Application" ADD CONSTRAINT "UX_Application_AppName" UNIQUE ("AppName");
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'UX_Application_RolePrefix') THEN
        ALTER TABLE "Admon"."Application" ADD CONSTRAINT "UX_Application_RolePrefix" UNIQUE ("RolePrefix");
    END IF;
END
$$;

-- -------------------------------------------------------
-- 5. Tabla ApplicationModule
--    Módulos funcionales de cada aplicación. Permite
--    habilitar/deshabilitar funcionalidades por organización.
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS "Admon"."ApplicationModule" (
    "Id"                    SERIAL          PRIMARY KEY,
    "ApplicationId"         INTEGER         NOT NULL,
    "ModuleName"            VARCHAR(100)    NOT NULL,
    "Description"           VARCHAR(500),
    "DisplayOrder"          INTEGER         DEFAULT 0,
    "AuditCreationUser"     VARCHAR(255),
    "AuditCreationDate"     TIMESTAMPTZ     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditModificationUser" VARCHAR(255),
    "AuditModificationDate" TIMESTAMPTZ,
    "AuditDeletionDate"     TIMESTAMPTZ
);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'UX_ApplicationModule_AppId_ModuleName') THEN
        ALTER TABLE "Admon"."ApplicationModule"
            ADD CONSTRAINT "UX_ApplicationModule_AppId_ModuleName" UNIQUE ("ApplicationId", "ModuleName");
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'FK_ApplicationModule_Application') THEN
        ALTER TABLE "Admon"."ApplicationModule"
            ADD CONSTRAINT "FK_ApplicationModule_Application"
            FOREIGN KEY ("ApplicationId") REFERENCES "Admon"."Application"("Id") ON DELETE CASCADE;
    END IF;
END
$$;

CREATE INDEX IF NOT EXISTS "IX_ApplicationModule_ApplicationId" ON "Admon"."ApplicationModule"("ApplicationId");

-- -------------------------------------------------------
-- 6. Tabla Organization_ApplicationModule
--    Relación N:M que define qué organizaciones tienen
--    acceso a qué módulos. AuditDeletionDate actúa como
--    revocación de acceso (soft delete).
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS "Admon"."Organization_ApplicationModule" (
    "Id"                    SERIAL          PRIMARY KEY,
    "ApplicationModuleId"   INTEGER         NOT NULL,
    "OrganizationId"        INTEGER         NOT NULL,
    "AuditCreationUser"     VARCHAR(255),
    "AuditCreationDate"     TIMESTAMPTZ     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditModificationUser" VARCHAR(255),
    "AuditModificationDate" TIMESTAMPTZ,
    "AuditDeletionDate"     TIMESTAMPTZ
);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'UX_OrgAppModule_ModuleId_OrgId') THEN
        ALTER TABLE "Admon"."Organization_ApplicationModule"
            ADD CONSTRAINT "UX_OrgAppModule_ModuleId_OrgId" UNIQUE ("ApplicationModuleId", "OrganizationId");
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'FK_OrgAppModule_ApplicationModule') THEN
        ALTER TABLE "Admon"."Organization_ApplicationModule"
            ADD CONSTRAINT "FK_OrgAppModule_ApplicationModule"
            FOREIGN KEY ("ApplicationModuleId") REFERENCES "Admon"."ApplicationModule"("Id") ON DELETE CASCADE;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'FK_OrgAppModule_Organization') THEN
        ALTER TABLE "Admon"."Organization_ApplicationModule"
            ADD CONSTRAINT "FK_OrgAppModule_Organization"
            FOREIGN KEY ("OrganizationId") REFERENCES "Admon"."Organization"("Id") ON DELETE CASCADE;
    END IF;
END
$$;

CREATE INDEX IF NOT EXISTS "IX_OrgAppModule_OrganizationId" ON "Admon"."Organization_ApplicationModule"("OrganizationId");

-- -------------------------------------------------------
-- 7. Tabla AuditLog
--    Registro INMUTABLE (append-only) de acciones críticas.
--    No incluye campos OldValue/NewValue en esta fase.
--    AuditDeletionDate no se usa (tabla no soft-deleteable).
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS "Admon"."AuditLog" (
    "Id"                    BIGSERIAL       PRIMARY KEY,
    "EntityType"            VARCHAR(50)     NOT NULL,
    "EntityId"              VARCHAR(50)     NOT NULL,
    "Action"                VARCHAR(100)    NOT NULL,
    "UserId"                INTEGER,
    "Timestamp"             TIMESTAMPTZ     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "CorrelationId"         VARCHAR(100),
    "AuditCreationUser"     VARCHAR(255),
    "AuditCreationDate"     TIMESTAMPTZ     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditModificationUser" VARCHAR(255),
    "AuditModificationDate" TIMESTAMPTZ,
    "AuditDeletionDate"     TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS "IX_AuditLog_EntityType_EntityId" ON "Admon"."AuditLog"("EntityType", "EntityId");
CREATE INDEX IF NOT EXISTS "IX_AuditLog_Timestamp"           ON "Admon"."AuditLog"("Timestamp" DESC);
CREATE INDEX IF NOT EXISTS "IX_AuditLog_UserId"              ON "Admon"."AuditLog"("UserId");

-- =====================================================
-- Fin del script 01000003_OrganizationInfrastructure
-- =====================================================
