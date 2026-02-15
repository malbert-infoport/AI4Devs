DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM pg_namespace WHERE nspname = 'Admon') THEN
        CREATE SCHEMA "Admon";
    END IF;
END $EF$;
CREATE TABLE IF NOT EXISTS "Admon"."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL,
    CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId")
);

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


INSERT INTO "Admon"."__EFMigrationsHistory" ("MigrationId", "ProductVersion")
VALUES ('20260215192054_01020001_StructureHelix', '9.0.9');

-- =====================================================================================
-- InfoportOneAdmon - Database Structure
-- =====================================================================================
-- Plataforma administrativa centralizada para gestión del portfolio de aplicaciones
-- empresariales y gobierno de identidad multi-organización
-- =====================================================================================

-- =====================================================================================
-- TABLA: OrganizationGroup
-- =====================================================================================
-- Grupos lógicos de organizaciones (holdings, consorcios, franquicias)
-- Permite administración colectiva de múltiples organizaciones relacionadas
-- =====================================================================================

CREATE TABLE "Admon"."OrganizationGroup" (
    Id SERIAL PRIMARY KEY,
    Name CITEXT NOT NULL,
    
    -- Campos de auditoría Helix6 (automáticos)
    AuditCreationUser CITEXT NOT NULL,
    AuditCreationDate TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    AuditModificationUser CITEXT NOT NULL,
    AuditModificationDate TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    AuditDeletionDate TIMESTAMP NULL,
    
    -- Restricciones de longitud para campos citext
    CONSTRAINT "chk_organizationgroup_name_length" CHECK (char_length(Name) <= 200),
    CONSTRAINT "chk_organizationgroup_auditcreationuser_length" CHECK (char_length(AuditCreationUser) <= 255),
    CONSTRAINT "chk_organizationgroup_auditmodificationuser_length" CHECK (char_length(AuditModificationUser) <= 255),
    
    -- Índices
    CONSTRAINT "uq_organizationgroup_name" UNIQUE (Name)
);

CREATE INDEX "idx_organizationgroup_auditdeletiondate" ON "Admon"."OrganizationGroup"(AuditDeletionDate);

COMMENT ON TABLE "Admon"."OrganizationGroup" IS 'Agrupaciones lógicas de organizaciones para facilitar gestión colectiva (holdings, consorcios)';
COMMENT ON COLUMN "Admon"."OrganizationGroup".Name IS 'Nombre del grupo de organizaciones';
COMMENT ON COLUMN "Admon"."OrganizationGroup".AuditDeletionDate IS 'Fecha de baja lógica (soft delete). NULL = activo';

-- =====================================================================================
-- TABLA: Organization
-- =====================================================================================
-- Organizaciones clientes del ecosistema (empresas que contratan las aplicaciones)
-- Es la entidad central del sistema de multi-tenancy
-- SecurityCompanyId es el identificador inmutable que se propaga en tokens JWT (claim c_ids)
-- =====================================================================================

CREATE TABLE "Admon"."Organization" (
    Id SERIAL PRIMARY KEY,
    SecurityCompanyId INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    Name CITEXT NOT NULL,
    Acronym CITEXT NOT NULL,
    TaxId CITEXT NULL,
    Address CITEXT NULL,
    City CITEXT NULL,
    Country CITEXT NULL,
    ContactEmail CITEXT NULL,
    ContactPhone CITEXT NULL,
    
    -- Relación con grupo (opcional)
    GroupId INTEGER NULL,
    
    -- Campos de auditoría Helix6 (automáticos)
    AuditCreationUser CITEXT NOT NULL,
    AuditCreationDate TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    AuditModificationUser CITEXT NOT NULL,
    AuditModificationDate TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    AuditDeletionDate TIMESTAMP NULL,
    
    -- Restricciones de longitud para campos citext
    CONSTRAINT "chk_organization_name_length" CHECK (char_length(Name) <= 200),
    CONSTRAINT "chk_organization_acronym_length" CHECK (char_length(Acronym) <= 10),
    CONSTRAINT "chk_organization_auditcreationuser_length" CHECK (char_length(AuditCreationUser) <= 255),
    CONSTRAINT "chk_organization_auditmodificationuser_length" CHECK (char_length(AuditModificationUser) <= 255),
    CONSTRAINT "chk_organization_taxid_length" CHECK (char_length(TaxId) <= 50),
    CONSTRAINT "chk_organization_address_length" CHECK (char_length(Address) <= 500),
    CONSTRAINT "chk_organization_city_length" CHECK (char_length(City) <= 100),
    CONSTRAINT "chk_organization_country_length" CHECK (char_length(Country) <= 100),
    CONSTRAINT "chk_organization_contactemail_length" CHECK (char_length(ContactEmail) <= 255),
    CONSTRAINT "chk_organization_contactphone_length" CHECK (char_length(ContactPhone) <= 50),
    
    -- Foreign Keys
    CONSTRAINT "fk_organization_group" FOREIGN KEY (GroupId) 
        REFERENCES "Admon"."OrganizationGroup"(Id) 
        ON DELETE SET NULL,
    
    -- Índices de unicidad
    CONSTRAINT "uq_organization_securitycompanyid" UNIQUE (SecurityCompanyId),
    CONSTRAINT "uq_organization_acronym" UNIQUE (Acronym),
    CONSTRAINT "uq_organization_taxid" UNIQUE (TaxId)
);

CREATE INDEX "idx_organization_name" ON "Admon"."Organization"(Name);
CREATE INDEX "idx_organization_securitycompanyid" ON "Admon"."Organization"(SecurityCompanyId);
CREATE INDEX "idx_organization_groupid" ON "Admon"."Organization"(GroupId);
CREATE INDEX "idx_organization_auditdeletiondate" ON "Admon"."Organization"(AuditDeletionDate);

COMMENT ON TABLE "Admon"."Organization" IS 'Organizaciones clientes del ecosistema. Fuente de verdad para multi-tenancy';
COMMENT ON COLUMN "Admon"."Organization".Id IS 'Clave primaria técnica requerida por Helix6 (IEntityBase)';
COMMENT ON COLUMN "Admon"."Organization".SecurityCompanyId IS 'Identificador único inmutable de la organización. Se propaga en claim c_ids de tokens JWT';
COMMENT ON COLUMN "Admon"."Organization".Acronym IS 'Acrónimo único de la organización (máx. 10 caracteres) para identificación rápida';
COMMENT ON COLUMN "Admon"."Organization".TaxId IS 'Identificador fiscal de la organización (CIF/NIF)';
COMMENT ON COLUMN "Admon"."Organization".GroupId IS 'ID del grupo al que pertenece (holding, consorcio). NULL si no pertenece a ningún grupo';
COMMENT ON COLUMN "Admon"."Organization".AuditDeletionDate IS 'Fecha de baja lógica. Al establecerse, bloquea acceso inmediato y propaga baja de usuarios a Keycloak';

-- =====================================================================================
-- TABLA: Application
-- =====================================================================================

