# ORG002-T003-DB: Crear vista `VTA_ORGANIZATION` con campos calculados (AppCount, ModuleCount)

=============================================================
**TICKET ID:** ORG002-T003-DB
**EPIC:** Gestión del Portfolio de Organizaciones Clientes
**USER STORY:** US-004 - Listar organizaciones con filtros y paginación
**COMPONENT:** Database (PostgreSQL)
**PRIORITY:** Alta
**ESTIMATION:** 1 hora
=============================================================

## TÍTULO
Crear la vista `VTA_ORGANIZATION` que incluya los campos calculados `ModuleCount` y `AppCount` y que sea consumible por los endpoints de listado (GetAllKendoFilter).

## OBJETIVO
Proveer una vista optimizada que entregue, por cada organización, los contadores de módulos y aplicaciones asignadas, además de los campos estándar de `ORGANIZATION`, para facilitar listados y filtros server-side en frontend.

## DESCRIPCIÓN
- Crear script SQL idempotente (`CREATE OR REPLACE VIEW`) que genere la vista `VTA_ORGANIZATION` basada en las tablas existentes (`ORGANIZATION`, `ORGANIZATION_APPLICATIONMODULE`, `APPLICATIONMODULE`, `APPLICATION`).
- Desplegar mediante **DBUp** como `EmbeddedResource` en `InfoportOneAdmon.Back.DB/Scripts` (script `01000004_VTA_Organization.sql`).
- **No usar migraciones EF Core** — la gestión de esquema se hace exclusivamente con DBUp.
- (Opcional) Añadir una entidad EF `VtaOrganization` sin clave para consultas read-only y registrarla en el `DbContext` como `HasNoKey().ToView(...)`.

## ALCANCE
- Incluir en la vista todos los campos relevantes de `ORGANIZATION` (Id, SecurityCompanyId, Name, TaxId/CIF, Address, City, PostalCode, Country, ContactEmail, ContactPhone, GroupId, Audit* fields).
- Añadir columnas calculadas:
  - `ModuleCount` : número de módulos distintos asignados a la organización (count distinct ApplicationModuleId)
  - `AppCount` : número de aplicaciones distintas asociadas (count distinct ApplicationId)
- Incluir `AuditDeletionDate` en la vista para permitir filtros por estado (alta/baja).

## DDL (SQL)
Archivo: `InfoportOneAdmon.Back.DB/Scripts/01000004_VTA_Organization.sql`

> Las columnas usan exactamente los nombres de `01000003_OrganizationInfrastructure.sql` (PascalCase con comillas dobles, schema `"Admon"`).

```sql
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
  COALESCE(COUNT(DISTINCT oam."ApplicationModuleId"), 0)::INTEGER AS "ModuleCount",
  COALESCE(COUNT(DISTINCT am."ApplicationId"),        0)::INTEGER AS "AppCount"
FROM "Admon"."Organization" o
LEFT JOIN "Admon"."Organization_ApplicationModule" oam
       ON o."Id" = oam."OrganizationId" AND oam."AuditDeletionDate" IS NULL
LEFT JOIN "Admon"."ApplicationModule" am
       ON oam."ApplicationModuleId" = am."Id" AND am."AuditDeletionDate" IS NULL
GROUP BY
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
  o."AuditDeletionDate";

COMMENT ON VIEW "Admon"."VTA_Organization" IS 'Vista de organizaciones con contadores de aplicaciones y módulos asignados (AppCount, ModuleCount)';
```

Notas:
- `CREATE OR REPLACE VIEW` es idempotente; no requiere bloque `IF NOT EXISTS`.
- Se filtran módulos y aplicaciones soft-deleted al computar los contadores.
- Todos los nombres de columna respetan el casing PascalCase de las tablas del script `01020004`.

## SCRIPT DBUP
Archivo a crear: `InfoportOneAdmon.Back.DB/Scripts/01000004_VTA_Organization.sql`
Registrar en: `InfoportOneAdmon.Back.DB/InfoportOneAdmon.Back.DB.csproj` como `EmbeddedResource`.

