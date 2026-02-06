```markdown
```markdown
# APL001-T002-BE: Backend — Application service orchestration (ApplicationComplete load/save)

**TICKET ID:** APL001-T002-BE
**EPIC:** Administración de Aplicaciones
**COMPONENT:** Backend - Helix6 (.NET 8)
**PRIORITY:** Alta
**ESTIMATION:** 3 días

## OBJETIVO
Implementar la orquestación en backend para soportar la configuración de carga completa `ApplicationComplete` y las operaciones únicas de inserción/actualización que reciben y persisten el `ApplicationView` completo (incluyendo `ApplicationModules`, `ApplicationRoles` y `ApplicationCredentials`) en una única transacción atómica.

Esto incluye:
- `GET /api/Application/GetById?id={id}&configuration=ApplicationComplete` que devuelve la entidad `Application` con sus colecciones relacionadas.
- `POST /api/Application` y `PUT /api/Application` que acepten `ApplicationView` con la configuración `ApplicationComplete` y apliquen insert/update/delete sobre colecciones anidadas de forma consistente.

## ALCANCE
- Service: `ApplicationService` (o extensión del existente) con nuevos métodos/overloads que soporten `configurationName` y mapeo completo `ApplicationView <-> Application`.
- Repository: posibles helpers en `IApplicationRepository` para obtener `Application` con joins (EF/Dapper) o mediante `BaseRepository` + includes eficientes.
- Migraciones: actualizar `EntityModel.cs` si faltan `DbSet` para `ApplicationModule`, `ApplicationRole`, `ApplicationCredential`.
- Tests: unitarios para `ApplicationService` y tests de integración para flujos de carga/guardado completo.

## DATAMODEL / VISTAS
- Confirmar que las Views generadas por Helix (`ApplicationView`, `ApplicationModuleView`, `ApplicationRoleView`, `ApplicationCredentialView`) incluyen las colecciones necesarias. Si faltan, regenerar con Helix Generator o añadir `PartialViews`.
- En el DataModel asegúrese de la existencia de las entidades y `DbSet<>`:

```csharp
public DbSet<Application> Applications { get; set; }
public DbSet<ApplicationModule> ApplicationModules { get; set; }
public DbSet<ApplicationRole> ApplicationRoles { get; set; }
public DbSet<ApplicationCredential> ApplicationCredentials { get; set; }
```

## REPOSITORIO
- `IApplicationRepository` debe exponer un método `GetWithCompleteLoad(int id)` o permitir `GetById(id, configurationName)` que nivele la carga completa de las relaciones usando Dapper/EF con joins para rendimiento.
- Añadir transacciones de larga duración en `ApplicationService` que coordinen llamadas a repositorios concretos para insertar/actualizar/eliminar elementos de colecciones.

## SERVICE — `ApplicationService` (detalles)
Responsabilidades principales:

- `GetById(id, configurationName = 'ApplicationComplete')`:
  - Recupera `Application` con `Modules`, `Roles`, `Credentials`.
  - Mapear a `ApplicationView` y devolver.

- `Insert(ApplicationView view, string? configurationName = null)` y `Update(ApplicationView view, string? configurationName = null)` cuando `configurationName == 'ApplicationComplete'`:
  - Validar vista completa con `ValidateView` (nombres, claves únicas, permisos válidos, no duplicados en colecciones).
  - Iniciar transacción.
  - Mapper `ApplicationView` → `Application`.
  - Para cada colección (`Modules`, `Roles`, `Credentials`):
    - Detectar items nuevos → `Insert` en repositorios correspondientes.
    - Detectar items modificados → `Update`.
    - Detectar items eliminados → `DeleteUndeleteLogicById(id)` (soft-delete) sin tercer parámetro (usar la firma correcta).
  - Guardar `Application` y cambios relacionados en la misma transacción.
  - Publicar eventos agregados (ej: `ApplicationUpdated`, `ApplicationModulesChanged`, `ApplicationRolesChanged`, `ApplicationCredentialsChanged`) en `PostActions`.

