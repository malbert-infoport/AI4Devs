---
name: Helix6 Service Agent
description: Generación de servicios Helix6 desde Views/DataModel usando el script PowerShell Create-Service.ps1
version: 1.0
commands:
  - name: /CreateService
    description: Crea o actualiza un servicio en el proyecto `*.Back.Services` a partir de un View / Entity. Usa `.github/agents/tools/Create-Service.ps1` para renderizar la plantilla.
tags:
  - helix6
  - services
  - generator
---

# Agente de Servicios — Helix6 Backend

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
| `/CreateService` | `.github/agents/tools/Create-Service.ps1` |

---

### REGLA 2 — Qué debe hacer Copilot al recibir el comando

```
SI el usuario invoca /CreateService:
  → INVOCAR el script .github/agents/tools/Create-Service.ps1 con los parámetros indicados
  → NO implementar la lógica de generación por cuenta propia
  → NO crear ni modificar archivos *Service.cs directamente
  → NO generar código C# de servicios sin pasar por el script
  → NO reproducir el contenido de las plantillas manualmente
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
❌ NO generar archivos *Service.cs directamente sin invocar el script
❌ NO crear scripts PowerShell alternativos o equivalentes
❌ NO omitir la invocación del script aunque la tarea parezca sencilla
❌ NO inferir el contenido de las plantillas a partir de su nombre o descripción
```

---

## `/CreateService`

**Descripción**: Genera o actualiza el archivo `[Entity]Service.cs` en el proyecto `*.Back.Services`. El script detecta la clase base adecuada (`BaseService`, `BaseVersionService`, `BaseValidityService`) en función de las propiedades de la entidad, inyecta el repositorio si existe y renderiza la plantilla correspondiente.

---

### EJECUCIÓN OBLIGATORIA

```
SCRIPT: .github/agents/tools/Create-Service.ps1
PARÁMETRO OBLIGATORIO: -EntityName
MODO: El script gestiona la generación completa del servicio
```

> ⚠️ Copilot debe invocar este script. No debe generar ni modificar archivos de servicio directamente.

---

### Parámetros del script

| Parámetro | Tipo | Obligatorio | Descripción |
|---|---|---|---|
| `-EntityName` | string | ✅ | Nombre de la entidad/view (ej: `Organization`) |
| `-SolutionPath` | string | No | Ruta al `.sln`. Si se omite el script intenta localizar la solución automáticamente |
| `-ProjectName` | string | No | Nombre del proyecto raíz si difiere de la detección automática |
| `-DryRun` | boolean | No | Si `true`, simula la ejecución y muestra qué archivo se escribiría sin crearlo |
| `-Backup` | boolean | No | Si `true`, crea copia de seguridad del archivo anterior antes de sobrescribir |
| `-Force` | boolean | No | Si `true`, fuerza la escritura aunque el archivo exista sin cambios |
| `-Verbose` | boolean | No | Habilita salida de diagnóstico mediante `Write-Verbose` |
| `-WithSkeletonOverrides` | boolean | No | Si `true`, usa plantillas con overrides esqueleto para facilitar la implementación inicial |

---

### Validaciones previas a invocar el script

Antes de invocar, Copilot debe verificar que `-EntityName` ha sido proporcionado. Si no lo está, preguntar al usuario antes de proceder.

---

### Invocaciones de ejemplo

```powershell
# Simulación sin escribir archivos
powershell -NoProfile -ExecutionPolicy Bypass -File \
  ".github/agents/tools/Create-Service.ps1" \
  -EntityName "Organization" -SolutionPath "C:\path\to\My.Back.sln" -DryRun

# Escribir el archivo y crear backup si ya existe
powershell -NoProfile -ExecutionPolicy Bypass -File \
  ".github/agents/tools/Create-Service.ps1" \
  -EntityName "Organization" -SolutionPath "C:\path\to\My.Back.sln" -Backup

# Forzar escritura aunque no haya cambios
powershell -NoProfile -ExecutionPolicy Bypass -File \
  ".github/agents/tools/Create-Service.ps1" \
  -EntityName "Organization" -Force

# Diagnóstico verbose
powershell -NoProfile -ExecutionPolicy Bypass -File \
  ".github/agents/tools/Create-Service.ps1" \
  -EntityName "Organization" -DryRun -Verbose

# Plantillas con overrides esqueleto
powershell -NoProfile -ExecutionPolicy Bypass -File \
  ".github/agents/tools/Create-Service.ps1" \
  -EntityName "Organization" -WithSkeletonOverrides -DryRun -Verbose
```

---

### Salida esperada del script

| Situación | Mensaje del script |
|---|---|
| `-DryRun` activo | `[DryRun] Would write: <path>` |
| Archivo creado | `Wrote: <path>` |
| Archivo actualizado | `Updated: <path>` |
| Sin cambios | `Skipped (up-to-date): <path>` |

---

## Comportamiento del script (referencia)

> ℹ️ Esta sección documenta lo que el script hace internamente. Copilot no debe reproducir esta lógica; se incluye únicamente como referencia para entender el resultado esperado.

### Detección de proyectos

El script localiza automáticamente:
- `*.Back.DataModel` — para leer propiedades de la entidad
- `*.Back.Data` — para detectar si existe `I[Entity]Repository`
- `*.Back.Services` — destino del archivo generado

### Selección de clase base

