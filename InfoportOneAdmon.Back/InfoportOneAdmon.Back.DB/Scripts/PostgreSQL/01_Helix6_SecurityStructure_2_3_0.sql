-- Helix 6 - Security structure - 2.3.0
DO $$

BEGIN
	RAISE NOTICE 'Creating schema Helix6_Attachment...';

	CREATE SCHEMA IF NOT EXISTS "Helix6_Attachment";
		EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Error creating Helix6_Attachment: %'
			,SQLERRM;
END $$;

DO $$

BEGIN
	RAISE NOTICE 'Creating schema Helix6_Security...';

	CREATE SCHEMA IF NOT EXISTS "Helix6_Security";
		EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Error creating Helix6_Security: %'
			,SQLERRM;
END $$;

DO $$

BEGIN
	RAISE NOTICE 'Creating table Helix6_Attachment.AttachmentFile...';

	CREATE TABLE IF NOT EXISTS "Helix6_Attachment"."AttachmentFile" (
			"Id" INTEGER generated always AS identity PRIMARY KEY
			,"FileContent" TEXT NOT NULL
			,"AuditCreationUser" VARCHAR(70)
			,"AuditModificationUser" VARCHAR(70)
			,"AuditCreationDate" TIMESTAMPTZ
			,"AuditModificationDate" TIMESTAMPTZ
			,"AuditDeletionDate" TIMESTAMPTZ
			);
		EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Error creating AttachmentFile: %'
			,SQLERRM;
END $$;

DO $$

BEGIN
	RAISE NOTICE 'Creating table Helix6_Attachment.AttachmentType...';

	CREATE TABLE

	IF NOT EXISTS "Helix6_Attachment"."AttachmentType" (
			"Id" INTEGER generated always AS identity PRIMARY KEY
			,"Description" VARCHAR(2000) NOT NULL
			,"AuditCreationUser" VARCHAR(70)
			,"AuditModificationUser" VARCHAR(70)
			,"AuditCreationDate" timestamptz
			,"AuditModificationDate" timestamptz
			,"AuditDeletionDate" timestamptz
			);
		EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Error creating AttachmentType: %'
			,SQLERRM;
END $$;

DO $$

BEGIN
	RAISE NOTICE 'Creating table Helix6_Attachment.Attachment ...';

	CREATE TABLE IF NOT EXISTS "Helix6_Attachment"."Attachment" (
			"Id" INTEGER generated always AS identity PRIMARY KEY
			,"EntityId" INTEGER NOT NULL
			,"EntityName" VARCHAR(1000) NOT NULL
			,"EntityDescription" VARCHAR(2000) NOT NULL
			,"FileName" VARCHAR(1000) NOT NULL
			,"FileExtension" VARCHAR(10)
			,"FileSizeKb" INTEGER
			,"AttachmentTypeId" INTEGER
			,"AttachmentDescription" VARCHAR(2000)
			,"AttachmentFileId" INTEGER
			,"AuditCreationUser" VARCHAR(70)
			,"AuditModificationUser" VARCHAR(70)
			,"AuditCreationDate" timestamptz
			,"AuditModificationDate" timestamptz
			,"AuditDeletionDate" timestamptz
			);
		ALTER TABLE "Helix6_Attachment"."Attachment" ADD CONSTRAINT "FK_Attachment_AttachmentFile" FOREIGN KEY ("AttachmentFileId") REFERENCES "Helix6_Attachment"."AttachmentFile" ("Id");

	ALTER TABLE "Helix6_Attachment"."Attachment" ADD CONSTRAINT "FK_Attachment_AttachmentType" FOREIGN KEY ("AttachmentTypeId") REFERENCES "Helix6_Attachment"."AttachmentType" ("Id");

	EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Error creating Attachment: %'
		,SQLERRM;
END $$;

DO $$

BEGIN
	RAISE NOTICE 'Creating table Helix6_Security.SecurityModule ...';

	CREATE TABLE IF NOT EXISTS "Helix6_Security"."SecurityModule" (
			"Id" INTEGER PRIMARY KEY
			,"Description" VARCHAR(200) NOT NULL
			,"AuditCreationUser" VARCHAR(70)
			,"AuditModificationUser" VARCHAR(70)
			,"AuditCreationDate" timestamptz
			,"AuditModificationDate" timestamptz
			,"AuditDeletionDate" timestamptz
			);
		CREATE UNIQUE INDEX "UK_SecurityModule" ON "Helix6_Security"."SecurityModule" ("Description");

	EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Error creating SecurityModule: %'
		,SQLERRM;
END $$;

DO $$

