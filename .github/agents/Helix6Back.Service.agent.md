---
name: Helix6 Service Agent
description: Generación de servicios Helix6 desde Views/DataModel usando el script PowerShell Create-Service.ps1
version: 1.0
commands:
  - name: /CreateService
    description: Crea o actualiza un servicio en el proyecto `*.Back.Services` a partir de un View / Entity. Usa `tools\Create-Service.ps1` para renderizar la plantilla.
tags:
  - helix6
  - services
  - generator
---

# Agente de Servicios - Helix6 Backend

Este agente automatiza la generación de clases `*Service` en proyectos Helix6 aprovechando la plantilla `tools/templates/Service.template.cs` y el script `tools/Create-Service.ps1`.

## Comando disponible

### `/CreateService`

Descripción: genera o actualiza el fichero `[Entity]Service.cs` en el proyecto `*.Back.Services` usando la lógica implementada en `tools/Create-Service.ps1`. El script detecta si existe el repositorio `I[Entity]Repository` para inyectarlo, determina la base (`BaseService`, `BaseVersionService`, `BaseValidityService`) en función de las propiedades de la entidad y soporta `-DryRun`, `-Backup` y `-Force`.

Parámetros del comando (mapeados al script PowerShell):
- `entity` (string, requerido): Nombre de la entidad / view (p.ej. `Organization`).
- `solutionPath` (string, opcional): Ruta al `.sln` para detectar proyectos. Si no se proporciona el script intenta localizar la solución.
- `projectName` (string, opcional): Nombre del proyecto raíz si difiere de la detección por carpeta.
- `dryRun` (boolean, opcional): Si `true` ejecuta en modo simulación y muestra qué archivo se escribiría.
- `backup` (boolean, opcional): Si `true` crea copia de seguridad del fichero anterior antes de sobrescribir.
- `force` (boolean, opcional): Si `true` fuerza la escritura incluso si el archivo existe sin cambios.
- `verbose` (boolean, opcional): Habilita salida de diagnóstico (el script usa `Write-Verbose`).
- `withSkeletonOverrides` (boolean, opcional): Si `true` el script usa plantillas con overrides esqueleto
  (ValidateView, PreviousActions, PostActions, MapViewToEntity, MapEntityToView, GetNewEntity) para facilitar arrancar la
  implementación del servicio.

Comportamiento clave del script (`Create-Service.ps1`):
- Localiza proyectos `*.Back.DataModel`, `*.Back.Data` y `*.Back.Services` en la solución.
- Busca el archivo de entidad `DataModel/[Entity].cs` y extrae propiedades para detectar si la entidad es versión/vigencia (determinando la base service correspondiente).
- Detecta si existe `Data/Repository/Interfaces/I[Entity]Repository.cs` y, si existe, inyecta `I[Entity]Repository`; en caso contrario usa `IBaseRepository<[Entity]>`.
- Renderiza la plantilla `tools/templates/Service.template.cs` reemplazando tokens (`__NAMESPACE__`, `__ENTITY_NAME__`, `__VIEW__`, `__REPO_USING__`, etc.).

Ejemplos de uso (invocación directa al script):

```powershell
# DryRun (no escribe)
powershell -NoProfile -ExecutionPolicy Bypass -File \
  "tools\Create-Service.ps1" -EntityName "Organization" -SolutionPath "C:\path\to\My.Back.sln" -DryRun

# Escribir el archivo y crear backup si existe
powershell -NoProfile -ExecutionPolicy Bypass -File \
  "tools\Create-Service.ps1" -EntityName "Organization" -SolutionPath "C:\path\to\My.Back.sln" -Backup

# Forzar escritura
powershell -NoProfile -ExecutionPolicy Bypass -File \
  "tools\Create-Service.ps1" -EntityName "Organization" -Force

# Mostrar diagnóstico verbose
powershell -NoProfile -ExecutionPolicy Bypass -File \
  "tools\Create-Service.ps1" -EntityName "Organization" -DryRun -Verbose

# Usar plantillas con overrides (skeleton)
powershell -NoProfile -ExecutionPolicy Bypass -File \
  "tools\Create-Service.ps1" -EntityName "Organization" -WithSkeletonOverrides -DryRun -Verbose
```