CREATE TABLE "Admon"."Application" (
    Id SERIAL PRIMARY KEY,
    ApplicationId INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    Name CITEXT NOT NULL,
    Acronym CITEXT NOT NULL,
    Description CITEXT NULL,
    
    -- Campos de auditoría Helix6 (automáticos)
    AuditCreationUser CITEXT NOT NULL,
    AuditCreationDate TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    AuditModificationUser CITEXT NOT NULL,
    AuditModificationDate TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    AuditDeletionDate TIMESTAMP NULL,
    
    -- Restricciones de longitud para campos citext
    CONSTRAINT "chk_application_name_length" CHECK (char_length(Name) <= 200),
    CONSTRAINT "chk_application_acronym_length" CHECK (char_length(Acronym) <= 10),
    CONSTRAINT "chk_application_auditcreationuser_length" CHECK (char_length(AuditCreationUser) <= 255),
    CONSTRAINT "chk_application_auditmodificationuser_length" CHECK (char_length(AuditModificationUser) <= 255),
    CONSTRAINT "chk_application_description_length" CHECK (char_length(Description) <= 1000),
    
    -- Índices de unicidad
    CONSTRAINT "uq_application_applicationid" UNIQUE (ApplicationId),
    CONSTRAINT "uq_application_name" UNIQUE (Name),
    CONSTRAINT "uq_application_acronym" UNIQUE (Acronym)
);

CREATE INDEX "idx_application_applicationid" ON "Admon"."Application"(ApplicationId);
CREATE INDEX "idx_application_auditdeletiondate" ON "Admon"."Application"(AuditDeletionDate);

COMMENT ON TABLE "Admon"."Application" IS 'Aplicaciones satélite del portfolio empresarial. Define el catálogo de aplicaciones disponibles';
COMMENT ON COLUMN "Admon"."Application".Id IS 'Clave primaria técnica requerida por Helix6 (IEntityBase)';
COMMENT ON COLUMN "Admon"."Application".ApplicationId IS 'Identificador único de negocio auto-generado inmutable';
COMMENT ON COLUMN "Admon"."Application".Acronym IS 'Acrónimo único para nomenclatura de roles y módulos (ej: STP, CRM, ERP)';
COMMENT ON COLUMN "Admon"."Application".AuditDeletionDate IS 'Fecha de baja lógica. Al establecerse, revoca automáticamente todas sus credenciales en Keycloak';

-- =====================================================================================
-- TABLA: ApplicationSecurity
-- =====================================================================================

CREATE TABLE "Admon"."ApplicationSecurity" (
    Id SERIAL PRIMARY KEY,
    ApplicationId INTEGER NOT NULL,
    ClientId CITEXT NOT NULL,
    ClientSecret CITEXT NULL,
    ClientType CITEXT NOT NULL,
    CredentialType CITEXT NOT NULL,
    Description CITEXT NULL,
    
    -- Campos de auditoría Helix6 (automáticos)
    AuditCreationUser CITEXT NOT NULL,
    AuditCreationDate TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    AuditModificationUser CITEXT NOT NULL,
    AuditModificationDate TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    AuditDeletionDate TIMESTAMP NULL,
    
    -- Restricciones de longitud para campos citext
    CONSTRAINT "chk_appsecurity_auditcreationuser_length" CHECK (char_length(AuditCreationUser) <= 255),
    CONSTRAINT "chk_appsecurity_auditmodificationuser_length" CHECK (char_length(AuditModificationUser) <= 255),
    CONSTRAINT "chk_appsecurity_clientid_length" CHECK (char_length(ClientId) <= 255),
    CONSTRAINT "chk_appsecurity_clientsecret_length" CHECK (char_length(ClientSecret) <= 512),
    CONSTRAINT "chk_appsecurity_clienttype_length" CHECK (char_length(ClientType) <= 50),
    CONSTRAINT "chk_appsecurity_credentialtype_length" CHECK (char_length(CredentialType) <= 50),
    CONSTRAINT "chk_appsecurity_description_length" CHECK (char_length(Description) <= 1000),
    
    -- Validaciones de negocio
    CONSTRAINT "chk_appsecurity_clienttype_values" CHECK (ClientType IN ('Public', 'Confidential')),
    CONSTRAINT "chk_appsecurity_credentialtype_values" CHECK (CredentialType IN ('CODE_PKCE', 'CLIENT_CREDENTIALS')),
    
    -- Foreign Keys
    CONSTRAINT "fk_appsecurity_application" FOREIGN KEY (ApplicationId) 
        REFERENCES "Admon"."Application"(Id) 
        ON DELETE CASCADE,
    
    -- Índices de unicidad
    CONSTRAINT "uq_appsecurity_clientid" UNIQUE (ClientId)
);

CREATE INDEX "idx_appsecurity_applicationid" ON "Admon"."ApplicationSecurity"(ApplicationId);
CREATE INDEX "idx_appsecurity_auditdeletiondate" ON "Admon"."ApplicationSecurity"(AuditDeletionDate);

COMMENT ON TABLE "Admon"."ApplicationSecurity" IS 'Credenciales OAuth2 para autenticación de aplicaciones en Keycloak. Soporta múltiples credenciales por aplicación';
COMMENT ON COLUMN "Admon"."ApplicationSecurity".ApplicationId IS 'ID de la aplicación (FK a Application.Id)';
COMMENT ON COLUMN "Admon"."ApplicationSecurity".ClientId IS 'OAuth2 client_id único para autenticación en Keycloak';
COMMENT ON COLUMN "Admon"."ApplicationSecurity".ClientSecret IS 'OAuth2 client_secret. NULL para public clients (SPAs con PKCE), requerido para confidential clients';
COMMENT ON COLUMN "Admon"."ApplicationSecurity".ClientType IS 'Tipo de cliente OAuth2: Public (Angular SPAs) o Confidential (APIs backend)';
COMMENT ON COLUMN "Admon"."ApplicationSecurity".CredentialType IS 'Tipo de credencial: CODE_PKCE (acceso web) o CLIENT_CREDENTIALS (APIs externas)';
COMMENT ON COLUMN "Admon"."ApplicationSecurity".AuditDeletionDate IS 'Fecha de baja lógica. Al establecerse, revoca la credencial en Keycloak';

-- =====================================================================================
-- TABLA: ApplicationModule
-- =====================================================================================

CREATE TABLE "Admon"."ApplicationModule" (
    Id SERIAL PRIMARY KEY,
    ApplicationId INTEGER NOT NULL,
    Name CITEXT NOT NULL,
    Description CITEXT NULL,
    
    -- Campos de auditoría Helix6 (automáticos)
    AuditCreationUser CITEXT NOT NULL,
    AuditCreationDate TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    AuditModificationUser CITEXT NOT NULL,
    AuditModificationDate TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    AuditDeletionDate TIMESTAMP NULL,
    
    -- Restricciones de longitud para campos citext
    CONSTRAINT "chk_applicationmodule_auditcreationuser_length" CHECK (char_length(AuditCreationUser) <= 255),
    CONSTRAINT "chk_applicationmodule_auditmodificationuser_length" CHECK (char_length(AuditModificationUser) <= 255),
    CONSTRAINT "chk_applicationmodule_name_length" CHECK (char_length(Name) <= 200),
    CONSTRAINT "chk_applicationmodule_description_length" CHECK (char_length(Description) <= 1000),
    
    -- Foreign Keys
    CONSTRAINT "fk_applicationmodule_application" FOREIGN KEY (ApplicationId) 
        REFERENCES "Admon"."Application"(Id) 
        ON DELETE CASCADE,
    
    -- Índices de unicidad (nombre único por aplicación)
    CONSTRAINT "uq_applicationmodule_application_name" UNIQUE (ApplicationId, Name)
);

