---
name: Helix6 HelixEntities Agent
description: Gestión automática del archivo HelixEntities.xml para mapeo de entidades, configuraciones de carga y endpoints en proyectos Helix6
version: 1.0
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

# Agente de Gestión de HelixEntities.xml — Helix6 Backend

---

## ⚠️ REGLAS DE EJECUCIÓN OBLIGATORIAS (DECISION RULES)

> **Estas reglas tienen prioridad absoluta sobre cualquier otra instrucción de este documento.**  
> **Copilot NO debe implementar lógica propia para ningún comando que tenga un script asignado.**

### REGLA 1 — Ubicación de los scripts

Todos los scripts PowerShell de este agente se encuentran en:

```
.github/agents/tools/
```

Ruta completa de cada script:

| Comando | Script (ruta completa desde raíz del repo) |
|---|---|
| `/UpdateHelixEntities` | `.github/agents/tools/Update-HelixEntities.ps1` |
| `/SetEntityEndpoints` | `.github/agents/tools/Set-EntityEndpoints.ps1` |
| `/ListConfiguration` | Lectura directa del XML (sin script) |
| `/ViewConfiguration` | `.github/agents/tools/View-Configuration.ps1` |
| `/CreateConfiguration` | `.github/agents/tools/Create-Configuration.ps1` |
| `/UpdateConfiguration` | `.github/agents/tools/Update-Configuration.ps1` |
| `/DeleteConfiguration` | `.github/agents/tools/Delete-Configuration.ps1` |

---

### REGLA 2 — Qué debe hacer Copilot al recibir un comando

```
SI el comando tiene un script asignado en la tabla anterior:
  → INVOCAR el script PowerShell correspondiente
  → NO implementar la lógica del comando por cuenta propia
  → NO modificar HelixEntities.xml directamente (salvo /ListConfiguration)
  → NO generar código C#, XML o PowerShell alternativo

SI el comando es /ListConfiguration:
  → Leer y parsear HelixEntities.xml directamente
  → Mostrar el resultado en el formato definido en este documento
  → NO invocar ningún script
```

### REGLA 3 — Ante cualquier duda, preguntar antes de actuar

```
SI faltan parámetros obligatorios para invocar el script:
  → Preguntar al usuario mediante ask_questions
  → NO asumir valores por defecto ni proceder sin confirmación

SI el script no existe en la ruta esperada:
  → Informar al usuario indicando la ruta esperada
  → NO intentar recrear el script ni su lógica
```

### REGLA 4 — Prohibiciones explícitas

```
❌ NO reimplementar la lógica de ningún script en este agente
❌ NO modificar HelixEntities.xml directamente salvo en /ListConfiguration
❌ NO generar scripts PowerShell alternativos o equivalentes
❌ NO omitir la invocación del script aunque la tarea parezca sencilla
❌ NO inferir el contenido de un script a partir de su nombre o descripción
```

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

### 3. Reglas Obligatorias del Framework

- ✅ **Configuración "Defecto" obligatoria**: Toda entidad debe tener una configuración llamada "Defecto" con ordenación por Id ascendente
- ✅ **Ordenación obligatoria**: TODAS las configuraciones deben incluir al menos un `<Orders>`
- ✅ **Sincronización con Consts.cs**: Al crear/modificar/eliminar configuraciones personalizadas, actualizar automáticamente las constantes
- ✅ **Nombres consistentes**: `EntityFieldName` y `ViewFieldName` siempre son iguales
- ✅ **Campos de auditoría**: Todas las entidades IEntityBase deben incluir los 5 campos de auditoría

---

## Comandos Disponibles

---

### `/UpdateHelixEntities`

**Descripción**: Sincroniza el archivo `HelixEntities.xml` con el estado actual del DataModel y las Views.

#### EJECUCIÓN OBLIGATORIA

```
SCRIPT: .github/agents/tools/Update-HelixEntities.ps1
MODO: El script gestiona el proceso completo de forma autónoma
```

> ⚠️ Copilot debe invocar este script. No debe implementar los pasos descritos a continuación por su cuenta. Los pasos se documentan únicamente como referencia del comportamiento esperado del script.

#### Cuándo usar este comando

- ✅ Después de generar Views con `/UpdateViews`
- ✅ Después de aplicar cambios en el DataModel
- ✅ Al inicializar un proyecto nuevo
- ✅ Después de eliminar entidades del modelo
- ✅ Cuando hay inconsistencias entre XML y código

#### Proceso ejecutado por el script (referencia)

El script realiza los siguientes pasos en orden:

1. Localizar proyectos (`.sln`, DataModel, Entities, Api)
2. Leer o crear `HelixEntities.xml`
3. Inventariar entidades del DataModel (filtrar `IEntityBase`, excluir vistas BD)
4. Inventariar Views correspondientes (`[Entity]View.cs`)
5. Sincronizar mapeos:
   - Crear bloque completo para entidades nuevas
   - Añadir/eliminar Fields para entidades existentes
   - Actualizar tipos de datos modificados
6. Eliminar bloques de entidades obsoletas
7. Limpiar referencias a entidades eliminadas en `<Includes>`
8. Validar y crear configuración "Defecto" si falta
9. Validar y añadir campos de auditoría faltantes
10. Guardar y formatear `HelixEntities.xml`
11. Mostrar resumen de cambios

#### Salida esperada al usuario

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

#### Casos especiales que gestiona el script

**Vistas de Base de Datos (VTA\_, VW\_)**
```
ℹ VTA_ActiveWorkers: Omitida (vista de BD, no requiere sincronización completa)
```
- Solo se actualizan si ya existen en el XML
- No se crean automáticamente
- Solo tienen endpoints de lectura

**Tablas Relacionales (N:M)**
```
✓ Worker_Course: Tabla relacional detectada
  - Incluye FK: WorkerId, CourseId
  ℹ Endpoints: Bloque vacío (configuración posterior)
```

**Entidades con Versionado/Vigencia**
```
✓ Project (IVersionEntity)
  ✓ Propiedades especiales añadidas:
    - VersionKey (String)
    - VersionNumber (Int32)
```

#### Validaciones automáticas del script

- [ ] Todas las entidades tienen configuración "Defecto"
- [ ] Todas las configuraciones tienen al menos un `<Orders>`
- [ ] Todos los `EntityFieldName` coinciden con `ViewFieldName`
- [ ] Todas las entidades IEntityBase tienen los 5 campos de auditoría
- [ ] ViewName siempre es `[EntityName]View`
- [ ] No hay referencias a entidades eliminadas en Includes
- [ ] Tipos de datos son válidos según el mapeo .NET → XML
- [ ] Bloque `<Endpoints>` existe en cada entidad

---

### `/SetEntityEndpoints`

**Descripción**: Añade o elimina métodos de la sección `<Endpoints><Methods>` de una entidad. Pensado para flujos automatizados y CI.

#### EJECUCIÓN OBLIGATORIA

```
SCRIPT: .github/agents/tools/Set-EntityEndpoints.ps1
MODO: No interactivo, salida JSON
```

> ⚠️ Copilot debe invocar este script con los parámetros indicados. No debe modificar la sección `<Endpoints>` del XML directamente.

#### Parámetros del script

| Parámetro | Tipo | Obligatorio | Descripción |
|---|---|---|---|
| `-Entity` | string | ✅ | Nombre de la entidad (ej: `Organization`) |
| `-Methods` | string | ✅ | Lista separada por comas (ej: `Insert,GetById`) |
| `-Operation` | string | No | `add` (por defecto) o `remove` |
| `-SolutionPath` | string | No | Ruta al `.sln` para localizar `*.Back.Api` |
| `-DryRun` | boolean | No | Si `true`, muestra cambios sin modificar archivos |
| `-Backup` | boolean | No | Si `true`, crea copia de seguridad antes de escribir |
| `-Force` | boolean | No | Si `true`, aplica aunque no haya diferencias |

#### Invocación de ejemplo

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File \
  ".github/agents/tools/Set-EntityEndpoints.ps1" \
  -Entity "Organization" -Methods "Insert,GetById" -Operation add -Backup
```

#### Salida esperada (JSON)

```json
{
  "status": "ok",
  "path": "C:\\...\\HelixEntities.xml",
  "added": ["Insert", "GetById"],
  "removed": []
}
```

#### Comportamiento del script

- Valida que los métodos existan en el enum `HelixEndpoints`. Rechaza nombres desconocidos.
- `add`: añade únicamente métodos no presentes (idempotente)
- `remove`: elimina únicamente métodos presentes
- Solo modifica `<Endpoints><Methods>`; no toca otras secciones

---

### `/ListConfiguration`

**Descripción**: Lista todas las configuraciones de carga de una entidad específica.

#### EJECUCIÓN — LECTURA DIRECTA (sin script)

```
ACCIÓN: Leer y parsear HelixEntities.xml directamente
SCRIPT: No aplica
```

> ✅ Este es el único comando donde Copilot lee y muestra datos del XML directamente, sin invocar ningún script.

#### Parámetros

| Parámetro | Obligatorio | Descripción |
|---|---|---|
| `EntityName` | ✅ | Nombre de la entidad (ej: `Organization`) |

#### Formato de salida obligatorio

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

### `/ViewConfiguration`

**Descripción**: Visualiza una configuración de carga específica con formato jerárquico.

#### EJECUCIÓN OBLIGATORIA

```
SCRIPT: .github/agents/tools/View-Configuration.ps1
PARÁMETROS: -EntityName "<entity>" -ConfigurationName "<config>"
```

> ⚠️ Copilot debe invocar este script. No debe generar la visualización por su cuenta.

#### Parámetros del script

| Parámetro | Obligatorio | Descripción |
|---|---|---|
| `-EntityName` | ✅ | Nombre de la entidad (ej: `Organization`) |
| `-ConfigurationName` | ✅ | Nombre de la configuración (ej: `OrganizationComplete`) |

#### Invocación de ejemplo

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File \
  ".github/agents/tools/View-Configuration.ps1" \
  -EntityName "Organization" -ConfigurationName "OrganizationComplete"
```