Cómo el agente debe ejecutar el comando:
- Mapear la petición del usuario a los parámetros anteriores y ejecutar la línea de PowerShell apropiada. Devolver al usuario el resultado del `DryRun` o el path del archivo creado.

Salida esperada:
- En `-DryRun`: mensaje tipo `[DryRun] Would write: <path>` indicando el destino.
- En ejecución normal: mensaje indicando `Wrote: <path>` o `Updated: <path>` o `Skipped (up-to-date): <path>`.

Notas operativas y recomendaciones:
- El script ya usa `Write-Verbose` para mensajes de diagnóstico; habilítalos con `-Verbose` cuando necesites trazas.
- Asegúrate de que el agente ejecute el script con `-ExecutionPolicy Bypass` y en el directorio correcto para que `Join-Path $PSScriptRoot` resuelva plantillas y módulos.
- Si la entidad tiene includes o configuración especial, el servicio generado no gestiona cambios complejos en lógica de negocio; revisa la clase generada antes de usarla en producción.
- El token `__REPO_USING__` contiene el `using` completo si existe el repositorio; la plantilla evita generar `using ;` cuando no hay repo.

Cómo debe generar un servicio Helix6 (guía completa)
- **Selección de Base Service:**
  - Si la entidad contiene `VersionKey` + `VersionNumber` + campos de vigencia → usar `BaseValidityService`.
  - Si contiene `VersionKey` + `VersionNumber` → usar `BaseVersionService`.
  - En caso contrario usar `BaseService`.

- **Inyección de repositorio:**
  - Si existe `Data/Repository/Interfaces/I[Entity]Repository.cs` inyectar `I[Entity]Repository` y usar el namespace `Root.Back.Data.Repository.Interfaces`.
  - Si no existe, inyectar `IBaseRepository<[Entity]>` (el constructor base acepta esa abstracción).
  - Campo privado: `_repository` (prefijo `_` obligatorio según convención Helix6).

- **Archivos/Plantillas disponibles:**
  - `tools/templates/Service.template.cs` — plantilla mínima (sin overrides).
  - `tools/templates/ServiceFull.template.cs` — plantilla con overrides esqueleto (`GetNewEntity`, `ValidateView`, `PreviousActions`, `PostActions`, `MapViewToEntity`, `MapEntityToView`).
  - `tools/templates/ServiceVersion.template.cs` — plantilla para entidades versionadas.
  - `tools/templates/ServiceValidity.template.cs` — plantilla para entidades con vigencia.
  - Use el parámetro `-WithSkeletonOverrides` para elegir automáticamente la plantilla apropiada.

- **Overrides recomendados a generar (cuando aplique):**
  - `GetNewEntity()` — establecer valores por defecto del `View`.
  - `ValidateView(...)` — validar reglas de negocio y luego llamar a `await base.ValidateView(...)`.
  - `PreviousActions(...)` — acciones previas a persistir (ej: limpiar relaciones, validar unicidad compuesta).
  - `MapViewToEntity(...)` — añadir mapeos manuales que Mapster no resuelva automáticamente (se usa en Insert/Update para transformar la `View` en el `Entity`).
  - `MapEntityToView(...)` — completar/modificar propiedades calculadas o preparar la `View` después de consultas (se usa en Get/GetAll para enriquecer la `View`).
  - `PostActions(...)` — acciones posteriores (ej: publicar eventos, actualizar índices).

