# ORG001-T001-FE: Implementar formulario de creación y edición de organización con tres pestañas

=============================================================

**TICKET ID:** ORG001-T001-FE
**EPIC:** Gestión del Portfolio de Organizaciones Clientes  
**USER STORY:** ORG-001 - Crear y editar organización cliente  
**COMPONENT:** Frontend - Angular  
**PRIORITY:** Alta  
**ESTIMATION:** 10 horas  

=============================================================

## TÍTULO
Implementar formulario de creación y edición de organización con Angular Material Tabs y validación por pestaña

## DESCRIPCIÓN
Crear componente Angular para el formulario de creación/edición de organizaciones con estructura de tres pestañas según arquitectura Helix6.

**Pestaña 1 - Datos de Organización:**
- Editable por: Usuarios con permiso `Organization data modification`
- Solo lectura para: Usuarios con permiso `Organization data query` (sin modification)
- Campos: Name, TaxId (CIF), Address, City, PostalCode, Country, ContactEmail, ContactPhone, GroupId
- Validaciones: Name, TaxId, ContactEmail obligatorios
- Al guardar: **NO se publica evento OrganizationEvent**, solo se persiste en BD
- Aparece Pestaña 2 después de guardar si el usuario tiene permiso `Organization modules query` o `Organization modules modification`
 
Nota: El campo `GroupId` se mostrará como un combo desplegable. Las opciones se cargarán desde el endpoint Helix6 `OrganizationGroupClient.getAll()`.

**Pestaña 2 - Módulos y Permisos de Acceso:**
- Editable por: Usuarios con permiso `Organization modules modification`
- Solo lectura para: Usuarios con permiso `Organization modules query` (sin modification)
- Gestión de módulos/aplicaciones asignados mediante grid anidado con inline editing
- **PRIMER evento OrganizationEvent se publica aquí** al asignar el primer módulo a través de la tabla `ORGANIZATION_APPLICATIONMODULE`
- Grid master-detail: Columnas Application (ApplicationId, AppName), Módulos asignados (multiselect de ApplicationModule filtrados por ApplicationId)
- Relación N:M gestionada mediante `ORGANIZATION_APPLICATIONMODULE` (ApplicationModuleId, OrganizationId)

**Pestaña 3 - Auditoría:**
- Solo lectura para: Usuarios con permiso `Organization data query`
- Muestra histórico de cambios críticos desde tabla `AUDITLOG`
- Grid readonly con columnas: Timestamp, Action, UserId (nombre usuario), CorrelationId
- Filtrado server-side: `EntityType='Organization' AND EntityId={organizationId}`
- Acciones auditadas (Epic1): `ModuleAssigned`, `ModuleRemoved`, `OrganizationDeactivatedManual`, `OrganizationAutoDeactivated`, `OrganizationReactivatedManual`, `GroupChanged`
- Paginación server-side obligatoria (tabla puede contener miles de registros)

**Nota sobre eventos**: Los cambios en datos básicos (pestaña 1) NO publican eventos. Solo se publican eventos `OrganizationEvent` cuando:
- Se asigna/remueve un módulo (pestaña 2)
- Se activa/desactiva la organización
- Se cambia el grupo de la organización

## ROLES Y PERMISOS

Esta funcionalidad requiere un control granular de acceso basado en permisos. A continuación se detallan los roles típicos del sistema y los permisos necesarios para cada nivel de acceso.

### Permisos Requeridos

Añadir al enum `Access` en `src/app/theme/access/access.ts`:

| Permiso | Valor Sugerido | Descripción | Funcionalidad |
|---------|----------------|-------------|---------------|
| `Organization data modification` | 200 | Modificar datos de organización | Crear/editar nombre, TaxId, dirección y datos de contacto de organizaciones en Pestaña 1 |
| `Organization data query` | 201 | Consultar datos de organización | Ver en modo solo lectura los datos básicos de organizaciones (Pestaña 1) y acceso a Pestaña 3 (Auditoría) |
| `Organization modules modification` | 202 | Modificar módulos de organización | Asignar/desasignar módulos y aplicaciones a organizaciones en Pestaña 2 |
| `Organization modules query` | 203 | Consultar módulos de organización | Ver en modo solo lectura los módulos asignados a organizaciones en Pestaña 2 |

### Roles y Combinaciones de Permisos

| Rol | Permisos Asociados | Nivel de Acceso | Pestañas Disponibles |
|-----|-------------------|-----------------|----------------------|
| **Organization Administrator** | • `Organization data modification` (200)<br>• `Organization data query` (201)<br>• `Organization modules modification` (202)<br>• `Organization modules query` (203) | **Acceso completo**: Puede crear/editar organizaciones, gestionar todos los módulos asignados y consultar auditoría | Pestaña 1 (Editable)<br>Pestaña 2 (Editable)<br>Pestaña 3 (Solo lectura) |
| **Organization Manager** | • `Organization data modification` (200)<br>• `Organization data query` (201) | **Gestión de datos**: Puede crear/editar datos básicos de organizaciones. Solo puede **visualizar** módulos asignados (no modificarlos) | Pestaña 1 (Editable)<br>Pestaña 2 (Solo lectura)<br>Pestaña 3 (Solo lectura) |
| **Application Manager** | • `Organization modules modification` (202)<br>• `Organization modules query` (203)<br>• `Organization data query` (201) | **Gestión de módulos**: Puede asignar/modificar módulos. Solo puede **visualizar** datos básicos de organizaciones (no modificarlos) | Pestaña 1 (Solo lectura)<br>Pestaña 2 (Editable)<br>Pestaña 3 (Solo lectura) |
| **Organization Viewer** | • `Organization data query` (201)<br>• `Organization modules query` (203) | **Solo lectura completa**: Puede ver toda la información pero no puede realizar modificaciones | Pestaña 1 (Solo lectura)<br>Pestaña 2 (Solo lectura)<br>Pestaña 3 (Solo lectura) |
| **Data Viewer** | • `Organization data query` (201) | **Lectura limitada**: Solo puede ver datos básicos y auditoría, sin acceso a módulos | Pestaña 1 (Solo lectura)<br>Pestaña 2 (Oculta)<br>Pestaña 3 (Solo lectura) |

