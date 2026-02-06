```markdown
# ORG004-T001-BE: Backend — Gestión de módulos en organización (DataModel, Repo, Service, Endpoint)

=============================================================

**TICKET ID:** ORG004-T001-BE
**EPIC:** Gestión del Portfolio de Organizaciones Clientes
**USER STORY:** ORG-004 - Gestionar módulos y permisos de organización
**COMPONENT:** Backend - Helix6 (.NET 8)
**PRIORITY:** Alta
**ESTIMATION:** 2 días

=============================================================

**OBJETIVO**
Implementar la capa backend necesaria para soportar la asignación y remoción de módulos por organización, garantizando auditoría, publicación de eventos y la lógica de auto-baja cuando una organización se quede sin módulos.

**ALCANCE**
- Modelo de datos (DataModel) para `OrganizationApplicationModule`/`ApplicationModule` si no existe.
- Repositorio especializado si se requieren queries Dapper/EF personalizadas.
- Servicio `OrganizationService` con overrides de `ValidateView`, `PreviousActions` y `PostActions` para validar, aplicar lógica previa y publicar eventos/post-actions (auto-baja).
- Endpoints existentes (`Organization.GetById`, `Organization.Update`) deben soportar `configurationName=OrganizationComplete` que incluya `ApplicationModules`.
- Migración EF Core y tests unitarios/integ. Documentar comandos para migraciones y tests.

**REQUISITOS FUNCIONALES**
- Al actualizar la colección `ApplicationModules` dentro de `OrganizationView`, persistir cambios y actualizar auditoría (`AuditModificationUser/Date`).
- Si organización `Id > 0` y tras la operación `ApplicationModules` queda vacía, marcar la organización como `Active = false` (o llamar a la rutina de baja lógica existente) y registrar `AuditDeletionDate` o equivalente de la arquitectura Helix6. Registrar en `PostActions` la publicación del evento `OrganizationModulesChanged` o `OrganizationAutoDeactivated`.
- Publicar evento en broker con payload mínimo: `OrganizationId`, `PreviousModules`, `CurrentModules`, `TriggeredByUserId`.
- Mantener validaciones: evitar duplicados, validar que módulos sean válidos para las aplicaciones indicadas.

**CONTRATO / ENDPOINTS**
- GET `/api/Organization/GetById?id={id}&configurationName=OrganizationComplete` → retorna `OrganizationView` con `ApplicationModules`.
- PUT `/api/Organization/Update?configurationName=OrganizationComplete&reloadView=true` → body: `OrganizationView` (incluye `ApplicationModules`).

Headers:
- `Authorization: Bearer {token}`
- `Accept-Language`
- `X-Correlation-Id`

**MODELO DE DATOS (SUGERIDO)**
- Si el proyecto ya tiene `ApplicationModule` o `Organization_ApplicationModule`, ajustarse a la convención Helix6. Si no, añadir:

```csharp
[Table("Organization_ApplicationModule", Schema = "dbo")]
public class Organization_ApplicationModule : IEntityBase
{
    [Key]
    public int Id { get; set; }

    public int OrganizationId { get; set; }
    public int ApplicationId { get; set; }
    public int ModuleId { get; set; }

    // Auditoría Helix6
    public int AuditCreationUser { get; set; }
    public DateTime AuditCreationDate { get; set; }
    public int AuditModificationUser { get; set; }
    public DateTime AuditModificationDate { get; set; }
    public DateTime? AuditDeletionDate { get; set; }

