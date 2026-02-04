# ORG002-T002-BE: Endpoint GetAllKendoFilter para Organizations (Helix6)

=============================================================

**TICKET ID:** ORG002-T002-BE
**EPIC:** Gestión del Portfolio de Organizaciones Clientes
**USER STORY:** ORG-002 - Listar organizaciones con filtros
**COMPONENT:** Backend - Services / API (Helix6)
**PRIORITY:** Alta
**ESTIMATION:** 6 horas

=============================================================

## TÍTULO
Implementar el endpoint `GetAllKendoFilter` para `Organization` compatible con Kendo/ClGrid (server-side paging/filter/sort).

## OBJETIVO
Exponer un endpoint seguro y eficiente que devuelva listados paginados de organizaciones con `AppCount` y `ModuleCount`, respetando los contratos Helix6 y las reglas de permisos.

## DESCRIPCIÓN (resumida)
- Añadir/ajustar en `OrganizationService` la operación `GetAllKendoFilter(IGenericFilter filter)` reutilizando la infraestructura de `BaseService`/`EndpointHelper`.
- Registrar el endpoint en la API: `/api/Organization/GetAllKendoFilter` (método `PUT` o `POST` según convención del proyecto).
- La fuente de datos debe ser la vista `VW_ORGANIZATION` (o equivalente) para incluir las columnas calculadas `AppCount` y `ModuleCount`.

## ALCANCE
- Soportar filtros: estado (active/soft-deleted), búsqueda por `Name`/`TaxId`, filtro por `GroupId`.
- Paginación server-side con `pageSize` por defecto 20 (configurable desde request).
- Ordenación y agrupación según `KendoFilter`.
- Responder `{ data: OrganizationView[], total: int }` o el `FilterResult<TView>` que usa Helix6.
- Autorización: validar `Organization data query` (permiso 201) mediante `IUserPermissions`.

## CRITERIOS DE ACEPTACIÓN
- [ ] Endpoint expuesto en `/api/Organization/GetAllKendoFilter` y protegido por permisos.
- [ ] Respuesta contiene `AppCount` y `ModuleCount` para cada item.
- [ ] Filtros combinados (estado + búsqueda + group) devuelven `data` y `total` correctos.
- [ ] Paginación y ordenación compatibles con `KendoFilter`.
- [ ] Unit tests cubren la traducción de `IGenericFilter` a la consulta y el manejo de permisos.
- [ ] Integration test contra DB de pruebas valida `total` y resultados usando `VW_ORGANIZATION`.

## IMPLEMENTACIÓN (pasos sugeridos)
1. Añadir/actualizar en `Helix6.Back.Services` el método público:
	- `Task<FilterResult<OrganizationView>> GetAllKendoFilter(IGenericFilter filter, string? configurationName = null)`
	- Internamente reusar `GetAllKendoFilter` de `BaseService` o delegar a `IBaseRepository.GetAllFilter` según conveniencia.
2. En `Data` o `Repository` crear proyección que consulte `VW_ORGANIZATION` (Dapper o EF projection) para aportar `AppCount`/`ModuleCount` eficientemente.
3. Registrar endpoint en `Api/Endpoints` usando `EndpointHelper` o generarlo en `HelixEntities.xml` y ejecutar `HelixGenerator` si procede.
4. Implementar verificación de permisos con `IUserPermissions.HasPermission(entityName, SecurityLevel.Read)`.
5. Crear unit tests en `Helix6.Back.Services.Tests` (moq repo/usercontext) para validar filtros y permisos.
6. Crear un integration test en `Helix6.Back.Data.Tests` que consulte la vista `VW_ORGANIZATION` y verifique paginado y totals.

## CONSIDERACIONES TÉCNICAS
- Si la vista `VW_ORGANIZATION` no está disponible, coordinar con DBA para crearla o usar una consulta proyectada que calcule `AppCount`/`ModuleCount`.
- Preferir Dapper para la proyección si la consulta es intensiva en lecturas y requiere optimización.
- Añadir índices en columnas usadas por filtros (AuditDeletionDate, GroupId, TaxId/Name) para rendimiento.

## RIESGOS
- Cambios en el esquema de la vista `VW_ORGANIZATION` pueden romper la proyección: definir contrato claro con DBA.
- Carga inesperada en la BD si no se aplican filtros/limit correctamente: asegurar límites/telemetría.

## TESTS
- Unit: traducción de `IGenericFilter` a consulta, respeto de permisos, comportamiento ante filtros vacíos.
- Integration: dataset de prueba con organizaciones activas/inactivas y módulos/apps para validar `total` y `data`.

## ENTREGABLES
- Código: `OrganizationService.GetAllKendoFilter`, repository/projection Dapper/EF, endpoint registration.
- Tests unitarios e integration.
- Documentación breve del contrato de API para frontend (parámetros/ejemplo respuesta).

=============================================================
