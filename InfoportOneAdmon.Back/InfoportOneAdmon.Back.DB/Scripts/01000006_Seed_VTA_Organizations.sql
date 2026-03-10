-- Seed script: insert realistic sample organizations if they do not exist
-- Idempotent: checks by TaxId before inserting

BEGIN;

-- Helper pattern: upsert OrganizationGroup by name and obtain its Id (idempotent)
-- We'll use a CTE that inserts if missing and returns the id.

-- 1) Acme Logistics
-- 1) Acme Logistics
-- Only a single OrganizationGroup: TransMar Group
INSERT INTO "Admon"."OrganizationGroup"("GroupName", "Description", "AuditCreationUser", "AuditCreationDate")
VALUES ('TransMar Group', 'Holding para TransMar y NovaCargo', 1, NOW())
ON CONFLICT ("GroupName") DO NOTHING;

-- Insert organizations. Only TransMar and NovaCargo belong to TransMar Group; others have no group (NULL).
WITH grp AS (
  SELECT "Id" FROM "Admon"."OrganizationGroup" WHERE "GroupName" = 'TransMar Group' LIMIT 1
), next_id AS (
  SELECT COALESCE(MAX("Id"), 0) + 1 AS nid FROM "Admon"."Organization"
)
INSERT INTO "Admon"."Organization" (
  "Id","SecurityCompanyId","Name","Acronym","TaxId","Address","City","PostalCode","Country","ContactEmail","ContactPhone","GroupId",
  "AuditCreationUser","AuditCreationDate","AuditModificationUser","AuditModificationDate"
)
SELECT nid, 1, 'Acme Logistics S.L.', 'ACME', 'B12345678', 'C/ Comercio 12', 'Madrid', '28001', 'Spain', 'info@acmelogistics.com', '+34 912 345 678', NULL, 1, NOW(), 1, NOW()
FROM next_id
WHERE NOT EXISTS (SELECT 1 FROM "Admon"."Organization" WHERE "TaxId" = 'B12345678');

-- 2) Iberia Transportes
-- 2) Iberia Transportes
WITH next_id AS (
  SELECT COALESCE(MAX("Id"), 0) + 1 AS nid FROM "Admon"."Organization"
)
INSERT INTO "Admon"."Organization" (
  "Id","SecurityCompanyId","Name","Acronym","TaxId","Address","City","PostalCode","Country","ContactEmail","ContactPhone","GroupId",
  "AuditCreationUser","AuditCreationDate","AuditModificationUser","AuditModificationDate"
)
SELECT nid, 2, 'Iberia Transportes S.A.', 'IBER', 'A87654321', 'Av. de la Marina 45', 'Barcelona', '08001', 'Spain', 'contact@iberiatrans.es', '+34 934 567 890', NULL, 1, NOW(), 1, NOW()
FROM next_id
WHERE NOT EXISTS (SELECT 1 FROM "Admon"."Organization" WHERE "TaxId" = 'A87654321');

-- 3) TransMar Logistics
-- 3) TransMar Logistics
WITH grp AS (
  SELECT "Id" FROM "Admon"."OrganizationGroup" WHERE "GroupName" = 'TransMar Group' LIMIT 1
), next_id AS (
  SELECT COALESCE(MAX("Id"), 0) + 1 AS nid FROM "Admon"."Organization"
)
INSERT INTO "Admon"."Organization" (
  "Id","SecurityCompanyId","Name","Acronym","TaxId","Address","City","PostalCode","Country","ContactEmail","ContactPhone","GroupId",
  "AuditCreationUser","AuditCreationDate","AuditModificationUser","AuditModificationDate"
)
SELECT nid, 3, 'TransMar Logistics SL', 'TRMS', 'B23456789', 'C/ Puerto 7', 'Valencia', '46001', 'Spain', 'ops@transmar.es', '+34 911 223 344', (SELECT "Id" FROM grp), 1, NOW(), 1, NOW()
FROM next_id
WHERE NOT EXISTS (SELECT 1 FROM "Admon"."Organization" WHERE "TaxId" = 'B23456789');

