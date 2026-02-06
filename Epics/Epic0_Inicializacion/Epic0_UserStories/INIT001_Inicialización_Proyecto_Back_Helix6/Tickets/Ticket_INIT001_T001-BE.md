```markdown
# INIT001-T001-BE: Backend — Scaffold inicial Helix6 (.NET 8)

**TICKET ID:** INIT001-T001-BE
**EPIC:** Epic0 - Inicialización de proyectos Helix6
**COMPONENT:** Backend - Helix6 (.NET 8)
**PRIORITY:** Alta
**ESTIMATION:** 3 días

## OBJETIVO
Scaffold y configurar el proyecto backend base usando la plantilla Helix6: Api, Services, Data, DataModel, Entities, HelixGenerator y proyectos de tests.

## ALCANCE
- Crear la solución y proyectos básicos.
- Configurar Program.cs con Serilog, Mapster, DI y Helix Middlewares.
- Añadir `GroupOrganization` en DataModel y migración inicial.
- Añadir `HelixEntities.xml` de ejemplo y documentar cómo ejecutar el Helix Generator.
- Pipeline CI básico (.NET build + test).

## ENTREGABLES
- `Helix6.Back.sln` con proyectos listados.
- `Helix6.Back.Api` ejecutable en `dotnet run`.
- `HelixEntities.xml` y pasos para Helix Generator.
- Ejemplo de migración EF Core `InitialCreate`.
- `README.md` con instrucciones de desarrollo.

## PRUEBAS
- `dotnet build` y `dotnet test` deben pasar.
- `dotnet ef database update` ejecutable con connection string de desarrollo.

## CRITERIOS DE ACEPTACIÓN
- [ ] Repositorio contiene la solución y proyectos.
- [ ] Readme con pasos reproducibles añadido.
- [ ] Pipeline CI definido (.yml) para build/test.

```
