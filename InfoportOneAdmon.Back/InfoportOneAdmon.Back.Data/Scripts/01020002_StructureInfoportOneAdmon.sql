-- =====================================================================================
-- InfoportOneAdmon - Database Structure
-- =====================================================================================
-- Plataforma administrativa centralizada para gestión del portfolio de aplicaciones
-- empresariales y gobierno de identidad multi-organización
-- =====================================================================================

CREATE SCHEMA IF NOT EXISTS "Admon";

-- =====================================================================================
-- TABLA: OrganizationGroup
-- =====================================================================================
-- Grupos lógicos de organizaciones (holdings, consorcios, franquicias)
-- Permite administración colectiva de múltiples organizaciones relacionadas
-- =====================================================================================

CREATE TABLE "Admon"."OrganizationGroup" (
    "Id" SERIAL PRIMARY KEY,
    "Name" CITEXT NOT NULL,
    
    -- Campos de auditoría Helix6 (automáticos)
    "AuditCreationUser" CITEXT NOT NULL,
    "AuditCreationDate" TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditModificationUser" CITEXT NOT NULL,
    "AuditModificationDate" TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditDeletionDate" TIMESTAMP NULL,
    
    -- Restricciones de longitud para campos citext
    CONSTRAINT "chk_organizationgroup_name_length" CHECK (char_length("Name") <= 200),
    CONSTRAINT "chk_organizationgroup_auditcreationuser_length" CHECK (char_length("AuditCreationUser") <= 255),
    CONSTRAINT "chk_organizationgroup_auditmodificationuser_length" CHECK (char_length("AuditModificationUser") <= 255),
    
    -- Índices
    CONSTRAINT "uq_organizationgroup_name" UNIQUE ("Name")
);

CREATE INDEX "idx_organizationgroup_auditdeletiondate" ON "Admon"."OrganizationGroup"("AuditDeletionDate");

COMMENT ON TABLE "Admon"."OrganizationGroup" IS 'Agrupaciones lógicas de organizaciones para facilitar gestión colectiva (holdings, consorcios)';
COMMENT ON COLUMN "Admon"."OrganizationGroup"."Name" IS 'Nombre del grupo de organizaciones';
COMMENT ON COLUMN "Admon"."OrganizationGroup"."AuditDeletionDate" IS 'Fecha de baja lógica (soft delete). NULL = activo';

-- =====================================================================================
-- TABLA: Organization
-- =====================================================================================
-- Organizaciones clientes del ecosistema (empresas que contratan las aplicaciones)
-- Es la entidad central del sistema de multi-tenancy
-- SecurityCompanyId es el identificador inmutable que se propaga en tokens JWT (claim c_ids)
-- =====================================================================================

CREATE TABLE "Admon"."Organization" (
    "Id" SERIAL PRIMARY KEY,
    "SecurityCompanyId" INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    "Name" CITEXT NOT NULL,
    "Acronym" CITEXT NOT NULL,
    "TaxId" CITEXT NULL,
    "Address" CITEXT NULL,
    "City" CITEXT NULL,
    "Country" CITEXT NULL,
    "ContactEmail" CITEXT NULL,
    "ContactPhone" CITEXT NULL,
    
    -- Relación con grupo (opcional)
    "GroupId" INTEGER NULL,
    
    -- Campos de auditoría Helix6 (automáticos)
    "AuditCreationUser" CITEXT NOT NULL,
    "AuditCreationDate" TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditModificationUser" CITEXT NOT NULL,
    "AuditModificationDate" TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditDeletionDate" TIMESTAMP NULL,
    
    -- Restricciones de longitud para campos citext
    CONSTRAINT "chk_organization_name_length" CHECK (char_length("Name") <= 200),
    CONSTRAINT "chk_organization_acronym_length" CHECK (char_length("Acronym") <= 10),
    CONSTRAINT "chk_organization_auditcreationuser_length" CHECK (char_length("AuditCreationUser") <= 255),
    CONSTRAINT "chk_organization_auditmodificationuser_length" CHECK (char_length("AuditModificationUser") <= 255),
    CONSTRAINT "chk_organization_taxid_length" CHECK (char_length("TaxId") <= 50),
    CONSTRAINT "chk_organization_address_length" CHECK (char_length("Address") <= 500),
    CONSTRAINT "chk_organization_city_length" CHECK (char_length("City") <= 100),
    CONSTRAINT "chk_organization_country_length" CHECK (char_length("Country") <= 100),
    CONSTRAINT "chk_organization_contactemail_length" CHECK (char_length("ContactEmail") <= 255),
    CONSTRAINT "chk_organization_contactphone_length" CHECK (char_length("ContactPhone") <= 50),
    
    -- Foreign Keys
    CONSTRAINT "fk_organization_group" FOREIGN KEY ("GroupId") 
        REFERENCES "Admon"."OrganizationGroup"("Id") 
        ON DELETE SET NULL,
    
    -- Índices de unicidad
    CONSTRAINT "uq_organization_securitycompanyid" UNIQUE ("SecurityCompanyId"),
    CONSTRAINT "uq_organization_acronym" UNIQUE ("Acronym"),
    CONSTRAINT "uq_organization_taxid" UNIQUE ("TaxId")
);