#### Salida esperada del script

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

### `/CreateConfiguration`

**Descripción**: Crea una nueva configuración de carga de forma interactiva hasta N niveles de profundidad.

#### EJECUCIÓN OBLIGATORIA

```
SCRIPT: .github/agents/tools/Create-Configuration.ps1
PARÁMETROS: -EntityName "<entity>" -ConfigurationName "<config>" -Levels <n>
MODO: Interactivo — el script guía al usuario paso a paso
```

> ⚠️ Copilot debe invocar este script. No debe implementar el proceso interactivo ni modificar el XML directamente.

#### Parámetros del script

| Parámetro | Obligatorio | Descripción |
|---|---|---|
| `-EntityName` | ✅ | Nombre de la entidad (ej: `Organization`) |
| `-ConfigurationName` | ✅ | Nombre para la nueva configuración (ej: `OrganizationFull`) |
| `-Levels` | ✅ | Niveles de profundidad a mostrar, rango válido: 1–5 |

#### Validaciones previas a invocar el script

Antes de invocar, Copilot debe verificar:
- Que la configuración **no exista** ya en el XML (si existe, indicar al usuario que use `/UpdateConfiguration`)
- Que la entidad **sí exista** en `HelixEntities.xml`
- Que `Levels` esté entre 1 y 5

#### Invocación de ejemplo

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File \
  ".github/agents/tools/Create-Configuration.ps1" \
  -EntityName "Organization" -ConfigurationName "OrganizationFull" -Levels 3
```

#### Proceso interactivo ejecutado por el script (referencia)

1. Muestra árbol de entidades relacionadas hasta el nivel indicado con numeración jerárquica
2. Solicita selección de entidades y modo (`L` = Lectura, `E` = Escritura)
3. Muestra confirmación de la estructura propuesta
4. Solicita criterio de ordenación (Enter = Id ASC por defecto)
5. Guarda la configuración en `HelixEntities.xml`
6. Sincroniza la constante correspondiente en `Consts.cs`

#### Formato de numeración jerárquica (referencia)

```
(1)       → nivel 1
(2)       → nivel 1
  (2.1)   → nivel 2, hijo de (2)
  (2.2)   → nivel 2, hijo de (2)
    (2.2.1) → nivel 3, hijo de (2.2)
```

---

### `/UpdateConfiguration`

**Descripción**: Modifica una configuración de carga existente mostrando los valores actuales para facilitar cambios.

#### EJECUCIÓN OBLIGATORIA

```
SCRIPT: .github/agents/tools/Update-Configuration.ps1
PARÁMETROS: -EntityName "<entity>" -ConfigurationName "<config>" -Levels <n>
MODO: Interactivo — el script muestra valores actuales y guía las modificaciones
```

> ⚠️ Copilot debe invocar este script. No debe modificar el XML directamente ni generar la interacción por su cuenta.

#### Parámetros del script

| Parámetro | Obligatorio | Descripción |
|---|---|---|
| `-EntityName` | ✅ | Nombre de la entidad (ej: `Organization`) |
| `-ConfigurationName` | ✅ | Nombre de la configuración existente (ej: `OrganizationComplete`) |
| `-Levels` | ✅ | Niveles de profundidad a mostrar, rango válido: 1–5 |

#### Validaciones previas a invocar el script

Antes de invocar, Copilot debe verificar:
- Que la configuración **sí exista** en el XML (si no existe, indicar al usuario que use `/CreateConfiguration`)
- Que la entidad **sí exista** en `HelixEntities.xml`

#### Invocación de ejemplo

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File \
  ".github/agents/tools/Update-Configuration.ps1" \
  -EntityName "Organization" -ConfigurationName "OrganizationComplete" -Levels 3
```

#### Proceso interactivo ejecutado por el script (referencia)

