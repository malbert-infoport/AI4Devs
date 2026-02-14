-- Helix 6 - Test structure - 2.3.0
DO $$

BEGIN
	RAISE NOTICE 'Creating schema Helix6_Test...';

	CREATE SCHEMA IF NOT EXISTS "Helix6_Test";
		EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Error creating Helix6_Test: %'
			,SQLERRM;
END $$;

DO $$

BEGIN
	RAISE NOTICE 'Creating table Helix6_Test.Course...';

	CREATE TABLE IF NOT EXISTS "Helix6_Test"."Course" (
			"Id" INTEGER generated always AS identity PRIMARY key,
			"Name" VARCHAR(200) NOT NULL,
        "VersionKey" VARCHAR(100) NOT NULL,
        "VersionNumber" INT NOT NULL,
        "ValidityFrom" TIMESTAMPTZ NOT NULL,
        "ValidityTo" TIMESTAMPTZ NULL
			,"AuditCreationUser" VARCHAR(70)
			,"AuditModificationUser" VARCHAR(70)
			,"AuditCreationDate" TIMESTAMPTZ
			,"AuditModificationDate" TIMESTAMPTZ
			,"AuditDeletionDate" TIMESTAMPTZ
			);
		EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Error creating Course: %'
			,SQLERRM;
END $$;

DO $$

BEGIN
	RAISE NOTICE 'Creating table Helix6_Test.Worker_Course...';

	CREATE TABLE IF NOT EXISTS "Helix6_Test"."Worker_Course" (
			"Id" INTEGER generated always AS identity PRIMARY key,
        "WorkerId" INT NOT NULL,
        "CourseId" INT NOT NULL
			,"AuditCreationUser" VARCHAR(70)
			,"AuditModificationUser" VARCHAR(70)
			,"AuditCreationDate" TIMESTAMPTZ
			,"AuditModificationDate" TIMESTAMPTZ
			,"AuditDeletionDate" TIMESTAMPTZ
			);
		EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Error creating Worker_Course: %'
			,SQLERRM;
END $$;

DO $$

BEGIN
	RAISE NOTICE 'Creating table Helix6_Test.WorkerType...';

	CREATE TABLE IF NOT EXISTS "Helix6_Test"."WorkerType" (
			"Id" INT PRIMARY key,
			"Description" VARCHAR(200) NOT NULL
			,"AuditCreationUser" VARCHAR(70)
			,"AuditModificationUser" VARCHAR(70)
			,"AuditCreationDate" TIMESTAMPTZ
			,"AuditModificationDate" TIMESTAMPTZ
			,"AuditDeletionDate" TIMESTAMPTZ
			);
		
		
		EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Error creating WorkerType: %'
			,SQLERRM;
END $$;

DO $$

BEGIN
	RAISE NOTICE 'Creating table Helix6_Test.Worker...';

	CREATE TABLE IF NOT EXISTS "Helix6_Test"."Worker" (
			"Id" INTEGER generated always AS identity PRIMARY key,
			"Name" VARCHAR(500) NOT NULL,
        "Surnames" VARCHAR(200) NOT NULL,
        "BirthDate" TIMESTAMPTZ NOT NULL,
        "IsTrainee" BOOLEAN NOT NULL,
        "WorkerTypeId" INT NOT NULL,
        "Age" INT,
        "Height" NUMERIC(4,2)
			,"AuditCreationUser" VARCHAR(70)
			,"AuditModificationUser" VARCHAR(70)
			,"AuditCreationDate" TIMESTAMPTZ
			,"AuditModificationDate" TIMESTAMPTZ
			,"AuditDeletionDate" TIMESTAMPTZ
			);
		
		CREATE UNIQUE INDEX "UK_Worker" ON "Helix6_Test"."Worker"("Name", "Surnames", "AuditDeletionDate");
		EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Error creating Worker: %'
			,SQLERRM;
END $$;

DO $$

BEGIN
	RAISE NOTICE 'Creating table Helix6_Test.Project...';

	CREATE TABLE IF NOT EXISTS "Helix6_Test"."Project" (
			"Id" INTEGER generated always AS identity PRIMARY key,
			"Name" VARCHAR(500) NOT NULL,
         "VersionKey" VARCHAR(100) NOT NULL,
        "VersionNumber" INT NOT NULL
			,"AuditCreationUser" VARCHAR(70)
			,"AuditModificationUser" VARCHAR(70)
			,"AuditCreationDate" TIMESTAMPTZ
			,"AuditModificationDate" TIMESTAMPTZ
			,"AuditDeletionDate" TIMESTAMPTZ
			);
		
		
		EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Error creating Project: %'
			,SQLERRM;
END $$;

DO $$