CREATE INDEX "idx_applicationmodule_applicationid" ON "Admon"."ApplicationModule"(ApplicationId);
CREATE INDEX "idx_applicationmodule_auditdeletiondate" ON "Admon"."ApplicationModule"(AuditDeletionDate);

COMMENT ON TABLE "Admon"."ApplicationModule" IS 'Módulos funcionales de aplicaciones. Permiten ventas granulares por funcionalidad';
COMMENT ON COLUMN "Admon"."ApplicationModule".Name IS 'Nombre del módulo siguiendo nomenclatura: M + Acronym + _ + nombre funcional';
COMMENT ON COLUMN "Admon"."ApplicationModule".AuditDeletionDate IS 'Fecha de baja lógica del módulo';

-- =====================================================================================
-- TABLA: ApplicationRole
-- =====================================================================================

CREATE TABLE "Admon"."ApplicationRole" (
    Id SERIAL PRIMARY KEY,
    ApplicationId INTEGER NOT NULL,
    Name CITEXT NOT NULL,
    Description CITEXT NULL,
    
    -- Campos de auditoría Helix6 (automáticos)
    AuditCreationUser CITEXT NOT NULL,
    AuditCreationDate TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    AuditModificationUser CITEXT NOT NULL,
    AuditModificationDate TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    AuditDeletionDate TIMESTAMP NULL,
    
    -- Restricciones de longitud para campos citext
    CONSTRAINT "chk_applicationrole_auditcreationuser_length" CHECK (char_length(AuditCreationUser) <= 255),
    CONSTRAINT "chk_applicationrole_auditmodificationuser_length" CHECK (char_length(AuditModificationUser) <= 255),
    CONSTRAINT "chk_applicationrole_name_length" CHECK (char_length(Name) <= 200),
    CONSTRAINT "chk_applicationrole_description_length" CHECK (char_length(Description) <= 1000),
    
    -- Foreign Keys
    CONSTRAINT "fk_applicationrole_application" FOREIGN KEY (ApplicationId) 
        REFERENCES "Admon"."Application"(Id) 
        ON DELETE CASCADE,
    
    -- Índices de unicidad (nombre único por aplicación)
    CONSTRAINT "uq_applicationrole_application_name" UNIQUE (ApplicationId, Name)
);

CREATE INDEX "idx_applicationrole_applicationid" ON "Admon"."ApplicationRole"(ApplicationId);
CREATE INDEX "idx_applicationrole_auditdeletiondate" ON "Admon"."ApplicationRole"(AuditDeletionDate);

COMMENT ON TABLE "Admon"."ApplicationRole" IS 'Catálogo maestro de roles de cada aplicación. Garantiza coherencia en nomenclatura';
COMMENT ON COLUMN "Admon"."ApplicationRole".Name IS 'Nombre del rol siguiendo nomenclatura: Acronym + _ + nombre funcional (ej: STP_Supervisor)';
COMMENT ON COLUMN "Admon"."ApplicationRole".AuditDeletionDate IS 'Fecha de baja lógica. Roles dados de baja no se asignan a nuevos usuarios';

-- =====================================================================================
-- TABLA: OrganizationApplicationModule
-- =====================================================================================

CREATE TABLE "Admon"."OrganizationApplicationModule" (
    Id SERIAL PRIMARY KEY,
    OrganizationId INTEGER NOT NULL,
    ApplicationModuleId INTEGER NOT NULL,
    
    -- Campos de auditoría Helix6 (automáticos)
    AuditCreationUser CITEXT NOT NULL,
    AuditCreationDate TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    AuditModificationUser CITEXT NOT NULL,
    AuditModificationDate TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    AuditDeletionDate TIMESTAMP NULL,
    
    -- Restricciones de longitud para campos citext
    CONSTRAINT "chk_orgappmodule_auditcreationuser_length" CHECK (char_length(AuditCreationUser) <= 255),
    CONSTRAINT "chk_orgappmodule_auditmodificationuser_length" CHECK (char_length(AuditModificationUser) <= 255),
    
    -- Foreign Keys
    CONSTRAINT "fk_orgappmodule_organization" FOREIGN KEY (OrganizationId) 
        REFERENCES "Admon"."Organization"(Id) 
        ON DELETE CASCADE,
    CONSTRAINT "fk_orgappmodule_module" FOREIGN KEY (ApplicationModuleId) 
        REFERENCES "Admon"."ApplicationModule"(Id) 
        ON DELETE CASCADE,
    
    -- Índices de unicidad (una org no puede tener el mismo módulo duplicado)
    CONSTRAINT "uq_orgappmodule_org_module" UNIQUE (OrganizationId, ApplicationModuleId)
);

CREATE INDEX "idx_orgappmodule_organizationid" ON "Admon"."OrganizationApplicationModule"(OrganizationId);
CREATE INDEX "idx_orgappmodule_ApplicationModuleId" ON "Admon"."OrganizationApplicationModule"(ApplicationModuleId);
CREATE INDEX "idx_orgappmodule_auditdeletiondate" ON "Admon"."OrganizationApplicationModule"(AuditDeletionDate);

COMMENT ON TABLE "Admon"."OrganizationApplicationModule" IS 'Permisos de acceso a módulos por organización. Habilita ventas granulares por funcionalidad';
COMMENT ON COLUMN "Admon"."OrganizationApplicationModule".OrganizationId IS 'ID de la organización cliente (Organization.Id)';
COMMENT ON COLUMN "Admon"."OrganizationApplicationModule".ApplicationModuleId IS 'ID del módulo al que tiene acceso la organización';
COMMENT ON COLUMN "Admon"."OrganizationApplicationModule".AuditDeletionDate IS 'Fecha de revocación de acceso al módulo';

-- =====================================================================================
-- TABLA: AuditLog
-- =====================================================================================

CREATE TABLE "Admon"."AuditLog" (
    Id SERIAL PRIMARY KEY,
    Action CITEXT NOT NULL,
    EntityType CITEXT NOT NULL,
    EntityId INTEGER NOT NULL,
    UserId INTEGER NULL,
    Timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Campos de auditoría Helix6 (automáticos)
    AuditCreationUser CITEXT NOT NULL,
    AuditCreationDate TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    AuditModificationUser CITEXT NOT NULL,
    AuditModificationDate TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    AuditDeletionDate TIMESTAMP NULL,
    
    -- Restricciones de longitud para campos citext
    CONSTRAINT "chk_auditlog_auditcreationuser_length" CHECK (char_length(AuditCreationUser) <= 255),
    CONSTRAINT "chk_auditlog_auditmodificationuser_length" CHECK (char_length(AuditModificationUser) <= 255),
    CONSTRAINT "chk_auditlog_action_length" CHECK (char_length(Action) <= 100),
    CONSTRAINT "chk_auditlog_entitytype_length" CHECK (char_length(EntityType) <= 100),
    
    -- Validaciones de acciones permitidas (Epic1)
    CONSTRAINT "chk_auditlog_action_values" CHECK (Action IN (
        'ModuleAssigned',
        'ModuleRemoved',
        'OrganizationDeactivatedManual',
        'OrganizationAutoDeactivated',
        'OrganizationReactivatedManual',
        'GroupChanged'
    ))
);

