-- =====================================================
-- Script   : 01000004_VTA_Organization.sql
-- Proyecto  : InfoportOneAdmon - Epic1 Organization Management
-- Motor     : PostgreSQL 15+
-- Nota      : Prefijo de vistas: VTA_ (convención del proyecto)
-- Despliegue: DBUp (EmbeddedResource en InfoportOneAdmon.Back.DB)
-- Fecha     : 2026-03-02
-- Descripción:
--   Crea (o reemplaza) la vista VTA_ORGANIZATION que agrega,
--   por cada organización, los campos de la tabla ORGANIZATION
--   más dos contadores calculados:
--     - ModuleCount : nº de módulos distintos asignados y activos
--     - AppCount    : nº de aplicaciones distintas asociadas y activas
--   El script es idempotente gracias a CREATE OR REPLACE VIEW.
--
-- Dependencias:
--   Script 01000003_OrganizationInfrastructure.sql (ya desplegado)
--   Tablas: Organization, Organization_ApplicationModule,
--           ApplicationModule, Application
-- =====================================================

CREATE OR REPLACE VIEW "Admon"."VTA_Organization" AS
SELECT
  o."Id",
  o."SecurityCompanyId",
  o."GroupId",
  o."Name",
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
  COALESCE(COUNT(DISTINCT oam."ApplicationModuleId"), 0)::INTEGER AS "ModuleCount",
  COALESCE(COUNT(DISTINCT am."ApplicationId"),        0)::INTEGER AS "AppCount"
FROM "Admon"."Organization" o
LEFT JOIN "Admon"."Organization_ApplicationModule" oam
       ON o."Id" = oam."OrganizationId"
      AND oam."AuditDeletionDate" IS NULL
LEFT JOIN "Admon"."ApplicationModule" am
       ON oam."ApplicationModuleId" = am."Id"
      AND am."AuditDeletionDate" IS NULL
GROUP BY
  o."Id",
  o."SecurityCompanyId",
  o."GroupId",
  o."Name",
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
  o."AuditDeletionDate";

COMMENT ON VIEW "Admon"."VTA_Organization"
  IS 'Vista de organizaciones con contadores de aplicaciones y módulos asignados (AppCount, ModuleCount). Prefijo VTA_ según convención del proyecto InfoportOneAdmon.';

-- =====================================================
-- Fin del script 01000004_VTA_Organization
-- =====================================================