### Matriz de Control de UI por Permiso

| Elemento UI | Permiso Requerido | Estado sin Permiso | Estado con Permiso Query | Estado con Permiso Modification |
|-------------|-------------------|--------------------|--------------------------|---------------------------------|
| **Pestaña 1 - Formulario** | `Organization data query` | Oculto / Error | Solo lectura (campos disabled) | Editable (campos enabled) |
| **Pestaña 1 - Botón Guardar** | `Organization data modification` | Oculto | Oculto | Visible y habilitado |
| **Pestaña 1 - Combo Grupo** | `Organization data query` | Oculto | Solo lectura (disabled) | Editable (enabled) |
| **Pestaña 2 - Tab** | `Organization modules query` | Oculta | Visible | Visible |
| **Pestaña 2 - Grid Módulos** | `Organization modules query` | N/A | Solo lectura (sin inline edit) | Editable (inline edit habilitado) |
| **Pestaña 2 - Botón Asignar Módulo** | `Organization modules modification` | Oculto | Oculto | Visible y habilitado |
| **Pestaña 2 - Botón Remover Módulo** | `Organization modules modification` | Oculto | Oculto | Visible y habilitado |
| **Pestaña 3 - Tab Auditoría** | `Organization data query` | Oculta | Visible (solo lectura) | Visible (solo lectura) |
| **Pestaña 3 - Grid Auditoría** | `Organization data query` | N/A | Solo lectura (siempre) | Solo lectura (siempre) |

### Flujo de Trabajo Recomendado

**Caso 1: Creación completa por Organization Administrator**
1. Usuario con permisos 200, 201, 202, 203 accede al formulario
2. Completa Pestaña 1 (Datos de Organización) → Guarda (sin publicar evento)
3. Automáticamente puede acceder a Pestaña 2 (Módulos)
4. Asigna módulos mediante grid inline → Guarda → **Se publica el primer OrganizationEvent**
5. Puede consultar Pestaña 3 (Auditoría) para ver acción `ModuleAssigned`

**Caso 2: Creación colaborativa (Organization Manager + Application Manager)**
1. Organization Manager (permisos 200, 201) crea organización en Pestaña 1 → Guarda
2. Organization Manager puede ver Pestaña 2 pero en **solo lectura** y Pestaña 3
3. Application Manager (permisos 201, 202, 203) accede a la organización creada
4. Application Manager puede ver Pestaña 1 en **solo lectura**
5. Application Manager edita Pestaña 2 y asigna módulos → Guarda → **Se publica el primer OrganizationEvent**
6. Ambos roles pueden consultar Pestaña 3 para ver histórico de cambios

**Caso 3: Consulta (Organization Viewer)**
- Usuario con permisos 201, 203 puede navegar por las 3 pestañas
- Todos los campos y grids están en modo **solo lectura**
- No se muestran botones de guardar/editar/asignar/remover

**Caso 4: Consulta limitada (Data Viewer)**
- Usuario con permiso 201 solo ve Pestaña 1 y Pestaña 3 en **solo lectura**
- Pestaña 2 está **oculta** (no tiene permiso 203)

### Validación de Permisos en UI

El componente debe implementar las siguientes validaciones usando `AccessService`:

```typescript
// Pseudocódigo de validación
canViewBasicData = accessService.hasAccess(Access['Organization data query']);
canEditBasicData = accessService.hasAccess(Access['Organization data modification']);
canViewModules = accessService.hasAccess(Access['Organization modules query']);
canEditModules = accessService.hasAccess(Access['Organization modules modification']);
```

**Mensajes de estado:**
- **Sin permisos de query**: Mensaje de error "No tiene permisos para ver esta información"
- **Solo permisos de query**: Mensaje informativo "Visualización en modo solo lectura"
- **Con permisos de modification**: Sin mensaje (modo edición normal)

**Nota importante:** Los permisos deben configurarse en backend y asociarse a usuarios/roles mediante la gestión de identidad (Keycloak). El frontend solo verifica los permisos recibidos desde la API `GetPermissions`.

## BACKEND Y CONTRATO HELIX6

El frontend utilizará los endpoints genéricos de Helix6 auto-generados para la entidad `Organization`. A continuación se detallan los endpoints específicos, sus configuraciones de carga y el comportamiento esperado.

### Endpoints Utilizados

#### 1. GetById - Cargar Organización Existente

**Endpoint**: `GET /api/Organization/GetById`

**Parámetros**:
- `id` (int, required): ID de la organización
- `configurationName` (string, required): `"OrganizationComplete"`
- `Accept-Language` (header): Idioma del usuario (es, en, ca)

**Configuración de Carga `OrganizationComplete`**:

Esta configuración debe definirse en el `OrganizationRepository` del backend y carga:

1. **Entidad base Organization**: Todos los campos de la tabla `ORGANIZATION`
   - Id, SecurityCompanyId, Name, TaxId, Address, City, PostalCode, Country, ContactEmail, ContactPhone
   - GroupId (FK), AuditCreationUser, AuditCreationDate, AuditModificationUser, AuditModificationDate, AuditDeletionDate

2. **Navegación OrganizationGroup**: Carga el grupo asociado si `GroupId != null`
   - Incluye: Id, GroupName, Description

