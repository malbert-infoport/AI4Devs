```markdown
# APL004-T002-BE: Backend — CRUD de ApplicationModule y asignación a Application

**TICKET ID:** APL004-T002-BE
**EPIC:** Administración de Aplicaciones
**COMPONENT:** Backend - Helix6 (.NET 8)
**PRIORITY:** Alta
**ESTIMATION:** 2 días

## OBJETIVO
Implementar DataModel (si falta), repositorio y servicio para `ApplicationModule`, soportar CRUD y publicar eventos cuando cambian asignaciones.

Importante (configuración de carga completa): cuando la UI/cliente solicite la configuración de carga `ApplicationComplete` o similar, el backend deberá exponer un único `GetById` sobre `Application` que devuelva la `Application` junto a sus `Modules`, `Roles` y `Credentials` en una sola llamada. De igual forma, las operaciones de inserción y actualización que usen la configuración de carga completa serán operaciones únicas sobre `Application` que incluyan la colección de `ApplicationModule` (insert/update/delete en una transacción atomica gestionada por el `ApplicationService`).

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
- `IApplicationModuleRepository : IBaseRepository<ApplicationModule>` con métodos para operaciones por `ApplicationId`.
- Nota: Aunque exista `GetByApplicationId` para consultas puntuales, la implementación principal de carga completa deberá ser orquestada por `IApplicationRepository`/`ApplicationService` para devolver `Application` + `Modules` + `Roles` + `Credentials` en una sola consulta/configuración de carga (p.ej. `ApplicationBasic` / `ApplicationComplete`).

## SERVICE — `ApplicationModuleService`
- `ValidateView`: validar `Name`, `Key` y unicidad por `ApplicationId`.
- `PreviousActions`: antes de eliminar, comprobar dependencias y lanzar `HelixValidationException` si está en uso.
- `PostActions`: publicar `ApplicationModuleChanged` o `ApplicationModuleAssigned` eventos según corresponda.

Orquestación por `ApplicationService`:
- El `ApplicationService` será responsable de implementar `GetById` con la configuración de carga completa (`ApplicationComplete`) que devuelva `Application` con sus `Modules`, `Roles` y `Credentials` en una sola respuesta. `ApplicationService` debe mapear `ApplicationView` con colecciones anidadas y delegar inserciones/actualizaciones a los repositorios de `ApplicationModule` dentro de una única transacción para mantener consistencia.
- Insert/Update de la UI que envíe el `ApplicationView` completo deberá ser procesado por `ApplicationService` y no mediante múltiples llamadas separadas desde el cliente.

## ENDPOINTS / CONTRATO
- Mantener endpoints CRUD generados por Helix Generator para `ApplicationModule` para usos administrativos.
- Para la UI que gestione una `Application` completa, exponer y documentar el uso de `GET /api/Application/GetById?id={id}&configuration=ApplicationComplete` (o la convención de configuración de carga existente) que devuelve la `Application` junto a `Modules`, `Roles` y `Credentials`.
- Documentar que la inserción/actualización completa se realiza vía los endpoints generados `POST /api/Application/Insert` y `POST /api/Application/Update` con el `ApplicationView` completo (configuración de carga `ApplicationComplete`) y que el backend aplicará las inserciones/actualizaciones/soft-deletes de `ApplicationModule` dentro de la misma transacción.

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