-- 4) NovaCargo
-- 4) NovaCargo
WITH grp AS (
  SELECT "Id" FROM "Admon"."OrganizationGroup" WHERE "GroupName" = 'TransMar Group' LIMIT 1
), next_id AS (
  SELECT COALESCE(MAX("Id"), 0) + 1 AS nid FROM "Admon"."Organization"
)
INSERT INTO "Admon"."Organization" (
  "Id","SecurityCompanyId","Name","Acronym","TaxId","Address","City","PostalCode","Country","ContactEmail","ContactPhone","GroupId",
  "AuditCreationUser","AuditCreationDate","AuditModificationUser","AuditModificationDate"
)
SELECT nid, 4, 'NovaCargo S.L.', 'NOVC', 'B98765432', 'C/ Nave 3', 'Seville', '41001', 'Spain', 'hello@novacargo.com', '+34 900 111 222', (SELECT "Id" FROM grp), 1, NOW(), 1, NOW()
FROM next_id
WHERE NOT EXISTS (SELECT 1 FROM "Admon"."Organization" WHERE "TaxId" = 'B98765432');

-- 5) Grupo Oeste
-- 5) Grupo Oeste
WITH next_id AS (
  SELECT COALESCE(MAX("Id"), 0) + 1 AS nid FROM "Admon"."Organization"
)
INSERT INTO "Admon"."Organization" (
  "Id","SecurityCompanyId","Name","Acronym","TaxId","Address","City","PostalCode","Country","ContactEmail","ContactPhone","GroupId",
  "AuditCreationUser","AuditCreationDate","AuditModificationUser","AuditModificationDate"
)
SELECT nid, 5, 'Grupo Oeste S.A.', 'GOST', 'A11223344', 'Paseo Oeste 21', 'Seville', '41002', 'Spain', 'info@grupo-oeste.es', '+34 955 332 211', NULL, 1, NOW(), 1, NOW()
FROM next_id
WHERE NOT EXISTS (SELECT 1 FROM "Admon"."Organization" WHERE "TaxId" = 'A11223344');

-- 6) Alpine Freight (example EU entity)
-- 6) Alpine Freight (example EU entity)
WITH next_id AS (
  SELECT COALESCE(MAX("Id"), 0) + 1 AS nid FROM "Admon"."Organization"
)
INSERT INTO "Admon"."Organization" (
  "Id","SecurityCompanyId","Name","Acronym","TaxId","Address","City","PostalCode","Country","ContactEmail","ContactPhone","GroupId",
  "AuditCreationUser","AuditCreationDate","AuditModificationUser","AuditModificationDate"
)
SELECT nid, 6, 'Alpine Freight GmbH', 'ALPF', 'DE123456789', 'Berliner Str. 10', 'Berlin', '10115', 'Germany', 'contact@alpinefreight.de', '+49 30 1234567', NULL, 1, NOW(), 1, NOW()
FROM next_id
WHERE NOT EXISTS (SELECT 1 FROM "Admon"."Organization" WHERE "TaxId" = 'DE123456789');

-- 7) Deactivated organization (baja) - will have AuditDeletionDate set
WITH next_id AS (
  SELECT COALESCE(MAX("Id"), 0) + 1 AS nid FROM "Admon"."Organization"
)
INSERT INTO "Admon"."Organization" (
  "Id","SecurityCompanyId","Name","Acronym","TaxId","Address","City","PostalCode","Country","ContactEmail","ContactPhone","GroupId",
  "AuditCreationUser","AuditCreationDate","AuditModificationUser","AuditModificationDate","AuditDeletionDate"
)
SELECT nid, 7, 'Old Freight S.L.', 'OLDF', 'B00000000', 'C/ Vieja 1', 'Cadiz', '11001', 'Spain', 'noreply@oldfreight.es', '+34 900 000 000', NULL, 1, NOW(), 1, NOW(), NOW()
FROM next_id
WHERE NOT EXISTS (SELECT 1 FROM "Admon"."Organization" WHERE "TaxId" = 'B00000000');