3. **Colección ApplicationModules**: Carga todos los módulos asignados mediante tabla `ORGANIZATION_APPLICATIONMODULE`
   - Para cada registro activo (AuditDeletionDate IS NULL):
     - ApplicationModuleId (FK)
     - **Navegación ApplicationModule**: ModuleName, Description, DisplayOrder, ApplicationId (FK)
       - **Navegación anidada Application**: AppName, Description, RolePrefix

4. **Colección AuditLogs**: Carga histórico de auditoría filtrado
   - Filtro: `EntityType='Organization' AND EntityId={id} AND AuditDeletionDate IS NULL`
   - Ordenado por: Timestamp DESC
   - Incluye: Id, Action, EntityType, EntityId, UserId, Timestamp, CorrelationId

**Response esperado** (OrganizationView):
```typescript
{
  id: number;
  securityCompanyId: number;
  name: string;
  taxId: string;
  address?: string;
  city?: string;
  postalCode?: string;
  country?: string;
  contactEmail?: string;
  contactPhone?: string;
  groupId?: number;
  organizationGroup?: {
    id: number;
    groupName: string;
    description?: string;
  };
  applicationModules?: [
    {
      id: number; // ORGANIZATION_APPLICATIONMODULE.Id
      applicationModuleId: number;
      applicationModule: {
        id: number;
        moduleName: string;
        description?: string;
        displayOrder: number;
        applicationId: number;
        application: {
          id: number;
          appName: string;
          description?: string;
          rolePrefix: string;
        };
      };
    }
  ];
  auditLogs?: [
    {
      id: number;
      action: string;
      entityType: string;
      entityId: string;
      userId?: number;
      timestamp: Date;
      correlationId?: string;
    }
  ];
  auditCreationDate: Date;
  auditModificationDate?: Date;
}
```

#### 2. GetNewEntity - Obtener Plantilla para Nueva Organización

**Endpoint**: `GET /api/Organization/GetNewEntity`

**Parámetros**:
- `Accept-Language` (header): Idioma del usuario

**Response esperado**: OrganizationView con valores por defecto (todos los campos null excepto colecciones vacías)

**Uso**: Al abrir el formulario en modo creación para inicializar el FormGroup con valores vacíos.

#### 3. Insert - Crear Nueva Organización

**Endpoint**: `POST /api/Organization/Insert`

**Parámetros**:
- `configurationName` (string, required): `"OrganizationComplete"`
- `reloadView` (bool, optional): `true` (para recibir entidad con Id generado)
- `Accept-Language` (header): Idioma del usuario

**Body**: OrganizationView completo (igual estructura que GetById response)

**Comportamiento esperado según permisos del usuario**:

1. **Si el usuario tiene permiso `Organization data modification` (200)**:
   - El backend persiste los campos de la Pestaña 1 (Name, TaxId, Address, etc.)
   - Genera automáticamente `SecurityCompanyId` (auto-increment)
   - **NO persiste** la colección `ApplicationModules` (aunque se envíe en el payload)
   - **NO publica** evento `OrganizationEvent`
   - Retorna OrganizationView con Id y SecurityCompanyId generados

2. **Si el usuario tiene permiso `Organization modules modification` (202)**:
   - Si se envía la colección `ApplicationModules` en el payload:
     - Persiste relaciones en tabla `ORGANIZATION_APPLICATIONMODULE`
     - **Publica evento `OrganizationEvent`** con payload completo incluyendo Apps y AccessibleModules
     - Registra acción `ModuleAssigned` en tabla `AUDITLOG` por cada módulo asignado

**Validaciones backend**:
- Name, TaxId, ContactEmail obligatorios (Helix6 FluentValidation)
- TaxId único (excluir soft-deleted)
- Name único (excluir soft-deleted)
- GroupId debe existir y estar activo si se proporciona
- ApplicationModuleId debe existir y estar activo

**Response**: OrganizationView completo con configuración `OrganizationComplete`

#### 4. Update - Actualizar Organización Existente

**Endpoint**: `PUT /api/Organization/Update`

**Parámetros**:
- `configurationName` (string, required): `"OrganizationComplete"`
- `reloadView` (bool, optional): `true`
- `Accept-Language` (header): Idioma del usuario

**Body**: OrganizationView completo con Id existente

**Comportamiento esperado según permisos del usuario**:

1. **Si el usuario tiene permiso `Organization data modification` (200)**:
   - Actualiza campos de Pestaña 1
   - **NO actualiza** la colección `ApplicationModules`
   - **NO publica** evento si solo cambian datos básicos
   - Si cambia `GroupId`: **Sí publica** evento `OrganizationEvent` y registra acción `GroupChanged` en `AUDITLOG`

2. **Si el usuario tiene permiso `Organization modules modification` (202)**:
   - Si la colección `ApplicationModules` cambia:
     - Detecta módulos añadidos: Crea registros en `ORGANIZATION_APPLICATIONMODULE`, publica evento, registra `ModuleAssigned`
     - Detecta módulos removidos: Marca `AuditDeletionDate` en `ORGANIZATION_APPLICATIONMODULE`, publica evento, registra `ModuleRemoved`
     - **Publica evento `OrganizationEvent`** con estado final completo

**Validaciones backend**:
- Mismas validaciones que Insert
- Id debe existir y no estar soft-deleted

**Response**: OrganizationView actualizado con configuración `OrganizationComplete`

### Endpoints Adicionales Necesarios

#### 5. OrganizationGroupClient.getAll - Cargar Grupos para Combo

**Endpoint**: `GET /api/OrganizationGroup/GetAll`

**Parámetros**:
- `Accept-Language` (header): Idioma del usuario

**Response**: Array de OrganizationGroupView
```typescript
[
  {
    id: number;
    groupName: string;
    description?: string;
  }
]
```

**Uso**: Popular el combo desplegable de GroupId en Pestaña 1.

