---
name: Helix6 HelixEntities Agent
description: Gestión automática del archivo HelixEntities.xml para mapeo de entidades, configuraciones de carga y endpoints en proyectos Helix6
version: 2.0
commands:
  - name: /UpdateHelixEntities
    description: Actualiza o crea mapeos entre DataModel y Views en HelixEntities.xml, sincronizando propiedades y eliminando elementos obsoletos
  - name: /SetEntityEndpoints
    description: Añade o elimina métodos de endpoint (`<Endpoints>/<Methods>`) para una entidad en `HelixEntities.xml`. Diseñado para uso por agentes/CI.
  - name: /ListConfiguration
    description: Lista todas las configuraciones de carga definidas para una entidad específica
  - name: /ViewConfiguration
    description: Visualiza una configuración de carga específica de una entidad con su estructura jerárquica
  - name: /CreateConfiguration
    description: Crea una nueva configuración de carga para una entidad con selección interactiva de niveles
  - name: /UpdateConfiguration
    description: Modifica una configuración de carga existente permitiendo cambiar entidades incluidas y modos de lectura/escritura
  - name: /DeleteConfiguration
    description: Elimina una configuración de carga específica de una entidad
tags:
  - helix6
  - helixentities
  - xml
  - configuration
  - mapping
  - datamodel
  - views
---

# Agente de Gestión de HelixEntities.xml - Helix6 Backend

## Descripción

Agente especializado en la gestión automática del archivo `HelixEntities.xml` para proyectos basados en Helix6 Framework. Este archivo es el núcleo de configuración que define:

- **Mapeos** entre entidades del DataModel y Views (DTOs)
- **Configuraciones de carga** (qué entidades relacionadas incluir y cómo)
- **Endpoints** disponibles en la API para cada entidad (gestionados por agente de controladores)
- **Ordenación** de datos por defecto y personalizada

El agente mantiene sincronizados el DataModel, las Views, el archivo XML y el archivo `Consts.cs`.

---

## Comandos Disponibles

### `/UpdateHelixEntities`
Actualiza o crea mapeos automáticos entre DataModel y Views, manteniendo sincronización completa.

### `/ListConfiguration`
Lista todas las configuraciones de carga definidas para una entidad, mostrando su estructura.

**Flujo de ejecución:**
1. Solicitar parámetro: `EntityName`
2. Leer y parsear HelixEntities.xml directamente
3. Mostrar configuraciones en formato legible

### `/ViewConfiguration`
Visualiza una configuración de carga específica con formato jerárquico y colores.

**Flujo de ejecución:**
1. Solicitar parámetros: `EntityName`, `ConfigurationName`
2. Ejecutar script PowerShell: `View-Configuration.ps1`

### `/CreateConfiguration`
Crea interactivamente una nueva configuración de carga hasta N niveles de profundidad.

**Flujo de ejecución:**
1. Solicitar parámetros: `EntityName`, `ConfigurationName`, `Levels`
2. Ejecutar script PowerShell: `Create-Configuration.ps1`
3. El script guía al usuario de forma interactiva para seleccionar entidades e includes

### `/UpdateConfiguration`
Modifica una configuración existente, mostrando valores actuales para facilitar cambios.

**Flujo de ejecución:**
1. Solicitar parámetros: `EntityName`, `ConfigurationName`, `Levels`
2. Ejecutar script PowerShell: `Update-Configuration.ps1`
3. El script muestra la configuración actual y permite modificaciones interactivas

### `/DeleteConfiguration`
Elimina una configuración de carga específica de una entidad.

**Flujo de ejecución:**
1. Solicitar parámetros: `EntityName`, `ConfigurationName`
2. Confirmar eliminación con el usuario
3. Ejecutar script PowerShell: `Delete-Configuration.ps1`

---

## Conceptos Clave del Framework Helix6

### 1. Archivo HelixEntities.xml

**Ubicación**: `[Proyecto].Api/HelixEntities.xml`

**Propósito**: 
- Define la metadata que el Helix Generator utiliza para crear servicios, repositorios y endpoints
- Mapea cada entidad del DataModel con su View correspondiente
- Especifica qué propiedades se exponen y cómo se relacionan
- Define configuraciones de carga para operaciones complejas de lectura

### 2. Estructura Básica

```xml
<HelixEntities>
  <Entities>
    <EntityName>Worker</EntityName>
    <ViewName>WorkerView</ViewName>
    <DefaultFilterField>Name</DefaultFilterField>
    <IsVersionEntity>false</IsVersionEntity>
    <IsValidityEntity>false</IsValidityEntity>
    
    <!-- Mapeo de propiedades -->
    <Fields>...</Fields>
    
    <!-- Configuraciones de carga -->
    <Configurations>...</Configurations>
    
    <!-- Endpoints disponibles -->
    <Endpoints>...</Endpoints>
  </Entities>
</HelixEntities>
```

