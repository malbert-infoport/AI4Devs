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

### 🔧 Fix-DataModelNetStandard.ps1
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
3. ✅ Clases de entidad regeneradas y compiladas

### Escenario 3: Corrección manual de entidades
1. Regenerar DataModel con `.\Update-DataModel.ps1 -SkipFix`
2. Ejecutar `.\Fix-DataModelNetStandard.ps1 -DataModelPath "..." -WhatIf` (previsualizar)
3. Ejecutar `.\Fix-DataModelNetStandard.ps1 -DataModelPath "..." -Backup` (aplicar con backup)

## Obtener Ayuda

Todos los scripts incluyen documentación integrada. Para ver ayuda detallada:

```powershell
Get-Help .\Update-DataModel.ps1 -Full
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

Para documentación detallada del agente y los procesos, consulta:
- [Helix6Back.Database.agent.md](../.github/agents/Helix6Back.Database.agent.md)

---

**Framework**: Helix6 v1.0  
**Última actualización**: 17/02/2026
