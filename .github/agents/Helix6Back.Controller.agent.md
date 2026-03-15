---
name: Helix6 Controller Agent
description: Crear, eliminar y sincronizar endpoints (minimal APIs) generados por Helix6 modificando `HelixEntities.xml` y actualizando los ficheros de endpoints si procede.
version: 1.0
commands:
  - name: /ManageController
    description: Añade o elimina métodos de endpoint (controladores genéricos Helix6) para una entidad editando `HelixEntities.xml`.
tags:
  - helix6
  - controllers
  - generator
---

# Agente de Controladores - Helix6 Backend

Este agente gestiona la inclusión y eliminación de endpoints generados por Helix6 (las minimal APIs implementadas en `Helix6.Base`) para una entidad concreta. Para que los endpoints estén activos en tiempo de ejecución, `Program.cs` debe llamar a `app.MapGenericEndpoints()` y los archivos generados por el motor de generación se re-crean a partir de `HelixEntities.xml`.

Comandos disponibles:

## `/ManageController`

Descripción: interactivo — muestra la lista de controladores aplicables a la entidad (incluye métodos de versión/validity según `HelixEntities.xml`), marca en verde los que ya están configurados, permite crear o eliminar los que elijas y opcionalmente sincroniza/actualiza los archivos C# de endpoints.

Parámetros / flags:
- `entity` (string, requerido): Nombre de la entidad (p.ej. `Organization`).
- `solutionPath` (string, opcional): Ruta del `.sln` donde buscar el proyecto `*.Back.Api`. Si no se pasa, el script intenta localizar la solución.
- `dryRun` (boolean): Si `true` no modifica archivos; muestra los cambios que se harían.
- `backup` (boolean): Si `true` crea copia de seguridad del `HelixEntities.xml` antes de escribir.
- `force` (boolean): Si `true` aplica cambios aunque no haya diferencias.

Interacción:
- Al iniciar muestra una lista numerada de los tipos de endpoint soportados por Helix6 (basado en `HelixEndpoints` enum). Los existentes aparecen marcados en verde.
- El prompt interactivo acepta múltiples comandos por línea y entra en bucle hasta que el usuario deja la línea vacía; cada entrada se aplica inmediatamente y el menú se refresca para mostrar el nuevo estado.
- Entrada admitida:
  - `1C` → crear el endpoint número 1 (Create)
  - `2E` o `2D` → eliminar el endpoint número 2 (Delete / Erase)
  - `+Insert` → crear `Insert` por nombre
  - `-GetById` → eliminar `GetById` por nombre
  - `3D` → ejemplo de eliminación por índice (incluido en el prompt)
  - Métodos separados por comas o espacios: `1C,3C +Insert`
  - Vacío → finalizar (en modo interactivo las entradas ya aplicadas no se vuelven a re-aplicar)

Comportamiento:
- Actualiza la sección `<Endpoints><Methods>` del nodo `<Entity>` correspondiente en `HelixEntities.xml` (evita duplicados y valida nombres contra el enum de endpoints).
- En modo interactivo las entradas se aplican inmediatamente y el script refresca la vista para reflejar los cambios.
- Tras actualizar `HelixEntities.xml` el script intentará sincronizar los ficheros de endpoints C# en el proyecto API: `Endpoints\Base\GenericEndpoints.cs` y `Endpoints\Base\Generator\{Entity}Endpoints.cs`. En `-DryRun` imprimirá el contenido que escribiría.
- Si no existe el `Service` correspondiente, el script invocará `tools\Create-Service.ps1` para generar un `{EntityName}Service.cs` (respeta `-DryRun`, `-Backup` y `-Force`).
- `-DryRun` muestra los cambios previstos sin escribir ficheros. `-Backup` es opt-in y crea copias de seguridad cuando procede.

Parámetros / flags:
- `entity` (string, requerido): Nombre de la entidad (p.ej. `Organization`).
- `solutionPath` (string, opcional): Ruta del `.sln` donde buscar el proyecto `*.Back.Api`. Si no se pasa, el script intenta localizar la solución.
- `dryRun` (boolean): Si `true` no modifica archivos; muestra los cambios que se harían (`Would create` / `Would write`).
- `backup` (boolean): Si `true` crea copia de seguridad del `HelixEntities.xml` o de archivos existentes antes de sobrescribir.
- `force` (boolean): Si `true` aplica cambios aunque no haya diferencias.
- `methods` (string): Modo no interactivo — lista separada por comas/espacios con comandos (ej. `Insert,GetById` o `+Insert,-GetById`, también acepta `1C,2D`).

