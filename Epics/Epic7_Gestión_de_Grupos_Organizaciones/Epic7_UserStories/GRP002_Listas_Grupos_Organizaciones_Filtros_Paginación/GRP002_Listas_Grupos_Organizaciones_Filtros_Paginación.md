```markdown
#### GRP002 - Listas Grupos Organizaciones (Filtros y Paginación)

**ID:** GRP002_Listas_Grupos_Organizaciones_Filtros_Paginación
**EPIC:** Gestión de Grupos de Organizaciones (Epic7)

**RESUMEN:** Implementar el listado paginado y filtrable de grupos de organizaciones con soporte Kendo-like (filtros, orden, paginación). Interfaz simple para buscar y navegar grupos.

## OBJETIVOS
- Implementar endpoint `GetAllKendoFilter` para `GroupOrganization`.
- Implementar componente `group-organization-list` con `ClGrid` que soporte filtros por `Name`, `Key`, `Active` y orden/ paginación server-side.

## ACEPTACIÓN
- [ ] Listado con paginación y filtros server-side implementado y consumido por `group-organization-list`.
- [ ] Contrato NSwag documentado para `GroupOrganizationClient.GetAllKendoFilter`.

## CONTRATO / ENDPOINTS
- `POST /api/GroupOrganization/GetAllKendoFilter` — body `{ Filter, Sort, Page, PageSize }` → `FilterResult<GroupOrganizationView>`
- `GET /api/GroupOrganization/GetById?id={id}` — para detalle.

## NOTAS TÉCNICAS
- Implementar `IGroupOrganizationRepository.GetAllKendoFilter(IGenericFilter)` usando Dapper o EF según volumen.
- Asegurar índices en DB para `Name` y `Key` si se espera gran número de grupos.

## TESTS RECOMENDADOS
- Unit: repositorio devuelve `FilterResult` correcto con filtros combinados.
- Integration: endpoint `GetAllKendoFilter` con datos de prueba.

## CRITERIOS DE ACEPTACIÓN
- [ ] Endpoint y UI list funcionando con filtros y paginación.
- [ ] Tests básicos de servicio/back-end añadidos.

```