### 3. Reglas Obligatorias

- ✅ **Configuración "Defecto" obligatoria**: Toda entidad debe tener una configuración llamada "Defecto" con ordenación por Id ascendente
- ✅ **Ordenación obligatoria**: TODAS las configuraciones deben incluir al menos un `<Orders>`
  - ✅ **Sincronización con Consts.cs**: Al crear/modificar/eliminar configuraciones personalizadas, actualizar automáticamente las constantes
- ✅ **Nombres consistentes**: `EntityFieldName` y `ViewFieldName` siempre son iguales (no hay mapeos personalizados)
- ✅ **Campos de auditoría**: Todas las entidades IEntityBase deben incluir los 5 campos de auditoría

---

## Funcionalidad 1: `/UpdateHelixEntities`

### Descripción

Comando para sincronizar automáticamente el archivo `HelixEntities.xml` con el estado actual del DataModel y las Views. Este proceso:

1. Analiza todas las entidades del DataModel
2. Crea o actualiza mapeos de propiedades
3. Elimina propiedades obsoletas
4. Elimina entidades completas si ya no existen
5. Limpia configuraciones de carga de referencias a entidades eliminadas
6. Crea ordenación por defecto (Id ascendente) para nuevas entidades

### Cuándo Usar Este Comando

- ✅ Después de generar Views con `/UpdateViews`
- ✅ Después de aplicar cambios en el DataModel (añadir/quitar propiedades)
- ✅ Al inicializar un proyecto nuevo
- ✅ Después de eliminar entidades del modelo
- ✅ Cuando hay inconsistencias entre XML y código

### Proceso Detallado (11 Pasos)

#### Paso 1: Localizar Proyectos

**Acción:**
- Buscar archivo `.sln` en el workspace
- Localizar proyecto `[Proyecto].Back.DataModel`
- Localizar proyecto `[Proyecto].Back.Entities`
- Localizar proyecto `[Proyecto].Back.Api`

**Salida al usuario:**
```
🔍 Localizando proyectos...
✓ Solución: InfoportOneAdmon.Back.sln
✓ DataModel: InfoportOneAdmon.Back.DataModel
✓ Entities: InfoportOneAdmon.Back.Entities
✓ Api: InfoportOneAdmon.Back.Api
```

#### Paso 2: Leer o Crear HelixEntities.xml

**Acción:**
- Verificar si existe `[Proyecto].Api/HelixEntities.xml`
- Si existe: Parsear XML y cargar entidades actuales
- Si NO existe: Crear estructura base vacía

**Salida al usuario (si existe):**
```
📄 Leyendo HelixEntities.xml existente...
✓ Archivo encontrado: 8 entidades configuradas
  - Application, ApplicationModule, ApplicationRole, ...
```

**Salida al usuario (si no existe):**
```
⚠ HelixEntities.xml no existe
✓ Creando archivo nuevo con estructura base
```

#### Paso 3: Inventariar Entidades del DataModel

**Acción:**
- Listar archivos `.cs` en `[Proyecto].Back.DataModel`
- Filtrar solo clases que implementan `IEntityBase`
- Excluir vistas de BD (VTA_, VW_) de este análisis de sincronización completa
- Extraer información de cada entidad:
  - Propiedades escalares (int, string, DateTime, etc.)
  - Propiedades de navegación (virtual Entity)
  - Propiedades de colección (ICollection<Entity>)
  - Interfaces implementadas (IVersionEntity, IValidityEntity)

**Salida al usuario:**
```
📦 Inventariando entidades del DataModel...
✓ 10 entidades encontradas:
  1. Application (IEntityBase) - 11 propiedades
  2. ApplicationModule (IEntityBase) - 9 propiedades
  3. ApplicationRole (IEntityBase, IVersionEntity) - 13 propiedades
  ...
```

#### Paso 4: Inventariar Views Correspondientes

**Acción:**
- Para cada entidad del DataModel, buscar su View correspondiente
- Verificar que existe `[Entity]View.cs` en `Back.Entities/Views/`
- Marcar cuáles tienen View y cuáles no

**Salida al usuario:**
```
👁 Verificando Views correspondientes...
✓ Application → ApplicationView ✓
✓ ApplicationModule → ApplicationModuleView ✓
⚠ CustomEntity → CustomEntityView ✗ (no existe View)
```

