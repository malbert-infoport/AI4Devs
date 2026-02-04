# ORG001-T002-BE: Implementar entidad Organization con CRUD completo en Helix6

=============================================================

**TICKET ID:** ORG001-T002-BE  
**EPIC:** Gestión del Portfolio de Organizaciones Clientes  
**USER STORY:** ORG-001 - Crear y editar organización cliente  
**COMPONENT:** Backend - Helix6 Framework  
**PRIORITY:** Alta  
**ESTIMATION:** 8 horas  

=============================================================

## TÍTULO
Implementar entidad Organization con CRUD completo y control de permisos granular en Helix6

## DESCRIPCIÓN

Crear la infraestructura backend completa para gestionar Organizaciones Clientes siguiendo el patrón Helix6 Framework (.NET 8) con arquitectura en capas (Api → Services → Data → DataModel) y control de permisos granular.

**Entidad Organization** (tabla `ORGANIZATION`):
- **DataModel**: Clase POCO que mapea a tabla de BD con 15 campos (Id, SecurityCompanyId, Name, TaxId, Address, City, PostalCode, Country, ContactEmail, ContactPhone, GroupId + 5 campos audit)
- **Repository**: Implementación de `OrganizationRepository` heredando de `BaseRepository<Organization>` con configuraciones de carga personalizadas
- **Service**: Implementación de `OrganizationService` heredando de `BaseService<OrganizationView, Organization, OrganizationViewMetadata>` con validaciones y hooks personalizados
- **View**: DTO auto-generado `OrganizationView` con metadata personalizado para validaciones

**Configuraciones de Carga**:
1. **OrganizationBasic**: Solo entidad base sin navegaciones (rápida)
2. **OrganizationComplete**: Incluye navegación a OrganizationGroup, colección ApplicationModules (con navegación a ApplicationModule y Application), y colección AuditLogs

**Comportamiento según Permisos**:
- **Organization data modification (permiso 200)**: Puede crear/editar datos básicos (Name, TaxId, Address, etc.) en Pestaña 1
- **Organization modules modification (permiso 202)**: Puede asignar/remover módulos en Pestaña 2, lo cual publica evento OrganizationEvent

**Publicación de Eventos**:
- **NO se publica evento** al guardar datos básicos (Insert/Update de campos Name, TaxId, Address, etc.)
- **SÍ se publica evento `OrganizationEvent`** cuando:
  - Se asigna el primer módulo a la organización (relación en `ORGANIZATION_APPLICATIONMODULE`)
  - Se remueve un módulo
  - Se cambia el `GroupId` de la organización
  - Se activa/desactiva la organización (cambio en `AuditDeletionDate`)

**Auditoría Selectiva**:
- Helix6 proporciona auditoría automática en campos `Audit*` de la entidad (todos los cambios)
- Adicionalmente, se registran 6 acciones críticas en tabla `AUDITLOG`:
  - `ModuleAssigned`: Al asignar módulo en tabla `ORGANIZATION_APPLICATIONMODULE`
  - `ModuleRemoved`: Al remover módulo (soft delete con `AuditDeletionDate`)
  - `OrganizationDeactivatedManual`: Al desactivar organización manualmente
  - `OrganizationAutoDeactivated`: Al desactivar organización por regla automática
  - `OrganizationReactivatedManual`: Al reactivar organización (AuditDeletionDate = null)
  - `GroupChanged`: Al cambiar `GroupId`

**Relaciones**:
- N:1 con `ORGANIZATIONGROUP` (navegación `OrganizationGroup`)
- N:M con `APPLICATIONMODULE` a través de `ORGANIZATION_APPLICATIONMODULE` (colección `ApplicationModules`)
- 1:N con `AUDITLOG` (colección `AuditLogs` filtrada por EntityType='Organization' y EntityId)

**Validaciones de Negocio**:
- Name: Requerido, único (excluyendo soft-deleted), máximo 200 caracteres
- TaxId: Requerido, único (excluyendo soft-deleted), máximo 50 caracteres, formato CIF español
- ContactEmail: Requerido si se proporciona, formato email válido
- GroupId: Debe existir en tabla `ORGANIZATIONGROUP` y estar activo (AuditDeletionDate IS NULL) si se proporciona

**Generación Automática de Identificadores**:
- `Id`: Auto-increment, PK técnica gestionada por Helix6
- `SecurityCompanyId`: Auto-increment, UK de negocio usado en claim `c_ids` del JWT, inmutable después de creación

## ROLES Y PERMISOS

El backend debe implementar control de permisos granular utilizando las interfaces `IUserContext` y `IUserPermissions` proporcionadas por Helix6.

### Permisos del Sistema

Los permisos se gestionan en Keycloak y se reciben en el JWT del usuario. El servicio debe verificarlos antes de ejecutar operaciones.

| Permiso | Código/Valor | Descripción | Operaciones Permitidas |
|---------|--------------|-------------|------------------------|
| `Organization data modification` | 200 | Modificar datos básicos de organización | Insert/Update de campos: Name, TaxId, Address, City, PostalCode, Country, ContactEmail, ContactPhone, GroupId |
| `Organization data query` | 201 | Consultar datos de organización | GetById, GetAll, GetAllKendoFilter con configuración completa |
| `Organization modules modification` | 202 | Modificar módulos asignados | Insert/Update de colección ApplicationModules, crear/eliminar registros en ORGANIZATION_APPLICATIONMODULE |
| `Organization modules query` | 203 | Consultar módulos asignados | GetById/GetAll con configuración que incluye ApplicationModules |

### Matriz de Operaciones por Permiso

| Operación | Permiso Mínimo Requerido | Comportamiento según Permisos |
|-----------|--------------------------|-------------------------------|
| **GetById** | `Organization data query` (201) | Con 201: Retorna datos básicos + grupo. Con 203 adicional: Incluye ApplicationModules. Configuración "OrganizationComplete" requiere 201+203. |
| **GetNewEntity** | `Organization data modification` (200) | Retorna plantilla con valores por defecto para creación |
| **Insert** | `Organization data modification` (200) | Con 200 solo: Persiste datos básicos, ignora ApplicationModules del payload.<br>Con 200+202: Persiste datos básicos Y ApplicationModules, publica evento si se asignan módulos. |
| **Update** | `Organization data modification` (200) o `Organization modules modification` (202) | Con 200 solo: Actualiza datos básicos, ignora cambios en ApplicationModules.<br>Con 202 solo: Actualiza ApplicationModules, ignora datos básicos.<br>Con 200+202: Actualiza ambos. Publica evento solo si cambian módulos o GroupId. |
| **DeleteById** | `Organization data modification` (200) | Soft delete: Establece AuditDeletionDate, publica evento, registra acción en AUDITLOG |
| **GetAllKendoFilter** | `Organization data query` (201) | Retorna lista paginada según filtros. Configuración determina navegaciones cargadas. |

### Lógica de Validación de Permisos en Servicio

El `OrganizationService` debe implementar validación de permisos en los siguientes hooks de Helix6:

#### En ValidateView()

```csharp
public override async Task ValidateView(
    HelixValidationProblem validations,
    OrganizationView? view,
    EnumActionType actionType,
    string? configurationName = null)
{
    if (view == null) return;
    
    // Verificar permiso para datos básicos
    if (actionType == EnumActionType.Insert || actionType == EnumActionType.Update)
    {
        var hasDataModification = await _userPermissions.HasPermission("Organization", SecurityLevel.Modification);
        if (!hasDataModification)
        {
            validations.AddError("No tiene permisos para modificar datos de organizaciones");
        }
    }
    
    // Verificar permiso para módulos
    if (view.ApplicationModules?.Any() == true)
    {
        var hasModulesModification = await _userPermissions.HasPermission("OrganizationModules", SecurityLevel.Modification);
        if (!hasModulesModification)
        {
            validations.AddError("No tiene permisos para modificar módulos de organizaciones");
        }
    }
    
    // Validaciones de negocio
    if (string.IsNullOrWhiteSpace(view.Name))
        validations.AddError("El nombre de la organización es obligatorio");
        
    if (string.IsNullOrWhiteSpace(view.TaxId))
        validations.AddError("El identificador fiscal (TaxId) es obligatorio");
    
    // Validar unicidad de Name (excluyendo soft-deleted)
    var existingByName = await _repository.ExecuteQuery(
        "SELECT COUNT(*) FROM Organization WHERE Name = @Name AND AuditDeletionDate IS NULL AND Id != @Id",
        new { Name = view.Name, Id = view.Id ?? 0 }
    );
    if (existingByName.Any() && existingByName.First() > 0)
        validations.AddError($"Ya existe una organización con el nombre '{view.Name}'");
    
    // Validar unicidad de TaxId
    var existingByTaxId = await _repository.ExecuteQuery(
        "SELECT COUNT(*) FROM Organization WHERE TaxId = @TaxId AND AuditDeletionDate IS NULL AND Id != @Id",
        new { TaxId = view.TaxId, Id = view.Id ?? 0 }
    );
    if (existingByTaxId.Any() && existingByTaxId.First() > 0)
        validations.AddError($"Ya existe una organización con el TaxId '{view.TaxId}'");
    
    // Validar GroupId si se proporciona
    if (view.GroupId.HasValue)
    {
        var groupExists = await _repository.ExecuteQuery(
            "SELECT COUNT(*) FROM OrganizationGroup WHERE Id = @GroupId AND AuditDeletionDate IS NULL",
            new { GroupId = view.GroupId.Value }
        );
        if (!groupExists.Any() || groupExists.First() == 0)
            validations.AddError($"El grupo con Id {view.GroupId} no existe o está inactivo");
    }
    
    await base.ValidateView(validations, view, actionType, configurationName);
}
```

