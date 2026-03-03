-- =====================================================
-- Script   : 01000005_VTA_Organization_WithCounters.sql
-- Proyecto  : InfoportOneAdmon - Epic1 Organization Management
-- Motor     : PostgreSQL 15+
-- Despliegue: DBUp (EmbeddedResource en InfoportOneAdmon.Back.DB)
-- Fecha     : 2026-03-03
-- Descripción:
--   Recrea la vista "Admon"."VTA_Organization" asegurando que
--   AppCount y ModuleCount sean columnas reales de la vista
--   (no expresiones virtuales), de modo que los filtros y
--   ordenaciones server-side (Kendo/ClGrid) puedan operar
--   directamente sobre ellas sin transformaciones adicionales.
--
--   AppCount    : nº de aplicaciones activas distintas asignadas
--   ModuleCount : nº de módulos activos distintos asignados
--
--   El uso de CREATE OR REPLACE VIEW hace la sentencia idempotente.
--
-- Dependencias:
--   01000003_OrganizationInfrastructure.sql
--   Tablas: "Admon"."Organization", "Admon"."Organization_ApplicationModule",
--           "Admon"."ApplicationModule"
-- =====================================================
-- -------------------------------------------------------
-- Paso 1: Añadir columna Acronym a la tabla Organization
--         (idempotente: ADD COLUMN IF NOT EXISTS)
-- -------------------------------------------------------
ALTER TABLE "Admon"."Organization"
    ADD COLUMN IF NOT EXISTS "Acronym" VARCHAR(50);

-- -------------------------------------------------------
-- Paso 2: Recrear la vista VTA_Organization incluyendo
--         Acronym y usando subqueries correlacionadas para
--         AppCount y ModuleCount (filtrables server-side)
-- -------------------------------------------------------
CREATE OR REPLACE VIEW "Admon"."VTA_Organization" AS
SELECT
    o."Id",
    o."SecurityCompanyId",
    o."GroupId",
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
          WHERE  oam3."OrganizationId"     = o."Id"
            AND  oam3."AuditDeletionDate" IS NULL ),
        0
    )::INTEGER AS "AppCount"
FROM "Admon"."Organization" o;

COMMENT ON VIEW "Admon"."VTA_Organization"
    IS 'Vista de organizaciones con AppCount y ModuleCount como columnas reales para soporte de filtro/orden server-side (Kendo GetAllKendoFilter).';

COMMENT ON COLUMN "Admon"."VTA_Organization"."ModuleCount"
    IS 'Número de módulos activos (AuditDeletionDate IS NULL) asignados a la organización.';

COMMENT ON COLUMN "Admon"."VTA_Organization"."AppCount"
    IS 'Número de aplicaciones activas distintas cuyos módulos están asignados a la organización.';

-- =====================================================
-- Fin del script 01000005_VTA_Organization_WithCounters
-- =====================================================
