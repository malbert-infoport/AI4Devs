#### ORG003-T002-BE: Implementar baja/alta manual de organización (DeleteUndelete Helix6)

=============================================================

**TICKET ID:** ORG003-T002-BE  
**EPIC:** Gestión del Portfolio de Organizaciones Clientes  
**USER STORY:** US-003 - Dar de alta / baja organización manualmente  
**COMPONENT:** Backend - Api/Services (Helix6)  
**PRIORITY:** Alta  
**ESTIMATION:** 6 horas  

=============================================================

## TÍTULO
Garantizar que el endpoint genérico Helix6 `DeleteUndeleteLogicById` esté disponible para la entidad `Organization` y registre auditoría cuando se realice una baja (soft-delete) o una alta (restore) manual.

## DESCRIPCIÓN
El frontend utilizará `DELETE /api/Organization/DeleteUndeleteLogicById` para alternar el estado lógico (`AuditDeletionDate`) de una organización. El backend debe:

- Exponer o reutilizar el endpoint genérico Helix6 `DeleteUndeleteLogicById` para `Organization`.
- Validar permisos (`Organization data modification` = 200) usando `IUserPermissions`/`IUserContext`.
- Actualizar `AuditDeletionDate` (soft-delete) o restaurarlo (set null) según el flag `delete` o el estado actual.
- Registrar entrada en `AUDITLOG` con `Action` = `OrganizationDeactivatedManual` o `OrganizationReactivatedManual` incluyendo `UserId` y `CorrelationId`.
- Publicar `OrganizationEvent` (State Transfer Event) cuando proceda.
- Reutilizar `BaseService`/`EndpointHelper` y ejecutar hooks `ValidateView`/`PreviousActions`/`PostActions` según convenga.

## CRITERIOS TÉCNICOS
- Endpoint genérico Helix6 esperado:
  - `DELETE /api/Organization/DeleteUndeleteLogicById?id=123` — realiza soft-delete si la organización está activa; restaura si ya está soft-deleted.
  - Opcional: `configurationName` y `delete` como query params: `DELETE /api/Organization/DeleteUndeleteLogicById?id=123&delete=true&configurationName=OrganizationFull`.
- Autorizar: requerir permiso `Organization data modification` (200). Responder `403` si no autorizado.
- Si no existe la entidad, responder `404 Not Found`.
- Obtener `UserId` desde `IUserContext` y `CorrelationId` desde headers (`X-Correlation-Id`) o `ApplicationContext`.
- Registrar auditoría usando `IAuditLogService.LogAsync(AuditEntry)` con los campos: `Action`, `EntityType`, `EntityId`, `UserId`, `TimestampUtc`, `CorrelationId`, `ExtraData`.
- Publicar evento `OrganizationEvent` si la operación cambia estado (activar/desactivar), usando el publisher o service de eventos del proyecto.

## PRUEBAS REQUERIDAS
- Unit tests:
  - `OrganizationServiceTests.DeleteUndelete_LogsAuditAndPublishesEvent_WhenAuthorized`: mockear `IOrganizationRepository`, `IAuditLogService`, `IEventPublisher` y `IUserContext`.
  - `OrganizationServiceTests.DeleteUndelete_ThrowsForbidden_WhenNoPermission`: mockear `IUserPermissions.HasPermission` para devolver false.
- Integration tests:
  - `OrganizationEndpointsTests.DeleteUndelete_DeactivatesAndLogs`: con DB de pruebas, cuando la entidad está activa -> `AuditDeletionDate` poblada y `AUDITLOG` con `OrganizationDeactivatedManual`.
  - `OrganizationEndpointsTests.DeleteUndelete_ReactivatesAndLogs`: cuando la entidad está soft-deleted -> `AuditDeletionDate` a null y `AUDITLOG` con `OrganizationReactivatedManual`.