#### En PreviousActions()

```csharp
public override async Task PreviousActions(
    OrganizationView? view,
    EnumActionType actionType,
    string? configurationName = null)
{
    if (view == null) return;
    
    var hasDataModification = await _userPermissions.HasPermission("Organization", SecurityLevel.Modification);
    var hasModulesModification = await _userPermissions.HasPermission("OrganizationModules", SecurityLevel.Modification);
    
    // Filtrar qué partes del payload se procesarán
    if (!hasDataModification)
    {
        // Usuario no puede modificar datos básicos: preservar valores originales
        if (actionType == EnumActionType.Update && view.Id.HasValue)
        {
            var original = await GetById(view.Id.Value);
            if (original != null)
            {
                view.Name = original.Name;
                view.TaxId = original.TaxId;
                view.Address = original.Address;
                view.City = original.City;
                view.PostalCode = original.PostalCode;
                view.Country = original.Country;
                view.ContactEmail = original.ContactEmail;
                view.ContactPhone = original.ContactPhone;
                view.GroupId = original.GroupId;
            }
        }
    }
    
    if (!hasModulesModification)
    {
        // Usuario no puede modificar módulos: ignorar colección ApplicationModules
        view.ApplicationModules = null;
    }
    
    await base.PreviousActions(view, actionType, configurationName);
}
```

#### En PostActions()

```csharp
public override async Task PostActions(
    OrganizationView? view,
    EnumActionType actionType,
    string? configurationName = null)
{
    if (view == null) return;
    
    var shouldPublishEvent = false;
    var auditActions = new List<string>();
    
    // Determinar si se debe publicar evento y qué acciones auditar
    if (actionType == EnumActionType.Update)
    {
        var original = await GetById(view.Id!.Value);
        
        // Detectar cambio de grupo
        if (original?.GroupId != view.GroupId)
        {
            shouldPublishEvent = true;
            auditActions.Add("GroupChanged");
        }
        
        // Detectar cambios en módulos (comparar colecciones)
        var originalModuleIds = original?.ApplicationModules?.Select(m => m.ApplicationModuleId).ToList() ?? new List<int>();
        var newModuleIds = view.ApplicationModules?.Select(m => m.ApplicationModuleId).ToList() ?? new List<int>();
        
        var addedModules = newModuleIds.Except(originalModuleIds).ToList();
        var removedModules = originalModuleIds.Except(newModuleIds).ToList();
        
        if (addedModules.Any())
        {
            shouldPublishEvent = true;
            foreach (var moduleId in addedModules)
            {
                await RegisterAuditAction(view.Id!.Value, "ModuleAssigned", $"ModuleId: {moduleId}");
            }
        }
        
        if (removedModules.Any())
        {
            shouldPublishEvent = true;
            foreach (var moduleId in removedModules)
            {
                await RegisterAuditAction(view.Id!.Value, "ModuleRemoved", $"ModuleId: {moduleId}");
            }
        }
    }
    else if (actionType == EnumActionType.Insert)
    {
        // Primer insert con módulos: publicar evento
        if (view.ApplicationModules?.Any() == true)
        {
            shouldPublishEvent = true;
            foreach (var module in view.ApplicationModules)
            {
                await RegisterAuditAction(view.Id!.Value, "ModuleAssigned", $"ModuleId: {module.ApplicationModuleId}");
            }
        }
    }
    else if (actionType == EnumActionType.Delete)
    {
        shouldPublishEvent = true;
        auditActions.Add("OrganizationDeactivatedManual");
    }
    
    // Publicar evento si corresponde
    if (shouldPublishEvent)
    {
        await PublishOrganizationEvent(view);
    }
    
    // Registrar acciones en AUDITLOG
    foreach (var action in auditActions)
    {
        await RegisterAuditAction(view.Id!.Value, action);
    }
    
    await base.PostActions(view, actionType, configurationName);
}
```

### Roles Típicos del Sistema

Aunque los roles se gestionan en Keycloak, el backend debe ser agnóstico de roles y solo verificar permisos:

| Rol (Informativo) | Permisos Esperados | Capacidades en Backend |
|-------------------|--------------------|-----------------------|
| **Organization Administrator** | 200, 201, 202, 203 | CRUD completo en datos básicos y módulos |
| **Organization Manager** | 200, 201 | CRUD en datos básicos, solo lectura de módulos |
| **Application Manager** | 201, 202, 203 | Solo lectura de datos básicos, CRUD en módulos |
| **Organization Viewer** | 201, 203 | Solo lectura completa |
| **Data Viewer** | 201 | Solo lectura de datos básicos |

**Importante**: El backend NO debe hardcodear nombres de roles. Solo debe verificar permisos mediante `IUserPermissions.HasPermission()`.

## CONFIGURACIONES DE CARGA Y ENDPOINTS HELIX6

El framework Helix6 genera automáticamente endpoints CRUD para la entidad `Organization` basándose en el archivo `HelixEntities.xml`. A continuación se detallan las configuraciones de carga personalizadas y el comportamiento de cada endpoint.

### Configuraciones de Carga (Load Configurations)

Las configuraciones de carga determinan qué navegaciones y colecciones se incluyen al recuperar una entidad. Se definen en `OrganizationRepository.cs`.

#### 1. Configuración "OrganizationBasic"

**Propósito**: Carga rápida solo con datos de la tabla `ORGANIZATION`, sin navegaciones.

**Incluye**:
- Todos los campos de la entidad `Organization`
- **NO incluye**: OrganizationGroup, ApplicationModules, AuditLogs

**Uso**: Operaciones de listado rápido, validaciones, búsquedas simples.

**Implementación en Repository**:
```csharp
protected override IQueryable<Organization> ApplyIncludes(
    IQueryable<Organization> query,
    string? configurationName)
{
    if (configurationName == "OrganizationBasic")
    {
        // Sin includes, solo la entidad base
        return query;
    }
    
    // ... otras configuraciones
    
    return base.ApplyIncludes(query, configurationName);
}
```

#### 2. Configuración "OrganizationComplete"

**Propósito**: Carga completa con todas las navegaciones y colecciones necesarias para el formulario de edición en frontend.

**Incluye**:
1. **Navegación OrganizationGroup** (si GroupId != null):
   - Id, GroupName, Description

2. **Colección ApplicationModules** (eager loading):
   - Todos los registros activos de `ORGANIZATION_APPLICATIONMODULE` donde `OrganizationId = {id}` y `AuditDeletionDate IS NULL`
   - Para cada registro, incluye navegación a **ApplicationModule**:
     - Id, ModuleName, Description, DisplayOrder, ApplicationId
     - Navegación anidada a **Application**:
       - Id, AppName, Description, RolePrefix

3. **Colección AuditLogs** (filtrada):
   - Registros de `AUDITLOG` donde:
     - `EntityType = 'Organization'`
     - `EntityId = {organizationId}`
     - `AuditDeletionDate IS NULL`
   - Ordenado por `Timestamp DESC`
   - Incluye: Id, Action, EntityType, EntityId, UserId, Timestamp, CorrelationId

**Uso**: 
- Frontend: Cargar formulario de edición completo con 3 pestañas
- GetById para edición
- Insert/Update con reloadView=true

**Implementación en Repository**:
```csharp
protected override IQueryable<Organization> ApplyIncludes(
    IQueryable<Organization> query,
    string? configurationName)
{
    if (configurationName == "OrganizationComplete")
    {
        return query
            .Include(o => o.OrganizationGroup) // Navegación a grupo
            .Include(o => o.ApplicationModules) // Colección de módulos asignados
                .ThenInclude(om => om.ApplicationModule) // Navegación a módulo
                    .ThenInclude(m => m.Application) // Navegación a aplicación
            .Include(o => o.AuditLogs.Where(a => 
                a.EntityType == "Organization" && 
                a.AuditDeletionDate == null)
                .OrderByDescending(a => a.Timestamp)); // Colección de auditoría filtrada
    }
    
    if (configurationName == "OrganizationBasic")
    {
        return query; // Sin includes
    }
    
    // Default: incluir solo grupo
    return query.Include(o => o.OrganizationGroup);
}
```

