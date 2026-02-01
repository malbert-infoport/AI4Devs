=============================================================
**TICKET ID:** TASK-012-NOTE  
**EPIC:** Administración de Aplicaciones del Ecosistema  
**USER STORY:** US-012 - Agregar credencial adicional a aplicación  
**COMPONENT:** Backend - Nota Arquitectónica  
**PRIORITY:** Media  
**ESTIMATION:** 0 horas (Solo documentación)  
=============================================================

**TÍTULO:**
Documentar que las credenciales adicionales ya están soportadas

**DESCRIPCIÓN:**
Este ticket documenta que **US-012 ya está implementada**. El diseño de la relación 1:N entre Application y ApplicationSecurity permite agregar múltiples credenciales a una aplicación sin restricciones de código.

**Funcionalidad ya implementada:**
- ✅ Relación 1:N: `Application.Credentials` es una colección de `ApplicationSecurity`
- ✅ Una aplicación puede tener múltiples credenciales simultáneamente
- ✅ Cada credencial tiene su propio `client_id` único
- ✅ Validación: NO permite duplicar credenciales del **mismo tipo** para la **misma aplicación**
- ✅ Pero SÍ permite tener UNA credencial CODE y UNA ClientCredentials para la misma app
- ✅ Ambas credenciales se registran en Keycloak correctamente

**Evidencia de implementación:**

En `Application.cs`:
```csharp
/// <summary>
/// Colección de credenciales OAuth2 para esta aplicación
/// Una aplicación puede tener múltiples credenciales (frontend CODE + backend ClientCredentials)
/// </summary>
public virtual ICollection<ApplicationSecurity> Credentials { get; set; }
```

En `ApplicationSecurityService.cs` (validación que previene duplicados del mismo tipo):
```csharp
// Validación: No permitir crear credencial del mismo tipo para la misma aplicación
var sameTypeExists = await Repository.ExistsAsync(
    s => s.ApplicationId == view.ApplicationId 
         && s.CredentialType == view.CredentialType 
         && s.Id != view.Id 
         && s.AuditDeletionDate == null,
    cancellationToken);

if (sameTypeExists)
{
    AddError($"Ya existe una credencial de tipo {view.CredentialType} para esta aplicación");
    return false;
}
```

**Ejemplo de uso:**
1. Crear Application "CRM" con ID 1
2. Crear ApplicationSecurity CODE para Application ID 1 → `crm-frontend`
3. Crear ApplicationSecurity ClientCredentials para Application ID 1 → `crm-api`
4. Resultado: CRM tiene 2 credenciales activas simultáneamente

**Comportamiento actual:**
- ✅ Permitido: 1 credencial CODE + 1 credencial ClientCredentials por aplicación
- ❌ Rechazado: 2 credenciales CODE para la misma aplicación
- ❌ Rechazado: 2 credenciales ClientCredentials para la misma aplicación

**NOTA IMPORTANTE:**
Si en el futuro se necesita permitir MÚLTIPLES credenciales del mismo tipo (ej: 2 clients CODE con diferentes RedirectURIs), simplemente eliminar la validación `sameTypeExists` de `ApplicationSecurityService.cs`.

**ARCHIVOS RELEVANTES:**
- `InfoportOneAdmon.DataModel/Entities/Application.cs` - Relación 1:N
- `InfoportOneAdmon.Services/Services/ApplicationSecurityService.cs` - Validación