#### 6. ApplicationClient.getAllKendoFilter - Cargar Aplicaciones para Grid Anidado

**Endpoint**: `POST /api/Application/GetAllKendoFilter`

**Parámetros**:
- `configurationName` (string): `"ApplicationWithModules"`
- `includeDeleted` (bool): `false`
- `Accept-Language` (header): Idioma del usuario

**Body**: KendoGridFilter (vacío para obtener todas)

**Response**: PagingResponse con lista de ApplicationView incluyendo navegación a ApplicationModules

**Uso**: Popular el grid de aplicaciones disponibles en Pestaña 2 con sus módulos asociados.

#### 7. AuditLogClient.getAllKendoFilter - Cargar Auditoría

**Endpoint**: `POST /api/AuditLog/GetAllKendoFilter`

**Parámetros**:
- `configurationName` (string): `""` (sin navegaciones, tabla plana)
- `includeDeleted` (bool): `false`
- `Accept-Language` (header): Idioma del usuario

**Body**: KendoGridFilter con filtro server-side
```typescript
{
  data: {
    filter: {
      logic: 'and',
      filters: [
        { field: 'entityType', operator: 'eq', value: 'Organization' },
        { field: 'entityId', operator: 'eq', value: organizationId.toString() }
      ]
    },
    sort: [{ field: 'timestamp', dir: 'desc' }],
    skip: 0,
    take: 20
  }
}
```

**Response**: PagingResponse con lista de AuditLogView y count total

**Uso**: Popular el grid de auditoría en Pestaña 3 con paginación server-side.

### Gestión de Permisos en Backend

El backend **debe** validar permisos usando `IUserContext` y `IUserPermissions` (provistos por Helix6):

1. **En OrganizationService.ValidateView()**: Verificar que el usuario tiene permiso para la operación solicitada
2. **En OrganizationService.PreviousActions()**: Filtrar qué partes del payload se procesarán según permisos
3. **En OrganizationService.PostActions()**: Decidir si publicar evento según cambios realizados

**Ejemplo de lógica backend** (pseudocódigo):
```csharp
// En Insert/Update
if (userHasPermission("Organization modules modification") && moduleCollectionChanged)
{
    // Persistir cambios en ORGANIZATION_APPLICATIONMODULE
    // Publicar OrganizationEvent
    // Registrar en AUDITLOG
}
else if (moduleCollectionChanged && !userHasPermission("Organization modules modification"))
{
    // Ignorar cambios en módulos (no error, solo ignorar)
}
```

### Notas Importantes

1. **Arquitectura Event-Driven**: El backend es responsable de publicar eventos `OrganizationEvent` a ActiveMQ Artemis. El frontend **no debe** preocuparse por esto.

2. **Configuraciones de Carga**: El nombre `OrganizationComplete` debe estar documentado en el ticket backend (Ticket_ORG001_T002-BE) y definido en `OrganizationRepository.cs`.

3. **Auditoría Dual**:
   - **Helix6 Base Audit**: Todos los cambios se registran automáticamente en campos `Audit*` de la entidad
   - **AUDITLOG selectivo**: Solo 6 acciones críticas se registran explícitamente (ModuleAssigned, ModuleRemoved, OrganizationDeactivatedManual, OrganizationAutoDeactivated, OrganizationReactivatedManual, GroupChanged)

4. **Soft Delete**: Todas las entidades usan `AuditDeletionDate` para soft delete. El frontend debe filtrar registros con `AuditDeletionDate != null`.

## GUÍA DE IMPLEMENTACIÓN CON HELIX6

Esta sección describe los pasos ordenados para implementar el formulario de organización siguiendo los patrones de arquitectura Helix6 y CommonLibrary. **No incluye código**, solo la secuencia de acciones.

### Paso 0: Definir Permisos en Access Enum

1. Abrir archivo `src/app/theme/access/access.ts`
2. Añadir 4 nuevos permisos al enum `Access` con valores numéricos sugeridos 200-203:
   - `'Organization data modification' = 200`
   - `'Organization data query' = 201`
   - `'Organization modules modification' = 202`
   - `'Organization modules query' = 203`
3. Guardar archivo

### Paso 1: Crear Estructura de Componentes

1. Crear carpeta `src/app/modules/organizations/components/organization-form/`
2. Crear componente standalone `organization-form.component.ts` con decorador `@Component`:
   - Selector: `app-organization-form`
   - Imports: CommonModule, ReactiveFormsModule, TranslateModule, MatTabsModule, ClInputComponent, ClComboBoxComponent, ClGridComponent, ClButtonComponent
   - Providers: OrganizationClient, OrganizationGroupClient, ApplicationClient, AuditLogClient (NSwag clients)
3. Crear archivos complementarios:
   - `organization-form.component.html`
   - `organization-form.component.scss`
   - `organization-form.component.spec.ts`

### Paso 2: Implementar Inyección de Dependencias y Propiedades

1. Usar función `inject()` para inyectar servicios como propiedades readonly:
   - `private readonly organizationClient = inject(OrganizationClient)`
   - `private readonly organizationGroupClient = inject(OrganizationGroupClient)`
   - `private readonly applicationClient = inject(ApplicationClient)`
   - `private readonly auditLogClient = inject(AuditLogClient)`
   - `private readonly fb = inject(FormBuilder)`
   - `private readonly accessService = inject(AccessService)`
   - `private readonly translate = inject(TranslateService)`
   - `private readonly sharedMessageService = inject(SharedMessageService)`
   - `private readonly kendoFiltersService = inject(KendoFiltersService)`