#### 3. Configuración "OrganizationWithGroup"

**Propósito**: Carga intermedia solo con navegación a grupo, sin módulos ni auditoría.

**Incluye**:
- Entidad `Organization` completa
- Navegación `OrganizationGroup`

**Uso**: Listados que necesitan mostrar nombre de grupo pero no módulos.

### Endpoints Auto-Generados por Helix6

Los siguientes endpoints se generan automáticamente en `Endpoints/Base/Generator/OrganizationEndpoints.cs` basándose en la configuración de `HelixEntities.xml`.

#### 1. GET /api/Organization/GetById

**Propósito**: Obtener una organización por ID con configuración de carga especificada.

**Parámetros**:
- `id` (int, query, required): ID de la organización
- `configurationName` (string, query, optional): Nombre de configuración ("OrganizationBasic", "OrganizationComplete", "OrganizationWithGroup")
- `Accept-Language` (header, optional): Idioma (es, en, ca)

**Permisos Requeridos**: `Organization data query` (201)

**Response**: 
- 200 OK: `OrganizationView` con estructura según configuración
- 404 Not Found: Si no existe o está soft-deleted
- 403 Forbidden: Si no tiene permiso

**Ejemplo Request**:
```http
GET /api/Organization/GetById?id=123&configurationName=OrganizationComplete
Accept-Language: es
Authorization: Bearer {jwt_token}
```

**Ejemplo Response**:
```json
{
  "id": 123,
  "securityCompanyId": 1001,
  "name": "Acme Corp",
  "taxId": "A12345678",
  "address": "Calle Principal 123",
  "city": "Barcelona",
  "postalCode": "08001",
  "country": "España",
  "contactEmail": "admin@acme.com",
  "contactPhone": "+34912345678",
  "groupId": 5,
  "organizationGroup": {
    "id": 5,
    "groupName": "Holding Norte",
    "description": "Grupo de empresas del norte"
  },
  "applicationModules": [
    {
      "id": 501,
      "applicationModuleId": 10,
      "organizationId": 123,
      "applicationModule": {
        "id": 10,
        "moduleName": "MSTP_Trafico",
        "description": "Módulo de gestión de tráfico",
        "displayOrder": 1,
        "applicationId": 2,
        "application": {
          "id": 2,
          "appName": "Sintraport",
          "description": "Sistema de gestión logística",
          "rolePrefix": "STP"
        }
      }
    }
  ],
  "auditLogs": [
    {
      "id": 1001,
      "action": "ModuleAssigned",
      "entityType": "Organization",
      "entityId": "123",
      "userId": 50,
      "timestamp": "2026-02-04T10:30:00Z",
      "correlationId": "abc123-def456"
    }
  ],
  "auditCreationUser": "admin@system.com",
  "auditCreationDate": "2026-01-15T09:00:00Z",
  "auditModificationUser": "manager@system.com",
  "auditModificationDate": "2026-02-04T10:30:00Z",
  "auditDeletionDate": null
}
```

#### 2. GET /api/Organization/GetNewEntity

**Propósito**: Obtener plantilla de nueva organización con valores por defecto.

**Parámetros**:
- `Accept-Language` (header, optional): Idioma

**Permisos Requeridos**: `Organization data modification` (200)

**Response**:
- 200 OK: `OrganizationView` con todos los campos null/empty y colecciones vacías
- 403 Forbidden: Si no tiene permiso

**Ejemplo Response**:
```json
{
  "id": null,
  "securityCompanyId": null,
  "name": null,
  "taxId": null,
  "address": null,
  "city": null,
  "postalCode": null,
  "country": null,
  "contactEmail": null,
  "contactPhone": null,
  "groupId": null,
  "organizationGroup": null,
  "applicationModules": [],
  "auditLogs": [],
  "auditCreationUser": null,
  "auditCreationDate": null,
  "auditModificationUser": null,
  "auditModificationDate": null,
  "auditDeletionDate": null
}
```

#### 3. POST /api/Organization/Insert

**Propósito**: Crear nueva organización.

**Parámetros**:
- `configurationName` (string, query, optional): Configuración para recargar después del insert
- `reloadView` (bool, query, optional, default=true): Si true, recarga entidad con Id generado
- `Accept-Language` (header, optional): Idioma

**Body**: `OrganizationView` completo

**Permisos Requeridos**:
- Mínimo: `Organization data modification` (200) para datos básicos
- Adicional: `Organization modules modification` (202) para asignar módulos

**Comportamiento**:
1. Valida permisos del usuario
2. Ejecuta `OrganizationService.ValidateView()` con validaciones de negocio
3. Ejecuta `OrganizationService.PreviousActions()` para filtrar payload según permisos
4. Genera `SecurityCompanyId` automáticamente (auto-increment)
5. Persiste entidad en tabla `ORGANIZATION`
6. Si el usuario tiene permiso 202 y se enviaron `ApplicationModules`:
   - Persiste relaciones en tabla `ORGANIZATION_APPLICATIONMODULE`
   - Registra acciones `ModuleAssigned` en `AUDITLOG`
   - Publica evento `OrganizationEvent` a ActiveMQ Artemis
7. Ejecuta `OrganizationService.PostActions()`
8. Si `reloadView=true`: Recarga entidad con configuración especificada
9. Retorna `OrganizationView` con Id y SecurityCompanyId generados

**Response**:
- 201 Created: `OrganizationView` con Id generado
- 400 Bad Request: Si validaciones fallan (con `HelixValidationProblem`)
- 403 Forbidden: Si no tiene permiso

**Ejemplo Request**:
```http
POST /api/Organization/Insert?configurationName=OrganizationComplete&reloadView=true
Content-Type: application/json
Accept-Language: es
Authorization: Bearer {jwt_token}

{
  "name": "Nueva Empresa SL",
  "taxId": "B98765432",
  "address": "Avenida Ejemplo 456",
  "city": "Madrid",
  "postalCode": "28001",
  "country": "España",
  "contactEmail": "contacto@nuevaempresa.com",
  "contactPhone": "+34911223344",
  "groupId": 3,
  "applicationModules": [
    {
      "applicationModuleId": 10
    },
    {
      "applicationModuleId": 12
    }
  ]
}
```

**Ejemplo Response**:
```json
{
  "id": 124,
  "securityCompanyId": 1002,
  "name": "Nueva Empresa SL",
  "taxId": "B98765432",
  "address": "Avenida Ejemplo 456",
  "city": "Madrid",
  "postalCode": "28001",
  "country": "España",
  "contactEmail": "contacto@nuevaempresa.com",
  "contactPhone": "+34911223344",
  "groupId": 3,
  "organizationGroup": {
    "id": 3,
    "groupName": "Grupo Centro",
    "description": null
  },
  "applicationModules": [
    {
      "id": 502,
      "applicationModuleId": 10,
      "organizationId": 124,
      "applicationModule": { /* ... */ }
    },
    {
      "id": 503,
      "applicationModuleId": 12,
      "organizationId": 124,
      "applicationModule": { /* ... */ }
    }
  ],
  "auditLogs": [
    {
      "id": 1002,
      "action": "ModuleAssigned",
      "entityType": "Organization",
      "entityId": "124",
      "userId": 50,
      "timestamp": "2026-02-04T11:00:00Z",
      "correlationId": "xyz789"
    },
    {
      "id": 1003,
      "action": "ModuleAssigned",
      "entityType": "Organization",
      "entityId": "124",
      "userId": 50,
      "timestamp": "2026-02-04T11:00:01Z",
      "correlationId": "xyz789"
    }
  ],
  "auditCreationUser": "admin@system.com",
  "auditCreationDate": "2026-02-04T11:00:00Z",
  "auditModificationUser": null,
  "auditModificationDate": null,
  "auditDeletionDate": null
}
```

#### 4. PUT /api/Organization/Update

**Propósito**: Actualizar organización existente.

**Parámetros**:
- `configurationName` (string, query, optional): Configuración para recargar
- `reloadView` (bool, query, optional, default=true): Recargar después de update
- `Accept-Language` (header, optional): Idioma

**Body**: `OrganizationView` completo con `id` obligatorio

**Permisos Requeridos**:
- Para datos básicos: `Organization data modification` (200)
- Para módulos: `Organization modules modification` (202)

**Comportamiento**:
1. Valida que entidad existe y no está soft-deleted
2. Ejecuta validaciones de permisos y negocio
3. Filtra payload según permisos en `PreviousActions()`
4. Actualiza campos modificados
5. Detecta cambios en colección `ApplicationModules`:
   - Módulos añadidos: Crea registros en `ORGANIZATION_APPLICATIONMODULE`, registra `ModuleAssigned`
   - Módulos removidos: Soft delete (AuditDeletionDate), registra `ModuleRemoved`
