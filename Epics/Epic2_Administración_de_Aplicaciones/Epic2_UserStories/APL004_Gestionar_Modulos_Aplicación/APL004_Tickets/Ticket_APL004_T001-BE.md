```markdown
# APL004-T001-BE: Backend — CRUD de ApplicationModule y asignación a Application

**TICKET ID:** APL004-T001-BE
**EPIC:** Administración de Aplicaciones
**COMPONENT:** Backend - Helix6 (.NET 8)
**PRIORITY:** Alta
**ESTIMATION:** 2 días

## OBJETIVO
Implementar DataModel (si falta), repositorio y servicio para `ApplicationModule`, soportar CRUD, asignación a `Application` y publicar eventos cuando cambian asignaciones.

## DATAMODEL SUGERIDO
Si no existe:

```csharp
[Table("ApplicationModules", Schema = "dbo")]
public class ApplicationModule : IEntityBase
{
    [Key]
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Key { get; set; } = string.Empty;
    public int? ApplicationId { get; set; }
    public int DisplayOrder { get; set; }

    public int AuditCreationUser { get; set; }
    public DateTime AuditCreationDate { get; set; }
    public int AuditModificationUser { get; set; }
    public DateTime AuditModificationDate { get; set; }
    public DateTime? AuditDeletionDate { get; set; }
}
```

Añadir `DbSet<ApplicationModule> ApplicationModules` en `EntityModel.cs`.

## REPOSITORIO
- `IApplicationModuleRepository : IBaseRepository<ApplicationModule>` con método `GetByApplicationId(int applicationId)`.

## SERVICE — `ApplicationModuleService`
- `ValidateView`: validar `Name`, `Key` y unicidad por `ApplicationId`.
- `PreviousActions`: antes de eliminar, comprobar dependencias y lanzar `HelixValidationException` si está en uso.
- `PostActions`: publicar `ApplicationModuleChanged` o `ApplicationModuleAssigned` eventos según corresponda.

## ENDPOINTS / CONTRATO
- GET/POST/PUT/DELETE endpoints generados por Helix Generator para `ApplicationModule`.
- Asegurar `GetById` y `GetAllKendoFilter` para la grid.

## MIGRACIONES / COMANDOS
```powershell
dotnet ef migrations add AddApplicationModule --project Helix6.Back.Data --startup-project Helix6.Back.Api
dotnet ef database update --project Helix6.Back.Data --startup-project Helix6.Back.Api
```

## TESTS
- Services.Tests: ValidateView uniqueness, PreviousActions dependency checks, PostActions event publication.
- Data.Tests: repository queries for `GetByApplicationId`.

## CRITERIOS DE ACEPTACIÓN
- [ ] DataModel + DbSet añadidos (si no existían) y migración creada.
- [ ] CRUD funcional y tests añadidos.
- [ ] Eventos publicados en cambios de asignación.

***
```
