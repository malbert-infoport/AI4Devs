-- Regenerated security data script for InfoportOneAdmon
-- Adjusted per request: removed specified modules/options/levels and remapped
-- Applications and Organizations use ids 100/101; Groups inherit Organization permissions.
-- Idempotent inserts using ON CONFLICT ("Id") DO UPDATE

-- Source: consolidated and adjusted from original 01020003_SecurityData.sql

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


-- SecurityModule: keep Security and create Applications/Organizations at 100/101
INSERT INTO "Helix6_Security"."SecurityModule" AS t (
	"Id", "Description", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate"
)
VALUES
	(1, 'Security', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.747', '2025-07-29 09:31:23.747', NULL),
	(100, 'Applications', '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(101, 'Organizations', '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL)
ON CONFLICT ("Id") DO UPDATE SET
	"Description" = EXCLUDED."Description",
	"AuditCreationUser" = EXCLUDED."AuditCreationUser",
	"AuditModificationUser" = EXCLUDED."AuditModificationUser",
	"AuditCreationDate" = EXCLUDED."AuditCreationDate",
	"AuditModificationDate" = EXCLUDED."AuditModificationDate",
	"AuditDeletionDate" = EXCLUDED."AuditDeletionDate";


-- SecurityAccessOption: keep core security options and add new ranges for Applications (300s), Organizations (200s), Groups (210s)
INSERT INTO "Helix6_Security"."SecurityAccessOption" AS t (
	"Id", "SecurityModuleId", "Description", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate"
)
VALUES
	-- Core security options
	(1, 1, 'User customization', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.747', '2025-07-29 09:31:23.747', NULL),
	(2, 1, 'Profile query', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.750', '2025-07-29 09:31:23.750', NULL),
	(3, 1, 'Profile modification', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.753', '2025-07-29 09:31:23.753', NULL),
	(4, 1, 'General company configuration query', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.753', '2025-07-29 09:31:23.753', NULL),
	(5, 1, 'General company configuration modification', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.757', '2025-07-29 09:31:23.757', NULL),

	-- Organizations (module 101) options
	(200, 101, 'Organization query', '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(201, 101, 'Organization modification', '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(202, 101, 'Organization modules query', '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(204, 101, 'Organization modules modification', '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(203, 101, 'Organization audit query', '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),

	-- Applications (module 100) options: add query options for roles and credentials
	(300, 100, 'Application data query', '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(301, 100, 'Application data modification', '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(302, 100, 'Application modules query', '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(303, 100, 'Application modules modification', '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(304, 100, 'Application roles query', '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(305, 100, 'Application roles modification', '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(306, 100, 'Application credentials query', '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(307, 100, 'Application credentials modification', '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(308, 100, 'Application audit query', '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL)
ON CONFLICT ("Id") DO UPDATE SET
	"SecurityModuleId" = EXCLUDED."SecurityModuleId",
	"Description" = EXCLUDED."Description",
	"AuditCreationUser" = EXCLUDED."AuditCreationUser",
	"AuditModificationUser" = EXCLUDED."AuditModificationUser",
	"AuditCreationDate" = EXCLUDED."AuditCreationDate",
	"AuditModificationDate" = EXCLUDED."AuditModificationDate",
	"AuditDeletionDate" = EXCLUDED."AuditDeletionDate";


-- SecurityCompany (preserve existing)
INSERT INTO "Helix6_Security"."SecurityCompany" AS t (
	"Id", "SecurityCompanyGroupId", "Name", "Cif", "SecurityCompanyConfigurationId",
	"AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate"
)
VALUES
	(1, 1, 'Infoport', '12345678Z2', 1, '1#hlxadm', '1#hlxusr', '2025-07-29 09:31:23.770', '2023-08-03 07:31:29.110', NULL)
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


-- SecurityAccessOptionLevel: keep base mappings and add levels for new options; removed the attachment/worker/rate entries
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

	-- Organizations controllers (example mappings)
	(2000, 200, 'Organization', 1, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(2001, 201, 'Organization', 2, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(2002, 202, 'OrganizationModules', 1, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(2004, 204, 'OrganizationModules', 2, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(2003, 203, 'OrganizationAudit', 1, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),

	-- Group controllers (mirror Organization access options so Groups inherit Org permissions)
	(2010, 200, 'Group', 1, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(2011, 201, 'Group', 2, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(2012, 202, 'GroupModules', 1, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(2014, 204, 'GroupModules', 2, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(2013, 203, 'GroupAudit', 1, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),

	-- Applications controllers
	(3000, 300, 'Application', 1, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(3001, 301, 'Application', 2, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(3002, 302, 'ApplicationModules', 1, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(3003, 303, 'ApplicationModules', 2, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(3004, 304, 'ApplicationRoles', 1, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(3005, 305, 'ApplicationRoles', 2, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(3006, 306, 'ApplicationCredentials', 1, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(3007, 307, 'ApplicationCredentials', 2, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(3008, 308, 'ApplicationAudit', 1, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL)
ON CONFLICT ("Id") DO UPDATE SET
	"SecurityAccessOptionId" = EXCLUDED."SecurityAccessOptionId",
	"Controller" = EXCLUDED."Controller",
	"SecurityLevel" = EXCLUDED."SecurityLevel",
	"AuditCreationUser" = EXCLUDED."AuditCreationUser",
	"AuditModificationUser" = EXCLUDED."AuditModificationUser",
	"AuditCreationDate" = EXCLUDED."AuditCreationDate",
	"AuditModificationDate" = EXCLUDED."AuditModificationDate",
	"AuditDeletionDate" = EXCLUDED."AuditDeletionDate";


-- SecurityProfile (preserve)
INSERT INTO "Helix6_Security"."SecurityProfile" AS t (
	"Id", "SecurityCompanyId", "Description", "Rol", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate"
)
OVERRIDING SYSTEM VALUE
VALUES
	(1, 1, 'Admin', 'HLX_admin', NULL, '1#hlxadm', '2025-07-29 09:31:23.800', '2025-07-29 09:31:23.800', NULL),
	(2, 1, 'User', 'ipvRateApi_user', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.803', '2025-07-29 09:31:23.803', NULL),
	(3, 1, 'Organization Admin', 'HLX_orgadmin', '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(4, 1, 'Application Admin', 'HLX_appadmin', '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(5, 1, 'Organization Manager', 'OrganizationManager', '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(6, 1, 'Security Manager', 'SecurityManager', '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(7, 1, 'Application Manager', 'ApplicationManager', '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(8, 1, 'Audit Operator', 'AuditOperator', '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL)
ON CONFLICT ("Id") DO UPDATE SET
	"SecurityCompanyId" = EXCLUDED."SecurityCompanyId",
	"Description" = EXCLUDED."Description",
	"Rol" = EXCLUDED."Rol",
	"AuditCreationUser" = EXCLUDED."AuditCreationUser",
	"AuditModificationUser" = EXCLUDED."AuditModificationUser",
	"AuditCreationDate" = EXCLUDED."AuditCreationDate",
	"AuditModificationDate" = EXCLUDED."AuditModificationDate",
	"AuditDeletionDate" = EXCLUDED."AuditDeletionDate";


-- SecurityProfile -> SecurityAccessOption mappings (keep minimal safe set)
INSERT INTO "Helix6_Security"."SecurityProfile_SecurityAccessOption" AS t (
	"Id", "SecurityProfileId", "SecurityAccessOptionId", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate"
)
OVERRIDING SYSTEM VALUE
VALUES
	(1, 1, 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.807', '2025-07-29 09:31:23.807', NULL),
	(2, 1, 3, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.810', '2025-07-29 09:31:23.810', NULL),
	(3, 1, 5, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.810', '2025-07-29 09:31:23.810', NULL),
	(4, 2, 2, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.813', '2025-07-29 09:31:23.813', NULL),

	-- Admin (profile 1): full access to core, organizations and applications
	(5, 1, 2, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(6, 1, 4, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(7, 1, 200, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(8, 1, 201, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(9, 1, 202, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(10, 1, 204, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(11, 1, 203, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(12, 1, 300, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(13, 1, 301, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(14, 1, 302, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(15, 1, 303, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(16, 1, 304, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(17, 1, 305, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(18, 1, 306, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(19, 1, 307, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(20, 1, 308, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),

	-- User (profile 2): basic query access
	(21, 2, 200, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(22, 2, 300, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),

	-- Organization Admin (profile 3): organization management (modules + audit)
	(23, 3, 200, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(24, 3, 201, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(25, 3, 202, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(26, 3, 204, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(27, 3, 203, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),

	-- Application Admin (profile 4): application management
	(28, 4, 300, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(29, 4, 301, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(30, 4, 302, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(31, 4, 303, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(32, 4, 304, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(33, 4, 305, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(34, 4, 306, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(35, 4, 307, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(36, 4, 308, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),

	-- OrganizationManager (profile 5): create/edit/list organizations, view audit
	(37, 5, 200, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(38, 5, 201, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(39, 5, 202, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(40, 5, 203, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),

	-- SecurityManager (profile 6): organization activate/deactivate and audit view
	(41, 6, 201, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(42, 6, 200, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(43, 6, 203, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),

	-- ApplicationManager (profile 7): manage applications/modules/roles/credentials
	(44, 7, 300, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(45, 7, 301, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(46, 7, 302, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(47, 7, 303, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(48, 7, 304, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(49, 7, 305, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(50, 7, 306, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(51, 7, 307, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(52, 7, 308, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),

	-- AuditOperator (profile 8): read-only audit access
	(53, 8, 203, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL),
	(54, 8, 308, '1#hlxadm', '1#hlxadm', '2026-02-15 10:00:00', '2026-02-15 10:00:00', NULL)
ON CONFLICT ("Id") DO UPDATE SET
	"SecurityProfileId" = EXCLUDED."SecurityProfileId",
	"SecurityAccessOptionId" = EXCLUDED."SecurityAccessOptionId",
	"AuditCreationUser" = EXCLUDED."AuditCreationUser",
	"AuditModificationUser" = EXCLUDED."AuditModificationUser",
	"AuditCreationDate" = EXCLUDED."AuditCreationDate",
	"AuditModificationDate" = EXCLUDED."AuditModificationDate",
	"AuditDeletionDate" = EXCLUDED."AuditDeletionDate";