**Nota**: Si una entidad no tiene View, se omite del XML con advertencia.

#### Paso 5: Sincronizar Mapeos de Entidades

Para cada entidad con View, realizar sincronización:

##### 5.1 Entidad Nueva (no existe en XML)

**Acción:**
- Crear nuevo bloque `<Entities>` completo
- Generar todos los `<Fields>` desde el DataModel:
  - Propiedades escalares
  - Propiedades de auditoría (obligatorias)
  - Propiedades de versionado/vigencia (si aplica)
  - Propiedades de navegación
- Crear configuración "Defecto" con ordenación por Id ascendente
- Crear bloque `<Endpoints>` vacío (los endpoints se añaden mediante agente de controladores)
- Establecer `DefaultFilterField` (Name si existe, sino Id)

**Salida al usuario:**
```
➕ Nueva entidad: CustomEntity
  ✓ ViewName: CustomEntityView
  ✓ Fields generados: 12 propiedades
    - Escalares: 5
    - Auditoría: 5
    - Navegación: 2
  ✓ Configuración "Defecto" creada (Order: Id Ascending)
  ✓ Endpoints: Bloque vacío (se configuran por agente de controladores)
  ✓ DefaultFilterField: Name
```

##### 5.2 Entidad Existente (ya está en XML)

**Acción:**
- Comparar propiedades del DataModel con Fields del XML
- **Añadir Fields nuevos** si hay propiedades nuevas en el modelo
- **Eliminar Fields obsoletos** si propiedades fueron eliminadas del modelo
- Mantener configuraciones de carga existentes (pero limpiar referencias obsoletas)
- Mantener endpoints existentes

**Salida al usuario:**
```
🔄 Actualizando: Application
  ➕ Añadidas: 2 propiedades nuevas
    - LogoUrl (String)
    - IsActive (Boolean)
  ➖ Eliminadas: 1 propiedad obsoleta
    - OldField (ya no existe en DataModel)
  ✓ Propiedades actuales: 13
  ℹ Configuraciones de carga: 2 (mantenidas)
  ℹ Endpoints: Mantenidos sin cambios
```

##### 5.3 Actualizar Tipos de Datos

**Acción:**
- Si una propiedad cambió de tipo en el DataModel, actualizar XML
- Ejemplo: `string` → `int`, `DateTime` → `DateTime?`

**Salida al usuario:**
```
🔧 Tipos actualizados en Worker:
  - BirthDate: DateTime → DateTime? (ahora nullable)
  - Code: Int32 → String (cambio de tipo)
```

#### Paso 6: Limpiar Entidades Obsoletas

**Acción:**
- Identificar entidades que están en XML pero ya NO existen en DataModel
- Eliminar completamente el bloque `<Entities>` del XML
- Registrar para mostrar al usuario

**Salida al usuario:**
```
🗑 Eliminando entidades obsoletas:
  ✗ OldWorker (ya no existe en DataModel)
  ✗ TempEntity (ya no existe en DataModel)
```

#### Paso 7: Limpiar Configuraciones de Carga

**Acción:**
- Para cada entidad que tiene configuraciones de carga (`<Configurations>`)
- Revisar los `<Includes>` que referencian otras entidades
- Si una entidad referenciada ya no existe en el DataModel:
  - Eliminar ese bloque `<Includes>`
  - Eliminar `<Includes>` anidados dentro de ella recursivamente

**Ejemplo**: Si configuración "WorkerComplete" incluía Worker → Worker_Course → Course, y Course fue eliminada:

**Salida al usuario:**
```
🧹 Limpiando configuraciones de carga:
  Worker > "WorkerComplete":
    ✗ Referencia eliminada: Worker_Course (entidad no existe)
      ✗ Subreferenciaía eliminada: Course (entidad no existe)
  ✓ Configuración actualizada y funcional
```

#### Paso 8: Validar Configuración "Defecto"

**Acción:**
- Para cada entidad en el XML, verificar que existe configuración "Defecto"
- Si NO existe, crearla con ordenación por Id ascendente
- Si existe pero no tiene `<Orders>`, añadir Id ascendente por defecto

**Salida al usuario:**
```
✅ Validando configuraciones "Defecto"...
  ✓ Application: OK
  ✓ ApplicationModule: OK
  ⚠ CustomEntity: Añadida configuración "Defecto" (faltaba)
  ⚠ Worker: Añadida ordenación por Id (faltaba <Orders>)
```

#### Paso 9: Validar Campos de Auditoría

