
---
name: Helix6 Back Orchestrator
description: Orquestador que coordina agentes Helix6Back (HelixEntities, Views, Service, Controller, Database) para ejecutar flujos completos reproducibles.
version: 1.0
commands:
  - name: /RunFlow
	 description: Ejecuta un flujo orquestado entre los agentes Helix6Back para un requerimiento dado. Soporta dry-run y backup.
tags:
  - helix6
  - orchestrator
  - agents
argument-hint: "Descripción breve del requerimiento (p.ej. 'Crear Service + Endpoints para Organization con Insert/GetById (dry-run)')"
---

# AGENT: Orchestrator - Helix6 Back

## Rol
Coordina y secuencia la ejecución de los agentes especializados de Helix6Back para transformar un requerimiento en una serie de acciones reproducibles (actualizar HelixEntities.xml, generar Views, crear Services, añadir Endpoints y, opcionalmente, sincronizar DataModel).

## Agentes disponibles
- `Helix6Back.HelixEntities.agent.md`  — gestión de `HelixEntities.xml`
- `Helix6Back.Views.agent.md`         — generación/actualización de Views y Metadata
- `Helix6Back.Service.agent.md`       — generación de Services (`Create-Service.ps1`)
- `Helix6Back.Controller.agent.md`    — gestión de endpoints y sincronización de controladores (`Manage-Controller.ps1`)
- `Helix6Back.Database.agent.md`      — scaffolding inverso y sincronización del DataModel

## Flujo de trabajo (explícito)

1. Recibe requerimiento del usuario (alcance, entidad(s), métodos esperados, flags como `dry-run`, `backup`).
2. Invoca `HelixEntities` para: inventario de entidades y detectar si hay que crear/actualizar mapeos. Produce:
	[HELIXENTITIES OUTPUT]
3. Invoca `Views` pasando `[HELIXENTITIES OUTPUT]` como entrada: genera/actualiza Views y Metadata. Produce:
	[VIEWS OUTPUT]
4. Invoca `Service` pasando `[VIEWS OUTPUT]` como entrada: genera o actualiza servicios (`*.Back.Services`). Produce:
	[SERVICE OUTPUT]
5. Invoca `Controller` pasando `[SERVICE OUTPUT]` y `[HELIXENTITIES OUTPUT]`: actualiza `HelixEntities.xml` con endpoints y opcionalmente sincroniza los ficheros de endpoints. Produce:
	[CONTROLLER OUTPUT]
6. (Opcional) Invoca `Database` si el requerimiento implica cambios en BD o necesita scaffolding/sincronización. Produce:
	[DATABASE OUTPUT]
7. El Orchestrator valida resultados, ejecuta comprobaciones post-ejecución (`dry-run`, `dotnet build` si procede) y devuelve un resumen final:
	[ORCHESTRATOR SUMMARY]

Si algún agente devuelve errores o hallazgos relevantes (p.ej. fallos de compilación, cambios peligrosos en BD), el Orchestrator reencola el paso necesario (por ejemplo: volver a `Service` o `Views`) y marca los artefactos a revisar.

## Convención de intercambio de mensajes

Para forzar un paso de contexto claro entre agentes (y que Copilot Chat lo use correctamente), TODAS las salidas/intercambios deben seguir este formato (exacto):

- `[HELIXENTITIES OUTPUT]`\n<texto estructurado con cambios propuestos, comandos `tools/*.ps1` sugeridos y paths>\n
- `[VIEWS INPUT]`\n<entrada única que se pasará al agente Views>\n
- `[VIEWS OUTPUT]`\n<archivos a crear/actualizar, preview, `-DryRun` paths>\n
- `[SERVICE INPUT]`\n<entrada única para Service: entity, flags, templates>\n
- `[SERVICE OUTPUT]`\n<path(s) generados y comandos recomendados>\n
- `[CONTROLLER INPUT]`\n<endpoints a añadir/quitar, HelixEntities snippet>\n
- `[CONTROLLER OUTPUT]`\n<resultados, `HelixEntities.xml` path, preview>\n
- `[DATABASE INPUT]` / `[DATABASE OUTPUT]` para acciones sobre DataModel.

El Orchestrator añade siempre al final:

- `[ORCHESTRATOR SUMMARY]`\n<acciones realizadas, comandos exactos a ejecutar, riesgos, `next-steps`>

## Pasos completos para añadir un endpoint Helix6