- **Reglas y buenas prácticas al generar overrides:**
  - Siempre llamar a `await base.[Método](...)` salvo que haya una razón explícita para impedirlo.
  - Mantener métodos `async Task` y devolver `await base...` donde aplique.
  - No implementar lógica de acceso a datos directamente en el servicio; delegar a repositorios.
  - `MapEntityToView(...)` y `MapViewToEntity(...)` deben ser usados para adaptar modelos entre capas: el primero para enriquecer/transformar resultados de lectura, el segundo para preparar la entidad antes de persistir.
  - Añadir comentarios `// TODO:` donde el desarrollador debe ajustar la lógica específica.

- **Tokens que el script rellena:**
  - `__NAMESPACE__` → p.ej. `InfoportOneAdmon.Back.Services`.
  - `__ENTITY_NAME__` → `Organization`.
  - `__VIEW__` → `OrganizationView`.
  - `__BASE_SERVICE__` → p.ej. `BaseService<OrganizationView, Organization, OrganizationViewMetadata>`.
  - `__ENTITY_NAMESPACE__`, `__VIEWS_NAMESPACE__`, `__METADATA_NAMESPACE__`.
  - `__REPO_USING__`, `__REPO_FIELD__`, `__REPO_PARAM__`, `__REPO_ASSIGN__`, `__REPO_BASE__`.

- **Detección de entidades versionadas/vigencia:**
  - El helper extrae propiedades del POCO en `DataModel` y aplica reglas convenidas (VersionKey/VersionNumber/ValidityFrom/ValidityTo).
  - Si la detección es incorrecta ajusta manualmente el `base` en la clase generada.

- **Handler recomendado para el agente `/CreateService`:**
  - Validar parámetros entrantes (`entity`, `solutionPath`, flags).
  - Ejecutar `powershell -NoProfile -ExecutionPolicy Bypass -File "tools\Create-Service.ps1"` con parámetros mapeados.
  - Capturar `stdout`/`stderr` y analizar líneas útiles:
    - `[DryRun] Would write: <path>` → devolver al caller `{ status: "dryrun", path: "<path>", preview: <renderedContentOptional> }`.
    - `Wrote: <path>` / `Updated: <path>` → devolver `{ status: "ok", path: "<path>" }`.
    - Errores → devolver `{ status: "error", message: "..." }` con `stderr` completo.
  - Opcional: cuando `dryRun=false` devolver también el diff entre archivo anterior y generado.

- **Validación automática / pruebas posteriores a generar:**
  - Recomendado: ejecutar `dotnet build` del `*.Back.sln` para validar que el servicio compila.
  - Opcional: ejecutar tests de integración/compilation smoke (si existen) antes de commitear.

- **Precauciones:**
  - No modificar plantillas dentro de carpetas auto-generadas del Helix Generator (folder `Generator`), sólo en `tools/templates`.
  - Revisar los `using` importados en la clase generada—el script evita el `using ;` cuando no hay repo.

Ejemplo de flujo del agente (pseudocódigo):

1. Recibe: `{ command: "/CreateService", params: { entity: "Organization", withSkeletonOverrides: true, dryRun: true } }`.
2. Construye y ejecuta:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "tools\Create-Service.ps1" \
  -EntityName "Organization" -SolutionPath "C:\path\to\My.Back.sln" -WithSkeletonOverrides -DryRun
```

3. Parsea stdout; devuelve JSON al usuario con el `path` y, si `dryRun`, con el contenido renderizado (opcional).

¿Quieres que genere también el handler PowerShell que actúe como wrapper (ejecuta el script y devuelve JSON), y un pequeño test que haga `-DryRun` y verifique que el archivo a escribir coincide con la convención esperada?

Implementación recomendada del handler del agente:
- Validar parámetros, construir la línea de PowerShell, ejecutar el proceso, recopilar stdout/stderr y presentar salida limpia al usuario.
- Si `dryRun=true` devolver únicamente el path que se escribiría y el contenido renderizado opcionalmente.

¿Quieres que genere el handler PowerShell/C# del comando `/CreateService` (script que llame al `Create-Service.ps1` y devuelva JSON con el resultado)?