**Acción:**
- Para cada entidad IEntityBase, verificar que tiene los 5 campos de auditoría:
  - AuditCreationUser
  - AuditCreationDate
  - AuditModificationUser
  - AuditModificationDate
  - AuditDeletionDate
- Si falta alguno, añadirlo automáticamente

**Salida al usuario:**
```
🔍 Validando campos de auditoría...
  ✓ Application: 5/5 campos presentes
  ⚠ CustomEntity: Añadidos 2 campos faltantes
    - AuditModificationDate
    - AuditDeletionDate
```

#### Paso 10: Guardar HelixEntities.xml

**Acción:**
- Serializar la estructura XML actualizada
- Formatear con indentación correcta (2 espacios)
- Guardar en `[Proyecto].Api/HelixEntities.xml`

**Salida al usuario:**
```
💾 Guardando HelixEntities.xml...
  ✓ Archivo guardado exitosamente
```

#### Paso 11: Resumen del Proceso

**Salida al usuario:**
```
========================================
  RESUMEN DE ACTUALIZACIÓN
========================================

Entidades procesadas: 10

Cambios realizados:
  ➕ Entidades nuevas: 2
  🔄 Entidades actualizadas: 6
  🗑 Entidades eliminadas: 1
  
Propiedades:
  ➕ Añadidas: 8
  ➖ Eliminadas: 3
  🔧 Actualizadas (tipo): 2

Configuraciones:
  ✅ "Defecto" validadas: 10
  🧹 Referencias limpiadas: 4

✅ HelixEntities.xml actualizado correctamente

Siguiente paso recomendado:
  Ejecutar Helix Generator para regenerar servicios
```

### Validaciones Automáticas

Durante el proceso `/UpdateHelixEntities`, el agente valida:

- [ ] Todas las entidades tienen configuración "Defecto"
- [ ] Todas las configuraciones tienen al menos un `<Orders>`
- [ ] Todos los `EntityFieldName` coinciden con `ViewFieldName`
- [ ] Todas las entidades IEntityBase tienen los 5 campos de auditoría
- [ ] ViewName siempre es `[EntityName]View`
- [ ] No hay referencias a entidades eliminadas en Includes
- [ ] Tipos de datos son válidos según el mapeo .NET → XML
- [ ] Bloque `<Endpoints>` existe (vacío inicialmente)

## Funcionalidad X: `/SetEntityEndpoints`

Descripción

Comando para añadir o eliminar métodos (endpoints) de la sección `<Endpoints><Methods>` de una entidad en `HelixEntities.xml`. Está pensado para integrarse en flujos automatizados (agentes, CI) donde se desee activar o desactivar endpoints sin interacción manual.

Parámetros
- `entity` (string, requerido): Nombre de la entidad (p.ej. `Organization`).
- `methods` (string, requerido): Lista separada por comas de métodos a añadir o eliminar (p.ej. `Insert,GetById`).
- `operation` (string, opcional): `add` (por defecto) o `remove`.
- `solutionPath` (string, opcional): Ruta al `.sln` para localizar el proyecto `*.Back.Api`.
- `dryRun` (boolean): Si `true` no modifica archivos; muestra los cambios que se harían.
- `backup` (boolean): Si `true` crea copia de seguridad del `HelixEntities.xml` antes de escribir.
- `force` (boolean): Si `true` aplica cambios aunque no haya diferencias.

Comportamiento
- Valida que los métodos indicados existan en la lista admitida (`HelixEndpoints` enum). Rechaza nombres desconocidos.
- Al `operation=add` añade únicamente métodos que no estuvieran ya presentes (idempotente).
- Al `operation=remove` elimina únicamente métodos presentes.
- Actualiza solo la sección `<Endpoints><Methods>` del bloque de la entidad; no toca otras secciones.
- Soporta `-dryRun` y `-backup`.
- Devuelve un resumen JSON (cuando se invoque desde un handler) con `added`, `removed`, `path` y `status`.

Uso interno y recomendaciones
- Implementar el handler del agente para invocar en background un script PowerShell `tools/Set-EntityEndpoints.ps1` que reusa la lógica de `Create-Controller.ps1`/`Delete-Controller.ps1` pero en modo no interactivo y con salida JSON.
- Si se prefiere, el handler puede llamar directamente a `Create-Controller.ps1 -Methods '+Insert,GetById' -DryRun` u `-Methods '-Insert'` según la operación; sin embargo, `Set-EntityEndpoints` centraliza la semántica y la validación para agentes.

Ejemplo de uso (handler/CI):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File \
  "tools\Set-EntityEndpoints.ps1" -Entity "Organization" -Methods "Insert,GetById" -Operation add -Backup