Esta sección documenta la secuencia **canónica y completa** de pasos que se deben seguir para añadir un nuevo endpoint de Helix6 (p.ej. `GetAllKendoFilter`, `Insert`, `GetById`…). Muchos pasos pueden estar ya realizados; el orquestador **debe preguntar al usuario** qué pasos han sido completados antes de ejecutar ninguno.

### Protocolo de preguntas al usuario

Al recibir una solicitud de nuevo endpoint, hacer **siempre** estas preguntas antes de proceder:

```
1. ¿Se han ejecutado ya las migraciones de BD (DBUp)? [Sí / No / No aplica]
2. ¿El DataModel (.cs del proyecto *.DataModel) ya refleja las últimas tablas/vistas de BD? [Sí / No]
3. ¿Ya existe la View (fichero *View.cs en *.Entities/Views/) para la entidad? [Sí / No]
4. ¿Ya está la entidad registrada en HelixEntities.xml? [Sí / No]
5. ¿Ya existe el Repository e Interface para la entidad? [Sí / No]
6. ¿Ya existe el Service para la entidad? [Sí / No]
```

Con las respuestas, el orquestador **salta los pasos ya completados** y ejecuta solo los pendientes.

---

### Secuencia completa de pasos (orden obligatorio)

#### Paso 0 — Despliegue de migraciones de BD (DBUp)
**Cuándo**: Solo si hay nuevas tablas/vistas/cambios en BD que aún no se han desplegado.
**Cómo**: Ejecutar la aplicación con el runner de DBUp configurado, o aplicar los scripts `.sql` de la carpeta de migraciones directamente.
**Resultado esperado**: La BD contiene las tablas y vistas necesarias (p.ej. `"Admon"."VTA_Organization"`).
**Agente**: `Helix6Back.Database.agent.md`

> ⚠️ **Regla crítica**: Los scripts SQL deben usar `CREATE OR REPLACE VIEW` (nunca `DROP VIEW`). Los campos de auditoría de fecha (`AuditCreationDate`, `AuditModificationDate`) deben ser `TIMESTAMPTZ` **sin** `NOT NULL` ni `DEFAULT`. Las PKs deben ser `SERIAL` (nunca `BIGSERIAL`). Ver sección "Reglas Fundamentales" de `Helix6_Backend_Architecture.md`.

---

#### Paso 1 — Actualizar DataModel (scaffolding inverso desde BD)
**Cuándo**: Siempre que haya cambios en BD (tablas, vistas, columnas) que el DataModel no refleje aún.
**Comando**:
```powershell
.\tools\Update-DataModel.ps1 -Schemas "NombreSchema"
# Ejemplo: .\tools\Update-DataModel.ps1 -Schemas "Admon"
```
**Resultado esperado**: Los ficheros `.cs` del proyecto `*.DataModel` se regeneran con las entidades correspondientes a las tablas/vistas del schema indicado. Verificar que compila:
```powershell
dotnet build *.Back.DataModel --no-restore
```
**Agente**: `Helix6Back.Database.agent.md`

> ⚠️ Si el scaffolding genera `DateTime` (no-nullable) en campos de auditoría → la BD tiene `NOT NULL DEFAULT` en esos campos. Corregir el script SQL y repetir el scaffolding.

---

#### Paso 2 — Generar/actualizar Views
**Cuándo**: Siempre que el DataModel haya cambiado o la entidad no tenga View generada.
**Comando**:
```powershell
.\tools\Update-Views.ps1 -Force
# Para una entidad concreta (si el script lo soporta):
.\tools\Update-Views.ps1 -EntityName VTA_Organization -Force
```
**Resultado esperado**: Se crean/actualizan `*View.cs` y `*ViewMetadata.cs` en `*.Entities/Views/` y `*.Entities/Views/Metadata/`. El proyecto `*.Entities` compila sin errores.

> ⚠️ Si el script `Update-Views.ps1` excluye prefijos `VTA_` o `VT_`, revisar el filtro en la línea correspondiente del script y eliminarlo para que las vistas de BD también generen View.

**Agente**: `Helix6Back.Views.agent.md`

---

