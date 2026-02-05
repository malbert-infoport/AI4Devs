```markdown
# APL002-T001-BE: Backend — Soporte avanzado de filtros y configuraciones para Application

**TICKET ID:** APL002-T001-BE
**EPIC:** Administración de Aplicaciones
**COMPONENT:** Backend - Helix6 (.NET 8)
**PRIORITY:** Alta
**ESTIMATION:** 2 días

## OBJETIVO
Extender el soporte backend para filtros avanzados y configuraciones de carga (`ApplicationBasic`, `ApplicationComplete`) garantizando performance y compatibilidad con `GetAllKendoFilter`.

## ALCANCE
- Revisar `HelixEntities.xml` y asegurar `Application` tenga `GetAllKendoFilter` habilitado.
- Añadir mappings necesarios en `HelixFilterMapping` si hay campos complejos.
- Tests para filtros por `Owner`, `Active`, `CreatedAt` y búsquedas textuales.

## CONTRATO / ENDPOINTS
- POST `/api/Application/GetAllKendoFilter` (igual que APL001) con ejemplos de filtros complejos (nested, ranges).

## IMPLEMENTACIÓN
- `IApplicationRepository` debe soportar ejecución de filtros complejos con Dapper/EF según caso.
- Añadir helpers en `HelixFilterMapping` para propiedades anidadas (p.ej. `Owner.Name`).

## MIGRACIONES / COMANDOS
- No previstas migraciones estructurales; si añade índices, crear migración equivalente.

## TESTS
- Unit tests en `Helix6.Back.Services.Tests` que validen combinaciones de filtros y paging.

## CRITERIOS DE ACEPTACIÓN
- [ ] Filtros complejos devuelven resultados correctos y eficientes.
- [ ] Configuración `ApplicationComplete` incluye campos relacionados requeridos.

***
```