BEGIN
	RAISE NOTICE 'Creating table Helix6_Test.Worker_Project...';

	CREATE TABLE IF NOT EXISTS "Helix6_Test"."Worker_Project" (
			"Id" INTEGER generated always AS identity PRIMARY key,
			"WorkerId" INT NOT NULL,
        "ProjectId" INT NOT NULL
			,"AuditCreationUser" VARCHAR(70)
			,"AuditModificationUser" VARCHAR(70)
			,"AuditCreationDate" TIMESTAMPTZ
			,"AuditModificationDate" TIMESTAMPTZ
			,"AuditDeletionDate" TIMESTAMPTZ
			);
		
		
		EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Error creating Worker_Project: %'
			,SQLERRM;
END $$;



DO $$

BEGIN
	RAISE NOTICE 'Creating table Helix6_Test.AddressType...';

	CREATE TABLE IF NOT EXISTS "Helix6_Test"."AddressType" (
			"Id" INT PRIMARY key,
			"Description" VARCHAR(200) NOT NULL
			,"AuditCreationUser" VARCHAR(70)
			,"AuditModificationUser" VARCHAR(70)
			,"AuditCreationDate" TIMESTAMPTZ
			,"AuditModificationDate" TIMESTAMPTZ
			,"AuditDeletionDate" TIMESTAMPTZ
			);
		
		
		EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Error creating AddressType: %'
			,SQLERRM;
END $$;

DO $$

BEGIN
	RAISE NOTICE 'Creating table Helix6_Test.WorkerAddress...';

	CREATE TABLE IF NOT EXISTS "Helix6_Test"."WorkerAddress" (
			"Id" INTEGER generated always AS identity PRIMARY key,
			 "WorkerId" INT NOT NULL,
        "Address" VARCHAR(1000) NOT NULL,
        "AddressTypeId" INT NOT NULL
			,"AuditCreationUser" VARCHAR(70)
			,"AuditModificationUser" VARCHAR(70)
			,"AuditCreationDate" TIMESTAMPTZ
			,"AuditModificationDate" TIMESTAMPTZ
			,"AuditDeletionDate" TIMESTAMPTZ
			);
		
		
		EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Error creating WorkerAddress: %'
			,SQLERRM;
END $$;

DO $$
BEGIN
    RAISE NOTICE 'Creating view Helix6_Test.VTA_Worker ...';

    EXECUTE '
    CREATE OR REPLACE VIEW "Helix6_Test"."VTA_Worker" AS
    SELECT 
        w."Id", w."Name", w."Surnames", w."BirthDate", w."IsTrainee", wt."Description" AS "WorkerType",
        w."Age", w."Height",
        w."AuditCreationUser", w."AuditCreationDate", w."AuditModificationUser", w."AuditModificationDate", w."AuditDeletionDate"
    FROM "Helix6_Test"."Worker" w
    JOIN "Helix6_Test"."WorkerType" wt ON w."WorkerTypeId" = wt."Id";';

EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error creating VTA_Worker : %', SQLERRM;
END $$;

DO $$
BEGIN
    RAISE NOTICE 'Creating foreign keys ...';

   ALTER TABLE "Helix6_Test"."WorkerAddress"
    ADD CONSTRAINT "FK_WorkerAddress_AddressType" FOREIGN KEY ("AddressTypeId") REFERENCES "Helix6_Test"."AddressType" ("Id");
    
ALTER TABLE "Helix6_Test"."WorkerAddress"
    ADD CONSTRAINT "FK_WorkerAddress_Worker" FOREIGN KEY ("WorkerId") REFERENCES "Helix6_Test"."Worker" ("Id");
    
    ALTER TABLE "Helix6_Test"."Worker"
    ADD CONSTRAINT "FK_Worker_WorkerType" FOREIGN KEY ("WorkerTypeId") REFERENCES "Helix6_Test"."WorkerType" ("Id");
   
    ALTER TABLE "Helix6_Test"."Worker_Course"
    ADD CONSTRAINT "FK_Worker_Course_Course" FOREIGN KEY ("CourseId") REFERENCES "Helix6_Test"."Course" ("Id");
    
    ALTER TABLE "Helix6_Test"."Worker_Course"
    ADD CONSTRAINT "FK_Worker_Course_Worker" FOREIGN KEY ("WorkerId") REFERENCES "Helix6_Test"."Worker" ("Id");
    
   ALTER TABLE "Helix6_Test"."Worker_Project"
    ADD CONSTRAINT "FK_Worker_Project_Project" FOREIGN KEY ("ProjectId") REFERENCES "Helix6_Test"."Project" ("Id");
    
   ALTER TABLE "Helix6_Test"."Worker_Project"
    ADD CONSTRAINT "FK_Worker_Project_Worker" FOREIGN KEY ("WorkerId") REFERENCES "Helix6_Test"."Worker" ("Id");
    
    
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error creating foreign keys : %', SQLERRM;
END $$;