6. Detecta cambio en `GroupId`: Registra `GroupChanged`
7. Si hubo cambios en módulos o grupo: Publica evento `OrganizationEvent`
8. Ejecuta `PostActions()`
9. Recarga y retorna entidad actualizada

**Response**:
- 200 OK: `OrganizationView` actualizado
- 400 Bad Request: Validaciones fallidas
- 404 Not Found: Entidad no existe
- 403 Forbidden: Sin permiso

#### 5. DELETE /api/Organization/DeleteById

**Propósito**: Eliminar lógicamente (soft delete) una organización.

**Parámetros**:
- `id` (int, query, required): ID de la organización
- `Accept-Language` (header, optional): Idioma

**Permisos Requeridos**: `Organization data modification` (200)

**Comportamiento**:
1. Verifica que entidad existe
2. Establece `AuditDeletionDate = DateTime.UtcNow`
3. Registra acción `OrganizationDeactivatedManual` en `AUDITLOG`
4. Publica evento `OrganizationEvent` con `IsDeleted = true`
5. **Nota**: El soft delete de la organización NO elimina automáticamente sus registros en `ORGANIZATION_APPLICATIONMODULE`. Esos permanecen para histórico.

**Response**:
- 200 OK: `true`
- 404 Not Found: Entidad no existe
- 403 Forbidden: Sin permiso

#### 6. POST /api/Organization/GetAllKendoFilter

**Propósito**: Obtener lista paginada de organizaciones con filtros, ordenación y agrupación compatibles con Kendo Grid.

**Parámetros**:
- `configurationName` (string, query, optional): Configuración de carga
- `includeDeleted` (bool, query, optional, default=false): Incluir soft-deleted
- `Accept-Language` (header, optional): Idioma

**Body**: `KendoGridFilter`
```json
{
  "data": {
    "skip": 0,
    "take": 20,
    "sort": [
      { "field": "name", "dir": "asc" }
    ],
    "filter": {
      "logic": "and",
      "filters": [
        { "field": "city", "operator": "eq", "value": "Barcelona" },
        { "field": "groupId", "operator": "eq", "value": 5 }
      ]
    }
  }
}
```

**Permisos Requeridos**: `Organization data query` (201)

**Response**:
- 200 OK: `PagingResponse<OrganizationView>`
```json
{
  "list": [ /* array de OrganizationView */ ],
  "count": 150
}
```

**Operadores de Filtro Soportados**:
- `eq`, `neq`: Igualdad
- `lt`, `lte`, `gt`, `gte`: Comparación numérica/fecha
- `startswith`, `endswith`, `contains`: Texto
- `isnull`, `isnotnull`: Valores nulos
- `isempty`, `isnotempty`: Strings vacías

#### 7. GET /api/Organization/GetAll

**Propósito**: Obtener todas las organizaciones activas (sin paginación).

**Parámetros**:
- `configurationName` (string, query, optional): Configuración de carga
- `Accept-Language` (header, optional): Idioma

**Permisos Requeridos**: `Organization data query` (201)

**Response**:
- 200 OK: `List<OrganizationView>`

**Nota**: Solo retorna organizaciones con `AuditDeletionDate IS NULL`. No recomendado para tablas grandes.

### Configuración de HelixEntities.xml

Para habilitar la generación automática de endpoints, añadir en `[Proyecto].Api/HelixEntities.xml`:

```xml
<HelixEntities>
  <Entities>
    <EntityName>Organization</EntityName>
    <GetById>true</GetById>
    <GetNewEntity>true</GetNewEntity>
    <Insert>true</Insert>
    <Update>true</Update>
    <Delete>true</Delete>
    <GetAll>true</GetAll>
    <GetAllKendoFilter>true</GetAllKendoFilter>
    <DeleteUndeleteLogic>true</DeleteUndeleteLogic>
  </Entities>
</HelixEntities>
```

Después de modificar, ejecutar Helix Generator:
```bash
cd [Proyecto].HelixGenerator
dotnet run
```

Esto regenerará automáticamente:
- `Endpoints/Base/Generator/OrganizationEndpoints.cs`
- `Entities/Views/OrganizationView.cs` (si no existe)

### Publicación de Eventos (OrganizationEvent)

El servicio debe publicar eventos a ActiveMQ Artemis en tópico `infoportone.events.organization` siguiendo el patrón "State Transfer Event".

**Estructura del Evento**:
```json
{
  "EventId": "uuid-v4",
  "EventType": "ORGANIZATION",
  "EventTimestamp": "2026-02-04T11:00:00Z",
  "TraceId": "correlation-id",
  "OriginApplicationId": "InfoportOneAdmon",
  "SchemaVersion": "1.0",
  "Payload": [
    {
      "SecurityCompanyId": 1002,
      "Name": "Nueva Empresa SL",
      "TaxId": "B98765432",
      "Address": "Avenida Ejemplo 456",
      "City": "Madrid",
      "Country": "España",
      "IsDeleted": false,
      "GroupId": 3,
      "GroupName": "Grupo Centro",
      "Apps": [
        {
          "AppId": 2,
          "DatabaseName": "Sintraport_DB",
          "AccessibleModules": [10, 12]
        }
      ]
    }
  ]
}
```

**Cuándo Publicar**:
- ✅ Cuando se asigna/remueve un módulo
- ✅ Cuando se cambia `GroupId`
- ✅ Cuando se activa/desactiva la organización (soft delete)
- ❌ NO publicar al cambiar solo datos básicos (Name, TaxId, Address, etc.)

## GUÍA DE IMPLEMENTACIÓN CON HELIX6

Esta sección describe los pasos ordenados para implementar la entidad Organization siguiendo los patrones del Framework Helix6. **No incluye código completo**, solo la secuencia de acciones y decisiones de diseño.

### Paso 0: Configurar HelixEntities.xml

1. Abrir archivo `[Proyecto].Api/HelixEntities.xml`
2. Añadir configuración para entidad Organization:
   - Habilitar todos los endpoints: GetById, GetNewEntity, Insert, Update, Delete, GetAll, GetAllKendoFilter
   - Habilitar DeleteUndeleteLogic para soft delete
3. Guardar archivo (aún no ejecutar generator)

### Paso 1: Crear Entidad en DataModel

1. Crear archivo `[Proyecto].DataModel/Organization.cs`
2. Implementar clase POCO que hereda de `IEntityBase`:
   - Decorar con atributo `[Table("ORGANIZATION")]`
   - Definir propiedad `Id` con `[Key]`
   - Definir `SecurityCompanyId` con `[DatabaseGenerated(DatabaseGeneratedOption.Identity)]` y `[Column(Order = 2)]`
   - Definir propiedades de negocio: Name, TaxId, Address, City, PostalCode, Country, ContactEmail, ContactPhone
   - Definir `GroupId` como FK nullable con `[ForeignKey("OrganizationGroup")]`
   - Definir propiedad de navegación `public virtual OrganizationGroup? OrganizationGroup { get; set; }`
   - Definir colección de navegación `public virtual ICollection<Organization_ApplicationModule>? ApplicationModules { get; set; }`
   - Definir colección de navegación `public virtual ICollection<AuditLog>? AuditLogs { get; set; }`
   - Implementar propiedades de auditoría obligatorias de `IEntityBase`:
     - AuditCreationUser, AuditCreationDate (auto-gestionadas por Helix6)
     - AuditModificationUser, AuditModificationDate
     - AuditDeletionDate (para soft delete)
3. Añadir Data Annotations:
   - `[Required]` en Name, TaxId
   - `[StringLength(200)]` en Name
   - `[StringLength(50)]` en TaxId
   - `[StringLength(300)]` en Address
   - `[StringLength(100)]` en City, Country
   - `[StringLength(20)]` en PostalCode
   - `[StringLength(255)]` en ContactEmail
   - `[StringLength(50)]` en ContactPhone
4. Marcar navegaciones con `virtual` para lazy loading

### Paso 2: Añadir DbSet al DbContext

1. Abrir archivo `[Proyecto].Data/EntityModel.cs` (DbContext)
2. Añadir propiedad `DbSet<Organization>`:
   ```csharp
   public DbSet<Organization> Organizations { get; set; }
   ```
3. Si se requiere configuración Fluent API adicional, añadir en método `OnModelCreating()`:
   - Configurar índice único para SecurityCompanyId
   - Configurar índice único para Name
   - Configurar índice único para TaxId
   - Configurar FK a OrganizationGroup con DeleteBehavior.SetNull
   - Configurar relación 1:N con Organization_ApplicationModule

### Paso 3: Crear y Aplicar Migración de EF Core

1. Abrir terminal en carpeta del proyecto Api
2. Ejecutar comando para crear migración:
   ```bash
   dotnet ef migrations add AddOrganizationEntity --project [Proyecto].Data --startup-project [Proyecto].Api
   ```