BEGIN
	RAISE NOTICE 'Creating table Helix6_Security.SecurityAccessOption ...';

	CREATE TABLE IF NOT EXISTS "Helix6_Security"."SecurityAccessOption" (
			"Id" INTEGER PRIMARY KEY
			,"SecurityModuleId" INTEGER NOT NULL
			,"Description" VARCHAR(200) NOT NULL
			,"AuditCreationUser" VARCHAR(70)
			,"AuditModificationUser" VARCHAR(70)
			,"AuditCreationDate" timestamptz
			,"AuditModificationDate" timestamptz
			,"AuditDeletionDate" timestamptz
			);
		CREATE UNIQUE INDEX "UK_SecurityAccessOption" ON "Helix6_Security"."SecurityAccessOption" ("Description");

	ALTER TABLE "Helix6_Security"."SecurityAccessOption" ADD CONSTRAINT "FK_SecurityAccessOption_SecurityModule" FOREIGN KEY ("SecurityModuleId") REFERENCES "Helix6_Security"."SecurityModule" ("Id");

	EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Error creating SecurityAccessOption : %'
		,SQLERRM;
END $$;

DO $$

BEGIN
	RAISE NOTICE 'Creating table Helix6_Security.SecurityAccessOptionLevel ...';

	CREATE TABLE IF NOT EXISTS "Helix6_Security"."SecurityAccessOptionLevel" (
			"Id" INTEGER PRIMARY KEY
			,"SecurityAccessOptionId" INTEGER NOT NULL
			,"Controller" VARCHAR(200) NOT NULL
			,"SecurityLevel" INTEGER NOT NULL
			,"AuditCreationUser" VARCHAR(70)
			,"AuditModificationUser" VARCHAR(70)
			,"AuditCreationDate" timestamptz
			,"AuditModificationDate" timestamptz
			,"AuditDeletionDate" timestamptz
			);
		CREATE UNIQUE INDEX "UK_SecurityAccessOptionLevel" ON "Helix6_Security"."SecurityAccessOptionLevel" (
			"SecurityAccessOptionId"
			,"Controller"
			);

	ALTER TABLE "Helix6_Security"."SecurityAccessOptionLevel" ADD CONSTRAINT "FK_SecurityAccessOptionLevel_SecurityAccessOption" FOREIGN KEY ("SecurityAccessOptionId") REFERENCES "Helix6_Security"."SecurityAccessOption" ("Id");

	EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Error creating SecurityAccessOptionLevel : %'
		,SQLERRM;
END $$;

DO $$

BEGIN
	RAISE NOTICE 'Creating table Helix6_Security.SecurityCompanyGroup ...';

	CREATE TABLE IF NOT EXISTS "Helix6_Security"."SecurityCompanyGroup" (
			"Id" INTEGER PRIMARY KEY
			,"Name" VARCHAR(200) NOT NULL
			,"AuditCreationUser" VARCHAR(70)
			,"AuditModificationUser" VARCHAR(70)
			,"AuditCreationDate" timestamptz
			,"AuditModificationDate" timestamptz
			,"AuditDeletionDate" timestamptz
			);
		CREATE UNIQUE INDEX "UK_SecurityCompanyGroup" ON "Helix6_Security"."SecurityCompanyGroup" ("Name");

	EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Error creating SecurityCompanyGroup : %'
		,SQLERRM;
END $$;

DO $$

BEGIN
	RAISE NOTICE 'Creating table Helix6_Security.SecurityCompanyConfiguration ...';

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

	EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Error creating SecurityCompanyConfiguration : %'
		,SQLERRM;
END $$;

DO $$

BEGIN
	RAISE NOTICE 'Creating table Helix6_Security.SecurityCompany ...';

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
ALTER TABLE "Helix6_Security"."SecurityCompany"
ADD CONSTRAINT "FK_SecurityCompany_SecurityCompanyGroup"
FOREIGN KEY ("SecurityCompanyGroupId") REFERENCES "Helix6_Security"."SecurityCompanyGroup" ("Id");

ALTER TABLE "Helix6_Security"."SecurityCompany"
ADD CONSTRAINT "FK_SecurityCompany_SecurityCompanyConfiguration"
FOREIGN KEY ("SecurityCompanyConfigurationId") REFERENCES "Helix6_Security"."SecurityCompanyConfiguration" ("Id");
	EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Error creating SecurityCompany : %'
		,SQLERRM;
END $$;

DO $$

BEGIN
	RAISE NOTICE 'Creating table Helix6_Security.SecurityProfile ...';

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
ALTER TABLE "Helix6_Security"."SecurityProfile"
ADD CONSTRAINT "FK_SecurityProfile_SecurityCompany"
FOREIGN KEY ("SecurityCompanyId") REFERENCES "Helix6_Security"."SecurityCompany" ("Id");
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Error creating SecurityProfile : %'
		,SQLERRM;
