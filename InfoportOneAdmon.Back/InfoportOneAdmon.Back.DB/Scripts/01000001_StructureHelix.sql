-- Source: 01020001_StructureHelix .sql

-- =====================================================================================
-- EXTENSIONES
-- =====================================================================================

-- Extensión citext: permite comparaciones case-insensitive en campos de texto
CREATE EXTENSION IF NOT EXISTS citext;

CREATE SCHEMA IF NOT EXISTS "Helix6_Internal";
CREATE SCHEMA IF NOT EXISTS "Helix6_Security";

    CREATE TABLE IF NOT EXISTS "Helix6_Security"."SecurityCompanyConfiguration" (
        "Id" integer PRIMARY KEY,
        "HostEmail" varchar(50),
        "PortEmail" integer,
        "UserEmail" varchar(50),
        "PasswordEmail" varchar(50),
        "DefaultCredentialsEmail" boolean,
        "SSLEmail" boolean,
        "AuditCreationUser" varchar(70),
        "AuditModificationUser" varchar(70),
        "AuditCreationDate" timestamptz,
        "AuditModificationDate" timestamptz,
        "AuditDeletionDate" timestamptz
    );

    
    CREATE TABLE IF NOT EXISTS "Helix6_Security"."SecurityModule" (
        "Id" integer PRIMARY KEY,
        "Description" varchar(200) NOT NULL,
        "AuditCreationUser" varchar(70),
        "AuditModificationUser" varchar(70),
        "AuditCreationDate" timestamptz,
        "AuditModificationDate" timestamptz,
        "AuditDeletionDate" timestamptz
    );
    CREATE UNIQUE INDEX "UK_SecurityModule" ON "Helix6_Security"."SecurityModule" ("Description");

    
    CREATE TABLE IF NOT EXISTS "Helix6_Security"."SecurityAccessOption" (
        "Id" integer PRIMARY KEY,
        "SecurityModuleId" integer NOT NULL,
        "Description" varchar(200) NOT NULL,
        "AuditCreationUser" varchar(70),
        "AuditModificationUser" varchar(70),
        "AuditCreationDate" timestamptz,
        "AuditModificationDate" timestamptz,
        "AuditDeletionDate" timestamptz
    );
    CREATE UNIQUE INDEX "UK_SecurityAccessOption" ON "Helix6_Security"."SecurityAccessOption" ("Description", "SecurityModuleId");

    
    CREATE TABLE IF NOT EXISTS "Helix6_Security"."SecurityAccessOptionLevel" (
        "Id" integer PRIMARY KEY,
        "SecurityAccessOptionId" integer NOT NULL,
        "Controller" varchar(200) NOT NULL,
        "SecurityLevel" integer NOT NULL,
        "AuditCreationUser" varchar(70),
        "AuditModificationUser" varchar(70),
        "AuditCreationDate" timestamptz,
        "AuditModificationDate" timestamptz,
        "AuditDeletionDate" timestamptz
    );
    CREATE UNIQUE INDEX "UK_SecurityAccessOptionLevel" ON "Helix6_Security"."SecurityAccessOptionLevel" ("SecurityAccessOptionId", "Controller");

    
    CREATE TABLE IF NOT EXISTS "Helix6_Security"."SecurityCompany" (
        "Id" integer PRIMARY KEY,
        "SecurityCompanyGroupId" integer NOT NULL,
        "Name" varchar(200) NOT NULL,
        "Cif" varchar(20),
        "SecurityCompanyConfigurationId" integer,
        "AuditCreationUser" varchar(70),
        "AuditModificationUser" varchar(70),
        "AuditCreationDate" timestamptz,
        "AuditModificationDate" timestamptz,
        "AuditDeletionDate" timestamptz
    );
    CREATE UNIQUE INDEX "UK_SecurityCompany" ON "Helix6_Security"."SecurityCompany" ("SecurityCompanyGroupId", "Name");

    
    CREATE TABLE IF NOT EXISTS "Helix6_Security"."SecurityCompanyGroup" (
        "Id" integer PRIMARY KEY,
        "Name" varchar(200) NOT NULL,
        "AuditCreationUser" varchar(70),
        "AuditModificationUser" varchar(70),
        "AuditCreationDate" timestamptz,
        "AuditModificationDate" timestamptz,
        "AuditDeletionDate" timestamptz
    );
    CREATE INDEX "UK_SecurityCompanyGroup" ON "Helix6_Security"."SecurityCompanyGroup" ("Name");

    
    CREATE TABLE IF NOT EXISTS "Helix6_Security"."SecurityProfile" (
        "Id" integer generated always as identity PRIMARY KEY,
        "SecurityCompanyId" integer NOT NULL,
        "Description" varchar(200) NOT NULL,
        "Rol" varchar(100),
        "AuditCreationUser" varchar(70),
        "AuditModificationUser" varchar(70),
        "AuditCreationDate" timestamptz,
        "AuditModificationDate" timestamptz,
        "AuditDeletionDate" timestamptz
    );
    CREATE UNIQUE INDEX "UK_SecurityProfile" ON "Helix6_Security"."SecurityProfile" ("Description", "SecurityCompanyId");

    
    CREATE TABLE IF NOT EXISTS "Helix6_Security"."SecurityProfile_SecurityAccessOption" (
        "Id" integer generated always as identity PRIMARY KEY,
        "SecurityProfileId" integer NOT NULL,
        "SecurityAccessOptionId" integer NOT NULL,
        "AuditCreationUser" varchar(70),
        "AuditModificationUser" varchar(70),
        "AuditCreationDate" timestamptz,
        "AuditModificationDate" timestamptz,
        "AuditDeletionDate" timestamptz
    );
    CREATE UNIQUE INDEX "UK_SecurityProfile_SecurityAccessOption" ON "Helix6_Security"."SecurityProfile_SecurityAccessOption" ("SecurityAccessOptionId", "SecurityProfileId");

    
    CREATE TABLE IF NOT EXISTS "Helix6_Security"."SecurityUser" (
        "Id" integer generated always as identity PRIMARY KEY,
        "SecurityCompanyId" integer NOT NULL,
        "UserIdentifier" varchar(200) NOT NULL,
        "Login" varchar(50),
        "Name" varchar(200),
        "DisplayName" varchar(200),
        "Mail" varchar(200),
        "OrganizationCif" varchar(50),
        "OrganizationCode" varchar(50),
        "OrganizationName" varchar(200),
        "SecurityUserConfigurationId" integer,
        "AuditCreationUser" varchar(70),
        "AuditModificationUser" varchar(70),
        "AuditCreationDate" timestamptz,
        "AuditModificationDate" timestamptz,
        "AuditDeletionDate" timestamptz
    );
    CREATE UNIQUE INDEX "UK_SecurityUser" ON "Helix6_Security"."SecurityUser" ("SecurityCompanyId", "UserIdentifier");

    
    CREATE TABLE IF NOT EXISTS "Helix6_Security"."SecurityUserConfiguration" (
        "Id" integer generated always as identity PRIMARY KEY,
        "Pagination" integer NOT NULL,
        "ModalPagination" integer NOT NULL,
        "Language" varchar(10) NOT NULL,
        "LastConnectionDate" timestamp,
        "AuditCreationUser" varchar(70),
        "AuditModificationUser" varchar(70),
        "AuditCreationDate" timestamptz,
        "AuditModificationDate" timestamptz,
        "AuditDeletionDate" timestamptz
    );

    
    CREATE TABLE IF NOT EXISTS "Helix6_Security"."SecurityUserGridConfiguration" (
        "Id" integer generated always as identity PRIMARY KEY,
        "SecurityUserId" integer NOT NULL,
        "Entity" varchar(100) NOT NULL,
        "Description" varchar(100) NOT NULL,
        "DefaultConfiguration" boolean NOT NULL,
        "Configuration" text NOT NULL,
        "AuditCreationUser" varchar(70),
        "AuditModificationUser" varchar(70),
        "AuditCreationDate" timestamptz,
        "AuditModificationDate" timestamptz,
        "AuditDeletionDate" timestamptz
    );
    CREATE UNIQUE INDEX "UK_SecurityUserGridConfiguration" ON "Helix6_Security"."SecurityUserGridConfiguration" ("SecurityUserId", "Entity", "Description");