1. Muestra árbol completo con valores actuales marcados como `← ACTUAL`
2. Permite indicar cambios en formato `número + modo` (igual que `/CreateConfiguration`)
3. Muestra resumen de cambios detectados (modificados / añadidos / eliminados)
4. Solicita confirmación antes de guardar
5. Permite cambiar el criterio de ordenación (opcional)
6. Guarda cambios en `HelixEntities.xml` y sincroniza `Consts.cs`

---

### `/DeleteConfiguration`

**Descripción**: Elimina una configuración de carga específica del XML y de `Consts.cs`.

#### EJECUCIÓN OBLIGATORIA

```
SCRIPT: .github/agents/tools/Delete-Configuration.ps1
PARÁMETROS: -EntityName "<entity>" -ConfigurationName "<config>"
MODO: Requiere confirmación explícita del usuario antes de invocar el script
```

> ⚠️ Copilot debe invocar este script tras obtener confirmación. No debe eliminar bloques del XML directamente.

#### Parámetros del script

| Parámetro | Obligatorio | Descripción |
|---|---|---|
| `-EntityName` | ✅ | Nombre de la entidad (ej: `Organization`) |
| `-ConfigurationName` | ✅ | Nombre de la configuración a eliminar (ej: `OrganizationComplete`) |

#### Validaciones previas a invocar el script

Antes de invocar, Copilot debe verificar:
- Que la configuración **sí exista** en el XML
- Que **no sea** la configuración `"Defecto"` (protegida, no puede eliminarse)

Si la configuración es `"Defecto"`, responder:
```
❌ La configuración "Defecto" es obligatoria y no puede eliminarse.
```

#### Confirmación obligatoria al usuario

Copilot debe mostrar el siguiente mensaje y esperar confirmación explícita (`s`) antes de invocar el script:

```
⚠️  Vas a eliminar la configuración de carga

Entidad: Organization
Configuración: OrganizationComplete

Esta acción eliminará:
  - El bloque <Configurations> del XML
  - La constante ORGANIZATION_COMPLETE de Consts.cs

¿Confirmas la eliminación? (s/N):
```

#### Invocación de ejemplo (solo tras confirmar)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File \
  ".github/agents/tools/Delete-Configuration.ps1" \
  -EntityName "Organization" -ConfigurationName "OrganizationComplete"
```

#### Salida esperada tras ejecución del script

```
🗑️  Eliminando configuración...
  ✓ Configuración "OrganizationComplete" eliminada de HelixEntities.xml
  ✓ Constante ORGANIZATION_COMPLETE eliminada de Consts.cs

✅ Configuración eliminada exitosamente
```

---

## Formato y Convenciones del XML

### Indentación
- 2 espacios por nivel
- Sin tabs

### Orden de elementos dentro de `<Entities>`
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

### Nombres de configuraciones
- PascalCase: `WorkerComplete`, `ApplicationFull`
- Sin espacios ni caracteres especiales

### Tipos de datos soportados

| Tipo .NET | EntityFieldTypeDB XML |
|---|---|
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

## Checklist de Validación Post-Ejecución

### Después de `/UpdateHelixEntities`
- [ ] Todas las entidades del DataModel tienen mapeo en el XML (excepto vistas BD)
- [ ] No hay Fields de propiedades eliminadas
- [ ] Todas las entidades tienen configuración "Defecto" con Orders
- [ ] Campos de auditoría presentes en todas las entidades IEntityBase
- [ ] No hay referencias a entidades eliminadas en Includes
- [ ] ViewName siempre es `[EntityName]View`
- [ ] Archivo XML válido y bien formateado

### Después de `/CreateConfiguration` o `/UpdateConfiguration`
- [ ] Configuración creada o actualizada correctamente en XML
- [ ] Estructura de Includes correcta y sin referencias circulares
- [ ] Ordenación definida (mínimo Id ASC)
- [ ] `Consts.cs` actualizado con la constante correspondiente
- [ ] Nombre de constante sigue convención UPPER_CASE
- [ ] Configuración no referencia entidades inexistentes

---

## Referencias Técnicas

### Documentación relacionada
- Framework Helix6: `.github/copilot-instructions.md`
- Arquitectura Backend: `docs/[Proyecto]_Architecture.md`
- Agente de Database: `.github/agents/Helix6Back.Database.agent.md`
- Agente de Views: `.github/agents/Helix6Back.Views.agent.md`

### Archivos involucrados
- `[Proyecto].Back.DataModel/*.cs` — Entidades origen
- `[Proyecto].Back.Entities/Views/*.cs` — Views destino
- `[Proyecto].Back.Api/HelixEntities.xml` — Archivo de configuración
- `[Proyecto].Back.Entities/Consts.cs` — Constantes de configuraciones
- `.github/agents/tools/*.ps1` — Scripts de ejecución