2. Declarar propiedades del componente:
   - `@Input() organizationId: number = 0` (0 = creación, >0 = edición)
   - `organizationForm: FormGroup` (formulario reactivo para Pestaña 1)
   - `canViewBasicData: boolean`, `canEditBasicData: boolean`
   - `canViewModules: boolean`, `canEditModules: boolean`
   - `organizationGroups: IOrganizationGroupView[]` (datos para combo)
   - `modulesGridData: GridDataResult` (datos para grid de módulos en Pestaña 2)
   - `auditGridData: GridDataResult` (datos para grid de auditoría en Pestaña 3)
   - `selectedTabIndex: number = 0` (índice de pestaña activa)

### Paso 3: Inicializar Permisos en ngOnInit

1. En el método `ngOnInit()`:
   - Llamar a `AccessService.hasAccess()` para cada uno de los 4 permisos
   - Asignar resultados a propiedades booleanas del componente
   - Si `!canViewBasicData`: Mostrar mensaje de error y retornar early
2. Cargar datos iniciales:
   - Si `organizationId > 0`: Llamar a `organizationClient.getById(organizationId, 'OrganizationComplete')`
   - Si `organizationId === 0`: Llamar a `organizationClient.getNewEntity()`
3. Llamar a `organizationGroupClient.getAll()` para popular combo de grupos
4. Inicializar FormGroup con `FormBuilder.group()`:
   - Definir FormControl para cada campo (name, taxId, address, city, postalCode, country, contactEmail, contactPhone, groupId)
   - Añadir Validators: `Validators.required` para name, taxId, contactEmail
   - Añadir validador custom para taxId (regex CIF español si aplica)
5. Si `!canEditBasicData`: Llamar a `organizationForm.disable()` para modo solo lectura

### Paso 4: Implementar Template HTML con Material Tabs

1. Crear estructura de pestañas usando `<mat-tab-group>`:
   - Binding: `[(selectedIndex)]="selectedTabIndex"`
2. **Pestaña 1 - Datos de Organización**:
   - Usar directiva `*ngIf="canViewBasicData"` para mostrar/ocultar
   - Crear formulario con `[formGroup]="organizationForm"`
   - Campos usando componentes CommonLibrary:
     - `<cl-input>` para: name, taxId, address, city, postalCode, country, contactEmail, contactPhone
     - `<cl-combo-box>` para: groupId (binding a `organizationGroups`, textField="groupName", valueField="id")
   - Cada campo con:
     - `[label]` usando pipe translate: `{{ 'ORGANIZATIONS.NAME' | translate }}`
     - `[formControlName]` apuntando al control del FormGroup
     - `[disabled]` binding a `!canEditBasicData`
   - Botón "Guardar" al final:
     - `*ngIf="canEditBasicData"`
     - `[disabled]="organizationForm.invalid"`
     - `(click)="onSaveBasicData()"`
3. **Pestaña 2 - Módulos y Permisos**:
   - Usar directiva `*ngIf="canViewModules"` para mostrar/ocultar
   - Mensaje si organización no está guardada: `*ngIf="organizationId === 0"` → "Debe guardar la organización antes de asignar módulos"
   - Si `organizationId > 0`: Renderizar `<cl-grid>` con:
     - `[config]="modulesGridConfig"` (ClGridConfig con definición de columnas)
     - `[data]="modulesGridData"`
     - `[loading]="loadingModules"`
     - `(changesSaved)="onModulesSaved($event)"` (para inline editing)
   - Configurar ClGridConfig:
     - Columnas: Application (texto), Módulos asignados (multiselect editable si `canEditModules`)
     - `edition.mode = 'row'` si `canEditModules`, sino sin edición
     - Endpoints para inline save apuntando a `Organization.Update` con payload completo
4. **Pestaña 3 - Auditoría**:
   - Usar directiva `*ngIf="canViewBasicData"` (cualquiera con acceso a datos puede ver auditoría)
   - Mensaje si organización no está guardada: `*ngIf="organizationId === 0"` → "La auditoría estará disponible después de guardar"
   - Si `organizationId > 0`: Renderizar `<cl-grid>` con:
     - `[config]="auditGridConfig"` (ClGridConfig en modo solo lectura)
     - `[data]="auditGridData"`
     - `(dataStateChange)="onAuditStateChange($event)"` (paginación server-side)
   - Configurar ClGridConfig:
     - Columnas: Timestamp (fecha formateada), Action (traducida), UserId (nombre usuario), CorrelationId
     - `sortable.mode = 'single'`, sort inicial por timestamp DESC
     - `pageable` con pageSizes [10, 20, 50]
     - Sin edición (grid readonly)

### Paso 5: Implementar Métodos de Guardado

1. **Método `onSaveBasicData()`**:
   - Validar formulario: `if (!organizationForm.valid) return;`
   - Obtener datos con `organizationForm.getRawValue()` (incluye campos disabled)
   - Si `organizationId === 0`:
     - Llamar a `organizationClient.insert(payload, 'OrganizationComplete', true)`
     - En respuesta: Asignar `organizationId = response.id`
     - Mostrar toast de éxito con `sharedMessageService.showSuccess()`
     - Si `canViewModules`: Cambiar a Pestaña 2 con `selectedTabIndex = 1`
   - Si `organizationId > 0`:
     - Llamar a `organizationClient.update(payload, 'OrganizationComplete', true)`
     - En respuesta: Actualizar FormGroup con datos frescos
     - Mostrar toast de éxito
2. **Método `onModulesSaved(event)`**:
   - Recibir evento desde grid anidado con cambios en módulos
   - Construir payload completo de OrganizationView incluyendo colección `applicationModules` modificada
   - Llamar a `organizationClient.update(payload, 'OrganizationComplete', true)`
   - En respuesta: Recargar grid de módulos con datos frescos
   - Mostrar toast indicando que se publicó evento (si aplica)
   - Recargar Pestaña 3 (auditoría) para mostrar nueva acción `ModuleAssigned` o `ModuleRemoved`

### Paso 6: Implementar Carga de Grid de Auditoría con Paginación Server-Side

