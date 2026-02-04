# ORG002-T003-DB: Crear vista `VW_ORGANIZATION` con campos calculados (AppCount, ModuleCount)

=============================================================
**TICKET ID:** ORG002-T003-DB
**EPIC:** Gestión del Portfolio de Organizaciones Clientes
**USER STORY:** US-004 - Listar organizaciones con filtros y paginación
**COMPONENT:** Database (PostgreSQL)
**PRIORITY:** Alta
**ESTIMATION:** 1 hora
=============================================================

## TÍTULO
Crear la vista `VW_ORGANIZATION` que incluya los campos calculados `ModuleCount` y `AppCount` y que sea consumible por los endpoints de listado (GetAllKendoFilter).

## OBJETIVO
Proveer una vista optimizada que entregue, por cada organización, los contadores de módulos y aplicaciones asignadas, además de los campos estándar de `ORGANIZATION`, para facilitar listados y filtros server-side en frontend.

## DESCRIPCIÓN
- Crear script SQL que genere la vista `VW_ORGANIZATION` basada en las tablas existentes (`ORGANIZATION`, `ORGANIZATION_APPLICATIONMODULE`, `APPLICATIONMODULE`, `APPLICATION`).
- Generar migración EF Core que aplique el script desde el proyecto `InfoportOneAdmon.DataModel`.
- (Opcional) Añadir una entidad EF `VwOrganization` para consultas en pruebas/integration tests y registrarla en el `DbContext` como `HasNoKey().ToView(...)`.

## ALCANCE
- Incluir en la vista todos los campos relevantes de `ORGANIZATION` (Id, SecurityCompanyId, Name, TaxId/CIF, Address, City, PostalCode, Country, ContactEmail, ContactPhone, GroupId, Audit* fields).
- Añadir columnas calculadas:
  - `ModuleCount` : número de módulos distintos asignados a la organización (count distinct ApplicationModuleId)
  - `AppCount` : número de aplicaciones distintas asociadas (count distinct ApplicationId)
- Incluir `AuditDeletionDate` en la vista para permitir filtros por estado (alta/baja).

## DDL (SQL) - SUGERENCIA
Archivo: `InfoportOneAdmon.DataModel/Migrations/Scripts/CreateView_VW_ORGANIZATION.sql`

```sql
CREATE OR REPLACE VIEW public.vw_organization AS
SELECT
  o.id,
  o.security_company_id,
  o.name,
  o.taxid AS cif,
  o.address,
  o.city,
  o.postal_code,
  o.country,
  o.contact_email,
  o.contact_phone,
  o.group_id,
  o.audit_creation_user,
  o.audit_creation_date,
  o.audit_modification_user,
  o.audit_modification_date,
  o.audit_deletion_date,
  COALESCE(COUNT(DISTINCT oam.applicationmoduleid), 0) AS module_count,
  COALESCE(COUNT(DISTINCT am.applicationid), 0) AS app_count
FROM public.organization o
LEFT JOIN public.organization_applicationmodule oam ON o.id = oam.organizationid AND oam.auditdeletiondate IS NULL
LEFT JOIN public.applicationmodule am ON oam.applicationmoduleid = am.id AND am.auditdeletiondate IS NULL
GROUP BY
  o.id,
  o.security_company_id,
  o.name,
  o.taxid,
  o.address,
  o.city,
  o.postal_code,
  o.country,
  o.contact_email,
  o.contact_phone,
  o.group_id,
  o.audit_creation_user,
  o.audit_creation_date,
  o.audit_modification_user,
  o.audit_modification_date,
  o.audit_deletion_date;

COMMENT ON VIEW public.vw_organization IS 'Vista de organizaciones con contadores de aplicaciones y módulos asignados';
```

Notas:
- Usamos `organization_applicationmodule` (nombre según `ORG001-T003-DB`) como tabla de relación N:M.
- La vista filtra módulos y aplicaciones soft-deleted al computar los contadores.

## MIGRACIÓN EF CORE (sugerida)
- Crear migración en `InfoportOneAdmon.DataModel` que ejecute el script SQL como en `Ticket_ORG001_T003-DB.md`.
- Up: ejecutar contenido de `CreateView_VW_ORGANIZATION.sql`.
- Down: `DROP VIEW IF EXISTS public.vw_organization;`.

Comandos (ejemplo):
```powershell
dotnet ef migrations add CreateVwOrganization --project InfoportOneAdmon.DataModel --startup-project InfoportOneAdmon.Api --output-dir Migrations
dotnet ef database update --project InfoportOneAdmon.DataModel --startup-project InfoportOneAdmon.Api
```

## ENTIDAD EF (OPCIONAL)
Archivo: `InfoportOneAdmon.DataModel/Entities/VwOrganization.cs`

```csharp
[Table("vw_organization")]
public class VwOrganization
{
  public int Id { get; set; }
  public int SecurityCompanyId { get; set; }
  public string Name { get; set; } = string.Empty;
  public string? Cif { get; set; }
  public string? Address { get; set; }
  public string? City { get; set; }
  public string? PostalCode { get; set; }
  public string? Country { get; set; }
  public string? ContactEmail { get; set; }
  public string? ContactPhone { get; set; }
  public int? GroupId { get; set; }
  public string? AuditCreationUser { get; set; }
  public DateTime? AuditCreationDate { get; set; }
  public string? AuditModificationUser { get; set; }
  public DateTime? AuditModificationDate { get; set; }
  public DateTime? AuditDeletionDate { get; set; }

  public int ModuleCount { get; set; }
  public int AppCount { get; set; }
}
```

Registrar en `OnModelCreating`:

```csharp
modelBuilder.Entity<VwOrganization>().HasNoKey().ToView("vw_organization");
```

## TESTS (recomendado)
- Unit/integration tests que validen:
  - `ModuleCount = 0` cuando no hay módulos asignados.
  - `ModuleCount` y `AppCount` correctos ante varias asignaciones (mismos módulos, distintas aplicaciones).
  - Filtros por `AuditDeletionDate` separan activas/inactivas.

## CRITERIOS DE ACEPTACIÓN
- [ ] `vw_organization` creada y desplegada por migración EF Core.
- [ ] `ModuleCount` y `AppCount` calculados correctamente en tests de integración.
- [ ] La vista contiene los campos necesarios para el grid (incluyendo `AuditDeletionDate`).
- [ ] Los endpoints backend (GetAllKendoFilter) pueden consumir la vista sin transformaciones costosas.

## DEPENDENCIAS
- `ORGANIZATION` table must exist (see `Ticket_ORG001_T003-DB.md`).
- `ORGANIZATION_APPLICATIONMODULE`, `APPLICATIONMODULE`, `APPLICATION` must exist and follow Helix6 audit conventions.

## RIESGOS / CONSIDERACIONES
- Si la tabla de relación tiene otro nombre en la BD, ajustar el script.
- Para conjuntos muy grandes considerar materialized view o usar pre-aggregated counters si el rendimiento lo requiere.

## ENTREGABLES
- `CreateView_VW_ORGANIZATION.sql` (Scripts folder, embedded resource)
- EF Migration `CreateVwOrganization` que ejecuta el script
- (Opcional) `VwOrganization` entity y DbContext registration
- Integration tests que validen los conteos

=============================================================