CREATE INDEX "idx_organization_name" ON "Admon"."Organization"("Name");
CREATE INDEX "idx_organization_securitycompanyid" ON "Admon"."Organization"("SecurityCompanyId");
CREATE INDEX "idx_organization_groupid" ON "Admon"."Organization"("GroupId");
CREATE INDEX "idx_organization_auditdeletiondate" ON "Admon"."Organization"("AuditDeletionDate");

COMMENT ON TABLE "Admon"."Organization" IS 'Organizaciones clientes del ecosistema. Fuente de verdad para multi-tenancy';
COMMENT ON COLUMN "Admon"."Organization"."Id" IS 'Clave primaria técnica requerida por Helix6 (IEntityBase)';
COMMENT ON COLUMN "Admon"."Organization"."SecurityCompanyId" IS 'Identificador único inmutable de la organización. Se propaga en claim c_ids de tokens JWT';
COMMENT ON COLUMN "Admon"."Organization"."Acronym" IS 'Acrónimo único de la organización (máx. 10 caracteres) para identificación rápida';
COMMENT ON COLUMN "Admon"."Organization"."TaxId" IS 'Identificador fiscal de la organización (CIF/NIF)';
COMMENT ON COLUMN "Admon"."Organization"."GroupId" IS 'ID del grupo al que pertenece (holding, consorcio). NULL si no pertenece a ningún grupo';
COMMENT ON COLUMN "Admon"."Organization"."AuditDeletionDate" IS 'Fecha de baja lógica. Al establecerse, bloquea acceso inmediato y propaga baja de usuarios a Keycloak';

-- =====================================================================================
-- TABLA: Application
-- =====================================================================================

CREATE TABLE "Admon"."Application" (
    "Id" SERIAL PRIMARY KEY,
    "ApplicationId" INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    "Name" CITEXT NOT NULL,
    "Acronym" CITEXT NOT NULL,
    "Description" CITEXT NULL,
    
    -- Campos de auditoría Helix6 (automáticos)
    "AuditCreationUser" CITEXT NOT NULL,
    "AuditCreationDate" TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditModificationUser" CITEXT NOT NULL,
    "AuditModificationDate" TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditDeletionDate" TIMESTAMP NULL,
    
    -- Restricciones de longitud para campos citext
    CONSTRAINT "chk_application_name_length" CHECK (char_length("Name") <= 200),
    CONSTRAINT "chk_application_acronym_length" CHECK (char_length("Acronym") <= 10),
    CONSTRAINT "chk_application_auditcreationuser_length" CHECK (char_length("AuditCreationUser") <= 255),
    CONSTRAINT "chk_application_auditmodificationuser_length" CHECK (char_length("AuditModificationUser") <= 255),
    CONSTRAINT "chk_application_description_length" CHECK (char_length("Description") <= 1000),
    
    -- Índices de unicidad
    CONSTRAINT "uq_application_applicationid" UNIQUE ("ApplicationId"),
    CONSTRAINT "uq_application_name" UNIQUE ("Name"),
    CONSTRAINT "uq_application_acronym" UNIQUE ("Acronym")
);

CREATE INDEX "idx_application_applicationid" ON "Admon"."Application"("ApplicationId");
CREATE INDEX "idx_application_auditdeletiondate" ON "Admon"."Application"("AuditDeletionDate");

