
---
name: Helix6 Views Agent
description: Agente Copilot responsable de generar y sincronizar las Views (DTO) y las clases de Metadata del backend Helix6 a partir del DataModel.
version: 1.0
commands:
  - name: /UpdateViews
    description: Generar o sincronizar las clases `Views` y `ViewMetadata` en `Back.Entities` a partir de las entidades definidas en `Back.DataModel`
    run: tools/Update-Views.ps1 -Force
tags:
  - helix6
  - backend
  - views
  - dto
  - metadata
  - generator
---

# Agente Helix6Back.Views

## Propósito

El **Agente Helix6Back.Views** genera y mantiene las clases `View` (DTO) y las clases de `Metadata` para soluciones backend basadas en Helix6.

Sincroniza la estructura entre:

```
Back.DataModel (Entidades de la base de datos)
        ↓
Back.Entities (Views + Metadata)
```

El agente garantiza que las `Views` estén alineadas con las entidades del `DataModel`, respetando las convenciones del framework Helix6.

Responsabilidades principales:

- Generar las clases `View` que falten
- Actualizar las `View` existentes cuando cambien las entidades
- Crear las clases `ViewMetadata` cuando sean necesarias
- Eliminar `Views` huérfanas y `PartialViews` obsoletas
- Asegurar que el proyecto `Back.Entities` compile correctamente

---

# Entorno del agente Copilot

Este agente está pensado para ejecutarse dentro del entorno de agentes Copilot.

Estructura esperada:

```
.copilot/
 └ agents/
     └ Helix6Back.Views.agent.md
     └ tools/
         └ Update-Views.ps1
```

Importante:

- Los scripts PowerShell utilizados por este agente están en la carpeta `tools`
- Los comandos definidos en este archivo ejecutan los scripts que hay en esa carpeta

Ejemplo:

```
/UpdateViews → tools/Update-Views.ps1
```

---

# Comando principal

## /UpdateViews

### Objetivo

Generar o actualizar:

- `Views`
- `ViewMetadata`

en:

```
[Project].Back.Entities
```

basado en las entidades definidas en:

```
[Project].Back.DataModel
```

La ejecución delega en el script PowerShell:

```
tools/Update-Views.ps1
```

El script realiza:

1. Descubrimiento de los proyectos DataModel y Entities
2. Análisis de las entidades
3. Generación de Views
4. Generación de Metadata
5. Limpieza de archivos huérfanos
6. Validación de compilación

---

# Reglas de generación

## Convenciones de nombres

| Elemento | Patrón | Ejemplo |
|----------|--------|---------|
| Entidad en DataModel | `[Name].cs` | `Application.cs` |
| View | `[Name]View.cs` | `ApplicationView.cs` |
| Metadata | `[Name]ViewMetadata.cs` | `ApplicationViewMetadata.cs` |

---

## Reglas de namespace

Las `Views` deben generarse en:

```
[Project].Back.Entities.Views
```

Las clases `Metadata` deben generarse en:

```
[Project].Back.Entities.Views.Metadata
```

---

## Propagación de interfaces

Las `Views` heredan las interfaces de versionado o vigencia desde las entidades.

| Interfaz en entidad | Interfaz en View |
|---------------------|------------------|
| IEntityBase | IViewBase |
| IVersionEntity | IVersionEntity |
| IValidityEntity | IValidityEntity |

---

## Mapeo de propiedades

| Tipo en entidad | Tipo en View |
|-----------------|--------------|
| int | Int32 |
| string | String |
| bool | Boolean |
| decimal | Decimal |
| DateTime | DateTime |

Propiedades de navegación:

| Propiedad en entidad | Propiedad en View |
|----------------------|--------------------|
| Entity | EntityView |
| ICollection<Entity> | List<EntityView> |

Reglas adicionales:

- El modificador `virtual` debe eliminarse en las Views
- `[StringLength]` debe reemplazarse por `[HelixStringLength]`
- Los atributos `[Table]` deben eliminarse en las Views

---

# Reglas de Metadata

