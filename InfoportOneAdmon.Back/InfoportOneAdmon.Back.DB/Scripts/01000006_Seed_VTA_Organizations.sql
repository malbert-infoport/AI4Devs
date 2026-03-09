-- Seed script: insert realistic sample organizations if they do not exist
-- Idempotent: checks by TaxId before inserting

BEGIN;

-- Helper pattern: upsert OrganizationGroup by name and obtain its Id (idempotent)
-- We'll use a CTE that inserts if missing and returns the id.

-- 1) Acme Logistics
-- 1) Acme Logistics
WITH ins_group AS (
  INSERT INTO "Admon"."OrganizationGroup"("GroupName")
  VALUES ('Logistics Group')
  ON CONFLICT ("GroupName") DO NOTHING
  RETURNING "Id"
), gid AS (
  SELECT "Id" FROM ins_group
  UNION ALL
  SELECT "Id" FROM "Admon"."OrganizationGroup" WHERE "GroupName" = 'Logistics Group' LIMIT 1
), next_id AS (
  SELECT COALESCE(MAX("Id"), 0) + 1 AS nid FROM "Admon"."Organization"
)
INSERT INTO "Admon"."Organization" (
  "Id","SecurityCompanyId","Name","TaxId","ContactEmail","ContactPhone","GroupId",
  "AuditCreationUser","AuditCreationDate","AuditModificationUser","AuditModificationDate"
)
SELECT nid, 1, 'Acme Logistics S.L.', 'B12345678', 'info@acmelogistics.com', '+34 912 345 678', (SELECT "Id" FROM gid), 1, NOW(), 1, NOW()
FROM next_id
WHERE NOT EXISTS (SELECT 1 FROM "Admon"."Organization" WHERE "TaxId" = 'B12345678');

-- 2) Iberia Transportes
-- 2) Iberia Transportes
WITH ins_group AS (
  INSERT INTO "Admon"."OrganizationGroup"("GroupName")
  VALUES ('Iberia Group')
  ON CONFLICT ("GroupName") DO NOTHING
  RETURNING "Id"
), gid AS (
  SELECT "Id" FROM ins_group
  UNION ALL
  SELECT "Id" FROM "Admon"."OrganizationGroup" WHERE "GroupName" = 'Iberia Group' LIMIT 1
), next_id AS (
  SELECT COALESCE(MAX("Id"), 0) + 1 AS nid FROM "Admon"."Organization"
)
INSERT INTO "Admon"."Organization" (
  "Id","SecurityCompanyId","Name","TaxId","ContactEmail","ContactPhone","GroupId",
  "AuditCreationUser","AuditCreationDate","AuditModificationUser","AuditModificationDate"
)
SELECT nid, 2, 'Iberia Transportes S.A.', 'A87654321', 'contact@iberiatrans.es', '+34 934 567 890', (SELECT "Id" FROM gid), 1, NOW(), 1, NOW()
FROM next_id
WHERE NOT EXISTS (SELECT 1 FROM "Admon"."Organization" WHERE "TaxId" = 'A87654321');

-- 3) TransMar Logistics
-- 3) TransMar Logistics
WITH ins_group AS (
  INSERT INTO "Admon"."OrganizationGroup"("GroupName")
  VALUES ('TransMar Group')
  ON CONFLICT ("GroupName") DO NOTHING
  RETURNING "Id"
), gid AS (
  SELECT "Id" FROM ins_group
  UNION ALL
  SELECT "Id" FROM "Admon"."OrganizationGroup" WHERE "GroupName" = 'TransMar Group' LIMIT 1
), next_id AS (
  SELECT COALESCE(MAX("Id"), 0) + 1 AS nid FROM "Admon"."Organization"
)
INSERT INTO "Admon"."Organization" (
  "Id","SecurityCompanyId","Name","TaxId","ContactEmail","ContactPhone","GroupId",
  "AuditCreationUser","AuditCreationDate","AuditModificationUser","AuditModificationDate"
)
SELECT nid, 3, 'TransMar Logistics SL', 'B23456789', 'ops@transmar.es', '+34 911 223 344', (SELECT "Id" FROM gid), 1, NOW(), 1, NOW()
FROM next_id
WHERE NOT EXISTS (SELECT 1 FROM "Admon"."Organization" WHERE "TaxId" = 'B23456789');