```

Salida esperada (ejemplo JSON):

{
  "status": "ok",
  "path": "C:\\...\\HelixEntities.xml",
  "added": ["Insert","GetById"],
  "removed": []
}


### Casos Especiales Manejados

#### Vistas de Base de Datos (VTA_, VW_)

```
ℹ VTA_ActiveWorkers: Omitida (vista de BD, no requiere sincronización completa)
```

- Solo se actualizan si ya existen en el XML
- No se crean automáticamente
- Solo tienen endpoints de lectura

#### Tablas Relacionales (N:M)

```
✓ Worker_Course: Tabla relacional detectada
  - Incluye FK: WorkerId, CourseId
  ℹ Endpoints: Bloque vacío (configuración posterior)
```

#### Entidades con Versionado/Vigencia

```
✓ Project (IVersionEntity)
  ✓ Propiedades especiales añadidas:
    - VersionKey (String)
    - VersionNumber (Int32)
  ℹ Endpoints: Bloque vacío (configuración posterior)
```

**Nota**: Los endpoints específicos de versionado/vigencia se añaden mediante el agente de controladores según los controladores genéricos utilizados.

---

## Funcionalidad 2: `/ListConfiguration`

### Descripción

Lista todas las configuraciones de carga definidas para una entidad específica, mostrando cada configuración con su estructura jerárquica completa.

**Flujo de ejecución:**
1. Solicitar parámetro: `EntityName` (mediante `ask_questions`)
2. Leer directamente el archivo HelixEntities.xml
3. Parsear y mostrar todas las configuraciones de la entidad en formato legible

**Nota:** Este comando NO utiliza script PowerShell, lee y muestra la información directamente.

### Sintaxis

```
/ListConfiguration <EntityName>
```

**Parámetros:**
- `EntityName`: Nombre de la entidad del DataModel (ej: `Organization`, `Application`)

### Ejemplo de Uso

```
/ListConfiguration Organization
```

### Salida Esperada

```
Organization
-----------------------

Configuración: Defecto
Organization
  (Sin includes - configuración básica)
  Ordenación: Id ASC

Configuración: OrganizationComplete
Organization
  (1) Group (L)
  (2) OrganizationApplicationModule (E)
    (2.1) ApplicationModule (L)
  Ordenación: Id ASC

Configuración: OrganizationLite
Organization
  (1) OrganizationGroup (L)
  Ordenación: Name ASC

Total: 3 configuraciones
```

---

## Funcionalidad 3: `/ViewConfiguration`

### Descripción

Visualiza una configuración de carga específica con formato jerárquico, códigos de colores y numeración para facilitar su comprensión.

**Flujo de ejecución:**
1. Solicitar parámetros: `EntityName`, `ConfigurationName` (mediante `ask_questions`)
2. Ejecutar script PowerShell: `View-Configuration.ps1 -EntityName "<entity>" -ConfigurationName "<config>"`
3. El script muestra la visualización con colores en el terminal

### Sintaxis

```
/ViewConfiguration <EntityName> <ConfigurationName>
```

**Parámetros:**
- `EntityName`: Nombre de la entidad (ej: `Organization`)
- `ConfigurationName`: Nombre de la configuración (ej: `OrganizationComplete`)

### Ejemplo de Uso

```
/ViewConfiguration Organization OrganizationComplete
```

### Salida Esperada

```
Organization
-----------------------

Configuración: OrganizationComplete

Organization
  (1) Group (L)                             ← Rojo (Lectura)
  (2) OrganizationApplicationModule (E)     ← Verde (Escritura)
    (2.1) ApplicationModule (L)             ← Rojo (Lectura)

Ordenación: Id ASC

Leyenda:
  (L) = ReadOnly: true  (solo lectura)
  (E) = ReadOnly: false (escritura)
```

---

## Funcionalidad 4: `/CreateConfiguration`

### Descripción

Crea una nueva configuración de carga de forma interactiva, mostrando el árbol completo de entidades relacionadas hasta el nivel especificado y permitiendo al usuario seleccionar qué incluir.

**Flujo de ejecución:**
1. Solicitar parámetros: `EntityName`, `ConfigurationName`, `Levels` (mediante `ask_questions`)
2. Ejecutar script PowerShell: `Create-Configuration.ps1 -EntityName "<entity>" -ConfigurationName "<config>" -Levels <n>`
3. El script guía al usuario de forma interactiva para:
   - Seleccionar entidades relacionadas a incluir
   - Definir modo de acceso (Lectura/Escritura)
   - Establecer ordenación
4. Al finalizar, el script guarda en HelixEntities.xml y sincroniza Consts.cs

### Sintaxis

```
/CreateConfiguration <EntityName> <ConfigurationName> <Levels>
```

**Parámetros:**
- `EntityName`: Nombre de la entidad (ej: `Organization`)
- `ConfigurationName`: Nombre para la nueva configuración (ej: `OrganizationFull`)
- `Levels`: Número de niveles de profundidad a mostrar (ej: `3`)

### Proceso Interactivo

#### Paso 1: Validación

El agente verifica que:
- La configuración NO exista (si existe, usar `/UpdateConfiguration`)
- La entidad exista en HelixEntities.xml
- El número de niveles sea válido (1-5)

#### Paso 2: Visualización del Árbol

```
Organization
-----------------------