COMMENT ON TABLE "Admon"."Application" IS 'Aplicaciones satélite del portfolio empresarial. Define el catálogo de aplicaciones disponibles';
COMMENT ON COLUMN "Admon"."Application"."Id" IS 'Clave primaria técnica requerida por Helix6 (IEntityBase)';
COMMENT ON COLUMN "Admon"."Application"."ApplicationId" IS 'Identificador único de negocio auto-generado inmutable';
COMMENT ON COLUMN "Admon"."Application"."Acronym" IS 'Acrónimo único para nomenclatura de roles y módulos (ej: STP, CRM, ERP)';
COMMENT ON COLUMN "Admon"."Application"."AuditDeletionDate" IS 'Fecha de baja lógica. Al establecerse, revoca automáticamente todas sus credenciales en Keycloak';

-- =====================================================================================
-- TABLA: ApplicationSecurity
-- =====================================================================================

CREATE TABLE "Admon"."ApplicationSecurity" (
    "Id" SERIAL PRIMARY KEY,
    "ApplicationId" INTEGER NOT NULL,
    "ClientId" CITEXT NOT NULL,
    "ClientSecret" CITEXT NULL,
    "ClientType" CITEXT NOT NULL,
    "CredentialType" CITEXT NOT NULL,
    "Description" CITEXT NULL,
    
    -- Campos de auditoría Helix6 (automáticos)
    "AuditCreationUser" CITEXT NOT NULL,
    "AuditCreationDate" TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditModificationUser" CITEXT NOT NULL,
    "AuditModificationDate" TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditDeletionDate" TIMESTAMP NULL,
    
    -- Restricciones de longitud para campos citext
    CONSTRAINT "chk_appsecurity_auditcreationuser_length" CHECK (char_length("AuditCreationUser") <= 255),
    CONSTRAINT "chk_appsecurity_auditmodificationuser_length" CHECK (char_length("AuditModificationUser") <= 255),
    CONSTRAINT "chk_appsecurity_clientid_length" CHECK (char_length("ClientId") <= 255),
    CONSTRAINT "chk_appsecurity_clientsecret_length" CHECK (char_length("ClientSecret") <= 512),
    CONSTRAINT "chk_appsecurity_clienttype_length" CHECK (char_length("ClientType") <= 50),
    CONSTRAINT "chk_appsecurity_credentialtype_length" CHECK (char_length("CredentialType") <= 50),
    CONSTRAINT "chk_appsecurity_description_length" CHECK (char_length("Description") <= 1000),
    
    -- Validaciones de negocio
    CONSTRAINT "chk_appsecurity_clienttype_values" CHECK ("ClientType" IN ('Public', 'Confidential')),
    CONSTRAINT "chk_appsecurity_credentialtype_values" CHECK ("CredentialType" IN ('CODE_PKCE', 'CLIENT_CREDENTIALS')),
    
    -- Foreign Keys
    CONSTRAINT "fk_appsecurity_application" FOREIGN KEY ("ApplicationId") 
        REFERENCES "Admon"."Application"("Id") 
        ON DELETE CASCADE,
    
    -- Índices de unicidad
    CONSTRAINT "uq_appsecurity_clientid" UNIQUE ("ClientId")
);

CREATE INDEX "idx_appsecurity_applicationid" ON "Admon"."ApplicationSecurity"("ApplicationId");
CREATE INDEX "idx_appsecurity_auditdeletiondate" ON "Admon"."ApplicationSecurity"("AuditDeletionDate");

COMMENT ON TABLE "Admon"."ApplicationSecurity" IS 'Credenciales OAuth2 para autenticación de aplicaciones en Keycloak. Soporta múltiples credenciales por aplicación';
COMMENT ON COLUMN "Admon"."ApplicationSecurity"."ApplicationId" IS 'ID de la aplicación (FK a Application.Id)';
COMMENT ON COLUMN "Admon"."ApplicationSecurity"."ClientId" IS 'OAuth2 client_id único para autenticación en Keycloak';
COMMENT ON COLUMN "Admon"."ApplicationSecurity"."ClientSecret" IS 'OAuth2 client_secret. NULL para public clients (SPAs con PKCE), requerido para confidential clients';
COMMENT ON COLUMN "Admon"."ApplicationSecurity"."ClientType" IS 'Tipo de cliente OAuth2: Public (Angular SPAs) o Confidential (APIs backend)';
COMMENT ON COLUMN "Admon"."ApplicationSecurity"."CredentialType" IS 'Tipo de credencial: CODE_PKCE (acceso web) o CLIENT_CREDENTIALS (APIs externas)';
COMMENT ON COLUMN "Admon"."ApplicationSecurity"."AuditDeletionDate" IS 'Fecha de baja lógica. Al establecerse, revoca la credencial en Keycloak';