1. **Método `loadAuditLog(state?: State)`**:
   - Construir objeto KendoGridFilter con filtros:
     - `entityType = 'Organization'`
     - `entityId = organizationId.toString()`
   - Si `state` contiene paginación/ordenación: Incluir en el filter
   - Llamar a `auditLogClient.getAllKendoFilter(filter, '', false)`
   - En respuesta: Asignar a `auditGridData = { data: response.list, total: response.count }`
2. **Método `onAuditStateChange(state: State)`**:
   - Llamar a `loadAuditLog(state)` para recargar con nueva página/ordenación

### Paso 7: Implementar Carga de Grid de Módulos

1. **Método `loadModulesGrid()`**:
   - Si la respuesta de `getById` ya incluye `applicationModules` (configuración `OrganizationComplete`):
     - Transformar datos para el grid:
       - Agrupar por Application
       - Para cada aplicación, mostrar array de módulos asignados
     - Asignar a `modulesGridData`
   - Configurar ClGridConfig para inline editing:
     - Columna Application (readonly, texto)
     - Columna Módulos (multiselect editable con lista de módulos disponibles filtrados por ApplicationId)
     - Definir endpoints de edición inline apuntando a método `onModulesSaved`

### Paso 8: Configurar ClGridConfig para Cada Grid

1. **Para grid de módulos (Pestaña 2)**:
   - Crear instancia de `ClGridConfig` con:
     - `idGrid: 'organizationModulesGrid'`
     - `columns`: Array de ClGridColumn
       - Columna 1: field='application.appName', title traducido, editor=null (readonly)
       - Columna 2: field='modules', title traducido, editor={ type: 'custom', customTemplate: multiselect de módulos }
     - `edition`: ClGridEdition con mode='row' si `canEditModules`, allowAdding/allowDeleting según permisos
     - `filterable`, `sortable`, `pageable` según necesidad
2. **Para grid de auditoría (Pestaña 3)**:
   - Crear instancia de `ClGridConfig` con:
     - `idGrid: 'organizationAuditGrid'`
     - `columns`: Array de ClGridColumn
       - Timestamp (fecha formateada), Action (traducida), UserId, CorrelationId
     - `sortable.mode = 'single'`, sort inicial timestamp DESC
     - `pageable` con server-side paging
     - Sin edición (readonly)

### Paso 9: Añadir Traducciones

1. Abrir archivos de traducción en `src/assets/i18n/`:
   - `es.json`
   - `en.json`
   - `ca.json`
2. Añadir claves para el módulo de organizaciones:
   - Estructura sugerida: `ORGANIZATIONS.TITLE`, `ORGANIZATIONS.NAME`, `ORGANIZATIONS.TAXID`, etc.
   - Traducciones para pestañas: `ORGANIZATIONS.TABS.BASIC_DATA`, `ORGANIZATIONS.TABS.MODULES`, `ORGANIZATIONS.TABS.AUDIT`
   - Traducciones para acciones de auditoría: `AUDIT.ACTIONS.MODULE_ASSIGNED`, `AUDIT.ACTIONS.MODULE_REMOVED`, etc.
   - Mensajes de validación y confirmación
3. Usar pipe `translate` en todos los textos del template: `{{ 'ORGANIZATIONS.NAME' | translate }}`

### Paso 10: Configurar Routing

1. Abrir archivo de rutas del módulo organizations (ej: `organizations.routes.ts`)
2. Añadir ruta para el formulario de organización:
   - Path: `'organizations/:id/edit'` (id = 0 para creación)
   - Component: OrganizationFormComponent
   - Metadata: título traducido, permisos requeridos usando guard
3. Si existe componente de listado (organization-list), añadir navegación al formulario al hacer clic en editar/crear

### Paso 11: Implementar Validaciones Custom

1. **Validador de TaxId** (CIF español):
   - Crear función validadora que verifique formato con regex
   - Añadir al FormControl de taxId: `Validators.pattern(/^[A-Z]\d{8}$/)`
2. **Validación de unicidad** (opcional, backend ya valida):
   - Implementar AsyncValidator que llame a endpoint de verificación
   - Añadir al FormControl de name y taxId

### Paso 12: Implementar Tests Unitarios

1. Crear archivo `organization-form.component.spec.ts`
2. Configurar TestBed con:
   - MockProviders para todos los clients (OrganizationClient, etc.)
   - MockProviders para AccessService (retornar permisos mockeados)
   - Imports necesarios (ReactiveFormsModule, TranslateModule.forRoot(), etc.)
3. Escribir tests para:
   - **Inicialización**: Verificar que permisos se verifican correctamente
   - **Carga de datos**: Mockear respuesta de `getById` y verificar que FormGroup se populate
   - **Validaciones**: Verificar que campos requeridos muestran error
   - **Guardado**: Mockear `insert`/`update` y verificar que se llama con payload correcto
   - **Permisos**: Verificar que botones/campos se deshabilitan según permisos
   - **Navegación entre pestañas**: Verificar que pestaña 2 solo aparece después de guardar
4. Objetivo: Cobertura > 80%

### Paso 13: Implementar Tests End-to-End

1. Crear archivo `organization-form.e2e.spec.ts` (si el proyecto usa Cypress/Playwright)
2. Escribir tests para flujos completos:
   - **Flujo de creación completa** (Organization Administrator):
     - Login como admin
     - Navegar a formulario de creación
     - Completar Pestaña 1, guardar
     - Verificar que aparece Pestaña 2
     - Asignar módulos, guardar
     - Verificar que aparece acción en Pestaña 3
   - **Flujo de edición colaborativa**:
     - Login como Organization Manager
     - Crear organización (solo Pestaña 1)
     - Logout, login como Application Manager
     - Editar organización, asignar módulos
     - Verificar evento publicado
   - **Flujo de solo lectura** (Organization Viewer):
     - Login como viewer
     - Verificar que todos los campos están disabled
     - Verificar que no aparecen botones de guardar

