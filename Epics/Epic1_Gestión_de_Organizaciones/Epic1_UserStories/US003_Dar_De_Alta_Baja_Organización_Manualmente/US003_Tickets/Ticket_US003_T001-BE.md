#### TASK-003-BE: Implementar baja/alta manual de organización (DeleteUndelete Helix6)

=============================================================
**TICKET ID:** TASK-003-BE  
**EPIC:** Gestión del Portfolio de Organizaciones Clientes  
**USER STORY:** US-003 - Dar de alta / baja organización manualmente  
**COMPONENT:** Backend - Api/Services (Helix6)  
**PRIORITY:** Alta  
**ESTIMATION:** 6 horas  
=============================================================

## TÍTULO
Garantizar que el endpoint genérico Helix6 `DeleteUndeleteLogicById` esté disponible para la entidad `Organization` y registre auditoría cuando se realice una baja (soft-delete) o una alta (restore) manual.

## DESCRIPCIÓN
El frontend invocará directamente el endpoint generado por Helix6 `DeleteUndeleteLogicById` para alternar el estado de `AuditDeletionDate` de una organización. El backend debe:


## CRITERIOS TÉCNICOS
 - Endpoint genérico Helix6 esperado:
  - `DELETE /api/Organization/DeleteUndeleteLogicById?id=123` — la operación realizará soft-delete si la organización está activa, o restore si ya está soft-deleted, según la lógica interna de Helix6.
  - Opcional: `configurationName` como query param: `DELETE /api/Organization/DeleteUndeleteLogicById?id=123&delete=true&configurationName=OrganizationFull`.
- Obtener `UserId` desde `IUserContext` y `CorrelationId` desde cabeceras.
- Reutilizar `EndpointHelper` / `BaseService` y el método `DeleteUndeleteLogicById(int id, bool delete, string? configurationName = null)` del servicio.
- Registrar auditoría vía `IAuditLogService.LogAsync(AuditEntry)` dentro de `PostActions` o inmediatamente después de la operación.

## PRUEBAS REQUERIDAS
- Unit tests:
  - Verificar que la llamada delega en `DeleteUndeleteLogicById` y que se invoca `IAuditLogService.LogAsync` con la acción correcta según el flag `delete`.
  - Verificar 403 cuando el actor no tiene permisos.
- Integration tests:
    - Llamada: `DELETE /api/Organization/DeleteUndeleteLogicById?id=123` cuando la organización esté activa -> `AuditDeletionDate` poblada y `AUDIT_LOG` con `OrganizationDeactivatedManual`.
    - Llamada: `DELETE /api/Organization/DeleteUndeleteLogicById?id=123` cuando la organización ya esté soft-deleted -> `AuditDeletionDate` a null y `AUDIT_LOG` con `OrganizationReactivatedManual`.

## EJEMPLOS / CONTRATO
DELETE /api/Organization/DeleteUndeleteLogicById?id=123
Headers:
- `Authorization: Bearer <token>`
- `X-Correlation-Id: <uuid>` (opcional)

Ejemplo (baja/restauración automática por estado):
```
DELETE /api/Organization/DeleteUndeleteLogicById?id=123
```

Ejemplo con `configurationName` opcional:
```
DELETE /api/Organization/DeleteUndeleteLogicById?id=123&configurationName=OrganizationFull
```

Response: `200 OK` o error con `ProblemDetails`.

## DEFINITION OF DONE
- Endpoint genérico disponible y documentado para frontend.
- Auditoría registrada para ambas acciones con `UserId`.
- Permisos verificados y tests implementados.