-- =====================================================================================
-- TABLA: ApplicationModule
-- =====================================================================================

CREATE TABLE "Admon"."ApplicationModule" (
    "Id" SERIAL PRIMARY KEY,
    "ApplicationId" INTEGER NOT NULL,
    "Name" CITEXT NOT NULL,
    "Description" CITEXT NULL,
    
    -- Campos de auditoría Helix6 (automáticos)
    "AuditCreationUser" CITEXT NOT NULL,
    "AuditCreationDate" TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditModificationUser" CITEXT NOT NULL,
    "AuditModificationDate" TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditDeletionDate" TIMESTAMP NULL,
    
    -- Restricciones de longitud para campos citext
    CONSTRAINT "chk_applicationmodule_auditcreationuser_length" CHECK (char_length("AuditCreationUser") <= 255),
    CONSTRAINT "chk_applicationmodule_auditmodificationuser_length" CHECK (char_length("AuditModificationUser") <= 255),
    CONSTRAINT "chk_applicationmodule_name_length" CHECK (char_length("Name") <= 200),
    CONSTRAINT "chk_applicationmodule_description_length" CHECK (char_length("Description") <= 1000),
    
    -- Foreign Keys
    CONSTRAINT "fk_applicationmodule_application" FOREIGN KEY ("ApplicationId") 
        REFERENCES "Admon"."Application"("Id") 
        ON DELETE CASCADE,
    
    -- Índices de unicidad (nombre único por aplicación)
    CONSTRAINT "uq_applicationmodule_application_name" UNIQUE ("ApplicationId", "Name")
);

CREATE INDEX "idx_applicationmodule_applicationid" ON "Admon"."ApplicationModule"("ApplicationId");
CREATE INDEX "idx_applicationmodule_auditdeletiondate" ON "Admon"."ApplicationModule"("AuditDeletionDate");

COMMENT ON TABLE "Admon"."ApplicationModule" IS 'Módulos funcionales de aplicaciones. Permiten ventas granulares por funcionalidad';
COMMENT ON COLUMN "Admon"."ApplicationModule"."Name" IS 'Nombre del módulo siguiendo nomenclatura: M + Acronym + _ + nombre funcional';
COMMENT ON COLUMN "Admon"."ApplicationModule"."AuditDeletionDate" IS 'Fecha de baja lógica del módulo';

-- =====================================================================================
-- TABLA: ApplicationRole
-- =====================================================================================

CREATE TABLE "Admon"."ApplicationRole" (
    "Id" SERIAL PRIMARY KEY,
    "ApplicationId" INTEGER NOT NULL,
    "Name" CITEXT NOT NULL,
    "Description" CITEXT NULL,
    
    -- Campos de auditoría Helix6 (automáticos)
    "AuditCreationUser" CITEXT NOT NULL,
    "AuditCreationDate" TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditModificationUser" CITEXT NOT NULL,
    "AuditModificationDate" TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditDeletionDate" TIMESTAMP NULL,
    
    -- Restricciones de longitud para campos citext
    CONSTRAINT "chk_applicationrole_auditcreationuser_length" CHECK (char_length("AuditCreationUser") <= 255),
    CONSTRAINT "chk_applicationrole_auditmodificationuser_length" CHECK (char_length("AuditModificationUser") <= 255),
    CONSTRAINT "chk_applicationrole_name_length" CHECK (char_length("Name") <= 200),
    CONSTRAINT "chk_applicationrole_description_length" CHECK (char_length("Description") <= 1000),
    
    -- Foreign Keys
    CONSTRAINT "fk_applicationrole_application" FOREIGN KEY ("ApplicationId") 
        REFERENCES "Admon"."Application"("Id") 
        ON DELETE CASCADE,
    
    -- Índices de unicidad (nombre único por aplicación)
    CONSTRAINT "uq_applicationrole_application_name" UNIQUE ("ApplicationId", "Name")
);

CREATE INDEX "idx_applicationrole_applicationid" ON "Admon"."ApplicationRole"("ApplicationId");
CREATE INDEX "idx_applicationrole_auditdeletiondate" ON "Admon"."ApplicationRole"("AuditDeletionDate");

COMMENT ON TABLE "Admon"."ApplicationRole" IS 'Catálogo maestro de roles de cada aplicación. Garantiza coherencia en nomenclatura';
COMMENT ON COLUMN "Admon"."ApplicationRole"."Name" IS 'Nombre del rol siguiendo nomenclatura: Acronym + _ + nombre funcional (ej: STP_Supervisor)';
COMMENT ON COLUMN "Admon"."ApplicationRole"."AuditDeletionDate" IS 'Fecha de baja lógica. Roles dados de baja no se asignan a nuevos usuarios';