CREATE OR REPLACE VIEW "Helix6_Security"."Permissions" AS
SELECT
    ROW_NUMBER() OVER (ORDER BY AO."Id" ASC)::int AS "Id",
    AO."Id" AS "SecurityAccessOptionId",
    AO."Description" AS "SecurityAccessOption",
    AOL."Controller",
    AOL."SecurityLevel",
    P."Description" AS "Profile",
    P."Rol",
    M."Description" AS "Module",
    C."Id" AS "SecurityCompanyId",
    C."Name" AS "SecurityCompany",
    AO."AuditCreationUser",
    AO."AuditModificationUser",
    AO."AuditCreationDate",
    AO."AuditModificationDate",
    AO."AuditDeletionDate"
FROM "Helix6_Security"."SecurityAccessOption" AS AO
LEFT JOIN "Helix6_Security"."SecurityAccessOptionLevel" AOL ON AOL."SecurityAccessOptionId" = AO."Id"
LEFT JOIN "Helix6_Security"."SecurityProfile_SecurityAccessOption" PAO ON PAO."SecurityAccessOptionId" = AO."Id"
LEFT JOIN "Helix6_Security"."SecurityProfile" P ON PAO."SecurityProfileId" = P."Id"
LEFT JOIN "Helix6_Security"."SecurityModule" M ON AO."SecurityModuleId" = M."Id"
LEFT JOIN "Helix6_Security"."SecurityCompany" C ON P."SecurityCompanyId" = C."Id";

    
CREATE OR REPLACE PROCEDURE "Helix6_Internal"."UpdateFieldDescription"(
    p_esquema TEXT,
    p_tabla TEXT,
    p_columna TEXT,
    p_descripcion TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    EXECUTE format(
        'COMMENT ON COLUMN %I.%I.%I IS %L',
        p_esquema,
        p_tabla,
        p_columna,
        p_descripcion
    );
END;
$$;

    
CREATE OR REPLACE PROCEDURE "Helix6_Internal"."UpdateStructure"()
LANGUAGE plpgsql
AS $$
DECLARE
    rec_tabla RECORD;
    rec_columna RECORD;
    nuevo_nombre TEXT;
BEGIN
    FOR rec_tabla IN
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_type = 'BASE TABLE'
          AND table_schema NOT IN ('Helix6_Internal', 'pg_catalog', 'information_schema', 'public')
        ORDER BY table_name
    LOOP
        -- Add columns
        EXECUTE format('ALTER TABLE %I.%I ADD COLUMN IF NOT EXISTS "AuditCreationUser" VARCHAR(70)', rec_tabla.table_schema, rec_tabla.table_name);
        EXECUTE format('ALTER TABLE %I.%I ADD COLUMN IF NOT EXISTS "AuditModificationUser" VARCHAR(70)', rec_tabla.table_schema, rec_tabla.table_name);
        EXECUTE format('ALTER TABLE %I.%I ADD COLUMN IF NOT EXISTS "AuditCreationDate" TIMESTAMPTZ', rec_tabla.table_schema, rec_tabla.table_name);
        EXECUTE format('ALTER TABLE %I.%I ADD COLUMN IF NOT EXISTS "AuditModificationDate" TIMESTAMPTZ', rec_tabla.table_schema, rec_tabla.table_name);
        EXECUTE format('ALTER TABLE %I.%I ADD COLUMN IF NOT EXISTS "AuditDeletionDate" TIMESTAMPTZ', rec_tabla.table_schema, rec_tabla.table_name);

        -- Update comment
        CALL "Helix6_Internal"."UpdateFieldDescription"(rec_tabla.table_schema, rec_tabla.table_name, 'Id', 'ID#Table identifier');
        CALL "Helix6_Internal"."UpdateFieldDescription"(rec_tabla.table_schema, rec_tabla.table_name, 'AuditCreationUser', 'Audit - Creation User#Registry creation user');
        CALL "Helix6_Internal"."UpdateFieldDescription"(rec_tabla.table_schema, rec_tabla.table_name, 'AuditModificationUser', 'Audit - Modification User#Registry modification User');
        CALL "Helix6_Internal"."UpdateFieldDescription"(rec_tabla.table_schema, rec_tabla.table_name, 'AuditCreationDate', 'Audit - Creation Date#Registry creation date');
        CALL "Helix6_Internal"."UpdateFieldDescription"(rec_tabla.table_schema, rec_tabla.table_name, 'AuditModificationDate', 'Audit - Modification Date#Last registry modification date');
        CALL "Helix6_Internal"."UpdateFieldDescription"(rec_tabla.table_schema, rec_tabla.table_name, 'AuditDeletionDate', 'Audit - Deletion Date#Logic registry deletion date');

        -- Capitalize columns
        FOR rec_columna IN
            SELECT column_name
            FROM information_schema.columns
            WHERE table_schema = rec_tabla.table_schema
              AND table_name = rec_tabla.table_name
        LOOP
            IF substring(rec_columna.column_name,1,1) = lower(substring(rec_columna.column_name,1,1)) THEN
                nuevo_nombre := upper(substring(rec_columna.column_name,1,1)) || substring(rec_columna.column_name,2);
                EXECUTE format('ALTER TABLE %I.%I RENAME COLUMN %I TO %I',
                               rec_tabla.table_schema, rec_tabla.table_name,
                               rec_columna.column_name, nuevo_nombre);
            END IF;
        END LOOP;
    END LOOP;
END;
$$;

    
    CREATE TABLE IF NOT EXISTS "Helix6_Security"."SecurityVersion" (
        "Id" integer generated always as identity PRIMARY KEY,
        "Version" char(20) NOT NULL,
        "Observations" text,
        "AuditCreationUser" varchar(70),
        "AuditModificationUser" varchar(70),
        "AuditCreationDate" timestamptz,
        "AuditModificationDate" timestamptz,
        "AuditDeletionDate" timestamptz
    );

    
    ALTER TABLE "Helix6_Security"."SecurityAccessOptionLevel"
        ADD CONSTRAINT "FK_SecurityAccessOptionLevel_SecurityAccessOption"
        FOREIGN KEY ("SecurityAccessOptionId") REFERENCES "Helix6_Security"."SecurityAccessOption" ("Id");

    ALTER TABLE "Helix6_Security"."SecurityAccessOption"
        ADD CONSTRAINT "FK_SecurityAccessOption_SecurityModule"
        FOREIGN KEY ("SecurityModuleId") REFERENCES "Helix6_Security"."SecurityModule" ("Id");

    ALTER TABLE "Helix6_Security"."SecurityCompany"
        ADD CONSTRAINT "FK_SecurityCompany_SecurityCompanyConfiguration"
        FOREIGN KEY ("SecurityCompanyConfigurationId") REFERENCES "Helix6_Security"."SecurityCompanyConfiguration" ("Id");

    ALTER TABLE "Helix6_Security"."SecurityCompany"
        ADD CONSTRAINT "FK_SecurityCompany_SecurityCompanyGroup"
        FOREIGN KEY ("SecurityCompanyGroupId") REFERENCES "Helix6_Security"."SecurityCompanyGroup" ("Id");

    ALTER TABLE "Helix6_Security"."SecurityProfile"
        ADD CONSTRAINT "FK_SecurityProfile_SecurityCompany"
        FOREIGN KEY ("SecurityCompanyId") REFERENCES "Helix6_Security"."SecurityCompany" ("Id");

    ALTER TABLE "Helix6_Security"."SecurityProfile_SecurityAccessOption"
        ADD CONSTRAINT "FK_SecurityProfile_SecurityAccessOption_SecurityAccessOption"
        FOREIGN KEY ("SecurityAccessOptionId") REFERENCES "Helix6_Security"."SecurityAccessOption" ("Id");

    ALTER TABLE "Helix6_Security"."SecurityProfile_SecurityAccessOption"
        ADD CONSTRAINT "FK_SecurityProfile_SecurityAccessOption_SecurityProfile"
        FOREIGN KEY ("SecurityProfileId") REFERENCES "Helix6_Security"."SecurityProfile" ("Id");

    ALTER TABLE "Helix6_Security"."SecurityUserGridConfiguration"
        ADD CONSTRAINT "FK_SecurityUserGridConfiguration_SecurityUser"
        FOREIGN KEY ("SecurityUserId") REFERENCES "Helix6_Security"."SecurityUser" ("Id");

    ALTER TABLE "Helix6_Security"."SecurityUser"
        ADD CONSTRAINT "FK_SecurityUser_SecurityCompany"
        FOREIGN KEY ("SecurityCompanyId") REFERENCES "Helix6_Security"."SecurityCompany" ("Id");

    ALTER TABLE "Helix6_Security"."SecurityUser"
        ADD CONSTRAINT "FK_SecurityUser_SecurityUserConfiguration"
        FOREIGN KEY ("SecurityUserConfigurationId") REFERENCES "Helix6_Security"."SecurityUserConfiguration" ("Id");