CREATE INDEX "idx_auditlog_entitytype_entityid" ON "Admon"."AuditLog"(EntityType, EntityId);
CREATE INDEX "idx_auditlog_userid" ON "Admon"."AuditLog"(UserId);
CREATE INDEX "idx_auditlog_timestamp" ON "Admon"."AuditLog"(Timestamp DESC);
CREATE INDEX "idx_auditlog_auditdeletiondate" ON "Admon"."AuditLog"(AuditDeletionDate);

COMMENT ON TABLE "Admon"."AuditLog" IS 'Auditoría selectiva de acciones críticas en seguridad y permisos (complementa auditoría automática Helix6)';
COMMENT ON COLUMN "Admon"."AuditLog".Action IS 'Acción auditada: ModuleAssigned, ModuleRemoved, OrganizationDeactivatedManual, OrganizationAutoDeactivated, OrganizationReactivatedManual, GroupChanged';
COMMENT ON COLUMN "Admon"."AuditLog".EntityType IS 'Tipo de entidad afectada: Organization, ApplicationModule, OrganizationApplicationModule';
COMMENT ON COLUMN "Admon"."AuditLog".EntityId IS 'ID de la entidad afectada';
COMMENT ON COLUMN "Admon"."AuditLog".UserId IS 'ID del usuario que ejecutó la acción (NULL si fue acción automática del sistema)';

-- =====================================================================================
-- TABLA: EventHash
-- =====================================================================================

CREATE TABLE "Admon"."EventHash" (
    Id SERIAL PRIMARY KEY,
    EntityType CITEXT NOT NULL,
    EntityId INTEGER NOT NULL,
    LastEventHash CHAR(64) NOT NULL,
    LastPublishedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Campos de auditoría Helix6 (automáticos)
    AuditCreationUser CITEXT NOT NULL,
    AuditCreationDate TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    AuditModificationUser CITEXT NOT NULL,
    AuditModificationDate TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    AuditDeletionDate TIMESTAMP NULL,
    
    -- Restricciones de longitud para campos citext
    CONSTRAINT "chk_eventhash_auditcreationuser_length" CHECK (char_length(AuditCreationUser) <= 255),
    CONSTRAINT "chk_eventhash_auditmodificationuser_length" CHECK (char_length(AuditModificationUser) <= 255),
    CONSTRAINT "chk_eventhash_entitytype_length" CHECK (char_length(EntityType) <= 100),
    
    -- Índices de unicidad (un hash por tipo de entidad y ID)
    CONSTRAINT "uq_eventhash_entitytype_entityid" UNIQUE (EntityType, EntityId)
);

CREATE INDEX "idx_eventhash_lastpublishedat" ON "Admon"."EventHash"(LastPublishedAt DESC);
CREATE INDEX "idx_eventhash_auditdeletiondate" ON "Admon"."EventHash"(AuditDeletionDate);

COMMENT ON TABLE "Admon"."EventHash" IS 'Control de eventos duplicados mediante hash SHA-256. Previene publicar eventos idénticos consecutivos';
COMMENT ON COLUMN "Admon"."EventHash".EntityType IS 'Tipo de entidad: ORGANIZATION, APPLICATION, USER';
COMMENT ON COLUMN "Admon"."EventHash".EntityId IS 'ID de la entidad';
COMMENT ON COLUMN "Admon"."EventHash".LastEventHash IS 'Hash SHA-256 (64 caracteres) del Payload del último evento publicado';
COMMENT ON COLUMN "Admon"."EventHash".LastPublishedAt IS 'Timestamp de la última publicación exitosa';

-- =====================================================================================
-- TABLA: UserCache
-- =====================================================================================

CREATE TABLE "Admon"."UserCache" (
    Id SERIAL PRIMARY KEY,
    Email CITEXT NOT NULL,
    ConsolidatedCompanyIds TEXT NOT NULL,
    ConsolidatedRoles TEXT NOT NULL,
    LastUpdated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    LastEventHash CHAR(64) NOT NULL,
    
    -- Campos de auditoría Helix6 (automáticos)
    AuditCreationUser CITEXT NOT NULL,
    AuditCreationDate TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    AuditModificationUser CITEXT NOT NULL,
    AuditModificationDate TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    AuditDeletionDate TIMESTAMP NULL,
    
    -- Restricciones de longitud para campos citext
    CONSTRAINT "chk_usercache_auditcreationuser_length" CHECK (char_length(AuditCreationUser) <= 255),
    CONSTRAINT "chk_usercache_auditmodificationuser_length" CHECK (char_length(AuditModificationUser) <= 255),
    CONSTRAINT "chk_usercache_email_length" CHECK (char_length(Email) <= 255),
    
    -- Índices de unicidad
    CONSTRAINT "uq_usercache_email" UNIQUE (Email)
);

CREATE INDEX "idx_usercache_lastupdated" ON "Admon"."UserCache"(LastUpdated DESC);
CREATE INDEX "idx_usercache_auditdeletiondate" ON "Admon"."UserCache"(AuditDeletionDate);
COMMENT ON TABLE "Admon"."UserCache" IS 'Caché de usuarios consolidados multi-organización. Optimiza procesamiento del Background Worker';
COMMENT ON COLUMN "Admon"."UserCache".Id IS 'Clave primaria técnica requerida por Helix6 (IEntityBase)';
COMMENT ON COLUMN "Admon"."UserCache".Email IS 'Email del usuario (único, case-insensitive)';
COMMENT ON COLUMN "Admon"."UserCache".ConsolidatedCompanyIds IS 'Array JSON con todos los SecurityCompanyId del usuario: [12345, 67890, 11111]';
COMMENT ON COLUMN "Admon"."UserCache".ConsolidatedRoles IS 'Array JSON con todos los roles consolidados del usuario de todas las apps: ["CRM_Vendedor", "ERP_Contable"]';
COMMENT ON COLUMN "Admon"."UserCache".LastUpdated IS 'Timestamp de la última consolidación';
COMMENT ON COLUMN "Admon"."UserCache".LastEventHash IS 'Hash SHA-256 del último evento procesado para este usuario';

-- =====================================================================================
-- VISTAS AUXILIARES
-- =====================================================================================

-- Vista para consultar organizaciones activas (no eliminadas)
CREATE OR REPLACE VIEW "Admon"."VTA_ActiveOrganizations" AS
SELECT 
    Id,
    SecurityCompanyId,
    Name,
    Acronym,
    TaxId,
    Address,
    City,
    Country,
    ContactEmail,
    ContactPhone,
    GroupId,
    AuditCreationUser,
    AuditCreationDate,
    AuditModificationUser,
    AuditModificationDate,
    AuditDeletionDate
FROM "Admon"."Organization"
WHERE AuditDeletionDate IS NULL;

COMMENT ON VIEW "Admon"."VTA_ActiveOrganizations" IS 'Organizaciones activas (no eliminadas lógicamente)';

-- Vista para consultar aplicaciones activas
CREATE OR REPLACE VIEW "Admon"."VTA_ActiveApplications" AS
SELECT 
    Id,
    ApplicationId,
    Name,
    Acronym,
    Description,
    AuditCreationUser,
    AuditCreationDate,
    AuditModificationUser,
    AuditModificationDate,
    AuditDeletionDate