3. Revisar archivo de migración generado en `[Proyecto].Data/Migrations/`:
   - Verificar que crea tabla ORGANIZATION con todos los campos
   - Verificar índices únicos (UK_Organization_SecurityCompanyId, UK_Organization_Name, UK_Organization_TaxId)
   - Verificar FK a ORGANIZATIONGROUP
   - Verificar campos de auditoría
4. Aplicar migración a base de datos:
   ```bash
   dotnet ef database update --project [Proyecto].Data --startup-project [Proyecto].Api
   ```
5. Verificar en BD que tabla se creó correctamente con todas las constraints

### Paso 4: Crear Interfaz de Repositorio

1. Crear archivo `[Proyecto].Data/Repository/Interfaces/IOrganizationRepository.cs`
2. Definir interfaz que hereda de `IBaseRepository<Organization>`:
   ```csharp
   public interface IOrganizationRepository : IBaseRepository<Organization>
   {
       // Métodos personalizados adicionales si se requieren
       Task<Organization?> GetBySecurityCompanyId(int securityCompanyId);
       Task<Organization?> GetByTaxId(string taxId);
   }
   ```
3. Solo añadir métodos que NO estén en `IBaseRepository` (GetById, Insert, Update, etc. ya están)

### Paso 5: Implementar Repositorio Concreto

1. Crear archivo `[Proyecto].Data/Repository/OrganizationRepository.cs`
2. Implementar clase que hereda de `BaseRepository<Organization>` e implementa `IOrganizationRepository`:
   ```csharp
   public class OrganizationRepository : BaseRepository<Organization>, IOrganizationRepository
   ```
3. Inyectar dependencias en constructor:
   - IApplicationContext
   - IUserContext
   - IBaseEFRepository<Organization>
   - IBaseDapperRepository<Organization>
4. Llamar al constructor base pasando las 4 dependencias
5. Implementar configuraciones de carga sobrescribiendo `ApplyIncludes()`:
   - Switch por `configurationName`
   - Caso "OrganizationBasic": retornar query sin includes
   - Caso "OrganizationComplete": añadir includes para OrganizationGroup, ApplicationModules (con ThenInclude a ApplicationModule y Application), AuditLogs (filtrado)
   - Caso "OrganizationWithGroup": solo incluir OrganizationGroup
   - Default: incluir OrganizationGroup
6. Implementar métodos personalizados si los definiste en la interfaz:
   - Usar `_baseEFRepository` para queries con Entity Framework
   - Usar `_baseDapperRepository` para queries SQL optimizadas con Dapper

### Paso 6: Ejecutar Helix Generator para Crear View

1. Abrir terminal en carpeta `[Proyecto].HelixGenerator`
2. Ejecutar:
   ```bash
   dotnet run
   ```
3. El generator escaneará las entidades en DataModel y generará automáticamente:
   - `[Proyecto].Entities/Views/OrganizationView.cs` (clase parcial con todas las propiedades mapeadas)
   - `[Proyecto].Entities/Views/Metadata/OrganizationViewMetadata.cs` (placeholder para metadata)
4. Verificar que OrganizationView tiene:
   - Todas las propiedades de Organization
   - Propiedad `OrganizationGroup` de tipo `OrganizationGroupView`
   - Propiedad `ApplicationModules` de tipo `List<Organization_ApplicationModuleView>`
   - Propiedad `AuditLogs` de tipo `List<AuditLogView>`
   - Implementa `IViewBase`

### Paso 7: Añadir Metadata y Validaciones a View

1. Abrir `[Proyecto].Entities/Views/Metadata/OrganizationViewMetadata.cs`
2. Añadir clase parcial con atributos de validación:
   ```csharp
   public partial class OrganizationViewMetadata
   {
       [Required(ErrorMessage = "El nombre es obligatorio")]
       [StringLength(200, ErrorMessage = "Máximo 200 caracteres")]
       public string? Name { get; set; }
       
       [Required(ErrorMessage = "El TaxId es obligatorio")]
       [StringLength(50)]
       [RegularExpression(@"^[A-Z]\d{8}$", ErrorMessage = "Formato de CIF inválido")]
       public string? TaxId { get; set; }
       
       [EmailAddress(ErrorMessage = "Email inválido")]
       public string? ContactEmail { get; set; }
       
       // ... resto de propiedades
   }
   ```
3. Los atributos de metadata se aplicarán automáticamente a OrganizationView mediante `[MetadataType(typeof(OrganizationViewMetadata))]`

### Paso 8: Crear Servicio de Negocio

1. Crear archivo `[Proyecto].Services/OrganizationService.cs`
2. Implementar clase que hereda de `BaseService<OrganizationView, Organization, OrganizationViewMetadata>`:
   ```csharp
   public class OrganizationService : BaseService<OrganizationView, Organization, OrganizationViewMetadata>
   ```
3. Inyectar dependencias en constructor:
   - IApplicationContext
   - IUserContext
   - IOrganizationRepository (específico, no IBaseRepository)
   - IUserPermissions
   - IEventPublisher (para publicar eventos a ActiveMQ)
4. Llamar al constructor base pasando applicationContext, userContext y repository
5. Guardar referencias privadas para usar en hooks:
   ```csharp
   private readonly IOrganizationRepository _organizationRepository;
   private readonly IUserPermissions _userPermissions;
   private readonly IEventPublisher _eventPublisher;
   ```

### Paso 9: Implementar Hook ValidateView

1. Sobrescribir método `ValidateView()`:
   ```csharp
   public override async Task ValidateView(
       HelixValidationProblem validations,
       OrganizationView? view,
       EnumActionType actionType,
       string? configurationName = null)
   ```
2. Implementar validaciones de negocio:
   - Verificar permisos usando `_userPermissions.HasPermission()`
   - Validar campos obligatorios (Name, TaxId, ContactEmail)
   - Validar unicidad de Name con query Dapper excluyendo soft-deleted
   - Validar unicidad de TaxId con query Dapper excluyendo soft-deleted
   - Validar que GroupId existe y está activo si se proporciona
   - Validar formato de TaxId (regex CIF español)
   - Validar formato de ContactEmail
3. SIEMPRE llamar al método base al final:
   ```csharp
   await base.ValidateView(validations, view, actionType, configurationName);
   ```

### Paso 10: Implementar Hook PreviousActions

1. Sobrescribir método `PreviousActions()`:
   ```csharp
   public override async Task PreviousActions(
       OrganizationView? view,
       EnumActionType actionType,
       string? configurationName = null)
   ```
2. Implementar lógica de filtrado de payload según permisos:
   - Verificar si usuario tiene `Organization data modification` (200)
   - Si NO tiene: preservar valores originales de datos básicos (cargar original y restaurar campos)
   - Verificar si usuario tiene `Organization modules modification` (202)
   - Si NO tiene: establecer `view.ApplicationModules = null` para ignorar cambios
3. Llamar al método base:
   ```csharp
   await base.PreviousActions(view, actionType, configurationName);
   ```

### Paso 11: Implementar Hook PostActions

1. Sobrescribir método `PostActions()`:
   ```csharp
   public override async Task PostActions(
       OrganizationView? view,
       EnumActionType actionType,
       string? configurationName = null)
   ```
2. Implementar lógica de eventos y auditoría:
   - Si actionType == Update:
     - Cargar versión original con `GetById()`
     - Comparar `GroupId` original vs nuevo: si cambió, marcar `shouldPublishEvent = true` y registrar `GroupChanged` en AUDITLOG
     - Comparar colecciones `ApplicationModules`:
       - Detectar módulos añadidos: registrar `ModuleAssigned` en AUDITLOG por cada uno
       - Detectar módulos removidos: registrar `ModuleRemoved` en AUDITLOG por cada uno
       - Si hay cambios: marcar `shouldPublishEvent = true`
   - Si actionType == Insert:
     - Si `view.ApplicationModules?.Any() == true`: marcar `shouldPublishEvent = true` y registrar `ModuleAssigned`
   - Si actionType == Delete:
     - Marcar `shouldPublishEvent = true`
     - Registrar `OrganizationDeactivatedManual` en AUDITLOG
   - Si `shouldPublishEvent == true`:
     - Construir `OrganizationEvent` con estructura completa (Payload con Apps y AccessibleModules)
     - Publicar a ActiveMQ Artemis usando `_eventPublisher.Publish()`
3. Llamar al método base:
   ```csharp
   await base.PostActions(view, actionType, configurationName);
   ```

### Paso 12: Implementar Métodos Helper Privados

1. Crear método privado `RegisterAuditAction()`:
   - Parámetros: organizationId, action, details (opcional)
   - Crear registro en tabla AUDITLOG:
     - EntityType = "Organization"
     - EntityId = organizationId.ToString()
     - Action = action ("ModuleAssigned", "ModuleRemoved", etc.)
     - UserId = _userContext.UserId
     - Timestamp = DateTime.UtcNow
     - CorrelationId = generar GUID
   - Persistir usando repositorio de AuditLog

