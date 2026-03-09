-- 01000007_SecurityAccessOptionLevel_SecurityUserGridConfiguration_Write.sql
-- Add write permission (SecurityLevel = 2) for SecurityAccessOptionId = 200 on controller SecurityUserGridConfiguration
-- Idempotent: updates existing record or inserts if not present
-- Alta de permiso de escritura (SecurityLevel=2) para el controlador SecurityUserGridConfiguration
-- asociado a la opcion de acceso 200.

-- 1) Actualizar si existe
UPDATE "Helix6_Security"."SecurityAccessOptionLevel"
SET
    "AuditModificationUser" = '1#hlxadm',
    "AuditModificationDate" = NOW(),
    "AuditDeletionDate" = NULL,
    "SecurityLevel" = 2
WHERE
    "SecurityAccessOptionId" = 200
    AND "Controller" = 'SecurityUserGridConfiguration'
    AND "SecurityLevel" <> 2;

-- 2) Insertar si no existe (calculo manual del Id para ser idempotente)
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
    'SecurityUserGridConfiguration',
    2,
    '1#hlxadm',
    '1#hlxadm',
    NOW(),
    NOW(),
    NULL
FROM "Helix6_Security"."SecurityAccessOptionLevel" t
WHERE NOT EXISTS (
    SELECT 1 FROM "Helix6_Security"."SecurityAccessOptionLevel" x
    WHERE x."SecurityAccessOptionId" = 200
      AND x."Controller" = 'SecurityUserGridConfiguration'
      AND x."SecurityLevel" = 2
);

COMMIT;