COMMIT;

-- =====================================================
-- Seed Applications, Modules and Organization assignments
-- Idempotent inserts into Application, ApplicationModule and Organization_ApplicationModule
-- =====================================================

BEGIN;

-- 1) Applications
WITH ins_sintra AS (
  INSERT INTO "Admon"."Application" ("AppName", "Description", "RolePrefix", "AuditCreationUser", "AuditCreationDate")
  VALUES ('Sintraport', 'Plataforma principal de Sintraport', 'SINTRA', 1, NOW())
  ON CONFLICT ("AppName") DO NOTHING RETURNING "Id"
), sintra AS (
  SELECT "Id" FROM ins_sintra
  UNION ALL
  SELECT "Id" FROM "Admon"."Application" WHERE "AppName" = 'Sintraport' LIMIT 1
), ins_translate AS (
  INSERT INTO "Admon"."Application" ("AppName", "Description", "RolePrefix", "AuditCreationUser", "AuditCreationDate")
  VALUES ('Translate', 'Servicio de mensajería y traducción', 'TLATE', 1, NOW())
  ON CONFLICT ("AppName") DO NOTHING RETURNING "Id"
), translate AS (
  SELECT "Id" FROM ins_translate
  UNION ALL
  SELECT "Id" FROM "Admon"."Application" WHERE "AppName" = 'Translate' LIMIT 1
), ins_onetrack AS (
  INSERT INTO "Admon"."Application" ("AppName", "Description", "RolePrefix", "AuditCreationUser", "AuditCreationDate")
  VALUES ('OneTrack', 'Tracking y mapas', 'ONET', 1, NOW())
  ON CONFLICT ("AppName") DO NOTHING RETURNING "Id"
), onetrack AS (
  SELECT "Id" FROM ins_onetrack
  UNION ALL
  SELECT "Id" FROM "Admon"."Application" WHERE "AppName" = 'OneTrack' LIMIT 1
), ins_shiptrace AS (
  INSERT INTO "Admon"."Application" ("AppName", "Description", "RolePrefix", "AuditCreationUser", "AuditCreationDate")
  VALUES ('ShipTrace', 'Servicios DCSA y mapas', 'SHIP', 1, NOW())
  ON CONFLICT ("AppName") DO NOTHING RETURNING "Id"
), shiptrace AS (
  SELECT "Id" FROM ins_shiptrace
  UNION ALL
  SELECT "Id" FROM "Admon"."Application" WHERE "AppName" = 'ShipTrace' LIMIT 1
)
SELECT 1 WHERE EXISTS (SELECT 1 FROM sintra);

-- 2) Application modules
-- Sintraport modules
WITH app AS (SELECT "Id" AS appid FROM "Admon"."Application" WHERE "AppName" = 'Sintraport' LIMIT 1)
INSERT INTO "Admon"."ApplicationModule" ("ApplicationId","ModuleName","Description","DisplayOrder","AuditCreationUser","AuditCreationDate")
SELECT appid, mname, mdesc, morder, 1, NOW()
FROM app, (VALUES
  ('SINTRA_Trafico','Módulo de tráfico',10),
  ('SINTRA_Tarifas','Módulo de tarifas',20),
  ('SINTRA_Flotas','Módulo de flotas',30)
) AS t(mname, mdesc, morder)
ON CONFLICT ("ApplicationId","ModuleName") DO NOTHING;

-- Translate modules
WITH app AS (SELECT "Id" AS appid FROM "Admon"."Application" WHERE "AppName" = 'Translate' LIMIT 1)
INSERT INTO "Admon"."ApplicationModule" ("ApplicationId","ModuleName","Description","DisplayOrder","AuditCreationUser","AuditCreationDate")
SELECT appid, mname, mdesc, morder, 1, NOW()
FROM app, (VALUES
  ('TLATE_Mensajeria','Mensajería y traducción',10)
) AS t(mname, mdesc, morder)
ON CONFLICT ("ApplicationId","ModuleName") DO NOTHING;