- `ValidateView(HelixValidationProblem validations, ApplicationView? view, EnumActionType actionType, string? configurationName = null)`:
  - Validaciones específicas para `ApplicationComplete`: nombres obligatorios, unicidad de `Key` en modules/roles, permisos existentes.
  - Llamar siempre a `await base.ValidateView(...)` al final.

- `PreviousActions`:
  - Antes de borrar o de aplicar cambios complejos, comprobar referencias a integraciones externas o constraints y abortar con `HelixValidationException` si aplica.

- `PostActions`:
  - Publicar eventos, limpiar caches relacionados y enviar notificaciones si se detectó cambio en credenciales.

Ejemplo simplificado de detección de cambios en colecciones:

```csharp
var existingModules = await _applicationModuleRepository.GetByApplicationId(appId);
var incoming = view.ApplicationModules ?? new List<ApplicationModuleView>();
// Insert new
var toInsert = incoming.Where(i => i.Id == 0);
// Update existing
var toUpdate = incoming.Where(i => i.Id != 0 && existingModules.Any(e => e.Id == i.Id));
// Delete removed
var toDelete = existingModules.Where(e => !incoming.Any(i => i.Id == e.Id));
```

Realizar operaciones en ese orden dentro de una transacción para mantener consistencia y evitar constraint violations.

## ENDPOINTS / CONTRATO
- `GET /api/Application/GetById?id={id}&configuration=ApplicationComplete` → `ApplicationView` con `Modules`, `Roles`, `Credentials`.
- `POST /api/Application/Insert` (body: `ApplicationView`, optional `configurationName=ApplicationComplete`) → Insert (create) with nested collections via generated Helix endpoint.
- `POST /api/Application/Update` (body: `ApplicationView`, optional `configurationName=ApplicationComplete`) → Update with nested collections via generated Helix endpoint.

Documentar claramente: clientes Angular deben preferir `ApplicationClient.getById(id, 'ApplicationComplete')` y enviar `ApplicationClient.update(applicationView, { configurationName: 'ApplicationComplete' })` (o `ApplicationClient.insert` para crear) para ediciones completas empleando los endpoints generados por Helix.

## MIGRACIONES / COMANDOS
Si se añaden entidades o `DbSet`, crear migración:

```powershell
dotnet ef migrations add AddApplicationFullLoadEntities --project Helix6.Back.Data --startup-project Helix6.Back.Api
dotnet ef database update --project Helix6.Back.Data --startup-project Helix6.Back.Api
```

## TESTS
- `Helix6.Back.Services.Tests`:
  - Unit: `ValidateView` para `ApplicationComplete` valida reglas.
  - Unit: `Insert`/`Update` orchestration, mocks de repositorios para asegurar llamadas a insert/update/delete en colecciones.
- `Helix6.Back.Data.Tests`:
  - Integration: carga `GetWithCompleteLoad` devuelve `Application` con colecciones esperadas.

## CRITERIOS DE ACEPTACIÓN
- [ ] `GET /api/Application/GetById` con `ApplicationComplete` devuelve `ApplicationView` con `Modules`, `Roles` y `Credentials`.
 - [ ] `POST /api/Application/Insert` / `POST /api/Application/Update` con `ApplicationComplete` aplica insert/update/delete sobre colecciones y mantiene integridad referencial.
- [ ] Tests unitarios e integración añadidos y pasan.
- [ ] Documentación del contrato (NSwag) y ejemplos de uso en tickets FE actualizados.

## NOTAS Y RIESGOS
- Debe cuidarse el rendimiento: cargar múltiples colecciones puede requerir queries optimizados o segmentación por Dapper.
- Coordinar con equipos de seguridad la persistencia de `clientSecret` (no almacenar en texto claro).
- Auditar eventos de cambio en `Credentials` y notificar según política.

```
```