Configuración: OrganizationFull (nueva)

Organization
  (1) Group
  (2) OrganizationApplicationModule
    (2.1) ApplicationModule
    (2.2) Organization
      (2.2.1) Group
      (2.2.2) OrganizationApplicationModule

Selecciona las entidades a incluir indicando el número y modo:
  L = Lectura (ReadOnly:true)
  E = Escritura (ReadOnly:false)
  [vacío] = No incluir

Formato: número + modo (ej: 1 L)
Ingresa las selecciones (una por línea o separadas por comas):

1
2
2.1
2.2
2.2.1
2.2.2
```

#### Paso 3: Entrada del Usuario

Usuario indica:
```
1 L
2 E
2.1 L
```

Interpretación:
- `1 L` → Incluir Group en modo lectura
- `2 E` → Incluir OrganizationApplicationModule en modo escritura
- `2.1 L` → Incluir ApplicationModule en modo lectura
- (No menciona 2.2, 2.2.1, 2.2.2) → No se incluyen

#### Paso 4: Confirmación de Estructura

```
Estructura propuesta:

Organization
  (1) Group (L)
  (2) OrganizationApplicationModule (E)
    (2.1) ApplicationModule (L)

¿Confirmas esta configuración? (S/n):
```

#### Paso 5: Criterio de Ordenación

```
Criterio de ordenación:

Campos disponibles en Organization:
  - Id
  - Name
  - Acronym
  - SecurityCompanyId
  ...

Ingresa el campo de ordenación (Enter para Id ASC):
```

Usuario ingresa: `Name`

#### Paso 6: Guardar y Sincronizar

```
💾 Creando configuración...
  ✓ Configuración "OrganizationFull" añadida a HelixEntities.xml
  ✓ Constante ORGANIZATION_FULL sincronizada en Consts.cs

✅ Configuración creada exitosamente
```

---

## Funcionalidad 5: `/UpdateConfiguration`

### Descripción

Modifica una configuración de carga existente, mostrando los valores actuales para facilitar cambios sin tener que reescribirlo todo.

**Flujo de ejecución:**
1. Solicitar parámetros: `EntityName`, `ConfigurationName`, `Levels` (mediante `ask_questions`)
2. Ejecutar script PowerShell: `Update-Configuration.ps1 -EntityName "<entity>" -ConfigurationName "<config>" -Levels <n>`
3. El script muestra la configuración actual con marcadores visuales
4. Permite modificaciones interactivas:
   - Cambiar modo de acceso (L/E)
   - Añadir nuevas entidades relacionadas
   - Eliminar entidades de la configuración
   - Modificar ordenación
5. Al finalizar, guarda cambios en HelixEntities.xml y sincroniza Consts.cs

### Sintaxis

```
/UpdateConfiguration <EntityName> <ConfigurationName> <Levels>
```

**Parámetros:**
- `EntityName`: Nombre de la entidad (ej: `Organization`)
- `ConfigurationName`: Nombre de la configuración existente (ej: `OrganizationComplete`)
- `Levels`: Número de niveles de profundidad a mostrar (ej: `3`)

### Proceso Interactivo

#### Paso 1: Validación

El agente verifica que:
- La configuración SÍ exista (si no existe, usar `/CreateConfiguration`)
- La entidad exista en HelixEntities.xml

#### Paso 2: Visualización con Valores Actuales

```
Organization
-----------------------

Configuración: OrganizationComplete (existente)

Organization
  (1) Group (L)                            ← ACTUAL
  (2) OrganizationApplicationModule (E)    ← ACTUAL
    (2.1) ApplicationModule (L)            ← ACTUAL
    (2.2) Organization
      (2.2.1) Group
      (2.2.2) OrganizationApplicationModule

Valores actuales mostrados. Modifica según necesites:
  L = Lectura (ReadOnly:true)
  E = Escritura (ReadOnly:false)
  [vacío] = Eliminar de configuración