-- OneTrack modules
WITH app AS (SELECT "Id" AS appid FROM "Admon"."Application" WHERE "AppName" = 'OneTrack' LIMIT 1)
INSERT INTO "Admon"."ApplicationModule" ("ApplicationId","ModuleName","Description","DisplayOrder","AuditCreationUser","AuditCreationDate")
SELECT appid, mname, mdesc, morder, 1, NOW()
FROM app, (VALUES
  ('TRACK_Tracking','Tracking en tiempo real',10),
  ('TRACK_Maps','Mapas y geolocalización',20)
) AS t(mname, mdesc, morder)
ON CONFLICT ("ApplicationId","ModuleName") DO NOTHING;

-- ShipTrace modules
WITH app AS (SELECT "Id" AS appid FROM "Admon"."Application" WHERE "AppName" = 'ShipTrace' LIMIT 1)
INSERT INTO "Admon"."ApplicationModule" ("ApplicationId","ModuleName","Description","DisplayOrder","AuditCreationUser","AuditCreationDate")
SELECT appid, mname, mdesc, morder, 1, NOW()
FROM app, (VALUES
  ('SHIP_DCSA','DCSA compliance y documentos',10),
  ('SHIP_Maps','Mapas y rutas marítimas',20)
) AS t(mname, mdesc, morder)
ON CONFLICT ("ApplicationId","ModuleName") DO NOTHING;

-- 3) Assign organizations to modules (Organization_ApplicationModule)
-- We'll map organizations by TaxId to ApplicationModule entries.

-- Helper CTE to resolve module ids
-- Note: use inline subquery to resolve module ids per statement (CTE lasted only for single statement)

-- Acme Logistics -> Sintraport: Trafico, Tarifas
INSERT INTO "Admon"."Organization_ApplicationModule" ("ApplicationModuleId","OrganizationId","AuditCreationUser","AuditCreationDate")
SELECT am."Id", o."Id", 1, NOW()
FROM (
  SELECT am."Id", a."AppName", am."ModuleName"
  FROM "Admon"."ApplicationModule" am
  JOIN "Admon"."Application" a ON a."Id" = am."ApplicationId"
) am
JOIN "Admon"."Organization" o ON o."TaxId" = 'B12345678'
WHERE am."AppName" = 'Sintraport' AND am."ModuleName" IN ('SINTRA_Trafico','SINTRA_Tarifas')
ON CONFLICT ("ApplicationModuleId","OrganizationId") DO NOTHING;

-- Iberia Transportes -> Sintraport all modules
INSERT INTO "Admon"."Organization_ApplicationModule" ("ApplicationModuleId","OrganizationId","AuditCreationUser","AuditCreationDate")
SELECT am."Id", o."Id", 1, NOW()
FROM (
  SELECT am."Id", a."AppName", am."ModuleName"
  FROM "Admon"."ApplicationModule" am
  JOIN "Admon"."Application" a ON a."Id" = am."ApplicationId"
) am
JOIN "Admon"."Organization" o ON o."TaxId" = 'A87654321'
WHERE am."AppName" = 'Sintraport'
ON CONFLICT ("ApplicationModuleId","OrganizationId") DO NOTHING;

-- TransMar Logistics -> Sintraport (Trafico), OneTrack (both), ShipTrace (SHIP_Maps)
INSERT INTO "Admon"."Organization_ApplicationModule" ("ApplicationModuleId","OrganizationId","AuditCreationUser","AuditCreationDate")
SELECT am."Id", o."Id", 1, NOW()
FROM (
  SELECT am."Id", a."AppName", am."ModuleName"
  FROM "Admon"."ApplicationModule" am
  JOIN "Admon"."Application" a ON a."Id" = am."ApplicationId"
) am
JOIN "Admon"."Organization" o ON o."TaxId" = 'B23456789'
WHERE (am."AppName" = 'Sintraport' AND am."ModuleName" = 'SINTRA_Trafico')
   OR (am."AppName" = 'OneTrack')
   OR (am."AppName" = 'ShipTrace' AND am."ModuleName" = 'SHIP_Maps')
