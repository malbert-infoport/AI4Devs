```markdown
# TASK-US003-BE: Implementar endpoint GetAllKendoFilter para Organizations (Helix6)

=============================================================
**TICKET ID:** TASK-US003-BE 
**EPIC:** Gestión del Portfolio de Organizaciones Clientes  
**USER STORY:** US-004 - Listar organizaciones con filtros  
**COMPONENT:** Backend - Services / API (Helix6)  
**PRIORITY:** Alta  
**ESTIMATION:** 6 horas  
=============================================================

## TÍTULO
Implementar en backend el endpoint que soporte la consulta de listing con `GetAllKendoFilter` siguiendo las convenciones de Helix6 y devolviendo el formato esperado por el frontend (`{ data, total }`).

## DESCRIPCIÓN
Crear/actualizar el `OrganizationService` y el endpoint correspondiente para exponer la consulta server-side usada por el grid Kendo. Debe aprovechar las utilidades de Helix6 (EndpointHelper / BaseService) y el método `GetAllKendoFilter` para soportar paginación, filtrado y ordenación eficientes.

## CRITERIOS TÉCNICOS
- El endpoint debe recibir parámetros de Kendo/OData (skip/top/filter/order) y devolver `{ data: OrganizationListItem[], total: number }`.
- Reusar/implementar `GetAllKendoFilter` en `OrganizationService` o `BaseService` según patrón Helix6.
- Consumir la vista `VW_ORGANIZATION` (o vista equivalente) para incluir `ModuleCount` y `AppCount` en la respuesta.
- Filtrado soportado: estado (AuditDeletionDate null/not-null), búsqueda por nombre/CIF, filtro por `GroupId`.
- Paginación server-side con `pageSize` por defecto 20 y configurable desde request.
- Respetar seguridad/`EndpointAccess` (SecurityLevel.Read) y permisos mediante `IUserPermissions`.
- Tests unitarios: mockear repositorio/servicio y validar que se traducen filtros y se lanza la consulta correcta.
- Tests de integración: ejecutar consulta contra DB de pruebas que use la vista `VW_ORGANIZATION` y validar `total` y `data`.

## IMPLEMENTACIÓN / NOTAS
- Modificar/crear en `Services/OrganizationService` un método público `GetAllKendoFilter(IGenericFilter filter)` que reentregue `FilterResult<OrganizationView>` tal y como espera Helix6.
- Registrar endpoint usando `EndpointHelper.GenerateGetAllKendoFilter` (o la convención de endpoints generados) en el proyecto `Api` para exponer `/api/Organization/GetAllKendoFilter`.
- Mapear columnas `ModuleCount` y `AppCount` desde la vista `VW_ORGANIZATION` en la consulta (usar Dapper o EF Core projection según conveniencia y rendimiento).
- Añadir tests en `Services.Tests` y `Data.Tests` (integration) que cubran: filtros combinados, ordenación y paginación.
- Documentar el contrato en el ticket FE (`Ticket_US004_T001-FE.md`) para asegurar que la forma de los parámetros y la respuesta coinciden.

## RIESGOS / CONSIDERACIONES
- Si la vista `VW_ORGANIZATION` no existe o tiene distinto nombre, coordinar con DBA/TASK-001-VIEW para usar la vista correcta.
- Asegurar índices sobre campos usados en filtros (AuditDeletionDate, EntityId, GroupId) para rendimiento.

```
