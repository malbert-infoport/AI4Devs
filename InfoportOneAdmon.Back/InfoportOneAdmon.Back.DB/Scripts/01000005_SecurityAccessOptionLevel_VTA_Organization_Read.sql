-- 01000005_SecurityAccessOptionLevel_VTA_Organization_Read.sql
-- Alta de permiso de lectura (SecurityLevel=1) para el controlador VTA_Organization
-- asociado a la opcion de acceso 200 (OrganizationQuery).

-- Regla de negocio:
-- GET -> SecurityLevel 1

-- 1) Si ya existe el registro, se reactiva/actualiza metadatos.
UPDATE "Helix6_Security"."SecurityAccessOptionLevel"
SET
    "AuditModificationUser" = '1#hlxadm',
    "AuditModificationDate" = NOW(),
    "AuditDeletionDate" = NULL
WHERE
    "SecurityAccessOptionId" = 200
    AND "Controller" = 'VTA_Organization'
    AND "SecurityLevel" = 1;

-- 2) Si no existe, se inserta un nuevo registro con Id incremental.
INSERT INTO "Helix6_Security"."SecurityAccessOptionLevel" (
    "Id",
    "SecurityAccessOptionId",
    "Controller",
    "SecurityLevel",
    "AuditCreationUser",
    "AuditModificationUser",
    "AuditCreationDate",
    "AuditModificationDate",
    "AuditDeletionDate"
)
SELECT
    COALESCE(MAX(t."Id"), 0) + 1,
    200,
    'VTA_Organization',
    1,
    '1#hlxadm',
    '1#hlxadm',
    NOW(),
    NOW(),
    NULL
FROM "Helix6_Security"."SecurityAccessOptionLevel" t
WHERE NOT EXISTS (
    SELECT 1
    FROM "Helix6_Security"."SecurityAccessOptionLevel" x
    WHERE
        x."SecurityAccessOptionId" = 200
        AND x."Controller" = 'VTA_Organization'
        AND x."SecurityLevel" = 1
);