-- =====================================================================================
-- TABLA: OrganizationApplicationModule
-- =====================================================================================

CREATE TABLE "Admon"."OrganizationApplicationModule" (
    "Id" SERIAL PRIMARY KEY,
    "OrganizationId" INTEGER NOT NULL,
    "ApplicationModuleId" INTEGER NOT NULL,
    
    -- Campos de auditoría Helix6 (automáticos)
    "AuditCreationUser" CITEXT NOT NULL,
    "AuditCreationDate" TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditModificationUser" CITEXT NOT NULL,
    "AuditModificationDate" TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditDeletionDate" TIMESTAMP NULL,
    
    -- Restricciones de longitud para campos citext
    CONSTRAINT "chk_orgappmodule_auditcreationuser_length" CHECK (char_length("AuditCreationUser") <= 255),
    CONSTRAINT "chk_orgappmodule_auditmodificationuser_length" CHECK (char_length("AuditModificationUser") <= 255),
    
    -- Foreign Keys
    CONSTRAINT "fk_orgappmodule_organization" FOREIGN KEY ("OrganizationId") 
        REFERENCES "Admon"."Organization"("Id") 
        ON DELETE CASCADE,
    CONSTRAINT "fk_orgappmodule_module" FOREIGN KEY ("ApplicationModuleId") 
        REFERENCES "Admon"."ApplicationModule"("Id") 
        ON DELETE CASCADE,
    
    -- Índices de unicidad (una org no puede tener el mismo módulo duplicado)
    CONSTRAINT "uq_orgappmodule_org_module" UNIQUE ("OrganizationId", "ApplicationModuleId")
);

CREATE INDEX "idx_orgappmodule_organizationid" ON "Admon"."OrganizationApplicationModule"("OrganizationId");
CREATE INDEX "idx_orgappmodule_ApplicationModuleId" ON "Admon"."OrganizationApplicationModule"("ApplicationModuleId");
CREATE INDEX "idx_orgappmodule_auditdeletiondate" ON "Admon"."OrganizationApplicationModule"("AuditDeletionDate");

COMMENT ON TABLE "Admon"."OrganizationApplicationModule" IS 'Permisos de acceso a módulos por organización. Habilita ventas granulares por funcionalidad';
COMMENT ON COLUMN "Admon"."OrganizationApplicationModule"."OrganizationId" IS 'ID de la organización cliente (Organization.Id)';
COMMENT ON COLUMN "Admon"."OrganizationApplicationModule"."ApplicationModuleId" IS 'ID del módulo al que tiene acceso la organización';
COMMENT ON COLUMN "Admon"."OrganizationApplicationModule"."AuditDeletionDate" IS 'Fecha de revocación de acceso al módulo';

-- =====================================================================================
-- TABLA: AuditLog
-- =====================================================================================

CREATE TABLE "Admon"."AuditLog" (
    "Id" SERIAL PRIMARY KEY,
    "Action" CITEXT NOT NULL,
    "EntityType" CITEXT NOT NULL,
    "EntityId" INTEGER NOT NULL,
    "UserId" INTEGER NULL,
    "Timestamp" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Campos de auditoría Helix6 (automáticos)
    "AuditCreationUser" CITEXT NOT NULL,
    "AuditCreationDate" TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditModificationUser" CITEXT NOT NULL,
    "AuditModificationDate" TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditDeletionDate" TIMESTAMP NULL,
    
    -- Restricciones de longitud para campos citext
    CONSTRAINT "chk_auditlog_auditcreationuser_length" CHECK (char_length("AuditCreationUser") <= 255),
    CONSTRAINT "chk_auditlog_auditmodificationuser_length" CHECK (char_length("AuditModificationUser") <= 255),
    CONSTRAINT "chk_auditlog_action_length" CHECK (char_length("Action") <= 100),
    CONSTRAINT "chk_auditlog_entitytype_length" CHECK (char_length("EntityType") <= 100),
    
    -- Validaciones de acciones permitidas (Epic1)
    CONSTRAINT "chk_auditlog_action_values" CHECK ("Action" IN (
        'ModuleAssigned',
        'ModuleRemoved',
        'OrganizationDeactivatedManual',
        'OrganizationAutoDeactivated',
        'OrganizationReactivatedManual',
        'GroupChanged'
    ))
);

