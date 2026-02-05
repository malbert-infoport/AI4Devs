```markdown
# APL001-T002-BE: Backend — Listar Aplicaciones (paginación y filtros Kendo)

**TICKET ID:** APL001-T002-BE
**EPIC:** Administración de Aplicaciones
**COMPONENT:** Backend - Helix6 (.NET 8)
**PRIORITY:** Alta
**ESTIMATION:** 2 días

## OBJETIVO
Implementar y exponer endpoints backend que permitan listar aplicaciones con soporte Kendo (filtros, orden, paginación), respetando convenciones Helix6 y optimizando lecturas con Dapper cuando aplique.

## ALCANCE
- Endpoint `GetAllKendoFilter` para `Application`.
- Soporte de configuraciones `ApplicationList` y `ApplicationComplete` en `HelixEntities.xml`.
- Tests unitarios e integración mínimos.

## CONTRATO / ENDPOINTS
- POST `/api/Application/GetAllKendoFilter` — body: `{ Filter, Sort, Page, PageSize }` → `FilterResult<ApplicationView>` (TotalCount + Items)
- GET `/api/Application/GetById?id={id}&configurationName=ApplicationComplete`

Headers: `Authorization`, `Accept-Language`, `X-Correlation-Id`.

## MODEL / DATAMODEL
- Revisar `Application` en `DataModel`. Si falta índice para campos de búsqueda (Name, Key, Active), añadir índices en la migración.

## REPOSITORY
- Interfaz: `IApplicationRepository : IBaseRepository<Application>` (usar existente).
- Implementación: usar `BaseRepository<Application>`. Añadir método optimizado para Kendo si requiere SQL custom:

```csharp
public async Task<FilterResult<Application>> GetAllKendoFilter(IGenericFilter filter, string? configurationName = null)
{
    // usar Dapper para consultas complejas y devolver TotalCount + Items
}
```

## SERVICE — `ApplicationService`
- Heredar: `BaseService<ApplicationView, Application, ApplicationViewMetadata>`
- `ValidateView`: llamar `await base.ValidateView(...)` y validar campos críticos en insert/update.
- `PreviousActions`: no especial salvo cache busting si aplica.
- `PostActions`: publicar evento `ApplicationListViewed` si se requiere telemetría.

Ejemplo:

```csharp
public override async Task<FilterResult<ApplicationView>> GetAllKendoFilter(IGenericFilter filter, string? configurationName = null)
{
    return await _applicationRepository.GetAllKendoFilter(filter, configurationName);
}
```

## MIGRACIONES / COMANDOS
```powershell
dotnet ef migrations add AddIndexes_Application_ForSearch --project Helix6.Back.Data --startup-project Helix6.Back.Api
dotnet ef database update --project Helix6.Back.Data --startup-project Helix6.Back.Api
```

## TESTS
- `Helix6.Back.Services.Tests`: test para `GetAllKendoFilter` devolviendo `TotalCount` y items correctos con filtros varios.
- `Helix6.Back.Data.Tests`: test de repositorio con casos de filtros y orden.

## CRITERIOS DE ACEPTACIÓN
- [ ] Endpoint `GetAllKendoFilter` implementado y documentado.
- [ ] Tests unitarios de servicio y repositorio añadidos.
- [ ] Migración con índices creada y verificada.

## NOTAS
- Registrar la configuración `ApplicationList` en `HelixEntities.xml` y ejecutar Helix Generator si es necesario.

***
```