END $$;

DO $$

BEGIN
	RAISE NOTICE 'Creating table Helix6_Security.SecurityUserConfiguration ...';

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

EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Error creating SecurityUserConfiguration : %'
		,SQLERRM;
END $$;

DO $$

BEGIN
	RAISE NOTICE 'Creating table Helix6_Security.SecurityUser ...';

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

ALTER TABLE "Helix6_Security"."SecurityUser"
ADD CONSTRAINT "FK_SecurityUser_SecurityCompany"
FOREIGN KEY ("SecurityCompanyId") REFERENCES "Helix6_Security"."SecurityCompany" ("Id");

ALTER TABLE "Helix6_Security"."SecurityUser"
ADD CONSTRAINT "FK_SecurityUser_SecurityUserConfiguration"
FOREIGN KEY ("SecurityUserConfigurationId") REFERENCES "Helix6_Security"."SecurityUserConfiguration" ("Id");

EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Error creating SecurityUser : %'
		,SQLERRM;
END $$;

DO $$

BEGIN
	RAISE NOTICE 'Creating table Helix6_Security.SecurityUserGridConfiguration ...';

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
CREATE UNIQUE INDEX "UK_SecurityUserGridConfiguration"
ON "Helix6_Security"."SecurityUserGridConfiguration" ("SecurityUserId", "Entity", "Description");

ALTER TABLE "Helix6_Security"."SecurityUserGridConfiguration"
ADD CONSTRAINT "FK_SecurityUserGridConfiguration_SecurityUser"
FOREIGN KEY ("SecurityUserId") REFERENCES "Helix6_Security"."SecurityUser" ("Id");
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Error creating SecurityUserGridConfiguration : %'
		,SQLERRM;
END $$;

DO $$

BEGIN
	RAISE NOTICE 'Creating table Helix6_Security.SecurityProfile_SecurityAccessOption ...';

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
CREATE UNIQUE INDEX "UK_SecurityProfile_SecurityAccessOption"
ON "Helix6_Security"."SecurityProfile_SecurityAccessOption" ("SecurityAccessOptionId", "SecurityProfileId");

ALTER TABLE "Helix6_Security"."SecurityProfile_SecurityAccessOption"
ADD CONSTRAINT "FK_SecurityProfile_SecurityAccessOption_SecurityAccessOption"
FOREIGN KEY ("SecurityAccessOptionId")
REFERENCES "Helix6_Security"."SecurityAccessOption" ("Id");

ALTER TABLE "Helix6_Security"."SecurityProfile_SecurityAccessOption"
ADD CONSTRAINT "FK_SecurityProfile_SecurityAccessOption_SecurityProfile"
FOREIGN KEY ("SecurityProfileId")
REFERENCES "Helix6_Security"."SecurityProfile" ("Id");
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Error creating SecurityProfile_SecurityAccessOption : %'
		,SQLERRM;
END $$;

DO $$

BEGIN
	RAISE NOTICE 'Creating table Helix6_Security.SecurityVersion ...';

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

EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Error creating SecurityVersion : %'
		,SQLERRM;
END $$;

DO $$
BEGIN
    RAISE NOTICE 'Creating view Helix6_Attachment.VTA_Attachment ...';

    EXECUTE '
    CREATE OR REPLACE VIEW "Helix6_Attachment"."VTA_Attachment" AS
    SELECT
        A."Id",
        A."AttachmentTypeId",
        A."EntityId",
        A."EntityName",
        A."EntityDescription",
        A."FileName",
        A."FileExtension",
        A."FileSizeKb",
        A."AttachmentDescription",
        A."AttachmentFileId",
        A."AuditCreationUser",
        A."AuditModificationUser",
        A."AuditCreationDate",
        A."AuditModificationDate",
        A."AuditDeletionDate",
        AT."Description" AS "AttachmentType"
    FROM "Helix6_Attachment"."Attachment" as A
    LEFT JOIN "Helix6_Attachment"."AttachmentType" AT ON A."AttachmentTypeId" = AT."Id";
    ';

EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error creating VTA_Attachment : %', SQLERRM;
END $$;

DO $$
BEGIN
    RAISE NOTICE 'Creating view Helix6_Security.Permissions ...';

    EXECUTE '
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
LEFT JOIN "Helix6_Security"."SecurityCompany" C ON P."SecurityCompanyId" = C."Id";';

EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error creating Permissions : %', SQLERRM;
END $$;