#### Paso 3 — Registrar entidades en HelixEntities.xml
**Cuándo**: Si la entidad no aparece aún en `HelixEntities.xml` del proyecto `*.Api`.
**Comando**:
```powershell
.\tools\Update-HelixEntities.ps1
```
**Resultado esperado**: La entidad (p.ej. `VTA_Organization`) aparece en `HelixEntities.xml` con todas sus propiedades listadas y los endpoints vacíos (se configurarán en el Paso 6).
**Agente**: `Helix6Back.HelixEntities.agent.md`

---

#### Paso 4 — Crear Repository e Interface
**Cuándo**: Si no existe `[Entidad]Repository.cs` ni `I[Entidad]Repository.cs`.
**Comando**:
```powershell
.\tools\Create-Repository.ps1 -EntityName NombreEntidad
# Ejemplo: .\tools\Create-Repository.ps1 -EntityName VTA_Organization
```
**Resultado esperado**:
- `*.Data/Repository/[Entidad]Repository.cs` — implementa `BaseRepository<[Entidad]>`
- `*.Data/Repository/Interfaces/I[Entidad]Repository.cs` — hereda `IBaseRepository<[Entidad]>`

**Agente**: `Helix6Back.Database.agent.md`

---

#### Paso 5 — Crear Service
**Cuándo**: Si no existe `[Entidad]Service.cs`.
**Comando**:
```powershell
.\tools\Create-Service.ps1 -EntityName NombreEntidad
# Ejemplo: .\tools\Create-Service.ps1 -EntityName VTA_Organization
```
**Resultado esperado**: `*.Services/[Entidad]Service.cs` que hereda de `BaseService<[Entidad]View, [Entidad], [Entidad]ViewMetadata>`.
**Agente**: `Helix6Back.Service.agent.md`

---

#### Paso 6 — Registrar endpoints en HelixEntities.xml
**Cuándo**: Siempre, para añadir o modificar los endpoints expuestos por la entidad.
**Comando**:
```powershell
.\tools\Manage-Controller.ps1 -EntityName NombreEntidad -Methods "Metodo1,Metodo2"
# Ejemplo: .\tools\Manage-Controller.ps1 -EntityName VTA_Organization -Methods "GetAllKendoFilter"
```
**Métodos disponibles**: `GetById`, `Insert`, `Update`, `DeleteById`, `DeleteUndeleteLogicById`, `GetByIds`, `InsertMany`, `UpdateMany`, `DeleteByIds`, `GetAll`, `GetAllKendoFilter`, `GetAllAttachments`, `GetNewAttachmentEntity`.
**Resultado esperado**: `HelixEntities.xml` añade `<Method>GetAllKendoFilter</Method>` (u otros) bajo la entidad indicada.

> ⚠️ **Patrón VTA_**: Si el endpoint `GetAllKendoFilter` debe filtrar por columnas calculadas (p.ej. `AppCount`, `ModuleCount`), registrar el endpoint sobre la entidad **vista** (`VTA_Organization`), no sobre la tabla base (`Organization`). La vista de BD expone esas columnas como columnas SQL reales, lo que permite el filtrado server-side de Kendo.

**Agente**: `Helix6Back.Controller.agent.md`

---

#### Paso 7 — Validar compilación
**Cuándo**: Siempre, como último paso de verificación.
**Comando**:
```powershell
dotnet build NombreSolucion.sln --no-restore
# Ejemplo: dotnet build InfoportOneAdmon.Back.sln --no-restore
```
**Resultado esperado**: `0 Errores`. Los warnings pre-existentes de versiones de paquetes (MSB3277) son aceptables si ya existían antes del cambio.

---

### Tabla resumen de pasos

| Paso | Acción | Herramienta | ¿Siempre obligatorio? |
|------|--------|-------------|----------------------|
| 0 | Despliegue de migraciones BD (DBUp) | Manual / DBUp | No — solo si hay cambios en BD |
| 1 | Actualizar DataModel (scaffolding) | `Update-DataModel.ps1` | No — solo si BD cambió |
| 2 | Generar/actualizar Views | `Update-Views.ps1` | No — solo si DataModel cambió o View no existe |
| 3 | Registrar entidad en HelixEntities.xml | `Update-HelixEntities.ps1` | No — solo si la entidad no está registrada |
| 4 | Crear Repository e Interface | `Create-Repository.ps1` | No — solo si no existen |
| 5 | Crear Service | `Create-Service.ps1` | No — solo si no existe |
| 6 | Registrar endpoints | `Manage-Controller.ps1` | **Sí** — siempre (es el objetivo final) |
| 7 | Validar compilación | `dotnet build` | **Sí** — siempre |

