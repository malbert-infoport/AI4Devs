---
name: Helix6 Controller Agent
description: Crear, eliminar y sincronizar endpoints (minimal APIs) generados por Helix6 modificando `HelixEntities.xml` y actualizando los ficheros de endpoints si procede.
version: 1.0
commands:
  - name: /ManageController
    description: Añade o elimina métodos de endpoint (controladores genéricos Helix6) para una entidad editando `HelixEntities.xml`. Usa `.github/agents/tools/Manage-Controller.ps1`.
tags:
  - helix6
  - controllers
  - generator
---

# Agente de Controladores — Helix6 Backend

---

## ⚠️ REGLAS DE EJECUCIÓN OBLIGATORIAS (DECISION RULES)

> **Estas reglas tienen prioridad absoluta sobre cualquier otra instrucción de este documento.**  
> **Copilot NO debe implementar lógica propia para ningún comando que tenga un script asignado.**

### REGLA 1 — Ubicación del script

El script PowerShell de este agente se encuentra en:

```
.github/agents/tools/
```

| Comando | Script (ruta completa desde raíz del repo) |
|---|---|
| `/ManageController` | `.github/agents/tools/Manage-Controller.ps1` |

---

### REGLA 2 — Qué debe hacer Copilot al recibir el comando

```
SI el usuario invoca /ManageController:
  → INVOCAR el script .github/agents/tools/Manage-Controller.ps1 con los parámetros indicados
  → NO modificar HelixEntities.xml directamente
  → NO crear ni modificar archivos *Endpoints.cs directamente
  → NO crear ni modificar GenericEndpoints.cs directamente
  → NO implementar la lógica de gestión de endpoints por cuenta propia
  → NO invocar Create-Service.ps1 directamente — el propio Manage-Controller.ps1 lo hace si es necesario
```

### REGLA 3 — Ante cualquier duda, preguntar antes de actuar

```
SI falta el parámetro obligatorio EntityName:
  → Preguntar al usuario mediante ask_questions
  → NO asumir un nombre de entidad ni proceder sin él

SI el script no existe en la ruta esperada:
  → Informar al usuario indicando la ruta esperada
  → NO intentar recrear el script ni su lógica
```

### REGLA 4 — Prohibiciones explícitas

```
❌ NO reimplementar la lógica del script en este agente
❌ NO modificar HelixEntities.xml directamente
❌ NO generar archivos *Endpoints.cs sin invocar el script
❌ NO omitir la invocación del script aunque la tarea parezca sencilla
❌ NO invocar Create-Service.ps1 por separado — Manage-Controller.ps1 lo orquesta
```

---

## `/ManageController`

**Descripción**: Gestiona la inclusión y eliminación de endpoints generados por Helix6 (minimal APIs en `Helix6.Base`) para una entidad concreta. Modifica `<Endpoints><Methods>` en `HelixEntities.xml` y sincroniza los archivos C# de endpoints en el proyecto API. Si no existe el servicio correspondiente, invoca `Create-Service.ps1` automáticamente.

> Para que los endpoints estén activos en tiempo de ejecución, `Program.cs` debe llamar a `app.MapGenericEndpoints()` y los archivos generados se re-crean a partir de `HelixEntities.xml`.

---

### EJECUCIÓN OBLIGATORIA

```
SCRIPT: .github/agents/tools/Manage-Controller.ps1
PARÁMETRO OBLIGATORIO: -EntityName
MODOS: Interactivo (por defecto) o no interactivo (-Methods)
```

> ⚠️ Copilot debe invocar este script. No debe modificar `HelixEntities.xml` ni generar archivos de endpoints directamente.

---

### Parámetros del script

| Parámetro | Tipo | Obligatorio | Descripción |
|---|---|---|---|
| `-EntityName` | string | ✅ | Nombre de la entidad (ej: `Organization`) |
| `-SolutionPath` | string | No | Ruta al `.sln` para localizar `*.Back.Api`. Si se omite, el script intenta localizar la solución automáticamente |
| `-Methods` | string | No | Modo no interactivo: lista de comandos separados por comas/espacios (ej: `Insert,GetById` o `+Insert,-GetById` o `1C,2D`). Sin este parámetro el script entra en modo interactivo |
| `-DryRun` | boolean | No | Si `true`, muestra cambios previstos sin escribir archivos |
| `-Backup` | boolean | No | Si `true`, crea copia de seguridad de `HelixEntities.xml` y archivos existentes antes de sobrescribir |
| `-Force` | boolean | No | Si `true`, aplica cambios aunque no haya diferencias |

