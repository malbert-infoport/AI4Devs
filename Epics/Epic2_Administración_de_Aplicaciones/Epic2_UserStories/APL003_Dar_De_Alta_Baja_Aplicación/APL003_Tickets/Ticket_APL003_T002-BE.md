```markdown
```markdown
# APL003-T002-BE: Backend — Alta/Baja lógica de Aplicación (soft-delete / undelete)

**TICKET ID:** APL003-T002-BE
**EPIC:** Administración de Aplicaciones
**COMPONENT:** Backend - Helix6 (.NET 8)
**PRIORITY:** Alta
**ESTIMATION:** 1.5 días

## OBJETIVO
Garantizar la correcta implementación de la lógica de baja/alta (soft delete) para `Application`: endpoint genérico `DeleteUndeleteLogicById`, auditoría y publicación de eventos.

## ALCANCE
- Asegurar que `BaseService` o `ApplicationService` expone `DeleteUndeleteLogicById(int id, string? configurationName = null)` comportándose como toggle según `AuditDeletionDate`.
- Publicar eventos `ApplicationDeactivated` / `ApplicationActivated` con payload mínimo `{ ApplicationId, TriggeredByUserId, CorrelationId }`.
- Tests unitarios para `DeleteUndeleteLogicById` y hooks `PostActions`.

## CONTRATO / ENDPOINTS
- DELETE `/api/Application/DeleteUndeleteLogicById?id={id}` — toggle soft delete; opcional `configurationName`.

## SERVICE — `ApplicationService`
- `PreviousActions`: validar permisos y condiciones (por ejemplo, no permitir desactivación si hay integraciones críticas sin permiso extra).
- `PostActions`: después de cambiar `AuditDeletionDate`, publicar evento y actualizar `AuditModification*`.

Ejemplo de PostActions snippet:

```csharp
if ((view.AuditDeletionDate != null))
    await _eventPublisher.PublishAsync(new ApplicationDeactivatedEvent { ApplicationId = view.Id.Value, UserId = _userContext.UserId });
else
    await _eventPublisher.PublishAsync(new ApplicationActivatedEvent { ApplicationId = view.Id.Value, UserId = _userContext.UserId });
```

## MIGRACIONES / COMANDOS
- No estructurales; revisar índices de auditoría si necesario.

## TESTS
- Unit: `DeleteUndeleteLogicById` sets `AuditDeletionDate` and publishes correct event.

## CRITERIOS DE ACEPTACIÓN
- [ ] Endpoint toggle implementado y probado.
- [ ] Eventos publicados y `AUDITLOG` actualizado.

```
```