---

## Comandos / Handler recomendado

Comando principal: `/RunFlow` (soporta `dryRun`, `backup`, `solutionPath`, `entity`, `methods`).

Comportamiento:
- Si `dryRun=true` solo genera previews en `[XXX OUTPUT]` y NO escribe archivos.
- Si `backup=true` crea copias de seguridad antes de sobrescribir `HelixEntities.xml` o Services/Controllers.
- Permite modo no-interactivo (CI): pasar `entity` y `methods` (p.ej. `Insert,GetById`) y ejecutar la secuencia sin prompts.

Ejemplo de invocación (plantilla):

```
Command: /RunFlow
Params:
  entity: "Organization"
  methods: "Insert,GetById"
  dryRun: true
  backup: true
  solutionPath: "c:\\Ai4Devs\\AI4Devs\\InfoportOneAdmon.Back\\InfoportOneAdmon.Back.sln"
```

## Plantilla de prompt para uso con Copilot Chat

1) Abrir en el editor: `HElix6Back.Orchestrator.agent.md` y los agentes listados (`Helix6Back.*.agent.md`).
2) En Copilot Chat ejecutar:

"Actúa como Orchestrator y ejecuta el flujo completo para el siguiente requerimiento: <DESCRIPCIÓN>. Respeta la convención de secciones `[HELIXENTITIES OUTPUT]`, `[VIEWS INPUT]`, `[VIEWS OUTPUT]`, `[SERVICE INPUT]`, `[SERVICE OUTPUT]`, `[CONTROLLER INPUT]`, `[CONTROLLER OUTPUT]`, `[DATABASE INPUT]`, `[DATABASE OUTPUT]` y finaliza con `[ORCHESTRATOR SUMMARY]`. Usa `dry-run` por defecto salvo que el prompt indique lo contrario."

Ejemplo real (prompt de ejemplo):

"Orchestrator, ejecuta el flujo para: 'Generar Service `Organization` con métodos `Insert,GetById`, crear endpoints correspondientes y realizar dry-run. Usa backups.'"

Resultado esperado (ejemplo parcial):

[HELIXENTITIES OUTPUT]
Detectadas entidades: Organization (sin View). Proponer creación de OrganizationView. Recomiendo ejecutar `tools/Update-Views.ps1 -EntityName Organization -DryRun`.

[VIEWS INPUT]
EntityName=Organization; SolutionPath=...; DryRun=true

[VIEWS OUTPUT]
Would write: InfoportOneAdmon.Back.Entities/Views/OrganizationView.cs (preview attached)

[SERVICE INPUT]
Entity=Organization; WithSkeletonOverrides=true; DryRun=true

[SERVICE OUTPUT]
Would write: InfoportOneAdmon.Back.Services/OrganizationService.cs

[CONTROLLER INPUT]
Entity=Organization; Methods=Insert,GetById; DryRun=true

[CONTROLLER OUTPUT]
Would update: InfoportOneAdmon.Back.Api/HelixEntities.xml (preview)

[ORCHESTRATOR SUMMARY]
- Actions: Views(dry-run) → Service(dry-run) → Controller(dry-run)
- Commands: tools\Update-Views.ps1 -EntityName Organization -DryRun; tools\Create-Service.ps1 -EntityName Organization -DryRun; tools\Manage-Controller.ps1 -EntityName Organization -DryRun
- Next: run `dotnet build` on solution to validate.

## Comprobaciones post-ejecución recomendadas
- `dotnet build <solution>` (validación de compilación)
- Revisar previews y diffs antes de aplicar cambios
- Ejecutar `tools\Create-Service.ps1` con `-DryRun` y revisar salida

## Notas operativas
- Mantener `Database` como paso opcional y solo ejecutarlo con confirmación explícita (riesgo sobre estructuras de BD).
- Siempre crear backups automáticos de `HelixEntities.xml` antes de escribir.
- El orquestador no ejecuta commits automáticamente; se sugiere que el desarrollador revise y confirme cambios antes de commitear.

---

`Mantenedor`: Equipo Helix6 / AI4Devs

## Notas sobre cambios en BD

Las convenciones relativas a vistas y despliegues de base de datos están gestionadas por el agente de Base de Datos (`Helix6Back.Database.agent.md`). Consulta ese agente para las reglas obligatorias sobre prefijos de vistas y despliegue con DBUp.