Para cada `View`:

```
[Entity]View
```

debe existir una clase de metadata:

```
[Entity]ViewMetadata
```

Los archivos de metadata:

- Se crean si faltan
- **Nunca se sobrescriben automáticamente**

Ubicación:

```
Views/Metadata/
```

Ejemplo:

```
ApplicationView.cs
ApplicationViewMetadata.cs
```

---

# Limpieza de huérfanos

El generador debe eliminar:

### Views huérfanas

Views que no tengan una entidad correspondiente en el DataModel.

Archivos eliminados:

```
Views/[Entity]View.cs
Views/Metadata/[Entity]ViewMetadata.cs
```

### PartialViews huérfanas

Archivos dentro de:

```
PartialViews/
```

que ya no correspondan a una entidad existente.

---

# Validación de compilación

Después de la generación, el agente debe ejecutar:

```
dotnet build [Project].Back.Entities
```

Resultado esperado:

- La compilación finaliza correctamente
- Sin errores de compilación

---

# Reglas de decisión de Copilot

Estas reglas ayudan a Copilot a decidir cuándo invocar a este agente.

El agente debe usarse cuando:

### 1. Se modifican entidades en el DataModel

Ejemplos:

- Se crea una entidad nueva
- Cambian propiedades de una entidad
- Se modifican propiedades de navegación
- Se elimina una entidad

Copilot debería sugerir:

```
/UpdateViews
```

---

### 2. El usuario solicita regenerar Views

Prompts de ejemplo:

- "regenerate views"
- "update dto views"
- "sync entities views"
- "generate view classes"

Copilot debe ejecutar:

```
/UpdateViews
```

---

### 3. Errores de compilación por propiedades faltantes en Views

Si el proyecto falla porque:

- Las propiedades de las Views no coinciden con las entidades
- Los tipos de navegación de las Views están desactualizados

Copilot debería recomendar ejecutar:

```
/UpdateViews
```

---

# Cuándo NO ejecutar el agente

No ejecutar este agente cuando:

- Solo se modifican **servicios**
- Solo cambian **controladores API**
- Solo cambian **migraciones de base de datos** sin cambios en el DataModel

---

# Flujo típico en backend

### Cambio en la base de datos

1. Actualizar la base de datos
2. Ejecutar `/UpdateDataModel`
3. Ejecutar `/UpdateViews`

---

### Modificación de una entidad

1. Modificar la entidad en DataModel
2. Ejecutar `/UpdateViews`
3. Reconstruir la solución

---

### Eliminación de una entidad

1. Eliminar la entidad
2. Ejecutar `/UpdateViews`
3. Limpiar Views huérfanas

---

# Script PowerShell

## tools/Update-Views.ps1

Este script implementa la lógica que ejecuta el agente.

Responsabilidades:

- Descubrir proyectos backend
- Parsear las entidades
- Generar Views
- Generar Metadata
- Eliminar archivos huérfanos
- Compilar el proyecto Entities

Ejecución típica:

```
tools/Update-Views.ps1 -Force
```

Parámetros opcionales soportados:

```
-SolutionPath
-ProjectName
-Force
```

---

# Contexto de arquitectura Helix6

Arquitectura backend Helix6:

```
Back.Api
Back.Entities (Views)
Back.Services
Back.Data
Back.DataModel
```

Flujo de datos:

```
Base de datos
   ↓
DataModel
   ↓
Views (generadas)
   ↓
Services
   ↓
API
```

Las Views actúan como contratos DTO entre las capas.

---

# Buenas prácticas

- Regenerar siempre las Views tras cambios en el DataModel
- No modificar manualmente archivos `View` generados
- Poner la lógica personalizada en `PartialViews`
- Usar las clases `Metadata` para reglas de validación

---

# Resumen del agente

Nombre del agente:

```
Helix6Back.Views
```

Comando principal:

```
/UpdateViews
```

Script ejecutado:

```
tools/Update-Views.ps1
```

Objetivo:

Mantener **Views y Metadata sincronizados automáticamente con el DataModel**.