ON CONFLICT ("ApplicationModuleId","OrganizationId") DO NOTHING;

-- NovaCargo -> belongs to TransMar Group; assign ShipTrace DCSA and Sintraport Tarifas
INSERT INTO "Admon"."Organization_ApplicationModule" ("ApplicationModuleId","OrganizationId","AuditCreationUser","AuditCreationDate")
SELECT am."Id", o."Id", 1, NOW()
FROM (
  SELECT am."Id", a."AppName", am."ModuleName"
  FROM "Admon"."ApplicationModule" am
  JOIN "Admon"."Application" a ON a."Id" = am."ApplicationId"
) am
JOIN "Admon"."Organization" o ON o."TaxId" = 'B98765432'
WHERE (am."AppName" = 'ShipTrace' AND am."ModuleName" = 'SHIP_DCSA')
   OR (am."AppName" = 'Sintraport' AND am."ModuleName" = 'SINTRA_Tarifas')
ON CONFLICT ("ApplicationModuleId","OrganizationId") DO NOTHING;

-- Grupo Oeste -> Translate Mensajeria
INSERT INTO "Admon"."Organization_ApplicationModule" ("ApplicationModuleId","OrganizationId","AuditCreationUser","AuditCreationDate")
SELECT am."Id", o."Id", 1, NOW()
FROM (
  SELECT am."Id", a."AppName", am."ModuleName"
  FROM "Admon"."ApplicationModule" am
  JOIN "Admon"."Application" a ON a."Id" = am."ApplicationId"
) am
JOIN "Admon"."Organization" o ON o."TaxId" = 'A11223344'
WHERE am."AppName" = 'Translate' AND am."ModuleName" = 'TLATE_Mensajeria'
ON CONFLICT ("ApplicationModuleId","OrganizationId") DO NOTHING;

-- Alpine Freight -> OneTrack Tracking
INSERT INTO "Admon"."Organization_ApplicationModule" ("ApplicationModuleId","OrganizationId","AuditCreationUser","AuditCreationDate")
SELECT am."Id", o."Id", 1, NOW()
FROM (
  SELECT am."Id", a."AppName", am."ModuleName"
  FROM "Admon"."ApplicationModule" am
  JOIN "Admon"."Application" a ON a."Id" = am."ApplicationId"
) am
JOIN "Admon"."Organization" o ON o."TaxId" = 'DE123456789'
WHERE am."AppName" = 'OneTrack' AND am."ModuleName" = 'TRACK_Tracking'
ON CONFLICT ("ApplicationModuleId","OrganizationId") DO NOTHING;

-- Old Freight S.L. (deactivated) -> had access to Sintraport Trafico but marked as revoked via AuditDeletionDate
WITH target AS (
  SELECT o."Id" AS OrgId FROM "Admon"."Organization" o WHERE o."TaxId" = 'B00000000'
), target_am AS (
  SELECT am."Id" AS AmId FROM "Admon"."ApplicationModule" am JOIN "Admon"."Application" a ON a."Id" = am."ApplicationId"
  WHERE a."AppName" = 'Sintraport' AND am."ModuleName" = 'SINTRA_Trafico' LIMIT 1
)
INSERT INTO "Admon"."Organization_ApplicationModule" ("ApplicationModuleId","OrganizationId","AuditCreationUser","AuditCreationDate","AuditDeletionDate")
SELECT t.AmId, tg.OrgId, 1, NOW(), NOW()
FROM target_am t, target tg
ON CONFLICT ("ApplicationModuleId","OrganizationId") DO UPDATE SET "AuditDeletionDate" = EXCLUDED."AuditDeletionDate";

COMMIT;