CREATE INDEX "idx_auditlog_entitytype_entityid" ON "Admon"."AuditLog"("EntityType", "EntityId");
CREATE INDEX "idx_auditlog_userid" ON "Admon"."AuditLog"("UserId");
CREATE INDEX "idx_auditlog_timestamp" ON "Admon"."AuditLog"("Timestamp" DESC);
CREATE INDEX "idx_auditlog_auditdeletiondate" ON "Admon"."AuditLog"("AuditDeletionDate");

COMMENT ON TABLE "Admon"."AuditLog" IS 'Auditoría selectiva de acciones críticas en seguridad y permisos (complementa auditoría automática Helix6)';
COMMENT ON COLUMN "Admon"."AuditLog"."Action" IS 'Acción auditada: ModuleAssigned, ModuleRemoved, OrganizationDeactivatedManual, OrganizationAutoDeactivated, OrganizationReactivatedManual, GroupChanged';
COMMENT ON COLUMN "Admon"."AuditLog"."EntityType" IS 'Tipo de entidad afectada: Organization, ApplicationModule, OrganizationApplicationModule';
COMMENT ON COLUMN "Admon"."AuditLog"."EntityId" IS 'ID de la entidad afectada';
COMMENT ON COLUMN "Admon"."AuditLog"."UserId" IS 'ID del usuario que ejecutó la acción (NULL si fue acción automática del sistema)';

-- =====================================================================================
-- TABLA: EventHash
-- =====================================================================================

CREATE TABLE "Admon"."EventHash" (
    "Id" SERIAL PRIMARY KEY,
    "EntityType" CITEXT NOT NULL,
    "EntityId" INTEGER NOT NULL,
    "LastEventHash" CHAR(64) NOT NULL,
    "LastPublishedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Campos de auditoría Helix6 (automáticos)
    "AuditCreationUser" CITEXT NOT NULL,
    "AuditCreationDate" TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditModificationUser" CITEXT NOT NULL,
    "AuditModificationDate" TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditDeletionDate" TIMESTAMP NULL,
    
    -- Restricciones de longitud para campos citext
    CONSTRAINT "chk_eventhash_auditcreationuser_length" CHECK (char_length("AuditCreationUser") <= 255),
    CONSTRAINT "chk_eventhash_auditmodificationuser_length" CHECK (char_length("AuditModificationUser") <= 255),
    CONSTRAINT "chk_eventhash_entitytype_length" CHECK (char_length("EntityType") <= 100),
    
    -- Índices de unicidad (un hash por tipo de entidad y ID)
    CONSTRAINT "uq_eventhash_entitytype_entityid" UNIQUE ("EntityType", "EntityId")
);

CREATE INDEX "idx_eventhash_lastpublishedat" ON "Admon"."EventHash"("LastPublishedAt" DESC);
CREATE INDEX "idx_eventhash_auditdeletiondate" ON "Admon"."EventHash"("AuditDeletionDate");

COMMENT ON TABLE "Admon"."EventHash" IS 'Control de eventos duplicados mediante hash SHA-256. Previene publicar eventos idénticos consecutivos';
COMMENT ON COLUMN "Admon"."EventHash"."EntityType" IS 'Tipo de entidad: ORGANIZATION, APPLICATION, USER';
COMMENT ON COLUMN "Admon"."EventHash"."EntityId" IS 'ID de la entidad';
COMMENT ON COLUMN "Admon"."EventHash"."LastEventHash" IS 'Hash SHA-256 (64 caracteres) del Payload del último evento publicado';
COMMENT ON COLUMN "Admon"."EventHash"."LastPublishedAt" IS 'Timestamp de la última publicación exitosa';

-- =====================================================================================
-- TABLA: UserCache
-- =====================================================================================

CREATE TABLE "Admon"."UserCache" (
    "Id" SERIAL PRIMARY KEY,
    "Email" CITEXT NOT NULL,
    "ConsolidatedCompanyIds" TEXT NOT NULL,
    "ConsolidatedRoles" TEXT NOT NULL,
    "LastUpdated" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "LastEventHash" CHAR(64) NOT NULL,
    
    -- Campos de auditoría Helix6 (automáticos)
    "AuditCreationUser" CITEXT NOT NULL,
    "AuditCreationDate" TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditModificationUser" CITEXT NOT NULL,
    "AuditModificationDate" TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    "AuditDeletionDate" TIMESTAMP NULL,
    
    -- Restricciones de longitud para campos citext
    CONSTRAINT "chk_usercache_auditcreationuser_length" CHECK (char_length("AuditCreationUser") <= 255),
    CONSTRAINT "chk_usercache_auditmodificationuser_length" CHECK (char_length("AuditModificationUser") <= 255),
    CONSTRAINT "chk_usercache_email_length" CHECK (char_length("Email") <= 255),
    
    -- Índices de unicidad
    CONSTRAINT "uq_usercache_email" UNIQUE ("Email")
);