### Paso 14: Añadir Estilos SCSS

1. Abrir archivo `organization-form.component.scss`
2. Añadir estilos para:
   - Layout responsive usando grid Bootstrap (row/col)
   - Espaciado entre campos de formulario
   - Estilos para pestañas Material (personalización si necesaria)
   - Estilos para grids (altura fija, scrollbar, etc.)
   - Estilos para mensajes de estado (solo lectura, sin permisos)
3. Usar variables de tema definidas en `src/styles.scss` para consistencia

### Paso 15: Añadir Accesibilidad

1. Añadir atributos ARIA a elementos interactivos:
   - `aria-label` en botones sin texto
   - `aria-required="true"` en campos obligatorios
   - `role="tabpanel"` en contenido de pestañas
2. Verificar navegación por teclado:
   - Tab para moverse entre campos
   - Enter para guardar formulario
   - Flechas para cambiar pestañas
3. Añadir mensajes de error accesibles usando `aria-describedby`

### Paso 16: Code Review y Ajustes

1. Ejecutar linter: `npm run lint` y corregir errores
2. Ejecutar tests: `npm test` y verificar que todos pasan
3. Verificar que no hay console.log olvidados
4. Revisar que todos los textos usan traducciones (no hardcoded)
5. Verificar que imports solo incluyen lo necesario (tree-shaking)
6. Solicitar code review al equipo

## CONTEXTO TÉCNICO

- **Framework**: Angular 20.1.6 con Standalone Components
- **UI Components**: 
  - Angular Material Tabs para navegación entre pestañas
  - CommonLibrary (@cl/common-library) para formularios y grids:
    - `cl-input` para campos de texto
    - `cl-combo-box` para selección de grupo
    - `cl-grid` para grids de módulos y auditoría
    - `cl-modal-service` si se usa en contexto de modal
- **Validación**: Reactive Forms con validadores custom (TaxId pattern)
- **Estado**: Signals de Angular (opcional) o propiedades tradicionales para gestionar estado de pestañas
- **Permisos**: AccessService para verificar permisos del usuario (valores numéricos 200-203)
- **Routing**: Navegación con parámetros de ruta `:id` (0 para creación, >0 para edición)
- **Backend Integration**: NSwag clients auto-generados desde Swagger del backend Helix6
- **Traducciones**: ngx-translate con archivos JSON (es, en, ca)

## CRITERIOS DE ACEPTACIÓN TÉCNICOS

- [ ] 4 permisos añadidos al enum Access con valores 200-203
- [ ] Componente OrganizationFormComponent creado como standalone con 3 pestañas Material
- [ ] Pestaña 1 implementada con todos los campos usando componentes cl-input y cl-combo-box
- [ ] Validaciones reactivas implementadas (Name, TaxId, ContactEmail obligatorios)
- [ ] TaxId validado con regex pattern español (formato CIF)
- [ ] Combo de grupos carga datos desde OrganizationGroupClient.getAll()
- [ ] Pestaña 2 implementada con grid cl-grid de módulos con inline editing
- [ ] Grid de módulos agrupa por Application y muestra multiselect de módulos asignados
- [ ] Pestaña 3 implementada con grid readonly de auditoría con paginación server-side
- [ ] Grid de auditoría filtra por EntityType='Organization' y EntityId={id}
- [ ] AccessService implementado para verificar 4 permisos por pestaña
- [ ] Campos habilitados/deshabilitados según permisos del usuario
- [ ] Pestaña 2 solo visible después de guardar organización y si usuario tiene permiso 203
- [ ] Pestaña 3 visible solo si usuario tiene permiso 201
- [ ] Integración con NSwag clients: OrganizationClient.getById/insert/update con configuración "OrganizationComplete"
- [ ] Uso de getRawValue() para obtener datos del formulario (incluyendo disabled)
- [ ] Navegación automática a Pestaña 2 después de crear (si tiene permiso 202 o 203)
- [ ] Mensajes de permisos diferenciados (solo lectura vs sin acceso)
- [ ] Todas las etiquetas y mensajes usando TranslateModule (pipe translate)
- [ ] Traducciones añadidas en es.json, en.json, ca.json
- [ ] Notificaciones toast usando SharedMessageService con mensajes traducidos
- [ ] Estilos responsive usando clases Bootstrap grid
- [ ] Providers declarados en el componente (OrganizationClient, OrganizationGroupClient, ApplicationClient, AuditLogClient)
- [ ] Inyección de dependencias usando inject() con readonly
- [ ] Tests unitarios con cobertura > 80%
- [ ] Tests verifican navegación automática a módulos
- [ ] Tests verifican permisos usando métodos de AccessService
- [ ] Tests verifican carga de grupos de organizaciones
- [ ] Tests verifican guardado sin publicar evento en Pestaña 1
- [ ] Tests verifican publicación de evento al asignar módulos en Pestaña 2
- [ ] Tests verifican que grid de auditoría se recarga después de asignar módulos
- [ ] Tests E2E del flujo completo de creación (3 pestañas)
- [ ] Code review aprobado
- [ ] Accesibilidad verificada (aria labels, navegación por teclado)

## DEPENDENCIAS

Este ticket frontend tiene las siguientes dependencias técnicas y funcionales:

### Tickets Backend/Base de Datos (Bloqueantes)