2. Crear método privado `PublishOrganizationEvent()`:
   - Parámetro: OrganizationView
   - Construir objeto OrganizationEvent:
     - EventId = GUID
     - EventType = "ORGANIZATION"
     - EventTimestamp = DateTime.UtcNow
     - TraceId = obtener de contexto o generar
     - OriginApplicationId = "InfoportOneAdmon"
     - SchemaVersion = "1.0"
     - Payload = array con objeto organization transformado:
       - SecurityCompanyId, Name, TaxId, Address, City, Country
       - IsDeleted = (AuditDeletionDate != null)
       - GroupId, GroupName
       - Apps = array transformado desde ApplicationModules agrupados por Application
   - Publicar a tópico `infoportone.events.organization` usando `_eventPublisher`

### Paso 13: Registrar Servicio y Repositorio en DI

1. Abrir archivo `[Proyecto].Api/Extensions/DependencyInjection.cs`
2. El método `AddServicesRepositories()` usa reflexión para autodescubrir servicios y repositorios
3. Verificar que sigue la convención de nomenclatura:
   - Clase termina en "Service" → Se registra como scoped
   - Clase termina en "Repository" → Se registra como scoped
4. Si la convención falla, añadir registro manual:
   ```csharp
   services.AddScoped<IOrganizationService, OrganizationService>();
   services.AddScoped<IOrganizationRepository, OrganizationRepository>();
   ```

### Paso 14: Ejecutar Helix Generator para Crear Endpoints

1. Verificar que `HelixEntities.xml` tiene configuración de Organization (Paso 0)
2. Ejecutar generator:
   ```bash
   cd [Proyecto].HelixGenerator
   dotnet run
   ```
3. El generator creará automáticamente `[Proyecto].Api/Endpoints/Base/Generator/OrganizationEndpoints.cs` con:
   - MapOrganizationEndpoints() método estático
   - Endpoints: GetById, GetNewEntity, Insert, Update, DeleteById, GetAll, GetAllKendoFilter
4. **NO modificar archivos en carpeta Generator/** (se sobrescriben en cada ejecución)

### Paso 15: Registrar Endpoints en Program.cs

1. Abrir archivo `[Proyecto].Api/Program.cs`
2. Buscar sección donde se mapean endpoints generados (suele estar después de `app.UseAuthorization()`)
3. Añadir llamada a método generado:
   ```csharp
   app.MapOrganizationEndpoints();
   ```
4. Esto expondrá todos los endpoints bajo ruta `/api/Organization/*`

### Paso 16: Configurar Autenticación y Autorización

1. Verificar en `appsettings.json` que está configurado JWT:
   - Authority (URL de Keycloak)
   - Audience
   - ValidIssuers
2. En `Program.cs`, verificar que está configurado:
   ```csharp
   builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
       .AddJwtBearer(options => { /* ... */ });
   ```
3. Configurar mapeo de claims según proveedor de identidad en `Security/`:
   - Si es Keycloak: usar `KeyCloakUserClaimsMapping`
   - Implementa `IUserClaimsMapping` para extraer UserId, Roles, Permisos del JWT
4. Los endpoints auto-generados tienen decorador `[Authorize]` por defecto

### Paso 17: Implementar IUserPermissions

1. Crear servicio que implemente `IUserPermissions`:
   - Método `HasPermission(string entityName, SecurityLevel level)`
   - Lee claims del JWT del usuario actual
   - Compara contra claim de permisos (ej: "permissions" en JWT)
   - Retorna true si usuario tiene permiso para la entidad y nivel especificados
2. Registrar en DI como scoped:
   ```csharp
   services.AddScoped<IUserPermissions, UserPermissionsService>();
   ```
3. El servicio `OrganizationService` lo inyectará y usará en `ValidateView()` y `PreviousActions()`

### Paso 18: Implementar Event Publisher para ActiveMQ

1. Crear servicio `EventPublisherService` que implemente `IEventPublisher`:
   - Método `Publish(string topic, object eventData)`
   - Usa cliente de ActiveMQ Artemis (Apache.NMS.ActiveMQ)
   - Serializa evento a JSON
   - Calcula hash SHA-256 del Payload
   - Verifica en tabla EVENTHASH si el hash cambió (prevención de duplicados)
   - Si cambió: Publica a tópico especificado, actualiza EVENTHASH
   - Si no cambió: Omite publicación (log warning)
2. Registrar en DI como scoped o singleton según diseño
3. Configurar conexión a ActiveMQ en `appsettings.json`:
   ```json
   "ActiveMQ": {
     "BrokerUri": "activemq:tcp://localhost:61616",
     "Username": "artemis",
     "Password": "artemis"
   }
   ```

### Paso 19: Crear Tabla EVENTHASH para Control de Duplicados

1. Crear migración de EF Core:
   ```bash
   dotnet ef migrations add AddEventHashTable --project [Proyecto].Data --startup-project [Proyecto].Api
   ```
2. Estructura de tabla:
   - Id (PK, auto-increment)
   - EntityType (varchar 50) - ej: "Organization"
   - EntityId (varchar 50) - ej: "123"
   - LastEventHash (varchar 64) - SHA-256 del Payload
   - LastEventTimestamp (datetime)
3. Aplicar migración:
   ```bash
   dotnet ef database update --project [Proyecto].Data --startup-project [Proyecto].Api
   ```

### Paso 20: Implementar Tests Unitarios del Servicio

1. Crear archivo `[Proyecto].Services.Tests/OrganizationServiceTests.cs`
2. Configurar framework de testing (xUnit, NUnit o MSTest)
3. Mockear dependencias usando Moq:
   - Mock de IOrganizationRepository
   - Mock de IUserContext (simular UserId, UserName)
   - Mock de IUserPermissions (simular permisos)
   - Mock de IEventPublisher
4. Escribir tests para:
   - **Test_Insert_WithDataPermission_PersistsBasicData**: Verifica que usuario con permiso 200 solo persiste datos básicos
   - **Test_Insert_WithModulesPermission_PersistsModulesAndPublishesEvent**: Verifica que usuario con permiso 202 persiste módulos y publica evento
   - **Test_Update_ChangeGroup_PublishesEventAndRegistersAudit**: Verifica que cambio de grupo publica evento y registra en AUDITLOG
   - **Test_ValidateView_DuplicateName_ReturnsValidationError**: Verifica que nombre duplicado genera error
   - **Test_ValidateView_InvalidTaxId_ReturnsValidationError**: Verifica formato de TaxId
   - **Test_PreviousActions_UserWithoutDataPermission_PreservesOriginalData**: Verifica que sin permiso 200 se preservan datos originales
5. Objetivo: Cobertura > 80% del servicio

### Paso 21: Implementar Tests de Integración de Endpoints

1. Crear archivo `[Proyecto].Api.Tests/OrganizationEndpointsIntegrationTests.cs`
2. Usar `WebApplicationFactory<Program>` para crear servidor de pruebas
3. Configurar base de datos en memoria (SQLite o EF Core InMemory provider)
4. Escribir tests de integración:
   - **Test_GetById_ReturnsOrganization**: GET con ID válido retorna 200 y OrganizationView
   - **Test_Insert_ValidPayload_Returns201**: POST con payload válido retorna 201 y entity con Id generado
   - **Test_Insert_WithoutPermission_Returns403**: POST sin JWT o sin permiso retorna 403
   - **Test_Update_ChangeModules_PublishesEvent**: PUT que cambia módulos verifica que se publicó evento (spy en EventPublisher)
   - **Test_GetAllKendoFilter_WithFilters_ReturnsPaginatedResults**: POST con filtros retorna lista paginada correcta
5. Mockear ActiveMQ (no publicar a broker real en tests)

### Paso 22: Configurar Logging con Serilog

1. Verificar configuración de Serilog en `Program.cs`:
   ```csharp
   Log.Logger = new LoggerConfiguration()
       .ReadFrom.Configuration(builder.Configuration)
       .CreateLogger();
   ```
2. Añadir sinks en `appsettings.json`:
   ```json
   "Serilog": {
     "MinimumLevel": "Information",
     "WriteTo": [
       { "Name": "Console" },
       { "Name": "File", "Args": { "path": "logs/log-.txt", "rollingInterval": "Day" } }
     ]
   }
   ```
3. En `OrganizationService`, inyectar `ILogger<OrganizationService>`:
   ```csharp
   private readonly ILogger<OrganizationService> _logger;
   ```
4. Añadir logs estructurados en puntos clave:
   - Inicio/Fin de Insert/Update
   - Publicación de eventos (con EventId)
   - Errores de validación
   - Cambios detectados (módulos añadidos/removidos)

### Paso 23: Documentar Endpoints en Swagger

1. Verificar que Swagger está configurado en `Program.cs`:
   ```csharp
   builder.Services.AddSwaggerGen();
   app.UseSwagger();
   app.UseSwaggerUI();
   ```
2. Los endpoints auto-generados incluyen automáticamente:
   - Decorador `[ProducesResponseType]` para 200, 400, 404, 403
   - Decorador `[SwaggerOperation]` con descripción
3. Añadir comentarios XML al servicio para enriquecer documentación:
   - Habilitar generación de XML en .csproj: `<GenerateDocumentationFile>true</GenerateDocumentationFile>`
   - Configurar Swagger para incluir XML:
     ```csharp
     options.IncludeXmlComments(Path.Combine(AppContext.BaseDirectory, "[Proyecto].Api.xml"));
     ```
4. Ejecutar aplicación y verificar Swagger UI en `https://localhost:5001/swagger`