    // Navegaciones si aplican
    public virtual Organization? Organization { get; set; }
}
```

- Añadir `DbSet<Organization_ApplicationModule>` en `EntityModel.cs`:

```csharp
public DbSet<Organization_ApplicationModule> Organization_ApplicationModules { get; set; }
```

**REPOSITORIO (SUGERIDO)**
- Interfaz (solo si necesita querys personalizados):
```csharp
public interface IOrganizationModuleRepository : IBaseRepository<Organization_ApplicationModule>
{
    Task<List<Organization_ApplicationModule>> GetByOrganizationIdAsync(int organizationId);
}
```
- Implementación mínima basada en `BaseRepository<T>` que expone `GetByOrganizationIdAsync` usando Dapper/EF según conveniencia.

**SERVICE — `OrganizationService` (SUGERIDO)**
- Heredar: `BaseService<OrganizationView, Organization, OrganizationViewMetadata>`
- Inyectar `IOrganizationModuleRepository` si se crea.

Puntos clave a implementar:
- `ValidateView(HelixValidationProblem validations, OrganizationView? view, EnumActionType actionType, string? configurationName = null)`
  - Validar que `ApplicationModules` contenga módulos válidos (sin duplicados) y que existan las aplicaciones y módulos referenciados.
  - Llamar `await base.ValidateView(...)`.

- `PreviousActions(OrganizationView? view, EnumActionType actionType, string? configurationName = null)`
  - Antes de persistir, comparar `view.ApplicationModules` con los módulos actuales en DB para detectar removidos/añadidos.
  - Si se remueven módulos, preparar un `ChangeSet` que pueda usarse en `PostActions` (ej: guardar en `UserContext.TempData` o en variable local si el flujo lo permite).
  - Llamar `await base.PreviousActions(...)`.

- `PostActions(OrganizationView? view, EnumActionType actionType, string? configurationName = null)`
  - Tras el `Insert/Update`, calcular `previousModules` vs `currentModules` y publicar evento al broker (ej: `OrganizationModulesChanged`).
  - Si `currentModules` queda vacío y `view.Id > 0`, ejecutar la lógica de auto-baja:
    - `await DeleteUndeleteLogicById(view.Id.Value)` o la rutina del framework que exista para baja lógica.
    - Registrar evento `OrganizationAutoDeactivated`.
  - Llamar `await base.PostActions(...)`.

Ejemplo simplificado de `PostActions`:
```csharp
public override async Task PostActions(OrganizationView? view, EnumActionType actionType, string? configurationName = null)
{
    if (view == null) { await base.PostActions(view, actionType, configurationName); return; }

    var previousModules = await _organizationModuleRepository.GetByOrganizationIdAsync(view.Id ?? 0);
    var currentModules = view.ApplicationModules ?? new List<ApplicationModuleView>();

    // Publish event with differences
    await _eventPublisher.PublishAsync(new OrganizationModulesChangedEvent
    {
        OrganizationId = view.Id ?? 0,
        PreviousModules = previousModules.Select(m => m.ModuleId).ToList(),
        CurrentModules = currentModules.Select(m => m.ModuleId).ToList(),
        UserId = _userContext.UserId
    });

    if ((currentModules == null || currentModules.Count == 0) && (view.Id ?? 0) > 0)
    {
      await base.DeleteUndeleteLogicById(view.Id.Value);
      await _eventPublisher.PublishAsync(new OrganizationAutoDeactivatedEvent { OrganizationId = view.Id.Value, UserId = _userContext.UserId });
    }

    await base.PostActions(view, actionType, configurationName);
}
```

**MIGRACIONES / COMANDOS**
Ejecutar desde la raíz de solución o proyecto Data siguiendo convención:

```powershell
# Crear migración
dotnet ef migrations add AddOrganizationApplicationModule --project Helix6.Back.Data --startup-project Helix6.Back.Api

# Aplicar migración
dotnet ef database update --project Helix6.Back.Data --startup-project Helix6.Back.Api
```

**TESTS**
- `Helix6.Back.Services.Tests`:
  - Unit tests para `OrganizationService.ValidateView` validando duplicados y módulos inexistentes.
  - Unit tests para `PreviousActions` que detecten cambios entre conjuntos de módulos.
  - Unit tests para `PostActions` que verifiquen que: evento `OrganizationModulesChanged` se publica y que cuando `currentModules` queda vacío se invoca la baja lógica.
- `Helix6.Back.Data.Tests`:
  - Repositorio `GetByOrganizationIdAsync` returns correct rows (setup in-memory DB or test DB).

Comandos de tests:
```powershell
dotnet test Helix6.Back.Services.Tests
dotnet test Helix6.Back.Data.Tests
```

**CRITERIOS DE ACEPTACIÓN**
- [ ] `OrganizationView` con `ApplicationModules` se persiste correctamente vía `Organization.Update` con `configurationName=OrganizationComplete`.
- [ ] Evento `OrganizationModulesChanged` se publica con `PreviousModules` y `CurrentModules`.
- [ ] Si tras la operación `ApplicationModules` queda vacío y `Id > 0`, la organización pasa a estado no-activa (auto-baja) y se publica `OrganizationAutoDeactivated`.
- [ ] Tests unitarios y de repositorio mínimos añadidos y pasan.
- [ ] Documentación de migración y comandos añadida al ticket/PR.

**NOTAS / CONSIDERACIONES**
- Respeta las reglas Helix6: usar servicios en endpoints, no saltar capas.
- Evitar duplicar lógica ya existente en `BaseService` (usar hooks y llamar a `await base.*`).
- Revisar si existe entidad `ApplicationModule`/`Organization_ApplicationModule` ya implementada para no duplicarla.
- Coordinar con frontend el `configurationName=OrganizationComplete` para asegurar el mapeo correcto de `ApplicationModules`.

**ENTREGABLES / CHECKLIST PR**
- [ ] `Organization_ApplicationModule` DataModel (si aplica) y `DbSet` en `EntityModel.cs`.
- [ ] `IOrganizationModuleRepository` + `OrganizationModuleRepository` (si necesario).
- [ ] `OrganizationService` overrides implementados.
- [ ] Migración EF Core generada.
- [ ] Pruebas unitarias de servicio y repositorio.
- [ ] Documentación en el ticket con comandos para migración y tests.

```