- **Ticket_ORG001_T002-BE**: Implementación del servicio backend OrganizationService con:
  - Endpoint `GetById` con configuración de carga `OrganizationComplete` que incluye:
    - Navegación a OrganizationGroup
    - Colección ApplicationModules con navegación a ApplicationModule y Application
    - Colección AuditLogs filtrada por EntityType y EntityId
  - Endpoints `Insert` y `Update` con lógica de permisos:
    - Persistencia selectiva según permisos del usuario
    - Publicación de evento OrganizationEvent solo cuando corresponde (asignación de módulos, cambio de grupo)
    - Registro de acciones críticas en tabla AUDITLOG
  - Validaciones de negocio (Name, TaxId únicos, GroupId válido)
  
- **Ticket_ORG001_T003-DB**: Creación de estructura de base de datos con:
  - Tabla ORGANIZATION (15 campos incluyendo SecurityCompanyId, GroupId, audit fields)
  - Tabla ORGANIZATIONGROUP (8 campos)
  - Tabla APPLICATION (9 campos incluyendo RolePrefix)
  - Tabla APPLICATIONMODULE (9 campos con FK a Application)
  - Tabla ORGANIZATION_APPLICATIONMODULE (relación N:M con 8 campos)
  - Tabla AUDITLOG (10 campos para registro de 6 acciones críticas)
  - Índices, constraints y foreign keys según diseño
  - Vista VW_ORGANIZATION (opcional para consultas optimizadas)

### Bibliotecas y Dependencias de Frontend

- **@cl/common-library** (versión 2.8.0+): Instalada y configurada con:
  - ClGridComponent para grids de módulos y auditoría
  - ClInputComponent, ClComboBoxComponent para formularios
  - ClModalService (si se usa en contexto modal)
  - ClButtonComponent para acciones
  
- **@angular/material** (versión 20.x): Instalado con:
  - MatTabsModule para navegación entre pestañas
  - MatButtonModule, MatIconModule para UI
  
- **NSwag TypeScript Clients**: Generados desde Swagger del backend con:
  - OrganizationClient con métodos: getById, getNewEntity, insert, update
  - OrganizationGroupClient con método: getAll
  - ApplicationClient con método: getAllKendoFilter (configuración "ApplicationWithModules")
  - AuditLogClient con método: getAllKendoFilter
  - Ubicación: `src/webServicesReferences/api/apiClients.ts`

### Servicios Core de Frontend

- **AccessService** (`src/app/theme/access/access.service.ts`): Configurado con métodos para verificar permisos:
  - `hasAccess(Access['Organization data modification'])` → boolean
  - `hasAccess(Access['Organization data query'])` → boolean
  - `hasAccess(Access['Organization modules modification'])` → boolean
  - `hasAccess(Access['Organization modules query'])` → boolean

- **TranslateModule** (ngx-translate): Configurado en app.config.ts con:
  - HttpLoaderFactory apuntando a `./assets/i18n/`
  - Idiomas soportados: es, en, ca
  - Default language configurado

- **SharedMessageService**: Disponible para mostrar notificaciones toast:
  - `showSuccess(message: string)`
  - `showError(message: string)`
  - `showWarning(message: string)`

### Configuración de Entorno

- **Keycloak/Identity Management**: Configurado con:
  - Permisos 200-203 definidos en el sistema
  - Roles asociados a permisos (Organization Administrator, Organization Manager, etc.)
  - Endpoint GetPermissions devolviendo permisos correctos para organizaciones
  - Claims en JWT token incluyendo permisos del usuario

- **Bootstrap Grid**: Disponible en estilos globales para layout responsive (row/col classes)

### Datos de Prueba (Opcional pero Recomendado)

- Grupos de organizaciones de ejemplo en tabla ORGANIZATIONGROUP
- Aplicaciones de ejemplo en tabla APPLICATION con módulos asociados
- Usuarios de prueba con diferentes combinaciones de permisos (roles del sistema)

### Orden de Implementación Recomendado

1. **Primero**: Ticket_ORG001_T003-DB (estructura de datos)
2. **Segundo**: Ticket_ORG001_T002-BE (lógica de negocio y endpoints)
3. **Tercero**: Generación de NSwag clients (comando `npm run generate-clients` o similar)
4. **Cuarto**: Este ticket (Ticket_ORG001_T001-FE)

### Verificación de Dependencias Antes de Empezar

Ejecutar checklist de dependencias:
- [ ] Tablas de BD creadas y migradas
- [ ] Backend desplegado y endpoints /api/Organization/* disponibles en Swagger
- [ ] NSwag clients regenerados con última versión de Swagger
- [ ] CommonLibrary instalada (`npm list @cl/common-library`)
- [ ] Angular Material instalada (`npm list @angular/material`)
- [ ] Archivos de traducción base creados (es.json, en.json, ca.json)
- [ ] AccessService implementado con método `hasAccess()`
- [ ] Keycloak configurado con permisos 200-203
- [ ] Usuario de prueba con rol Organization Administrator disponible para testing

## RECURSOS

- **Angular Material Tabs**: [Documentation](https://material.angular.io/components/tabs/overview)
- **Angular Reactive Forms**: [Documentation](https://angular.io/guide/reactive-forms)
- **CommonLibrary ClGrid**: Ver Helix6_Frontend_Architecture.md - Sección 6
- **CommonLibrary ClFormFields**: Ver Helix6_Frontend_Architecture.md - Sección 8
- **NSwag Integration**: Ver Helix6_Frontend_Architecture.md - Sección 9
- **Testing Patterns**: Ver Helix6_Frontend_Architecture.md - Sección 13
- **User Story**: Epic1_UserStories/ORG001_Gestion_Organizacion/ORG001_Gestion_Organizacion.md
- **Backend Architecture**: Helix6_Backend_Architecture.md
- **Product Documentation**: readme.md (secciones 3.2.1 ORGANIZATION, 3.2.2 ORGANIZATIONGROUP, 3.2.4 AUDITLOG)
- **Event Schema**: readme.md - Sección 1.3.1 (OrganizationEvent structure)

=============================================================