### Paso 24: Configurar CORS si Frontend está en Dominio Diferente

1. En `Program.cs`, añadir configuración de CORS antes de `builder.Build()`:
   ```csharp
   builder.Services.AddCors(options =>
   {
       options.AddDefaultPolicy(builder =>
       {
           builder.WithOrigins("http://localhost:4200") // Angular dev server
                  .AllowAnyHeader()
                  .AllowAnyMethod()
                  .AllowCredentials();
       });
   });
   ```
2. Añadir middleware de CORS después de `UseAuthentication()`:
   ```csharp
   app.UseCors();
   ```

### Paso 25: Crear Script de Seed Data para Testing

1. Crear archivo `[Proyecto].Api/SeedData.cs` con método estático `SeedDatabase()`
2. Implementar lógica para poblar datos iniciales:
   - Crear grupos de organizaciones de ejemplo
   - Crear aplicaciones y módulos de ejemplo
   - Crear organizaciones de prueba con módulos asignados
3. Llamar en `Program.cs` si argumento `--seed` está presente:
   ```csharp
   if (args.Contains("--seed"))
   {
       using var scope = app.Services.CreateScope();
       var context = scope.ServiceProvider.GetRequiredService<EntityModel>();
       SeedData.SeedDatabase(context);
   }
   ```
4. Ejecutar:
   ```bash
   dotnet run --project [Proyecto].Api -- --seed
   ```

### Paso 26: Verificación Final y Pruebas Manuales

1. Ejecutar aplicación:
   ```bash
   dotnet run --project [Proyecto].Api
   ```
2. Verificar que API arranca sin errores en `https://localhost:5001`
3. Abrir Swagger UI: `https://localhost:5001/swagger`
4. Verificar que endpoints de Organization aparecen:
   - GET /api/Organization/GetById
   - POST /api/Organization/Insert
   - PUT /api/Organization/Update
   - DELETE /api/Organization/DeleteById
   - POST /api/Organization/GetAllKendoFilter
   - GET /api/Organization/GetAll
   - GET /api/Organization/GetNewEntity
5. Probar flujo completo usando Postman o Swagger UI:
   - Obtener JWT de Keycloak con usuario de prueba
   - GetNewEntity → Verificar respuesta con valores null
   - Insert con datos válidos → Verificar que retorna 201 con Id generado
   - GetById con Id creado → Verificar configuración OrganizationComplete carga navegaciones
   - Update cambiando GroupId → Verificar que se registra en AUDITLOG
   - Update asignando módulos → Verificar que se publica evento (revisar logs)
   - GetAllKendoFilter con filtros → Verificar paginación
6. Verificar en base de datos:
   - Tabla ORGANIZATION tiene registros
   - Tabla ORGANIZATION_APPLICATIONMODULE tiene relaciones
   - Tabla AUDITLOG tiene acciones registradas
   - Tabla EVENTHASH tiene hashes de eventos publicados

## CONTEXTO TÉCNICO

- **Framework**: Helix6 v1.0 sobre .NET 8.0
- **Arquitectura**: N-Layer (Api → Services → Data → DataModel)
- **ORM**: Entity Framework Core 9.0.2 (escrituras) + Dapper 2.1.66 (lecturas optimizadas)
- **Mapeo**: Mapster 7.4.0 para transformación Entity ↔ View
- **Base de Datos**: PostgreSQL 15+ (diseño agnóstico, soporta SQL Server y MySQL)
- **Message Broker**: Apache ActiveMQ Artemis 2.31+ (publicación de eventos)
- **Autenticación**: JWT Bearer con Keycloak como IdP
- **Logging**: Serilog 9.0.2 con sinks a archivo y consola
- **Testing**: xUnit, Moq, FluentAssertions
- **Documentación API**: Swagger/OpenAPI 3.0

## CRITERIOS DE ACEPTACIÓN TÉCNICOS

- [ ] Entidad `Organization` creada en DataModel con 15 campos (Id, SecurityCompanyId, 8 campos de negocio, 5 campos audit)
- [ ] Tabla `ORGANIZATION` creada en BD con constraints (PK, 3 UK, FK a ORGANIZATIONGROUP)
- [ ] Migración de EF Core aplicada exitosamente sin errores
- [ ] Interfaz `IOrganizationRepository` definida heredando de `IBaseRepository<Organization>`
- [ ] Clase `OrganizationRepository` implementada heredando de `BaseRepository<Organization>`
- [ ] Configuraciones de carga implementadas: "OrganizationBasic", "OrganizationComplete", "OrganizationWithGroup"
- [ ] OrganizationView auto-generado por Helix Generator con todas las propiedades
- [ ] OrganizationViewMetadata creado con atributos de validación (Required, StringLength, RegularExpression, EmailAddress)
- [ ] `OrganizationService` implementado heredando de `BaseService<OrganizationView, Organization, OrganizationViewMetadata>`
- [ ] Hook `ValidateView()` implementado con:
  - Verificación de permisos usando `IUserPermissions`
  - Validación de unicidad de Name y TaxId (excluyendo soft-deleted)
  - Validación de existencia y estado de GroupId
  - Validación de formato de TaxId (regex CIF español)
  - Llamada a `base.ValidateView()` al final
- [ ] Hook `PreviousActions()` implementado con filtrado de payload según permisos
- [ ] Hook `PostActions()` implementado con:
  - Detección de cambios en GroupId y módulos
  - Registro de 6 acciones críticas en tabla AUDITLOG
  - Publicación de evento OrganizationEvent solo cuando corresponde (NO en cambios de datos básicos)
  - Llamada a `base.PostActions()` al final
- [ ] Métodos helper privados implementados: `RegisterAuditAction()`, `PublishOrganizationEvent()`
- [ ] Servicio y repositorio registrados en DI (manual o por convención)
- [ ] HelixEntities.xml configurado con Organization habilitando todos los endpoints
- [ ] Endpoints auto-generados en `Endpoints/Base/Generator/OrganizationEndpoints.cs`
- [ ] Endpoints registrados en `Program.cs` con `app.MapOrganizationEndpoints()`
- [ ] Autenticación JWT configurada con Keycloak (Authority, Audience en appsettings.json)
- [ ] Mapeo de claims implementado (KeyCloakUserClaimsMapping o personalizado)
- [ ] `IUserPermissions` implementado leyendo permisos desde JWT
- [ ] Event Publisher implementado con cliente ActiveMQ Artemis
- [ ] Tabla EVENTHASH creada con migración para control de duplicados
- [ ] Publicación de eventos usa hash SHA-256 para prevenir duplicados
- [ ] Logging con Serilog configurado en puntos clave (Insert, Update, Eventos, Errores)
- [ ] Tests unitarios del servicio con cobertura > 80%:
  - Test de Insert con permiso 200 solo
  - Test de Insert con permiso 200+202
  - Test de Update con cambio de grupo
  - Test de validaciones (nombre duplicado, TaxId inválido)
  - Test de filtrado de payload según permisos
- [ ] Tests de integración de endpoints:
  - GetById retorna 200 con OrganizationView
  - Insert retorna 201 con Id generado
  - Insert sin permiso retorna 403
  - Update con módulos publica evento
  - GetAllKendoFilter con filtros retorna paginación correcta
- [ ] Swagger UI muestra todos los endpoints de Organization con documentación
- [ ] CORS configurado si frontend en dominio diferente
- [ ] Seed data creado con grupos, aplicaciones, módulos y organizaciones de prueba
- [ ] Verificación manual exitosa:
  - GetNewEntity retorna template vacío
  - Insert crea organización con SecurityCompanyId auto-generado
  - GetById con "OrganizationComplete" carga navegaciones
  - Update con cambio de grupo registra en AUDITLOG y publica evento
  - Update con asignación de módulos publica evento OrganizationEvent
  - GetAllKendoFilter con filtros funciona correctamente
- [ ] Base de datos poblada con:
  - Registros en ORGANIZATION
  - Relaciones en ORGANIZATION_APPLICATIONMODULE
  - Acciones en AUDITLOG (ModuleAssigned, GroupChanged, etc.)
  - Hashes en EVENTHASH
- [ ] Code review aprobado siguiendo guías de Helix6
- [ ] Documentación técnica actualizada en README del proyecto

## DEPENDENCIAS