Flujo de despliegue:
1. Crear el archivo SQL en `Scripts/`.
2. Añadir la línea en el `.csproj`:
   ```xml
   <EmbeddedResource Include="Scripts\01000004_VTA_Organization.sql" />
   ```
3. Levantar la API → DBUp detecta el script nuevo y lo ejecuta automáticamente en orden.
4. Validar en BD que `"Admon"."VTA_Organization"` existe con los campos correctos.

> No usar `dotnet ef migrations add` ni `dotnet ef database update` para cambios de esquema.

## ENTIDAD EF (OPCIONAL — tras scaffolding inverso)
Tras ejecutar `/UpdateDataModel`, el scaffolding inverso puede generar automáticamente la entidad `VtaOrganization`. Si se necesita configuración manual:

Archivo: `InfoportOneAdmon.Back.DataModel/VtaOrganization.cs`

```csharp
[Table("VTA_Organization", Schema = "Admon")]
public class VtaOrganization
{
    public int Id { get; set; }
    public int SecurityCompanyId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Acronym { get; set; }
    public string? TaxId { get; set; }
    public string? Address { get; set; }
    public string? City { get; set; }
    public string? PostalCode { get; set; }
    public string? Country { get; set; }
    public string? ContactEmail { get; set; }
    public string? ContactPhone { get; set; }
    public int? GroupId { get; set; }
    public string? AuditCreationUser { get; set; }
    public DateTimeOffset? AuditCreationDate { get; set; }
    public string? AuditModificationUser { get; set; }
    public DateTimeOffset? AuditModificationDate { get; set; }
    public DateTimeOffset? AuditDeletionDate { get; set; }
    public int ModuleCount { get; set; }
    public int AppCount { get; set; }
}
```

Registrar en `OnModelCreating`:

```csharp
modelBuilder.Entity<VtaOrganization>().HasNoKey().ToView("VTA_Organization", "Admon");
```

> Los campos de fecha usan `DateTimeOffset` (mapea a `TIMESTAMPTZ`).

## TESTS (recomendado)
- Unit/integration tests que validen:
  - `ModuleCount = 0` cuando no hay módulos asignados.
  - `ModuleCount` y `AppCount` correctos ante varias asignaciones (mismos módulos, distintas aplicaciones).
  - Filtros por `AuditDeletionDate` separan activas/inactivas.

## CRITERIOS DE ACEPTACIÓN
- [ ] Script `01000004_VTA_Organization.sql` creado y registrado como `EmbeddedResource`.
- [ ] DBUp ejecuta el script correctamente al levantar la API.
- [ ] Vista `"Admon"."VTA_Organization"` existe en BD con los campos correctos.
- [ ] `ModuleCount` y `AppCount` calculados correctamente en tests de integración.
- [ ] La vista contiene todos los campos necesarios para el grid (incluyendo `AuditDeletionDate`).
- [ ] Los endpoints backend (`GetAllKendoFilter`) pueden consumir la vista sin transformaciones costosas.

## DEPENDENCIAS
- Script `01000003_OrganizationInfrastructure.sql` debe estar desplegado (tablas `"Admon"."Organization"`, `"Admon"."Organization_ApplicationModule"`, `"Admon"."ApplicationModule"`, `"Admon"."Application"`).
- DBUp ejecuta los scripts en orden alfanumérico; `01000004` se ejecuta siempre después de `01000003`.

## RIESGOS / CONSIDERACIONES
- Si la tabla de relación tiene otro nombre en la BD, ajustar el script.
- Para conjuntos muy grandes considerar materialized view o usar pre-aggregated counters si el rendimiento lo requiere.

## ENTREGABLES
- `InfoportOneAdmon.Back.DB/Scripts/01000004_VTA_Organization.sql` (EmbeddedResource)
- Entrada en `InfoportOneAdmon.Back.DB.csproj`
- (Opcional) `VtaOrganization` entity y `DbContext` registration (post-scaffolding inverso)
- Integration tests que validen los conteos

=============================================================
