```markdown
#### INIT001 - Inicialización Proyecto Back Helix6

**ID:** INIT001_Inicialización_Proyecto_Back_Helix6
**EPIC:** Epic0 - Inicialización de proyectos Helix6

**RESUMEN:** Crear el esqueleto del proyecto backend basado en la plantilla Helix6 (.NET 8). Incluir soluciones/proyectos: Api, Services, Data, DataModel, Entities, HelixGenerator, Tests y scaffolding inicial (Program.cs, DI, EF Core DbContext, ejemplo de entidad y migración inicial).

## OBJETIVOS
- Generar solución `.sln` con proyectos Helix6 estándar.
- Configurar `Program.cs` con Serilog, DI, Mapster y middleware `HelixExceptionsMiddleware`.
- Añadir `EntityModel` (DbContext) y ejemplo de entidad `GroupOrganization` en `DataModel`.
- Configurar EF Core migrations y script para generar la BD de desarrollo.
- Incluir `HelixEntities.xml` ejemplo para `GroupOrganization` y `Organization` y ejecutar Helix Generator (documentar pasos).
- Añadir pipelines CI (build + test) y instrucciones para local dev y docker.

## ACEPTACIÓN
- [ ] Solución construible (`dotnet build`) sin errores.
- [ ] `dotnet test` pasa en proyectos de tests iniciales (mocks básicos).
- [ ] `dotnet ef migrations add Initial` y `dotnet ef database update` funcionan según instrucciones.
- [ ] Endpoints básicos `GetById/Insert/Update/DeleteById` generados por Helix se exponen en Api.

## TAREAS PRINCIPALES / PASOS DE IMPLEMENTACIÓN
1. Crear solución y proyectos:
   - `Helix6.Back.Api` (Web API)
   - `Helix6.Back.Services`
   - `Helix6.Back.Data`
   - `Helix6.Back.DataModel`
   - `Helix6.Back.Entities`
   - `Helix6.Back.HelixGenerator` (si aplica)
   - `Helix6.Back.Services.Tests`, `Helix6.Back.Data.Tests`

2. `Program.cs` — registrar servicios estándar: Serilog, EF DbContext, Mapster, Helix middlewares, AddServicesRepositories auto-registry.

3. DataModel: añadir `GroupOrganization` entidad ejemplo con auditoría (`IEntityBase`). Añadir `DbSet<GroupOrganization>`.

4. HelixEntities.xml: incluir `GroupOrganization` con `GetById`, `Insert`, `Update`, `DeleteById`, `GetAllKendoFilter` y lanzar Helix Generator para producir Views/Endpoints.

5. EF Core:
   - Añadir paquete `Microsoft.EntityFrameworkCore.Design` y provider `Npgsql` (Postgres) o SQL Server según objetivo.
   - Ejecutar migración inicial y documentar comandos.

6. Dockerfile y docker-compose minimal para la Api (opcional), y variables de entorno en `appsettings.Development.json`.

7. Documentación `README.md`: comandos `dotnet build`, `dotnet run --project Helix6.Back.Api`, `dotnet test`, `dotnet ef` y cómo generar endpoints con Helix Generator.

## CONTRATO / ENDPOINTS (GENERADOS)
- GET `/api/GroupOrganization/GetById?id={id}&configurationName=GroupOrganizationComplete`
- POST `/api/GroupOrganization/Insert`
- PUT `/api/GroupOrganization/Update`
- DELETE `/api/GroupOrganization/DeleteById?id={id}`

## EJEMPLOS DE COMANDOS
```powershell
# Desde la raiz de la solución
dotnet build
dotnet test

# Crear migración (Data project)
dotnet ef migrations add InitialCreate --project Helix6.Back.Data --startup-project Helix6.Back.Api
dotnet ef database update --project Helix6.Back.Data --startup-project Helix6.Back.Api

# Ejecutar Api
dotnet run --project Helix6.Back.Api
```

## TESTS RECOMENDADOS
- Unit tests para `GroupOrganizationService.ValidateView` y `PreviousActions`.
- Integration test in-memory para repositorio `GetById`.

## CRITERIOS DE ACEPTACIÓN
- [ ] Estructura de proyectos creada en el repo.
- [ ] Documentación con pasos reproducibles para generar migraciones y ejecutar el app.
- [ ] Endpoints generados por Helix disponibles en runtime.

```