Este ticket backend tiene las siguientes dependencias técnicas y funcionales:

### Tickets de Base de Datos (Bloqueantes)

- **Ticket_ORG001_T003-DB**: Creación de estructura completa de base de datos con:
  - Tabla ORGANIZATION (15 campos con PK Id, UK SecurityCompanyId, UK Name, UK TaxId, FK GroupId)
  - Tabla ORGANIZATIONGROUP (8 campos)
  - Tabla APPLICATION (9 campos)
  - Tabla APPLICATIONMODULE (9 campos con FK a Application)
  - Tabla ORGANIZATION_APPLICATIONMODULE (relación N:M con 8 campos, FK a ApplicationModule y Organization)
  - Tabla AUDITLOG (10 campos para 6 acciones críticas: ModuleAssigned, ModuleRemoved, OrganizationDeactivatedManual, OrganizationAutoDeactivated, OrganizationReactivatedManual, GroupChanged)
  - Tabla EVENTHASH (5 campos para control de duplicados de eventos)
  - Todos los índices, constraints, foreign keys y triggers según diseño
  - Scripts de migración iniciales si no se usa EF Core Migrations

### Framework Helix6 Base (Prerequisito)

- **Helix6.Base** (NuGet package versión 9.0.2+): Framework base con:
  - `BaseRepository<TEntity>`, `BaseEFRepository<TEntity>`, `BaseDapperRepository<TEntity>`
  - `BaseService<TView, TEntity, TMetadata>`
  - `IUserContext`, `IApplicationContext`, `IUserPermissions`
  - Middleware de excepciones (`HelixExceptionsMiddleware`)
  - Helpers de endpoints (`EndpointHelper`)
  - Sistema de auditoría automática

- **Helix6.Base.Domain** (NuGet package versión 9.0.2+): Dominio base con:
  - `IEntityBase`, `IViewBase`
  - Enumeraciones (`EnumActionType`, `SecurityLevel`, `EnumDBMSType`)
  - `HelixValidationProblem`
  - `IGenericFilter`, `FilterResult<T>`

- **Helix6.Base.Utils** (NuGet package versión 9.0.2+): Utilidades con:
  - `FileHelper`, `MailHelper`
  - Extensiones de conversión

### Paquetes NuGet Adicionales

- **Microsoft.EntityFrameworkCore** (9.0.2): ORM para operaciones de escritura
- **Microsoft.EntityFrameworkCore.Tools** (9.0.2): Herramientas de migración
- **Npgsql.EntityFrameworkCore.PostgreSQL** (9.0.2): Provider para PostgreSQL (o equivalente para SQL Server/MySQL)
- **Dapper** (2.1.66): Micro-ORM para consultas optimizadas
- **Mapster** (7.4.0): Mapeo de alto rendimiento Entity ↔ View
- **Serilog.AspNetCore** (9.0.2): Logging estructurado
- **Serilog.Sinks.File** (6.0.0): Sink de archivo para logs
- **Swashbuckle.AspNetCore** (6.8.1): Generación de Swagger/OpenAPI
- **Microsoft.AspNetCore.Authentication.JwtBearer** (8.0.0): Autenticación JWT
- **Apache.NMS.ActiveMQ** (2.2.0): Cliente para ActiveMQ Artemis
- **System.Linq.Dynamic.Core** (1.6.0.2): Consultas LINQ dinámicas

### Infraestructura Externa

- **Base de Datos PostgreSQL 15+**: Instancia ejecutándose con:
  - Usuario con permisos de creación de tablas
  - Esquema definido (por defecto "public")
  - Cadena de conexión configurada en appsettings.json

- **Apache ActiveMQ Artemis 2.31+**: Message broker ejecutándose con:
  - Tópico `infoportone.events.organization` configurado o auto-creación habilitada
  - Credenciales de acceso (username/password)
  - BrokerUri accesible desde backend (ej: activemq:tcp://localhost:61616)

- **Keycloak 23+**: Identity Provider configurado con:
  - Realm `InfoportOne` creado
  - Client para InfoportOneAdmon registrado (confidential client con client_id y client_secret)
  - Usuarios de prueba con roles y permisos asignados:
    - Usuario Organization Administrator (permisos 200, 201, 202, 203)
    - Usuario Organization Manager (permisos 200, 201)
    - Usuario Application Manager (permisos 201, 202, 203)
    - Usuario Organization Viewer (permisos 201, 203)
  - Protocol Mapper configurado para incluir permisos en JWT (claim "permissions")
  - Authority URL accesible desde backend

### Configuración de Entorno

- **.NET 8 SDK** (8.0.100+): Instalado en entorno de desarrollo
- **Entity Framework Core CLI Tools**: Instalado globalmente (`dotnet tool install --global dotnet-ef`)
- **Visual Studio 2022** (17.8+) o **Visual Studio Code** con extensión C# Dev Kit
- **Postman** o herramienta similar para testing manual de endpoints

### Archivos de Configuración

- **appsettings.Development.json**: Configurado con:
  - ConnectionStrings.DefaultConnection apuntando a PostgreSQL local
  - Serilog.MinimumLevel y WriteTo configurados
  - Authentication.JwtBearer con Authority, Audience, RequireHttpsMetadata
  - ActiveMQ.BrokerUri, Username, Password
  - ApplicationContext con ApplicationName, RolePrefix

- **HelixEntities.xml**: Creado con configuración de entidad Organization

### Tickets Frontend/Integración (No Bloqueantes)

- **Ticket_ORG001_T001-FE**: Implementación de formulario Angular (consume endpoints de este ticket)
  - Requiere que endpoints estén disponibles y documentados en Swagger
  - Requiere NSwag clients regenerados después de completar este ticket

### Orden de Implementación Recomendado

1. **Primero**: Ticket_ORG001_T003-DB (estructura de datos)
2. **Segundo**: Este ticket (Ticket_ORG001_T002-BE) - Backend con endpoints
3. **Tercero**: Regenerar NSwag clients en proyecto frontend
4. **Cuarto**: Ticket_ORG001_T001-FE (frontend que consume endpoints)

### Verificación de Dependencias Antes de Empezar

Ejecutar checklist de dependencias:
- [ ] PostgreSQL instalado y ejecutándose
- [ ] Base de datos creada (o permisos para crearla con EF Core)
- [ ] ActiveMQ Artemis instalado y ejecutándose
- [ ] Tópico `infoportone.events.organization` accesible
- [ ] Keycloak instalado y ejecutándose
- [ ] Realm InfoportOne configurado con usuarios de prueba
- [ ] .NET 8 SDK instalado y verificado (`dotnet --version`)
- [ ] EF Core Tools instalado (`dotnet ef --version`)
- [ ] Helix6.Base NuGet packages disponibles (pública o feed privado configurado)
- [ ] Proyecto Helix6 base generado con estructura inicial (Api, DataModel, Data, Services, Entities)
- [ ] appsettings.Development.json con ConnectionString válido
- [ ] Ticket_ORG001_T003-DB completado (tablas creadas)

## RECURSOS

- **Helix6 Backend Architecture**: Ver [Helix6_Backend_Architecture.md](Helix6_Backend_Architecture.md) - Documentación completa del framework
  - Sección 2: Estructura de Capas y Proyectos
  - Sección 3: Implementación de Entidades y Repositorios
  - Sección 4: Implementación de Servicios
  - Sección 5: Generación de Endpoints
  - Sección 7: Bootstrapping y Program.cs
  - Sección 10: Seguridad y Autenticación
- **Product Documentation**: Ver [readme.md](readme.md)
  - Sección 3.2.1: Esquema tabla ORGANIZATION
  - Sección 3.2.2: Esquema tabla ORGANIZATIONGROUP
  - Sección 3.2.4: Esquema tabla AUDITLOG
  - Sección 3.2.7: Esquema tabla ORGANIZATION_APPLICATIONMODULE
  - Sección 1.3.1: Estructura de OrganizationEvent
- **Entity Framework Core Documentation**: [Microsoft Docs](https://learn.microsoft.com/en-us/ef/core/)
- **Dapper Documentation**: [GitHub](https://github.com/DapperLib/Dapper)
- **Mapster Documentation**: [GitHub](https://github.com/MapsterMapper/Mapster)
- **Serilog Documentation**: [Serilog.net](https://serilog.net/)
- **ActiveMQ Artemis Documentation**: [Apache ActiveMQ](https://activemq.apache.org/components/artemis/)
- **JWT Bearer Authentication**: [Microsoft Docs](https://learn.microsoft.com/en-us/aspnet/core/security/authentication/)
- **User Story**: [ORG001_Gestion_Organizacion.md](Epic1_UserStories/ORG001_Gestion_Organizacion/ORG001_Gestion_Organizacion.md)
- **Frontend Ticket**: [Ticket_ORG001_T001-FE.md](ORG001_Tickets/Ticket_ORG001_T001-FE.md) (para entender contrato de API)

=============================================================
