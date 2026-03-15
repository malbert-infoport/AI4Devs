# Scripts PowerShell - Helix6 Database Management

Esta carpeta contiene scripts de automatización para la gestión del DataModel y el despliegue de scripts SQL (DbUp) en proyectos Helix6.

## Scripts Disponibles

---

### 📦 Update-DataModel.ps1
Regenera el DataModel de Entity Framework desde la base de datos mediante scaffolding inverso (Database-First).

```powershell
# Uso básico
.\Update-DataModel.ps1

# Sin correcciones automáticas
.\Update-DataModel.ps1 -SkipFix
```

**Ver**: [Documentación completa del agente](../.github/agents/Helix6Back.Database.agent.md#funcionalidad-2-updatedatamodel)

---

### � Update-Views.ps1
Sincroniza las Views (DTOs) con los cambios detectados en el DataModel.

```powershell
# Actualizar Views (requiere confirmación)
.\Update-Views.ps1

# Forzar sobrescritura sin confirmación
.\Update-Views.ps1 -Force
```

---

### 🗂️ Update-HelixEntities.ps1
Sincroniza el archivo HelixEntities.xml con las entidades del DataModel.

```powershell
# Sincronizar XML
.\Update-HelixEntities.ps1
```

**Ver**: [Documentación completa del agente](../.github/agents/Helix6Back.HelixEntities.agent.md#funcionalidad-1-updatehelixentities)

---

### 📋 List-Configuration.ps1
Lista todas las configuraciones de carga definidas para una entidad específica.

```powershell
# Listar configuraciones de Organization
.\List-Configuration.ps1 -EntityName "Organization"
```

---

### 👁️ View-Configuration.ps1
Visualiza una configuración de carga específica con formato jerárquico y colores.

```powershell
# Ver configuración específica
.\View-Configuration.ps1 -EntityName "Organization" -ConfigurationName "OrganizationComplete"
```

---

### ➕ Create-Configuration.ps1
Crea una nueva configuración de carga de forma interactiva.

```powershell
# Crear configuración mostrando 3 niveles
.\Create-Configuration.ps1 -EntityName "Organization" -ConfigurationName "OrganizationFull" -Levels 3

# Crear con 2 niveles (por defecto)
.\Create-Configuration.ps1 -EntityName "Application" -ConfigurationName "ApplicationComplete"
```

---

### ✏️ Update-Configuration.ps1
Modifica una configuración de carga existente, mostrando valores actuales.

```powershell
# Actualizar configuración mostrando 3 niveles
.\Update-Configuration.ps1 -EntityName "Organization" -ConfigurationName "OrganizationComplete" -Levels 3
```

---

### 🗑️ Delete-Configuration.ps1
Elimina una configuración de carga específica del sistema.

```powershell
# Eliminar configuración
.\Delete-Configuration.ps1 -Entity Name "Organization" -ConfigurationName "OrganizationComplete"
```

---

### �🔧 Fix-DataModelNetStandard.ps1
Aplica correcciones de compatibilidad con .NET Standard 2.0 en clases de entidad.

```powershell
# Aplicar correcciones
.\Fix-DataModelNetStandard.ps1 -DataModelPath ".\InfoportOneAdmon.Back.DataModel"

# Modo simulación (no aplica cambios)
.\Fix-DataModelNetStandard.ps1 -DataModelPath ".\InfoportOneAdmon.Back.DataModel" -WhatIf

# Con backup de archivos
.\Fix-DataModelNetStandard.ps1 -DataModelPath ".\InfoportOneAdmon.Back.DataModel" -Backup
```

---

## Requisitos Previos

Antes de ejecutar estos scripts, asegúrate de tener:

- ✅ **PowerShell 5.1+** (Windows) o **PowerShell Core 7+** (multiplataforma)
- ✅ **.NET 8 SDK** instalado
- ✅ **Entity Framework Core Tools** instalados:
  ```powershell
  dotnet tool install --global dotnet-ef
  ```
- ✅ **Npgsql** provider instalado en el proyecto Data
- ✅ Acceso a la base de datos PostgreSQL

## DbUp — despliegue de scripts SQL

DbUp es el runner usado para aplicar los scripts SQL embebidos (`[Proyecto].Back.Data/Scripts`) durante el despliegue. En este repositorio el runner puede ejecutarse automáticamente al arrancar la API.

Ejemplos para ejecutar localmente (Windows PowerShell):

```powershell
# Permitir crear la base de datos si no existe (opcional y 'opt-in')
$env:HELIX6_ALLOW_CREATE_DB = 'true'
# Cambiar entorno si es necesario
$env:ASPNETCORE_ENVIRONMENT = 'Staging'
dotnet run --project "c:\Ai4Devs\AI4Devs\InfoportOneAdmon.Back\InfoportOneAdmon.Back.Api\InfoportOneAdmon.Back.Api.csproj"
```

Si prefieres ejecutar sólo las migraciones (modo CLI), revisa la implementación del runner o ejecuta el proyecto migrator si existe.

## Permisos de Ejecución

Si recibes un error de política de ejecución en PowerShell, ejecuta:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Flujos de Trabajo Comunes

### Escenario 1: Nueva base de datos desde scripts SQL
1. Crear scripts SQL en `[Proyecto].Back.Data/Scripts/`
2. Aplicar scripts SQL mediante el proceso de despliegue (DbUp)
3. ✅ Base de datos verificada con la estructura esperada

### Escenario 2: Sincronizar DataModel desde cambios en BD
1. Aplicar cambios DDL en PostgreSQL
2. Ejecutar `.\Update-DataModel.ps1`
3. Ejecutar `.\Update-Views.ps1 -Force`
4. Ejecutar `.\Update-HelixEntities.ps1` (opcional, si hay nuevas entidades)
5. ✅ Clases de entidad, Views y XML sincronizados

### Escenario 3: Crear configuración de carga personalizada
1. Ejecutar `.\List-Configuration.ps1 -EntityName "Organization"` (ver configuraciones existentes)
2. Ejecutar `.\Create-Configuration.ps1 -EntityName "Organization" -ConfigurationName "OrganizationFull" -Levels 3`
3. Seleccionar entidades relacionadas de forma interactiva (1.1 L, 1.2 E, 2.1 L)
4. ✅ Configuración creada y sincronizada en DataConsts.cs

### Escenario 4: Modificar configuración existente
1. Ejecutar `.\View-Configuration.ps1 -EntityName "Organization" -ConfigurationName "OrganizationComplete"` (ver estructura actual)
2. Ejecutar `.\Update-Configuration.ps1 -EntityName "Organization" -ConfigurationName "OrganizationComplete" -Levels 3`
3. Modificar selecciones (muestra valores actuales pre-rellenos)
4. ✅ Configuración actualizada

### Escenario 5: Eliminar configuración obsoleta
1. Ejecutar `.\Delete-Configuration.ps1 -EntityName "Organization" -ConfigurationName "OrganizationOld"`
2. Confirmar eliminación
3. ✅ Configuración eliminada del XML y DataConsts.cs

### Escenario 6: Corrección manual de entidades
1. Regenerar DataModel con `.\Update-DataModel.ps1 -SkipFix`
2. Ejecutar `.\Fix-DataModelNetStandard.ps1 -DataModelPath "..." -WhatIf` (previsualizar)
3. Ejecutar `.\Fix-DataModelNetStandard.ps1 -DataModelPath "..." -Backup` (aplicar con backup)
4. ✅ Entidades corregidas para .NET Standard 2.0

## Obtener Ayuda

Todos los scripts incluyen documentación integrada. Para ver ayuda detallada:

```powershell
# Scripts de sincronización
Get-Help .\Update-DataModel.ps1 -Full
Get-Help .\Update-Views.ps1 -Full
Get-Help .\Update-HelixEntities.ps1 -Full

# Scripts de configuración
Get-Help .\List-Configuration.ps1 -Full
Get-Help .\View-Configuration.ps1 -Full
Get-Help .\Create-Configuration.ps1 -Full
Get-Help .\Update-Configuration.ps1 -Full
Get-Help .\Delete-Configuration.ps1 -Full

# Scripts de corrección
Get-Help .\Fix-DataModelNetStandard.ps1 -Full
```

## Características Comunes

Todos los scripts incluyen:
- 🎨 Salida colorizada con indicadores de progreso
- ✅ Validación de prerequisitos
- 🔍 Detección automática de proyectos
- ⚠️ Manejo robusto de errores
- 📊 Resúmenes detallados de ejecución

## Solución de Problemas

### Error: "No se encontró el proyecto *.Back.Data.csproj"
- Asegúrate de ejecutar el script desde la raíz de la solución o especifica `-SolutionPath`

### Error: "No se pudo crear la migración"
- Verifica que el proyecto compila sin errores
- Comprueba que EF Core Tools está instalado: `dotnet ef --version`

### Error: "No se encontró la cadena de conexión"
- Verifica que existe `appsettings.Development.json` en el proyecto Api
- Comprueba que la clave `ConnectionStrings.DefaultConnection` está configurada

### Error de scaffolding: "Could not load file or assembly"
- Ejecuta `dotnet build` manualmente antes de ejecutar el script
- Verifica que el provider Npgsql está instalado

## Documentación Completa

Para documentación detallada de los agentes y los procesos, consulta:
- [Helix6Back.Database.agent.md](../.github/agents/Helix6Back.Database.agent.md)
- [Helix6Back.HelixEntities.agent.md](../.github/agents/Helix6Back.HelixEntities.agent.md)

---

**Framework**: Helix6 v2.0  
**Última actualización**: 20/02/2026