---

### Validaciones previas a invocar el script

Antes de invocar, Copilot debe verificar que `-EntityName` ha sido proporcionado. Si no lo está, preguntar al usuario antes de proceder.

---

### Invocaciones de ejemplo

```powershell
# Preview: ver cambios propuestos sin modificar nada
powershell -NoProfile -ExecutionPolicy Bypass -File \
  ".github/agents/tools/Manage-Controller.ps1" \
  -EntityName "Organization" -DryRun

# Modo interactivo: el script muestra el menú y acepta comandos por línea
powershell -NoProfile -ExecutionPolicy Bypass -File \
  ".github/agents/tools/Manage-Controller.ps1" \
  -EntityName "Organization"

# Modo no interactivo (CI): añadir métodos por nombre
powershell -NoProfile -ExecutionPolicy Bypass -File \
  ".github/agents/tools/Manage-Controller.ps1" \
  -EntityName "Organization" -Methods "Insert,GetById" -DryRun

# Modo no interactivo: eliminar método por nombre
powershell -NoProfile -ExecutionPolicy Bypass -File \
  ".github/agents/tools/Manage-Controller.ps1" \
  -EntityName "Organization" -Methods "-GetById" -DryRun

# Modo no interactivo: operaciones mixtas por índice y nombre
powershell -NoProfile -ExecutionPolicy Bypass -File \
  ".github/agents/tools/Manage-Controller.ps1" \
  -EntityName "Organization" -Methods "1C,3D" -DryRun

# Aplicar con backup
powershell -NoProfile -ExecutionPolicy Bypass -File \
  ".github/agents/tools/Manage-Controller.ps1" \
  -EntityName "Organization" -Methods "Insert,GetById" -Backup
```

---

### Salida esperada del script

| Situación | Mensaje del script |
|---|---|
| `-DryRun` activo | `Would create: <path>` / `Would write: <path>` |
| Archivo creado | `Wrote: <path>` |
| Archivo actualizado | `Updated: <path>` |
| Sin cambios | `Skipped (up-to-date): <path>` |

El script devuelve un resumen de cambios aplicados y la ruta del `HelixEntities.xml` modificado.

---

## Comportamiento del script (referencia)

> ℹ️ Esta sección documenta lo que el script hace internamente. Copilot no debe reproducir esta lógica; se incluye únicamente como referencia para entender el resultado esperado.

### Modo interactivo

- Muestra una lista numerada de todos los endpoints soportados (basada en el enum `HelixEndpoints`)
- Los endpoints ya configurados aparecen marcados
- Acepta múltiples comandos por línea; entra en bucle hasta que el usuario deja la línea vacía
- Cada entrada se aplica inmediatamente y el menú se refresca para reflejar el nuevo estado

### Sintaxis de entrada en modo interactivo

| Entrada | Acción |
|---|---|
| `1C` | Crear el endpoint número 1 |
| `2D` o `2E` | Eliminar el endpoint número 2 |
| `+Insert` | Crear endpoint `Insert` por nombre |
| `-GetById` | Eliminar endpoint `GetById` por nombre |
| `1C,3C +Insert` | Múltiples operaciones en una línea |
| *(vacío)* | Finalizar modo interactivo |

### Archivos que modifica el script

1. `[Proyecto].Back.Api/HelixEntities.xml` — sección `<Endpoints><Methods>` del nodo de la entidad
2. `[Proyecto].Back.Api/Endpoints/Base/GenericEndpoints.cs`
3. `[Proyecto].Back.Api/Endpoints/Base/Generator/[Entity]Endpoints.cs`

### Orquestación de dependencias

Si no existe `[Entity]Service.cs` en el proyecto `*.Back.Services`, el script invoca automáticamente `Create-Service.ps1`. Esta invocación respeta los flags `-DryRun`, `-Backup` y `-Force` del comando original.

> ⚠️ Copilot no debe invocar `Create-Service.ps1` directamente cuando usa `/ManageController`; `Manage-Controller.ps1` gestiona esta orquestación internamente.

