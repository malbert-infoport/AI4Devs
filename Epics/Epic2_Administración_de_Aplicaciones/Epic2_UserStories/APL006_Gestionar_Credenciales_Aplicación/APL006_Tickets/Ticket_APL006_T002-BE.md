```markdown
```markdown
# APL006-T002-BE: Backend — Gestionar ApplicationCredentials (client credentials)

**TICKET ID:** APL006-T002-BE
**EPIC:** Administración de Aplicaciones
**COMPONENT:** Backend - Helix6 (.NET 8)
**PRIORITY:** Alta
**ESTIMATION:** 2 días

## OBJETIVO
Implementar API y servicios que permitan crear (generar secret), rotar y eliminar credenciales de tipo client credentials, garantizando que `clientSecret` se devuelve solo una vez y que existe auditoría de rotaciones.

## ALCANCE
- Endpoints: `Create`, `Rotate`, `DeleteById`, `GetAllByApplicationId`.
- Backend debe generar `clientSecret` seguro y devolverlo únicamente en la respuesta de `Create` y `Rotate`.
- Registrar auditoría (CreatedBy, CreatedAt, RotatedBy, RotatedAt).

Importante (configuración de carga completa): cuando el cliente solicite la configuración de carga `ApplicationComplete` a través de `GET /api/Application/GetById?id={id}&configuration=ApplicationComplete`, la respuesta debe incluir las `Credentials` de la aplicación junto a `Modules` y `Roles`. Asimismo, las operaciones de inserción/actualización que usen el `ApplicationView` completo deben permitir crear/rotar/eliminar credenciales como parte de la transacción gestionada por `ApplicationService`.

## DATAMODEL SUGERIDO
Si no existe `ApplicationCredential`:

```csharp
[Table("ApplicationCredentials", Schema = "dbo")]
public class ApplicationCredential : IEntityBase
{
    [Key]
    public int Id { get; set; }
    public int ApplicationId { get; set; }
    public string ClientId { get; set; } = string.Empty;
    // clientSecret NEVER stored in plain text; store hash or encrypted value if required
    public DateTime AuditCreationDate { get; set; }
    public int AuditCreationUser { get; set; }
    public DateTime? LastRotationDate { get; set; }
    public int? LastRotationUser { get; set; }
    public DateTime? AuditDeletionDate { get; set; }
}
```

## REPOSITORIO
- `IApplicationCredentialRepository : IBaseRepository<ApplicationCredential>` con `GetAllByApplicationId` y helpers para revocación/rotación.

## SERVICE — `ApplicationCredentialService`
- `Insert`: generate secure `clientId` + `clientSecret` (use RNG + length), persist metadata (never store plain secret; if required store encrypted or store one-way hash) and return `clientSecret` in response only.
- `Rotate`: similar to `Insert` but update `LastRotation*` fields and publish `CredentialRotated` event.
- `DeleteById`: soft delete with `AuditDeletionDate` and event `CredentialDeleted`.

Ejemplo de creación:

```csharp
public override async Task<ApplicationCredentialView?> Insert(ApplicationCredentialView view, string? configurationName = null)
{
    var secret = _secretGenerator.Generate();
    view.ClientId = GenerateClientId();
    // store encrypted secret or hash
    await base.Insert(view, configurationName);
    // return view with secret in a separate response DTO
}
```

## ENDPOINTS / CONTRATO
- POST `/api/ApplicationCredential/Create` → `{ clientId, clientSecret }` (creación directa de credencial; `clientSecret` devuelto una vez)
- POST `/api/ApplicationCredential/Rotate?id={id}` → `{ clientId, clientSecret }` (rotación directa)
- DELETE `/api/ApplicationCredential/DeleteById?id={id}` (soft delete)
- GET `/api/ApplicationCredential/GetAllByApplicationId?applicationId={id}`
- Nota: Además de los endpoints específicos anteriores, documentar y soportar el uso de `GET /api/Application/GetById?id={id}&configuration=ApplicationComplete` que devuelve `Application` con `Credentials`. Para insertar/actualizar la `ApplicationView` completa (incluyendo `Credentials`) usar los endpoints generados `POST /api/Application/Insert` y `POST /api/Application/Update` como operación única/atómica gestionada por `ApplicationService`.

## MIGRACIONES / COMANDOS
```powershell
dotnet ef migrations add AddApplicationCredential --project Helix6.Back.Data --startup-project Helix6.Back.Api
dotnet ef database update --project Helix6.Back.Data --startup-project Helix6.Back.Api
```

## TESTS
- Services.Tests: create returns secret, rotate returns new secret, delete marks soft-deleted.
- Data.Tests: repository retrieval and rotation metadata.

## CRITERIOS DE ACEPTACIÓN
- [ ] Endpoints create/rotate/delete/getAll implementados.
- [ ] `clientSecret` returned only in create/rotate responses; not persisted in plain text.
- [ ] Auditoría de rotaciones disponible.

## NOTAS DE SEGURIDAD
- Evitar almacenar secret en logs; cifrar en DB o almacenar derivado seguro.
- Coordinar con equipos de seguridad para políticas de retención/rotación.

```
```