| Condición detectada en la entidad | Clase base seleccionada |
|---|---|
| Tiene `VersionKey` + `VersionNumber` + campos de vigencia | `BaseValidityService` |
| Tiene `VersionKey` + `VersionNumber` | `BaseVersionService` |
| Resto de casos | `BaseService` |

Si la detección automática es incorrecta, ajustar manualmente el `base` en la clase generada.

### Inyección de repositorio

| Condición | Repositorio inyectado |
|---|---|
| Existe `Data/Repository/Interfaces/I[Entity]Repository.cs` | `I[Entity]Repository` con namespace `Root.Back.Data.Repository.Interfaces` |
| No existe el repositorio específico | `IBaseRepository<[Entity]>` |

El campo privado usa siempre el prefijo `_` (convención Helix6): `_repository`.

### Plantillas disponibles

| Plantilla | Descripción |
|---|---|
| `tools/templates/Service.template.cs` | Plantilla mínima sin overrides |
| `tools/templates/ServiceFull.template.cs` | Plantilla con overrides esqueleto |
| `tools/templates/ServiceVersion.template.cs` | Plantilla para entidades versionadas |
| `tools/templates/ServiceValidity.template.cs` | Plantilla para entidades con vigencia |

El parámetro `-WithSkeletonOverrides` selecciona automáticamente la plantilla completa adecuada.

### Tokens reemplazados por el script

| Token | Valor de ejemplo |
|---|---|
| `__NAMESPACE__` | `InfoportOneAdmon.Back.Services` |
| `__ENTITY_NAME__` | `Organization` |
| `__VIEW__` | `OrganizationView` |
| `__BASE_SERVICE__` | `BaseService<OrganizationView, Organization, OrganizationViewMetadata>` |
| `__ENTITY_NAMESPACE__` | Namespace del DataModel |
| `__VIEWS_NAMESPACE__` | Namespace de las Views |
| `__METADATA_NAMESPACE__` | Namespace de los Metadata |
| `__REPO_USING__` | `using` completo del repositorio (vacío si no existe) |
| `__REPO_FIELD__` | Declaración del campo privado |
| `__REPO_PARAM__` | Parámetro del constructor |
| `__REPO_ASSIGN__` | Asignación en el constructor |
| `__REPO_BASE__` | Argumento pasado al constructor base |

---

## Overrides generados con `-WithSkeletonOverrides` (referencia)

> ℹ️ El script genera estos overrides como esqueleto con `// TODO:`. No deben ser implementados por Copilot directamente; son el punto de partida para que el desarrollador añada lógica de negocio.

| Override | Propósito |
|---|---|
| `GetNewEntity()` | Establecer valores por defecto del View |
| `ValidateView(...)` | Validar reglas de negocio; debe llamar a `await base.ValidateView(...)` |
| `PreviousActions(...)` | Acciones previas a persistir (limpiar relaciones, validar unicidad) |
| `MapViewToEntity(...)` | Mapeos manuales de View → Entity que Mapster no resuelve automáticamente |
| `MapEntityToView(...)` | Enriquecer la View tras consultas (propiedades calculadas) |
| `PostActions(...)` | Acciones posteriores (publicar eventos, actualizar índices) |

### Reglas de los overrides

- Siempre llamar a `await base.[Método](...)` salvo razón explícita documentada
- Mantener métodos como `async Task`
- No implementar acceso a datos directamente en el servicio; delegar en repositorios
- `MapEntityToView` → para transformar resultados de lectura
- `MapViewToEntity` → para preparar la entidad antes de persistir

---

## Notas operativas

- Ejecutar siempre el script con `-ExecutionPolicy Bypass` para que `Join-Path $PSScriptRoot` resuelva correctamente plantillas y módulos.
- Usar `-Verbose` cuando se necesiten trazas de diagnóstico.
- No modificar plantillas dentro de carpetas auto-generadas del Helix Generator (`Generator/`); solo editar las de `tools/templates/`.
- El script evita generar `using ;` cuando no existe repositorio específico.
- Recomendado: ejecutar `dotnet build` del `*.Back.sln` tras la generación para validar que el servicio compila correctamente.

---

## Checklist de validación post-ejecución

- [ ] El archivo `[Entity]Service.cs` existe en `*.Back.Services`
- [ ] La clase base es correcta (`BaseService`, `BaseVersionService` o `BaseValidityService`)
- [ ] El repositorio inyectado es el correcto (`I[Entity]Repository` o `IBaseRepository<[Entity]>`)
- [ ] Los `using` importados son válidos (sin `using ;`)
- [ ] El proyecto compila sin errores tras la generación
- [ ] Si se usó `-WithSkeletonOverrides`, los `// TODO:` están identificados para revisión

---

## Referencias técnicas

### Documentación relacionada
- Framework Helix6: `.github/copilot-instructions.md`
- Agente de HelixEntities: `.github/agents/Helix6Back.HelixEntities.agent.md`
- Agente de Views: `.github/agents/Helix6Back.Views.agent.md`

### Archivos involucrados
- `[Proyecto].Back.DataModel/[Entity].cs` — Entidad origen
- `[Proyecto].Back.Data/Repository/Interfaces/I[Entity]Repository.cs` — Repositorio (si existe)
- `[Proyecto].Back.Services/[Entity]Service.cs` — Archivo generado
- `.github/agents/tools/Create-Service.ps1` — Script de ejecución
- `.github/agents/tools/templates/Service.template.cs` — Plantilla mínima
- `.github/agents/tools/templates/ServiceFull.template.cs` — Plantilla con overrides