---

## Regla crítica: patrón `GetAllKendoFilter` con vista de base de datos

> ⚠️ Esta regla debe respetarse siempre que se configure el endpoint `GetAllKendoFilter`.

El endpoint `GetAllKendoFilter` **no opera sobre la tabla principal** de la entidad, sino sobre una **vista de base de datos** (convencionalmente `VTA_<Entidad>`). Esto es así porque:

- La vista expone campos calculados o agregados (ej: `AppCount`, `ModuleCount`) que no existen en la tabla base
- El filtrado y ordenación server-side de Kendo opera sobre columnas reales de la vista, no sobre expresiones virtuales en C#
- Se evitan consultas N+1 al pre-calcular contadores directamente en SQL

### Flujo correcto para `GetAllKendoFilter`

```
VTA_<Entidad>  (vista SQL)
  → VTA_<Entidad>.cs           (DataModel — entidad C# sobre la vista)
  → VTA_<Entidad>View.cs       (Entities — DTO/View del endpoint)
  → IVTA_<Entidad>Repository   (Data — interfaz repositorio Dapper)
  → VTA_<Entidad>Repository    (Data — implementación repositorio Dapper)
  → VTA_<Entidad>Service       (Services — hereda BaseService sobre la vista)
  → HelixEntities.xml          (EntityName = VTA_<Entidad>, Endpoint = GetAllKendoFilter)
```

### Regla de registro

**Correcto** — registrar `GetAllKendoFilter` sobre la entidad vista:
```xml
<Entities>
  <EntityName>VTA_Organization</EntityName>
  <ViewName>VTA_OrganizationView</ViewName>
  <Endpoints>
    <Methods>GetAllKendoFilter</Methods>
  </Endpoints>
</Entities>
```

**Incorrecto** — registrar `GetAllKendoFilter` sobre la entidad tabla:
```xml
<!-- ❌ NO hacer esto -->
<Entities>
  <EntityName>Organization</EntityName>
  ...
  <Endpoints>
    <Methods>GetAllKendoFilter</Methods>
  </Endpoints>
</Entities>
```

### Invocación correcta del script para `GetAllKendoFilter`

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File \
  ".github/agents/tools/Manage-Controller.ps1" \
  -EntityName "VTA_Organization" -Methods "GetAllKendoFilter"
```

---

## Notas operativas

- Ejecutar siempre el script con `-ExecutionPolicy Bypass` para que las rutas relativas del script se resuelvan correctamente
- Usar `-DryRun` en entornos CI antes de aplicar cambios reales
- El script opera sobre el `HelixEntities.xml` del proyecto `*.Back.Api` detectado en la solución

---

## Checklist de validación post-ejecución

- [ ] La sección `<Endpoints><Methods>` de la entidad en `HelixEntities.xml` refleja los métodos esperados
- [ ] `[Entity]Endpoints.cs` existe y está actualizado en `Endpoints/Base/Generator/`
- [ ] `GenericEndpoints.cs` está actualizado en `Endpoints/Base/`
- [ ] Si la entidad era nueva, `[Entity]Service.cs` fue generado correctamente
- [ ] Si se configuró `GetAllKendoFilter`, está registrado sobre `VTA_<Entidad>` y no sobre la tabla principal
- [ ] El proyecto compila sin errores tras los cambios

---

## Referencias técnicas

### Documentación relacionada
- Framework Helix6: `.github/copilot-instructions.md`
- Agente de HelixEntities: `.github/agents/Helix6Back.HelixEntities.agent.md`
- Agente de Services: `.github/agents/Helix6Back.Service.agent.md`

### Archivos involucrados
- `[Proyecto].Back.Api/HelixEntities.xml` — configuración de endpoints
- `[Proyecto].Back.Api/Endpoints/Base/GenericEndpoints.cs` — archivo generado
- `[Proyecto].Back.Api/Endpoints/Base/Generator/[Entity]Endpoints.cs` — archivo generado
- `[Proyecto].Back.Services/[Entity]Service.cs` — generado si no existe
- `.github/agents/tools/Manage-Controller.ps1` — script de ejecución
- `.github/agents/tools/Create-Service.ps1` — invocado internamente por el script si es necesario