Ingresa cambios (una por línea o separadas por comas):

1 L
2 E
2.1 L
2.2
2.2.1
2.2.2
```

#### Paso 3: Entrada del Usuario para Modificar

Usuario indica:
```
1 L
2 L
2.1 L
2.2 E
```

Interpretación:
- `1 L` → Mantener Group en lectura (sin cambios)
- `2 L` → **CAMBIO**: OrganizationApplicationModule de Escritura a Lectura
- `2.1 L` → Mantener ApplicationModule en lectura
- `2.2 E` → **NUEVO**: Añadir Organization en modo escritura
- (No menciona 2.2.1, 2.2.2) → No se añaden al árbol

#### Paso 4: Resumen de Cambios

```
Cambios detectados:

Modificados:
  - OrganizationApplicationModule: E → L

Añadidos:
  + Organization (nivel 2) en modo Escritura

Eliminados:
  (ninguno)

¿Confirmas los cambios? (S/n):
```

#### Paso 5: Actualizar Ordenación (Opcional)

```
Ordenación actual: Id ASC

¿Deseas cambiar la ordenación? (s/N):
```

Si usuario responde "s":
```
Ingresa el nuevo campo de ordenación:
```

#### Paso 6: Guardar Cambios

```
💾 Actualizando configuración...
  ✓ Configuración "OrganizationComplete" actualizada en HelixEntities.xml
  ✓ Consts.cs sincronizado

✅ Configuración actualizada exitosamente
```

---

## Funcionalidad 6: `/DeleteConfiguration`

### Descripción

Elimina una configuración de carga específica de una entidad, tanto del archivo HelixEntities.xml como de Consts.cs.

**Flujo de ejecución:**
1. Solicitar parámetros: `EntityName`, `ConfigurationName` (mediante `ask_questions`)
2. Validar que la configuración exista y no sea "Defecto"
3. Confirmar eliminación con el usuario (mediante `ask_questions`)
4. Ejecutar script PowerShell: `Delete-Configuration.ps1 -EntityName "<entity>" -ConfigurationName "<config>"`
5. El script elimina la configuración del XML y la constante de Consts.cs

### Sintaxis

```
/DeleteConfiguration <EntityName> <ConfigurationName>
```

**Parámetros:**
- `EntityName`: Nombre de la entidad (ej: `Organization`)
- `ConfigurationName`: Nombre de la configuración a eliminar (ej: `OrganizationComplete`)

### Proceso

#### Paso 1: Validación

El agente verifica que:
- La configuración exista
- No sea la configuración "Defecto" (protegida, no puede eliminarse)

#### Paso 2: Confirmación

```
⚠️  Vas a eliminar la configuración de carga

Entidad: Organization
Configuración: OrganizationComplete

Esta acción eliminará:
  - El bloque <Configurations> del XML
  - La constante ORGANIZATION_COMPLETE de Consts.cs

¿Confirmas la eliminación? (s/N):
```

#### Paso 3: Eliminar

Si usuario confirma con "s":

```
🗑️  Eliminando configuración...
  ✓ Configuración "OrganizationComplete" eliminada de HelixEntities.xml
  ✓ Constante ORGANIZATION_COMPLETE eliminada de Consts.cs

✅ Configuración eliminada exitosamente
```

Si usuario cancela:
```
❌ Eliminación cancelada
```

---

## Scripts PowerShell para Configuraciones

Cada comando tiene su script correspondiente en la carpeta `tools/`:

| Comando | Script | Descripción |
|---------|--------|-------------|
| `/ListConfiguration` | `List-Configuration.ps1` | Lista configuraciones de una entidad |
| `/ViewConfiguration` | `View-Configuration.ps1` | Visualiza una configuración específica |
| `/CreateConfiguration` | `Create-Configuration.ps1` | Crea nueva configuración interactivamente |
| `/UpdateConfiguration` | `Update-Configuration.ps1` | Modifica configuración existente |
| `/DeleteConfiguration` | `Delete-Configuration.ps1` | Elimina una configuración |

### Parámetros Comunes

Todos los scripts comparten estos parámetros base:

```powershell
-ProjectName <string>     # Nombre del proyecto (ej: "InfoportOneAdmon")
-EntityName <string>      # Nombre de la entidad
-ConfigurationName <string>  # Nombre de la configuración (excepto List)
-Levels <int>            # Niveles de profundidad (solo Create/Update)
```

### Ejemplos de Uso Directo

```powershell
# Listar configuraciones
.\tools\List-Configuration.ps1 -EntityName "Organization"