CREATE INDEX "idx_usercache_lastupdated" ON "Admon"."UserCache"("LastUpdated" DESC);
CREATE INDEX "idx_usercache_auditdeletiondate" ON "Admon"."UserCache"("AuditDeletionDate");
COMMENT ON TABLE "Admon"."UserCache" IS 'Caché de usuarios consolidados multi-organización. Optimiza procesamiento del Background Worker';
COMMENT ON COLUMN "Admon"."UserCache"."Id" IS 'Clave primaria técnica requerida por Helix6 (IEntityBase)';
COMMENT ON COLUMN "Admon"."UserCache"."Email" IS 'Email del usuario (único, case-insensitive)';
COMMENT ON COLUMN "Admon"."UserCache"."ConsolidatedCompanyIds" IS 'Array JSON con todos los SecurityCompanyId del usuario: [12345, 67890, 11111]';
COMMENT ON COLUMN "Admon"."UserCache"."ConsolidatedRoles" IS 'Array JSON con todos los roles consolidados del usuario de todas las apps: ["CRM_Vendedor", "ERP_Contable"]';
COMMENT ON COLUMN "Admon"."UserCache"."LastUpdated" IS 'Timestamp de la última consolidación';
COMMENT ON COLUMN "Admon"."UserCache"."LastEventHash" IS 'Hash SHA-256 del último evento procesado para este usuario';

-- =====================================================================================
-- VISTAS AUXILIARES
-- =====================================================================================

-- Vista para consultar organizaciones activas (no eliminadas)
CREATE OR REPLACE VIEW "Admon"."VTA_ActiveOrganizations" AS
SELECT 
    "Id",
    "SecurityCompanyId",
    "Name",
    "Acronym",
    "TaxId",
    "Address",
    "City",
    "Country",
    "ContactEmail",
    "ContactPhone",
    "GroupId",
    "AuditCreationUser",
    "AuditCreationDate",
    "AuditModificationUser",
    "AuditModificationDate",
    "AuditDeletionDate"
FROM "Admon"."Organization"
WHERE "AuditDeletionDate" IS NULL;

COMMENT ON VIEW "Admon"."VTA_ActiveOrganizations" IS 'Organizaciones activas (no eliminadas lógicamente)';

-- Vista para consultar aplicaciones activas
CREATE OR REPLACE VIEW "Admon"."VTA_ActiveApplications" AS
SELECT 
    "Id",
    "ApplicationId",
    "Name",
    "Acronym",
    "Description",
    "AuditCreationUser",
    "AuditCreationDate",
    "AuditModificationUser",
    "AuditModificationDate",
    "AuditDeletionDate"
FROM "Admon"."Application"
WHERE "AuditDeletionDate" IS NULL;

COMMENT ON VIEW "Admon"."VTA_ActiveApplications" IS 'Aplicaciones activas del portfolio';

-- Vista para consultar credenciales de seguridad activas por aplicación
CREATE OR REPLACE VIEW "Admon"."VTA_ApplicationSecurityCredentials" AS
SELECT 
    aps."Id",
    aps."ApplicationId",
    a."ApplicationId" AS "AppBusinessId",
    a."Name" AS "ApplicationName",
    aps."ClientId",
    aps."ClientType",
    aps."CredentialType",
    aps."Description",
    aps."AuditCreationUser",
    aps."AuditCreationDate",
    aps."AuditModificationUser",
    aps."AuditModificationDate",
    aps."AuditDeletionDate"
FROM "Admon"."ApplicationSecurity" aps
INNER JOIN "Admon"."Application" a ON aps."ApplicationId" = a."Id"
WHERE aps."AuditDeletionDate" IS NULL
  AND a."AuditDeletionDate" IS NULL;

COMMENT ON VIEW "Admon"."VTA_ApplicationSecurityCredentials" IS 'Credenciales OAuth2 activas de aplicaciones';