FROM "Admon"."Application"
WHERE AuditDeletionDate IS NULL;

COMMENT ON VIEW "Admon"."VTA_ActiveApplications" IS 'Aplicaciones activas del portfolio';

-- Vista para consultar credenciales de seguridad activas por aplicación
CREATE OR REPLACE VIEW "Admon"."VTA_ApplicationSecurityCredentials" AS
SELECT 
    aps.Id,
    aps.ApplicationId,
    a.ApplicationId AS AppBusinessId,
    a.Name AS ApplicationName,
    aps.ClientId,
    aps.ClientType,
    aps.CredentialType,
    aps.Description,
    aps.AuditCreationUser,
    aps.AuditCreationDate,
    aps.AuditModificationUser,
    aps.AuditModificationDate,
    aps.AuditDeletionDate
FROM "Admon"."ApplicationSecurity" aps
INNER JOIN "Admon"."Application" a ON aps.ApplicationId = a.Id
WHERE aps.AuditDeletionDate IS NULL
  AND a.AuditDeletionDate IS NULL;

COMMENT ON VIEW "Admon"."VTA_ApplicationSecurityCredentials" IS 'Credenciales OAuth2 activas de aplicaciones';

-- Vista para consultar módulos activos por aplicación
CREATE OR REPLACE VIEW "Admon"."VTA_ActiveApplicationModules" AS
SELECT 
    am.Id,
    am.ApplicationId,
    a.ApplicationId AS AppBusinessId,
    a.Name AS ApplicationName,
    a.Acronym,
    am.Name AS ApplicationModuleName,
    am.Description,
    am.AuditCreationUser,
    am.AuditCreationDate,
    am.AuditModificationUser,
    am.AuditModificationDate,
    am.AuditDeletionDate
FROM "Admon"."ApplicationModule" am
INNER JOIN "Admon"."Application" a ON am.ApplicationId = a.Id
WHERE am.AuditDeletionDate IS NULL
  AND a.AuditDeletionDate IS NULL;

COMMENT ON VIEW "Admon"."VTA_ActiveApplicationModules" IS 'Módulos activos de aplicaciones activas';

-- Vista para consultar permisos de módulos por organización
CREATE OR REPLACE VIEW "Admon"."VTA_OrganizationModuleAccess" AS
SELECT 
    oam.Id,
    o.Id AS OrganizationId,
    o.SecurityCompanyId,
    o.Name AS OrganizationName,
    a.Id AS ApplicationId,
    a.ApplicationId AS AppBusinessId,
    a.Name AS ApplicationName,
    am.Id AS ApplicationModuleId,
    am.Name AS ApplicationModuleName,
    oam.AuditCreationUser,
    oam.AuditCreationDate AS AccessGrantedDate,
    oam.AuditModificationUser,
    oam.AuditModificationDate,
    oam.AuditDeletionDate
FROM "Admon"."OrganizationApplicationModule" oam
INNER JOIN "Admon"."Organization" o ON oam.OrganizationId = o.Id
INNER JOIN "Admon"."ApplicationModule" am ON oam.ApplicationModuleId = am.Id
INNER JOIN "Admon"."Application" a ON am.ApplicationId = a.Id
WHERE oam.AuditDeletionDate IS NULL
  AND o.AuditDeletionDate IS NULL
  AND am.AuditDeletionDate IS NULL
  AND a.AuditDeletionDate IS NULL;

COMMENT ON VIEW "Admon"."VTA_OrganizationModuleAccess" IS 'Permisos activos de acceso a módulos por organización';

-- =====================================================================================
-- FUNCIONES AUXILIARES
-- =====================================================================================