# Ver configuración específica
.\tools\View-Configuration.ps1 -EntityName "Organization" -ConfigurationName "OrganizationComplete"

# Crear nueva configuración
.\tools\Create-Configuration.ps1 -EntityName "Organization" -ConfigurationName "OrganizationFull" -Levels 3

# Actualizar configuración existente
.\tools\Update-Configuration.ps1 -EntityName "Organization" -ConfigurationName "OrganizationComplete" -Levels 3

# Eliminar configuración
.\tools\Delete-Configuration.ps1 -EntityName "Organization" -ConfigurationName "OrganizationComplete"
```

---

## Checklist de Validación Post-Ejecución

### Después de `/UpdateHelixEntities`
- [ ] Todas las entidades del DataModel tienen mapeo en el XML (excepto vistas BD)
- [ ] No hay Fields de propiedades eliminadas
- [ ] Todas las entidades tienen configuración "Defecto" con Orders
- [ ] Campos de auditoría presentes en todas las entidades IEntityBase
- [ ] No hay referencias a entidades eliminadas en Includes
- [ ] ViewName siempre es `[EntityName]View`
- [ ] Archivo XML es válido y bien formateado

### Después de `/entityConfiguration`
- [ ] Configuración creada o actualizada correctamente en XML
- [ ] Estructura de Includes es correcta y sin referencias circulares
- [ ] Ordenación definida (mínimo Id ASC)
- [ ] Consts.cs actualizado con la constante correspondiente
- [ ] Nombre de constante sigue convención UPPER_CASE
- [ ] Configuración es funcional (no referencia entidades inexistentes)

---

## Formato y Convenciones del XML

### Indentación
- 2 espacios por nivel
- Sin tabs

### Orden de Elementos dentro de `<Entities>`
1. EntityName
2. ViewName
3. DefaultFilterField
4. IsVersionEntity
5. IsValidityEntity
6. Fields (escalares → auditoría → versionado/vigencia → navegación)
7. Configurations (Defecto primero, luego alfabético)
8. Endpoints

### Orden de Fields
1. **Id** (siempre primero)
2. **Propiedades escalares** (alfabético)
3. **Propiedades de auditoría** (orden fijo):
   - AuditCreationUser
   - AuditCreationDate
   - AuditModificationUser
   - AuditModificationDate
   - AuditDeletionDate
4. **Versionado/Vigencia** (si aplica)
5. **Propiedades de navegación** (alfabético)

### Nombres de Configuraciones
- PascalCase: `WorkerComplete`, `ApplicationFull`
- Sin espacios ni caracteres especiales
- Descriptivos y concisos

---

## Referencias Técnicas

### Documentación Relacionada
- Framework Helix6: `.github/copilot-instructions.md`
- Arquitectura Backend: `docs/[Proyecto]_Architecture.md`
- Agente de Database: `.github/agents/Helix6Back.Database.agent.md`
- Agente de Views: `.github/agents/Helix6Back.Views.agent.md`

### Archivos Involucrados
- `[Proyecto].Back.DataModel/*.cs` - Entidades origen
- `[Proyecto].Back.Entities/Views/*.cs` - Views destino
- `[Proyecto].Back.Api/HelixEntities.xml` - Archivo de configuración
  - `[Proyecto].Back.Entities/Consts.cs` - Constantes de configuraciones

### Tipos de Datos Soportados

| Tipo .NET | EntityFieldTypeDB XML |
|-----------|----------------------|
| `int` | `Int32` |
| `int?` | `Int32?` |
| `string` | `String` |
| `DateTime` | `DateTime` |
| `DateTime?` | `DateTime?` |
| `bool` | `Boolean` |
| `decimal` | `Decimal` |
| `Guid` | `Guid` |
| `[Entity]` | Nombre de clase |

---

## Historial de Cambios

| Fecha | Versión | Cambios |
|-------|---------|---------|
| 2026-02-17 | 1.0 | Creación inicial del agente con comandos /UpdateHelixEntities y /entityConfiguration |
| 2026-02-20 | 2.0 | Redesign completo de gestión de configuraciones: reemplazado /entityConfiguration con 5 comandos especializados (/ListConfiguration, /ViewConfiguration, /CreateConfiguration, /UpdateConfiguration, /DeleteConfiguration) para mejor UX. Añadido formato jerárquico con numeración (level.number) y colores (L=rojo, E=verde) |

---

## Autor y Mantenimiento

**Agente**: Helix6Back.HelixEntities  
**Framework**: Helix6 v1.0  
**Tecnologías**: .NET 8.0, XML, PowerShell  
**Mantenedor**: Equipo de Desarrollo Helix6