Ejemplos de uso (invocación directa al script dentro del proyecto `tools`):

```powershell
# Preview: ver cambios propuestos
powershell -NoProfile -ExecutionPolicy Bypass -File "tools\Manage-Controller.ps1" -EntityName "Organization" -DryRun

# Interactive: iniciar prompt y usar comandos (ej: escribir "1C" o "3D" por línea)
powershell -NoProfile -ExecutionPolicy Bypass -File "tools\Manage-Controller.ps1" -EntityName "Organization"

# Non-interactive (CI): aplicar métodos por nombre (usa -DryRun en CI primero)
powershell -NoProfile -ExecutionPolicy Bypass -File "tools\Manage-Controller.ps1" -EntityName "Organization" -Methods "Insert,GetById" -DryRun

# Eliminar por nombre (non-interactive, preview)
powershell -NoProfile -ExecutionPolicy Bypass -File "tools\Manage-Controller.ps1" -EntityName "Organization" -Methods "-GetById" -DryRun

# Eliminar por índice (non-interactive, preview) — usa el número que muestra el menú
powershell -NoProfile -ExecutionPolicy Bypass -File "tools\Manage-Controller.ps1" -EntityName "Organization" -Methods "3D" -DryRun
```

Notas operativas:
- El script opera sobre el `HelixEntities.xml` del `*.Back.Api` detectado en la solución.
- No toca los archivos generados; tras editar `HelixEntities.xml` ejecuta el flujo de generación manualmente para crear/actualizar `Endpoints/Base/Generator/{Entity}Endpoints.cs` y `Base/GenericEndpoints.cs`.
- El agente devuelve un resumen de cambios aplicados y la ruta del `HelixEntities.xml` modificado.

## Patrón `GetAllKendoFilter` con vista de base de datos

**Regla crítica:** El endpoint `GetAllKendoFilter` de una entidad **no opera directamente sobre la tabla principal** sino sobre una **vista de base de datos** (convencionalmente llamada `VTA_<Entidad>`, p.ej. `VTA_Organization`). Esta vista permite:

- Exponer campos calculados o agregados (p.ej. `AppCount`, `ModuleCount`) que no existen en la tabla base.
- Permitir **filtrado y ordenación server-side** sobre esos campos calculados, ya que son columnas reales de la vista y no expresiones virtuales en C#.
- Evitar N+1 queries al pre-calcular los contadores directamente en SQL.

Por tanto, cuando se implemente `GetAllKendoFilter` para una entidad, el flujo correcto es:

```
VTA_<Entidad> (vista SQL)
    → VTA_<Entidad>.cs  (DataModel — entidad C# sobre la vista)
    → VTA_<Entidad>View.cs  (Entities — DTO/View del endpoint)
    → IVTA_<Entidad>Repository / VTA_<Entidad>Repository  (Data — repositorio Dapper)
    → VTA_<Entidad>Service  (Services — hereda BaseService sobre la vista)
    → HelixEntities.xml: EntityName = VTA_<Entidad>, Endpoint = GetAllKendoFilter
```

**No** se registra `GetAllKendoFilter` sobre la entidad tabla (`Organization`); se registra sobre la entidad vista (`VTA_Organization`). Esto garantiza que los filtros Kendo operen correctamente contra columnas reales de la BD.

Ejemplo de registro correcto en `HelixEntities.xml`:
```xml
<Entities>
  <EntityName>VTA_Organization</EntityName>
  <ViewName>VTA_OrganizationView</ViewName>
  <Endpoints>
    <Methods>GetAllKendoFilter</Methods>
  </Endpoints>
</Entities>
```

Y el comando `Manage-Controller.ps1` correspondiente:
```powershell
.\tools\Manage-Controller.ps1 -EntityName "VTA_Organization" -Methods "GetAllKendoFilter"
``` 