-- 4) NovaCargo
-- 4) NovaCargo
WITH ins_group AS (
  INSERT INTO "Admon"."OrganizationGroup"("GroupName")
  VALUES ('Nova Group')
  ON CONFLICT ("GroupName") DO NOTHING
  RETURNING "Id"
), gid AS (
  SELECT "Id" FROM ins_group
  UNION ALL
  SELECT "Id" FROM "Admon"."OrganizationGroup" WHERE "GroupName" = 'Nova Group' LIMIT 1
), next_id AS (
  SELECT COALESCE(MAX("Id"), 0) + 1 AS nid FROM "Admon"."Organization"
)
INSERT INTO "Admon"."Organization" (
  "Id","SecurityCompanyId","Name","TaxId","ContactEmail","ContactPhone","GroupId",
  "AuditCreationUser","AuditCreationDate","AuditModificationUser","AuditModificationDate"
)
SELECT nid, 4, 'NovaCargo S.L.', 'B98765432', 'hello@novacargo.com', '+34 900 111 222', (SELECT "Id" FROM gid), 1, NOW(), 1, NOW()
FROM next_id
WHERE NOT EXISTS (SELECT 1 FROM "Admon"."Organization" WHERE "TaxId" = 'B98765432');

-- 5) Grupo Oeste
-- 5) Grupo Oeste
WITH ins_group AS (
  INSERT INTO "Admon"."OrganizationGroup"("GroupName")
  VALUES ('Grupo Oeste')
  ON CONFLICT ("GroupName") DO NOTHING
  RETURNING "Id"
), gid AS (
  SELECT "Id" FROM ins_group
  UNION ALL
  SELECT "Id" FROM "Admon"."OrganizationGroup" WHERE "GroupName" = 'Grupo Oeste' LIMIT 1
), next_id AS (
  SELECT COALESCE(MAX("Id"), 0) + 1 AS nid FROM "Admon"."Organization"
)
INSERT INTO "Admon"."Organization" (
  "Id","SecurityCompanyId","Name","TaxId","ContactEmail","ContactPhone","GroupId",
  "AuditCreationUser","AuditCreationDate","AuditModificationUser","AuditModificationDate"
)
SELECT nid, 5, 'Grupo Oeste S.A.', 'A11223344', 'info@grupo-oeste.es', '+34 955 332 211', (SELECT "Id" FROM gid), 1, NOW(), 1, NOW()
FROM next_id
WHERE NOT EXISTS (SELECT 1 FROM "Admon"."Organization" WHERE "TaxId" = 'A11223344');

-- 6) Alpine Freight (example EU entity)
-- 6) Alpine Freight (example EU entity)
WITH ins_group AS (
  INSERT INTO "Admon"."OrganizationGroup"("GroupName")
  VALUES ('Alpine Group')
  ON CONFLICT ("GroupName") DO NOTHING
  RETURNING "Id"
), gid AS (
  SELECT "Id" FROM ins_group
  UNION ALL
  SELECT "Id" FROM "Admon"."OrganizationGroup" WHERE "GroupName" = 'Alpine Group' LIMIT 1
), next_id AS (
  SELECT COALESCE(MAX("Id"), 0) + 1 AS nid FROM "Admon"."Organization"
)
INSERT INTO "Admon"."Organization" (
  "Id","SecurityCompanyId","Name","TaxId","ContactEmail","ContactPhone","GroupId",
  "AuditCreationUser","AuditCreationDate","AuditModificationUser","AuditModificationDate"
)
SELECT nid, 6, 'Alpine Freight GmbH', 'DE123456789', 'contact@alpinefreight.de', '+49 30 1234567', (SELECT "Id" FROM gid), 1, NOW(), 1, NOW()
FROM next_id
WHERE NOT EXISTS (SELECT 1 FROM "Admon"."Organization" WHERE "TaxId" = 'DE123456789');

COMMIT;
