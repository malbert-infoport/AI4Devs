```markdown
#### GRP003 - Eliminar Físicamente un Grupo de Organizaciones

**ID:** GRP003_Eliminar_Fisicamente
**EPIC:** Gestión de Grupos de Organizaciones (Epic7)

**RESUMEN:** Eliminar físicamente un grupo. Al eliminarse, las organizaciones vinculadas tendrán su `GroupId` anulado (se establece a `NULL`). El endpoint usado será `DeleteById`.

## OBJETIVOS
- Implementar endpoint y lógica que borre el grupo y actualice las organizaciones relacionadas para anular la asociación de forma transaccional.
- Garantizar que la operación queda registrada en auditoría (`AUDIT_LOG`) y que es idempotente cuando sea posible.

## ACEPTACIÓN
- [ ] Al ejecutar `DeleteById` sobre un grupo, el grupo se elimina físicamente y las organizaciones que tenían `GroupId` pasan a `NULL`.
- [ ] Operación ejecutada dentro de una transacción y con registro en `AUDIT_LOG` con `CorrelationId`.

## CONTRATO / ENDPOINTS
- `DELETE /api/GroupOrganization/DeleteById?id={id}` — elimina el grupo y limpia `Organization.GroupId` para las organizaciones relacionadas.

## NOTAS TÉCNICAS
- Implementar la lógica en `GroupOrganizationService.PreviousActions` o en un método transaccional del repositorio:
	- Leer `Organization` rows con `GroupId = id` y aplicar `UPDATE Organization SET GroupId = NULL`.
	- Eliminar el registro de `GroupOrganization` (o marca soft-delete si política lo requiere).
	- Publicar entrada en `AUDIT_LOG` con `EntityType='GroupOrganization'`, `ActionType='Delete'`, `CorrelationId`.
- Asegurar que el endpoint es seguro y requiere permiso `GroupOrganization data modification`.

## CRITERIOS DE ACEPTACIÓN
- [ ] End-to-end verified: group deleted and organizations updated.
- [ ] Auditoría creada y tests unitarios/integración añadidos.

```