## EJEMPLOS / CONTRATO
Request:
```
DELETE /api/Organization/DeleteUndeleteLogicById?id=123
Headers:
- Authorization: Bearer <token>
- X-Correlation-Id: <uuid> (opcional)
```

Opcional con flags:
```
DELETE /api/Organization/DeleteUndeleteLogicById?id=123&delete=true&configurationName=OrganizationFull
```

Response esperado (200):
```json
{
  "success": true,
  "message": "Organization deactivated",
  "id": 123
}
```

Errores: `403 Forbidden`, `404 Not Found`, `400 Bad Request` con `ProblemDetails` según Helix6.

## DEFINITION OF DONE
- Endpoint disponible y documentado en API (Swagger/OpenAPI).
- Auditoría registrada en `AUDITLOG` con `UserId` y `CorrelationId` para ambas acciones.
- Permisos verificados (403 cuando proceda).
- Unit tests y al menos 1 integration test añadidos y ejecutando en CI/local.
- Publicación de `OrganizationEvent` implementada o documentada si la infra no está disponible en pruebas.

## SUGERENCIA DE IMPLEMENTACIÓN (C# snippets)

1) `PostActions` en `OrganizationService` para auditar y publicar evento:

```csharp
public override async Task PostActions(OrganizationView? view, EnumActionType actionType, string? configurationName = null)
{
    if (view == null) return;

    if (actionType == EnumActionType.DeleteUndeleteLogic)
    {
        var action = view.AuditDeletionDate == null ? "OrganizationReactivatedManual" : "OrganizationDeactivatedManual";

        var auditEntry = new AuditEntry
        {
            Action = action,
            EntityType = "Organization",
            EntityId = view.Id,
            UserId = _userContext.UserId,
            TimestampUtc = DateTime.UtcNow,
            CorrelationId = _applicationContext.CorrelationId
        };

        await _auditLogService.LogAsync(auditEntry);

        // Publicar evento (si procede)
        await _eventPublisher.PublishAsync(new OrganizationEvent { Id = view.Id, Action = action });
    }

    await base.PostActions(view, actionType, configurationName);
}
```

2) Método público si `BaseService` no expone `DeleteUndeleteLogicById` directamente:

```csharp
public async Task<bool> DeleteUndeleteLogicById(int id, bool? delete = null, string? configurationName = null)
{
    if (!await _userPermissions.HasPermission("Organization", SecurityLevel.Modify))
        throw new HelixForbiddenException();

    var entity = await Repository.GetById(id, "OrganizationBasic");
    if (entity == null) throw new HelixNotFoundException();

    var doDelete = delete ?? (entity.AuditDeletionDate == null);
    entity.AuditDeletionDate = doDelete ? DateTime.UtcNow : (DateTime?)null;
    await Repository.Update(entity);

    var view = MapEntityToView(entity);
    await PostActions(view, EnumActionType.DeleteUndeleteLogic, configurationName);

    return true;
}
```

3) Unit test example (xUnit + Moq):

```csharp
[Fact]
public async Task DeleteUndelete_LogsAudit_WhenAuthorized()
{
    // Arrange: mocks for IUserContext.UserId, repository returns entity active, auditLogService and eventPublisher mocked
    // Act: await service.DeleteUndeleteLogicById(id, true)
    // Assert: Verify auditLogService.LogAsync called with Action = OrganizationDeactivatedManual
}
```

## PR / DEPLOY
- Crear rama `feature/ORG003-delete-undelete-organization`.
- Añadir tests y ejecutar:

```powershell
dotnet test Helix6.Back.Services.Tests
dotnet test Helix6.Back.Data.Tests
```

- Si no hay cambios de esquema no es necesario migración; si se altera esquema añadir migración:

```powershell
dotnet ef migrations add Org_DeleteUndelete --project Helix6.Back.Data --startup-project Helix6.Back.Api
dotnet ef database update --project Helix6.Back.Data --startup-project Helix6.Back.Api
```

- Abrir PR con descripción, lista de cambios, resultados de tests y notas sobre event publishing.
