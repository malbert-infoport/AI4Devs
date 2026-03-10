CREATE OR REPLACE VIEW "Admon"."VTA_Organization" AS
SELECT
    o."Id",
    o."SecurityCompanyId",
    og."GroupName" AS "GroupName",
    o."Name",
    o."Acronym",
    o."TaxId",
    o."Address",
    o."City",
    o."PostalCode",
    o."Country",
    o."ContactEmail",
    o."ContactPhone",
    o."AuditCreationUser",
    o."AuditCreationDate",
    o."AuditModificationUser",
    o."AuditModificationDate",
    o."AuditDeletionDate",
    COALESCE(
        ( SELECT COUNT(DISTINCT oam2."ApplicationModuleId")
          FROM   "Admon"."Organization_ApplicationModule" oam2
          WHERE  oam2."OrganizationId"     = o."Id"
            AND  oam2."AuditDeletionDate" IS NULL ),
        0
    )::INTEGER AS "ModuleCount",
    COALESCE(
        ( SELECT COUNT(DISTINCT am2."ApplicationId")
          FROM   "Admon"."Organization_ApplicationModule" oam3
          JOIN   "Admon"."ApplicationModule" am2
                   ON am2."Id" = oam3."ApplicationModuleId"
                  AND am2."AuditDeletionDate" IS NULL
          JOIN   "Admon"."Application" a2
                   ON a2."Id" = am2."ApplicationId"
                  AND a2."AuditDeletionDate" IS NULL
          WHERE  oam3."OrganizationId"     = o."Id"
            AND  oam3."AuditDeletionDate" IS NULL ),
        0
    )::INTEGER AS "AppCount",
    COALESCE(
        ( SELECT string_agg(DISTINCT a2."AppName", ' / ' ORDER BY a2."AppName")
          FROM   "Admon"."Organization_ApplicationModule" oam4
          JOIN   "Admon"."ApplicationModule" am3
                   ON am3."Id" = oam4."ApplicationModuleId"
                  AND am3."AuditDeletionDate" IS NULL
          JOIN   "Admon"."Application" a2
                   ON a2."Id" = am3."ApplicationId"
                  AND a2."AuditDeletionDate" IS NULL
          WHERE  oam4."OrganizationId" = o."Id"
            AND  oam4."AuditDeletionDate" IS NULL
        ), '') AS "AppList"
FROM "Admon"."Organization" o
LEFT JOIN "Admon"."OrganizationGroup" og ON og."Id" = o."GroupId";