-- Función para obtener todos los módulos accesibles por una organización en una aplicación específica
CREATE OR REPLACE FUNCTION Admon.FUN_GetOrganizationApplicationModules(
    p_OrganizationId INTEGER,
    p_ApplicationId INTEGER
)
RETURNS TABLE (
    ApplicationModuleId INTEGER,
    ApplicationModuleName CITEXT,
    Description CITEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        am.Id,
        am.Name,
        am.Description
    FROM "Admon"."OrganizationApplicationModule" oam
    INNER JOIN "Admon"."ApplicationModule" am ON oam.ApplicationModuleId = am.Id
    WHERE oam.OrganizationId = p_OrganizationId
      AND am.ApplicationId = p_ApplicationId
      AND oam.AuditDeletionDate IS NULL
      AND am.AuditDeletionDate IS NULL;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION Admon.FUN_GetOrganizationApplicationModules IS 'Obtiene los módulos accesibles por una organización en una aplicación específica';

-- Función para obtener el claim c_ids de un usuario (todos sus SecurityCompanyIds)
CREATE OR REPLACE FUNCTION Admon.FUN_GetUserCompanyIds(p_Email CITEXT)
RETURNS INTEGER[] AS $$
DECLARE
    v_CompanyIds INTEGER[];
BEGIN
    SELECT 
        ARRAY(
            SELECT DISTINCT CAST(value AS INTEGER)
            FROM json_array_elements_text(ConsolidatedCompanyIds::json) AS value
        )
    INTO v_CompanyIds
    FROM "Admon"."UserCache"
    WHERE Email = p_Email;
    
    RETURN COALESCE(v_CompanyIds, ARRAY[]::INTEGER[]);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION Admon.FUN_GetUserCompanyIds IS 'Obtiene el array de SecurityCompanyIds (claim c_ids) de un usuario por email';

-- =====================================================================================
-- FIN DEL SCRIPT
-- =====================================================================================


INSERT INTO "Admon"."__EFMigrationsHistory" ("MigrationId", "ProductVersion")
VALUES ('20260215192123_01020002_StructureInfoportOneAdmon', '9.0.9');

-- Source: 01020003_SecurityData.sql

INSERT INTO "Helix6_Security"."SecurityCompanyConfiguration" AS t (
    "Id", "HostEmail", "PortEmail", "UserEmail", "PasswordEmail", "DefaultCredentialsEmail", "SSLEmail",
    "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate"
)
VALUES
    (1, NULL, NULL, NULL, NULL, NULL, NULL, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.743', '2025-07-29 09:31:23.743', NULL)
ON CONFLICT ("Id") DO UPDATE SET
    "HostEmail" = EXCLUDED."HostEmail",
    "PortEmail" = EXCLUDED."PortEmail",
    "UserEmail" = EXCLUDED."UserEmail",
    "PasswordEmail" = EXCLUDED."PasswordEmail",
    "DefaultCredentialsEmail" = EXCLUDED."DefaultCredentialsEmail",
    "SSLEmail" = EXCLUDED."SSLEmail",
    "AuditCreationUser" = EXCLUDED."AuditCreationUser",
    "AuditModificationUser" = EXCLUDED."AuditModificationUser",
    "AuditCreationDate" = EXCLUDED."AuditCreationDate",
    "AuditModificationDate" = EXCLUDED."AuditModificationDate",
    "AuditDeletionDate" = EXCLUDED."AuditDeletionDate";


INSERT INTO "Helix6_Security"."SecurityCompanyGroup" AS t (
    "Id", "Name", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate"
)
VALUES
    (1, 'CompanyGroup', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.743', '2025-07-29 09:31:23.743', NULL)
ON CONFLICT ("Id") DO UPDATE SET
    "Name" = EXCLUDED."Name",
    "AuditCreationUser" = EXCLUDED."AuditCreationUser",
    "AuditModificationUser" = EXCLUDED."AuditModificationUser",
    "AuditCreationDate" = EXCLUDED."AuditCreationDate",
    "AuditModificationDate" = EXCLUDED."AuditModificationDate",
    "AuditDeletionDate" = EXCLUDED."AuditDeletionDate";


INSERT INTO "Helix6_Security"."SecurityModule" AS t (
    "Id", "Description", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate"
)
VALUES
    (1, 'Security', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.747', '2025-07-29 09:31:23.747', NULL),
    (2, 'Attachments', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.747', '2025-07-29 09:31:23.747', NULL),
    (3, 'Masters', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.747', '2025-07-29 09:31:23.747', NULL),
    (100, 'Workers', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.707', '2025-07-29 09:31:35.707', NULL),
    (101, 'Rate', '1#hlxadmin', '1#hlxadmin', '2025-08-05 13:17:44.050', '2025-08-05 13:17:44.050', NULL)
ON CONFLICT ("Id") DO UPDATE SET
    "Description" = EXCLUDED."Description",
    "AuditCreationUser" = EXCLUDED."AuditCreationUser",
    "AuditModificationUser" = EXCLUDED."AuditModificationUser",
    "AuditCreationDate" = EXCLUDED."AuditCreationDate",
    "AuditModificationDate" = EXCLUDED."AuditModificationDate",
    "AuditDeletionDate" = EXCLUDED."AuditDeletionDate";



INSERT INTO "Helix6_Security"."SecurityAccessOption" AS t (
    "Id", "SecurityModuleId", "Description", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate"
)
VALUES
    (1, 1, 'User customization', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.747', '2025-07-29 09:31:23.747', NULL),
    (2, 1, 'Profile query', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.750', '2025-07-29 09:31:23.750', NULL),
    (3, 1, 'Profile modification', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.753', '2025-07-29 09:31:23.753', NULL),
    (4, 1, 'General company configuration query', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.753', '2025-07-29 09:31:23.753', NULL),
    (5, 1, 'General company configuration modification', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.757', '2025-07-29 09:31:23.757', NULL),
    (6, 2, 'Attachment query', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.757', '2025-07-29 09:31:23.757', NULL),
    (7, 2, 'Attachment modification', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.760', '2025-07-29 09:31:23.760', NULL),
    (8, 2, 'View or download attachments', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.760', '2025-07-29 09:31:23.760', NULL),
    (9, 2, 'Attachment masters query', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.763', '2025-07-29 09:31:23.763', NULL),
    (10, 2, 'Attachment masters modification', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.763', '2025-07-29 09:31:23.763', NULL),
    (13, 3, 'Masters access', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.767', '2025-07-29 09:31:23.767', NULL),
    (100, 100, 'Worker query', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.710', '2025-07-29 09:31:35.710', NULL),
    (101, 100, 'Worker modification', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.710', '2025-07-29 09:31:35.710', NULL),
    (102, 100, 'Project query', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.710', '2025-07-29 09:31:35.710', NULL),
    (103, 100, 'Project modification', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.710', '2025-07-29 09:31:35.710', NULL),
    (104, 101, 'Rate query', '1#admin', '1#admin', '2025-08-05 13:18:05.510', '2025-08-05 13:18:05.510', NULL),
    (105, 101, 'Rate modification', '1#admin', '1#admin', '2025-08-05 13:18:18.533', '2025-08-05 13:18:18.533', NULL)
ON CONFLICT ("Id") DO UPDATE SET
    "SecurityModuleId" = EXCLUDED."SecurityModuleId",
    "Description" = EXCLUDED."Description",
    "AuditCreationUser" = EXCLUDED."AuditCreationUser",
    "AuditModificationUser" = EXCLUDED."AuditModificationUser",
    "AuditCreationDate" = EXCLUDED."AuditCreationDate",
    "AuditModificationDate" = EXCLUDED."AuditModificationDate",
    "AuditDeletionDate" = EXCLUDED."AuditDeletionDate";



INSERT INTO "Helix6_Security"."SecurityCompany" AS t (
    "Id", "SecurityCompanyGroupId", "Name", "Cif", "SecurityCompanyConfigurationId",
    "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate"
)
VALUES
    (1, 1, 'SecurityCompany', '12345678Z2', 1, '1#hlxadm', '1#hlxusr', '2025-07-29 09:31:23.770', '2023-08-03 07:31:29.110', NULL)
ON CONFLICT ("Id") DO UPDATE SET
    "SecurityCompanyGroupId" = EXCLUDED."SecurityCompanyGroupId",
    "Name" = EXCLUDED."Name",
    "Cif" = EXCLUDED."Cif",
    "SecurityCompanyConfigurationId" = EXCLUDED."SecurityCompanyConfigurationId",
    "AuditCreationUser" = EXCLUDED."AuditCreationUser",
    "AuditModificationUser" = EXCLUDED."AuditModificationUser",
    "AuditCreationDate" = EXCLUDED."AuditCreationDate",
    "AuditModificationDate" = EXCLUDED."AuditModificationDate",
    "AuditDeletionDate" = EXCLUDED."AuditDeletionDate";



INSERT INTO "Helix6_Security"."SecurityAccessOptionLevel" AS t (
    "Id", "SecurityAccessOptionId", "Controller", "SecurityLevel", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate"
)
VALUES
    (1, 1, 'SecurityUserConfiguration', 2, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.770', '2025-07-29 09:31:23.770', NULL),
    (2, 1, 'SecurityUserGridConfiguration', 2, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.773', '2025-07-29 09:31:23.773', NULL),
    (3, 1, 'SecurityVersion', 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.773', '2025-07-29 09:31:23.773', NULL),
    (4, 2, 'SecurityProfile', 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.777', '2025-07-29 09:31:23.777', NULL),
    (5, 3, 'SecurityProfile', 2, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.780', '2025-07-29 09:31:23.780', NULL),
    (6, 2, 'SecurityModule', 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.780', '2025-07-29 09:31:23.780', NULL),
    (7, 3, 'SecurityModule', 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.783', '2025-07-29 09:31:23.783', NULL),
    (8, 4, 'SecurityCompany', 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.783', '2025-07-29 09:31:23.783', NULL),
    (9, 5, 'SecurityCompany', 2, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.787', '2025-07-29 09:31:23.787', NULL),
    (10, 6, 'VTA_Attachment', 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.787', '2025-07-29 09:31:23.787', NULL),
    (11, 7, 'VTA_Attachment', 2, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.790', '2025-07-29 09:31:23.790', NULL),
    (12, 6, 'Attachment', 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.790', '2025-07-29 09:31:23.790', NULL),
    (13, 7, 'Attachment', 2, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.793', '2025-07-29 09:31:23.793', NULL),
    (14, 6, 'AttachmentType', 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.797', '2025-07-29 09:31:23.797', NULL),
    (15, 10, 'AttachmentType', 2, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.797', '2025-07-29 09:31:23.797', NULL),
    (16, 9, 'AttachmentType', 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.800', '2025-07-29 09:31:23.800', NULL),
    (100, 100, 'Worker', 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.717', '2025-07-29 09:31:35.717', NULL),
    (101, 100, 'WorkerType', 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.717', '2025-07-29 09:31:35.717', NULL),
    (102, 101, 'Worker', 2, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.717', '2025-07-29 09:31:35.717', NULL),
    (104, 102, 'Project', 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.717', '2025-07-29 09:31:35.717', NULL),
    (105, 103, 'Project', 2, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.717', '2025-07-29 09:31:35.717', NULL),
    (106, 100, 'Prueba', 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.720', '2025-07-29 09:31:35.720', NULL),
    (107, 101, 'Prueba', 2, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.720', '2025-07-29 09:31:35.720', NULL),
    (108, 100, 'VistaPrueba', 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.720', '2025-07-29 09:31:35.720', NULL),
    (109, 100, 'AddressType', 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.720', '2025-07-29 09:31:35.720', NULL),
    (111, 101, 'WorkerAddress', 2, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.720', '2025-07-29 09:31:35.720', NULL),
    (112, 100, 'Course', 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.720', '2025-07-29 09:31:35.720', NULL),
    (113, 101, 'Course', 2, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.720', '2025-07-29 09:31:35.720', NULL),
    (114, 104, 'Tarifa', 1, '1#hlxadm', '1#hlxadm', '2025-08-05 13:18:27.880', '2025-08-05 13:18:27.880', NULL),
    (115, 105, 'Tarifa', 2, '1#hlxadm', '1#hlxadm', '2025-08-05 13:18:46.700', '2025-08-05 13:18:46.700', NULL),
    (116, 104, 'VTA_Tarifa', 1, '1#hlxadm', '1#hlxadm', '2025-08-05 15:14:49.733', '2025-08-05 15:14:49.733', NULL),
    (117, 104, 'Concepto', 1, '1#hlxadm', '1#hlxadm', '2025-09-02 14:26:15.190', '2025-09-02 14:26:15.190', NULL),
    (118, 105, 'Concepto', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:15:31.397', '2025-09-03 09:15:31.397', NULL),
    (119, 104, 'ConceptoTipoServicioTarificable', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:15:48.150', '2025-09-03 09:15:48.150', NULL),
    (120, 105, 'ConceptoTipoServicioTarificable', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:15:53.497', '2025-09-03 09:15:53.497', NULL),
    (121, 104, 'ModoCalculo', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:16:16.817', '2025-09-03 09:16:16.817', NULL),
    (122, 105, 'ModoCalculo', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:16:20.120', '2025-09-03 09:16:20.120', NULL),
    (123, 104, 'ModoCalculoConcepto', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:16:29.130', '2025-09-03 09:16:29.130', NULL),
    (124, 105, 'ModoCalculoConcepto', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:16:33.637', '2025-09-03 09:16:33.637', NULL),
    (125, 104, 'Recargo', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:16:44.673', '2025-09-03 09:16:44.673', NULL),
    (126, 105, 'Recargo', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:16:49.960', '2025-09-03 09:16:49.960', NULL),
    (127, 104, 'RecargoTipoServicioTarificable', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:16:59.823', '2025-09-03 09:16:59.823', NULL),
    (128, 104, 'RecargoTipoServicioTarificableConcepto', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:17:14.017', '2025-09-03 09:17:14.017', NULL),
    (129, 105, 'RecargoTipoServicioTarificableConcepto', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:17:17.877', '2025-09-03 09:17:17.877', NULL),
    (130, 104, 'TarifaCalculo', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:17:35.757', '2025-09-03 09:17:35.757', NULL),
    (131, 105, 'TarifaCalculo', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:17:39.637', '2025-09-03 09:17:39.637', NULL),
    (132, 104, 'TarifaCalculoDetalle', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:17:48.917', '2025-09-03 09:17:48.917', NULL),
    (133, 105, 'TarifaCalculoDetalle', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:17:52.020', '2025-09-03 09:17:52.020', NULL),
    (134, 104, 'TarifaCalculoDetalleConcepto', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:18:00.500', '2025-09-03 09:18:00.500', NULL),
    (135, 105, 'TarifaCalculoDetalleConcepto', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:18:03.377', '2025-09-03 09:18:03.377', NULL),
    (136, 104, 'TarifaRecargo', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:18:11.577', '2025-09-03 09:18:11.577', NULL),
    (137, 105, 'TarifaRecargo', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:18:14.290', '2025-09-03 09:18:14.290', NULL),
    (138, 104, 'TarifaRecargoDetalle', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:19:09.167', '2025-09-03 09:19:09.167', NULL),
    (139, 105, 'TarifaRecargoDetalle', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:19:14.387', '2025-09-03 09:19:14.387', NULL),
    (140, 104, 'TarifaRecargoDetalleConcepto', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:19:24.450', '2025-09-03 09:19:24.450', NULL),
    (141, 105, 'TarifaRecargoDetalleConcepto', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:19:27.650', '2025-09-03 09:19:27.650', NULL),
    (142, 104, 'TarifaServicio', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:19:37.013', '2025-09-03 09:19:37.013', NULL),
    (143, 105, 'TarifaServicio', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:19:42.180', '2025-09-03 09:19:42.180', NULL),
    (144, 104, 'TipoConcepto', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:19:50.970', '2025-09-03 09:19:50.970', NULL),
    (145, 105, 'TipoConcepto', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:19:55.257', '2025-09-03 09:19:55.257', NULL),
    (146, 104, 'TipoRecargo', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:20:04.200', '2025-09-03 09:20:04.200', NULL),
    (147, 105, 'TipoRecargo', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:20:07.530', '2025-09-03 09:20:07.530', NULL),
    (148, 104, 'TipoServicioTarificable', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:20:22.227', '2025-09-03 09:20:22.227', NULL),
    (149, 105, 'TipoServicioTarificable', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:20:27.120', '2025-09-03 09:20:27.120', NULL),
    (150, 104, 'TipoTarifa', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:21:08.257', '2025-09-03 09:21:08.257', NULL),
    (151, 105, 'TipoTarifa', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:21:12.327', '2025-09-03 09:21:12.327', NULL),
    (152, 104, 'VTA_Concepto', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:21:30.060', '2025-09-03 09:21:30.060', NULL),
    (153, 105, 'VTA_Concepto', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:21:34.933', '2025-09-03 09:21:34.933', NULL),
    (154, 104, 'VTA_ModoCalculo', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:22:18.527', '2025-09-03 09:22:18.527', NULL),
    (155, 105, 'VTA_ModoCalculo', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:22:22.037', '2025-09-03 09:22:22.037', NULL),
    (156, 104, 'VTA_ModoCalculoConcepto', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:23:28.130', '2025-09-03 09:23:28.130', NULL),
    (157, 105, 'VTA_ModoCalculoConcepto', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:23:32.220', '2025-09-03 09:23:32.220', NULL),
    (158, 104, 'VTA_Recargo', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:23:57.837', '2025-09-03 09:23:57.837', NULL),
    (159, 105, 'VTA_Recargo', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:24:01.767', '2025-09-03 09:24:01.767', NULL),
    (160, 104, 'VTA_RecargoConcepto', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:24:11.390', '2025-09-03 09:24:11.390', NULL),
    (161, 105, 'VTA_RecargoConcepto', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:24:14.393', '2025-09-03 09:24:14.393', NULL),
    (162, 104, 'VTA_TarifaCalculoDetalleConcepto', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:33:01.987', '2025-09-03 09:33:01.987', NULL),
    (163, 105, 'VTA_TarifaCalculoDetalleConcepto', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:33:05.913', '2025-09-03 09:33:05.913', NULL),
    (164, 104, 'VTA_TarifaRecargoDetalleConcepto', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:33:14.587', '2025-09-03 09:33:14.587', NULL),
    (165, 105, 'VTA_TarifaRecargoDetalleConcepto', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:33:17.593', '2025-09-03 09:33:17.593', NULL),
    (166, 104, 'VTA_TipoServicioTarificable', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:33:25.663', '2025-09-03 09:33:25.663', NULL),
    (167, 105, 'VTA_TipoServicioTarificable', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:33:28.770', '2025-09-03 09:33:28.770', NULL),
    (168, 104, 'VTA_TipoTarifa', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:33:37.633', '2025-09-03 09:33:37.633', NULL),
    (169, 105, 'VTA_TipoTarifa', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:33:40.950', '2025-09-03 09:33:40.950', NULL),
    (170, 105, 'RecargoTipoServicioTarificable', 2, '1#hlxadm', '1#hlxadm', '2025-09-23 11:43:37.513', '2025-09-23 11:43:37.513', NULL)
ON CONFLICT ("Id") DO UPDATE SET
    "SecurityAccessOptionId" = EXCLUDED."SecurityAccessOptionId",
    "Controller" = EXCLUDED."Controller",
    "SecurityLevel" = EXCLUDED."SecurityLevel",
    "AuditCreationUser" = EXCLUDED."AuditCreationUser",
    "AuditModificationUser" = EXCLUDED."AuditModificationUser",
    "AuditCreationDate" = EXCLUDED."AuditCreationDate",
    "AuditModificationDate" = EXCLUDED."AuditModificationDate",
    "AuditDeletionDate" = EXCLUDED."AuditDeletionDate";



INSERT INTO "Helix6_Security"."SecurityProfile" AS t (
    "Id", "SecurityCompanyId", "Description", "Rol", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate"
)
OVERRIDING SYSTEM VALUE
VALUES
    (1, 1, 'Admin', 'HLX_admin', NULL, '1#hlxadm', '2025-07-29 09:31:23.800', '2025-07-29 09:31:23.800', NULL),
    (2, 1, 'User', 'ipvRateApi_user', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.803', '2025-07-29 09:31:23.803', NULL)
ON CONFLICT ("Id") DO UPDATE SET
    "SecurityCompanyId" = EXCLUDED."SecurityCompanyId",
    "Description" = EXCLUDED."Description",
    "Rol" = EXCLUDED."Rol",
    "AuditCreationUser" = EXCLUDED."AuditCreationUser",
    "AuditModificationUser" = EXCLUDED."AuditModificationUser",
    "AuditCreationDate" = EXCLUDED."AuditCreationDate",
    "AuditModificationDate" = EXCLUDED."AuditModificationDate",
    "AuditDeletionDate" = EXCLUDED."AuditDeletionDate";



INSERT INTO "Helix6_Security"."SecurityProfile_SecurityAccessOption" AS t (
    "Id", "SecurityProfileId", "SecurityAccessOptionId", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate"
)
OVERRIDING SYSTEM VALUE
VALUES
    (1, 1, 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.807', '2025-07-29 09:31:23.807', NULL),
    (2, 1, 3, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.810', '2025-07-29 09:31:23.810', NULL),
    (3, 1, 5, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.810', '2025-07-29 09:31:23.810', NULL),
    (4, 1, 7, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.813', '2025-07-29 09:31:23.813', NULL),
    (5, 2, 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.813', '2025-07-29 09:31:23.813', NULL),
    (6, 2, 6, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.817', '2025-07-29 09:31:23.817', NULL),
    (7, 2, 7, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.820', '2025-07-29 09:31:23.820', NULL),
    (8, 2, 13, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.820', '2025-07-29 09:31:23.820', NULL),
    (9, 1, 2, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.823', '2025-07-29 09:31:23.823', NULL),
    (10, 1, 4, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.823', '2025-07-29 09:31:23.823', NULL),
    (11, 1, 6, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.827', '2025-07-29 09:31:23.827', NULL),
    (12, 1, 8, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.830', '2025-07-29 09:31:23.830', NULL),
    (13, 1, 9, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.830', '2025-07-29 09:31:23.830', NULL),
    (14, 1, 10, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.833', '2025-07-29 09:31:23.833', NULL),
    (15, 1, 13, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.837', '2025-07-29 09:31:23.837', NULL),
    (16, 2, 8, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.837', '2025-07-29 09:31:23.837', NULL),
    (17, 2, 9, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.840', '2025-07-29 09:31:23.840', NULL),
    (18, 2, 10, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.840', '2025-07-29 09:31:23.840', NULL),
    (19, 2, 2, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.843', '2025-07-29 09:31:23.843', NULL),
    (20, 2, 3, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.847', '2025-07-29 09:31:23.847', NULL),
    (21, 2, 4, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.847', '2025-07-29 09:31:23.847', NULL),
    (22, 2, 5, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.850', '2025-07-29 09:31:23.850', NULL),
    (100, 1, 101, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.720', '2025-07-29 09:31:35.720', NULL),
    (101, 1, 103, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.720', '2025-07-29 09:31:35.720', NULL),
    (1202, 2, 100, '1#Nombre completo del Admin', '1#Nombre completo del Admin', '2025-07-29 09:31:35.720', '2025-07-29 09:31:35.720', NULL),
    (1203, 2, 101, '1#Nombre completo del Admin', '1#Nombre completo del Admin', '2025-07-29 09:31:35.720', '2025-07-29 09:31:35.720', NULL),
    (1204, 2, 102, '1#Nombre completo del Admin', '1#Nombre completo del Admin', '2025-07-29 09:31:35.720', '2025-07-29 09:31:35.720', NULL),
    (1205, 2, 103, '1#Nombre completo del Admin', '1#Nombre completo del Admin', '2025-07-29 09:31:35.720', '2025-07-29 09:31:35.720', NULL),
    (1213, 1, 100, '1#Nombre completo del Admin', '1#Nombre completo del Admin', '2025-07-29 09:31:35.720', '2025-07-29 09:31:35.720', NULL),
    (1214, 1, 104, NULL, NULL, NULL, NULL, NULL),
    (1215, 2, 104, NULL, NULL, NULL, NULL, NULL),
    (1216, 1, 105, NULL, NULL, NULL, NULL, NULL),
    (1217, 2, 105, NULL, NULL, NULL, NULL, NULL)
ON CONFLICT ("Id") DO UPDATE SET
    "SecurityProfileId" = EXCLUDED."SecurityProfileId",
    "SecurityAccessOptionId" = EXCLUDED."SecurityAccessOptionId",
    "AuditCreationUser" = EXCLUDED."AuditCreationUser",
    "AuditModificationUser" = EXCLUDED."AuditModificationUser",
    "AuditCreationDate" = EXCLUDED."AuditCreationDate",
    "AuditModificationDate" = EXCLUDED."AuditModificationDate",
    "AuditDeletionDate" = EXCLUDED."AuditDeletionDate";


INSERT INTO "Admon"."__EFMigrationsHistory" ("MigrationId", "ProductVersion")
VALUES ('20260215192142_01020003_SecurityData', '9.0.9');

