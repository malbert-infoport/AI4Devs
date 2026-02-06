#### GRP001 - Gestión Grupo Organización

**ID:** GRP001_Gestión_Grupo_Organización
**EPIC:** Gestión de Grupos de Organizaciones (Epic7)

**RESUMEN:** Formulario sencillo para gestionar grupos de organizaciones. Un `GroupOrganization` contiene campos básicos: `Id`, `Name`, `Key`, `Description`, `Active`. En la vista detalle del grupo se mostrará, en modo solo lectura, un `ClGrid` con las organizaciones que pertenecen al grupo.

## OBJETIVOS
- Implementar el formulario CRUD mínimo para `GroupOrganization` en frontend.
- En el detalle, mostrar la lista de `Organizations` pertenecientes al grupo en modo solo lectura (no editar desde el grupo).
- Documentar contrato backend mínimo para soporte FE.

## ACEPTACIÓN
- [ ] Existe componente `group-organization-form` standalone que permite crear y editar campos básicos.
- [ ] La pestaña `Organizaciones` en el detalle muestra un `ClGrid` readonly con las organizaciones vinculadas.
- [ ] Se documentaron los endpoints necesarios y el uso de `configurationName=GroupOrganizationComplete` para la carga con la lista de organizaciones en read-only.

## CONTRATO / ENDPOINTS (RECOMENDADO)
- `GET /api/GroupOrganization/GetById?id={id}&configurationName=GroupOrganizationComplete` → `GroupOrganizationView` (incluye `Organizations` readonly: minimal fields `Id, Name, Cid/CompanyId`).
- `POST /api/GroupOrganization/Insert` → crea grupo y retorna la vista.
- `PUT /api/GroupOrganization/Update` → actualiza grupo y retorna la vista.
- `DELETE /api/GroupOrganization/DeleteById?id={id}` → elimina grupo (backend decide soft/physical); ver GRP003 para comportamiento físico.

## UX / FLUJO
- En listado (`group-organization-list`) mostrar columnas: `Name`, `Key`, `Description`, `Active`, `OrganizationsCount`.
- En detalle (`group-organization-form`): pestañas: `Datos` (editable) y `Organizaciones` (readonly `ClGrid`).
- En creación: `Organizaciones` aparece vacío y no es editable hasta guardar el grupo.

## NOTAS TÉCNICAS
- Usar `inject()` para dependencias en componentes standalone: `GroupOrganizationClient`, `ClGridService`, `ClModalService`, `AccessService`, `CorrelationService`.
- Llamadas mutantes deben incluir header `X-Correlation-Id`.
- Cargar organizaciones embebidas vía `GroupOrganizationClient.getById(id,'GroupOrganizationComplete')` para evitar llamadas adicionales.

## TESTS RECOMENDADOS
- Unit: visibilidad de pestañas según permisos, `getById` llamado con `GroupOrganizationComplete`, `ClGrid` muestra items en modo readonly.
- E2E (opcional): crear grupo y verificar listado de organizaciones en detalle.

## CRITERIOS DE ACEPTACIÓN
- [ ] `group-organization-form` implementado y exportado en rutas.
- [ ] Pestaña `Organizaciones` muestra `ClGrid` readonly con datos correctos.
- [ ] Tests unitarios añadidos.