-- Vista para consultar módulos activos por aplicación
CREATE OR REPLACE VIEW "Admon"."VTA_ActiveApplicationModules" AS
SELECT 
    am."Id",
    am."ApplicationId",
    a."ApplicationId" AS "AppBusinessId",
    a."Name" AS "ApplicationName",
    a."Acronym",
    am."Name" AS "ApplicationModuleName",
    am."Description",
    am."AuditCreationUser",
    am."AuditCreationDate",
    am."AuditModificationUser",
    am."AuditModificationDate",
    am."AuditDeletionDate"
FROM "Admon"."ApplicationModule" am
INNER JOIN "Admon"."Application" a ON am."ApplicationId" = a."Id"
WHERE am."AuditDeletionDate" IS NULL
  AND a."AuditDeletionDate" IS NULL;

COMMENT ON VIEW "Admon"."VTA_ActiveApplicationModules" IS 'Módulos activos de aplicaciones activas';

-- Vista para consultar permisos de módulos por organización
CREATE OR REPLACE VIEW "Admon"."VTA_OrganizationModuleAccess" AS
SELECT 
    oam."Id",
    o."Id" AS "OrganizationId",
    o."SecurityCompanyId",
    o."Name" AS "OrganizationName",
    a."Id" AS "ApplicationId",
    a."ApplicationId" AS "AppBusinessId",
    a."Name" AS "ApplicationName",
    am."Id" AS "ApplicationModuleId",
    am."Name" AS "ApplicationModuleName",
    oam."AuditCreationUser",
    oam."AuditCreationDate" AS "AccessGrantedDate",
    oam."AuditModificationUser",
    oam."AuditModificationDate",
    oam."AuditDeletionDate"
FROM "Admon"."OrganizationApplicationModule" oam
INNER JOIN "Admon"."Organization" o ON oam."OrganizationId" = o."Id"
INNER JOIN "Admon"."ApplicationModule" am ON oam."ApplicationModuleId" = am."Id"
INNER JOIN "Admon"."Application" a ON am."ApplicationId" = a."Id"
WHERE oam."AuditDeletionDate" IS NULL
  AND o."AuditDeletionDate" IS NULL
  AND am."AuditDeletionDate" IS NULL
  AND a."AuditDeletionDate" IS NULL;

COMMENT ON VIEW "Admon"."VTA_OrganizationModuleAccess" IS 'Permisos activos de acceso a módulos por organización';

-- =====================================================================================
-- FUNCIONES AUXILIARES
-- =====================================================================================

-- Función para obtener todos los módulos accesibles por una organización en una aplicación específica
CREATE OR REPLACE FUNCTION "Admon"."FUN_GetOrganizationApplicationModules"(
    p_OrganizationId INTEGER,
    p_ApplicationId INTEGER
)
RETURNS TABLE (
    "ApplicationModuleId" INTEGER,
    "ApplicationModuleName" CITEXT,
    "Description" CITEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        am."Id",
        am."Name",
        am."Description"
    FROM "Admon"."OrganizationApplicationModule" oam
    INNER JOIN "Admon"."ApplicationModule" am ON oam."ApplicationModuleId" = am."Id"
    WHERE oam."OrganizationId" = p_OrganizationId
      AND am."ApplicationId" = p_ApplicationId
      AND oam."AuditDeletionDate" IS NULL
      AND am."AuditDeletionDate" IS NULL;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION "Admon"."FUN_GetOrganizationApplicationModules" IS 'Obtiene los módulos accesibles por una organización en una aplicación específica';

-- Función para obtener el claim c_ids de un usuario (todos sus SecurityCompanyIds)
CREATE OR REPLACE FUNCTION "Admon"."FUN_GetUserCompanyIds"(p_Email CITEXT)
RETURNS INTEGER[] AS $$
DECLARE
    v_CompanyIds INTEGER[];
BEGIN
    SELECT 
        ARRAY(
            SELECT DISTINCT CAST(value AS INTEGER)
            FROM json_array_elements_text("ConsolidatedCompanyIds"::json) AS value
        )
    INTO v_CompanyIds
    FROM "Admon"."UserCache"
    WHERE "Email" = p_Email;
    
    RETURN COALESCE(v_CompanyIds, ARRAY[]::INTEGER[]);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION "Admon"."FUN_GetUserCompanyIds" IS 'Obtiene el array de SecurityCompanyIds (claim c_ids) de un usuario por email';

-- =====================================================================================
-- FIN DEL SCRIPT
-- =====================================================================================
