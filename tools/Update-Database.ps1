<#
.SYNOPSIS
    Automatiza la actualización de la base de datos aplicando migraciones de Entity Framework.

.DESCRIPTION
    Script para proyectos Helix6 que:
    1. Localiza el proyecto Back.Data
    2. Inventaría migraciones existentes y scripts SQL
    3. Genera migraciones faltantes con scripts SQL embebidos
    4. Aplica todas las migraciones a la base de datos

.PARAMETER SolutionPath
    Ruta al archivo .sln del proyecto backend. Si no se especifica, busca en el directorio actual.

.PARAMETER ProjectName
    Nombre del proyecto (ej: InfoportOneAdmon). Si no se especifica, se intenta detectar automáticamente.

.PARAMETER SkipConfirmation
    Si se especifica, no solicita confirmación antes de crear migraciones.

.EXAMPLE
    .\Update-Database.ps1
    Ejecuta el proceso completo con detección automática del proyecto.

.EXAMPLE
    .\Update-Database.ps1 -ProjectName "InfoportOneAdmon" -SkipConfirmation
    Ejecuta sin confirmaciones para el proyecto InfoportOneAdmon.

.NOTES
    Requiere: .NET CLI, EF Core Tools
    Framework: Helix6 v1.0
    Autor: Helix6 Development Team
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$SolutionPath,
    
    [Parameter(Mandatory=$false)]
    [string]$ProjectName,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipConfirmation
)

# Configuración de colores para salida
$script:ErrorColor = "Red"
$script:SuccessColor = "Green"
$script:InfoColor = "Cyan"
$script:WarningColor = "Yellow"

function Write-Step {
    param([string]$Message)
    Write-Host "`n$Message" -ForegroundColor $script:InfoColor
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor $script:SuccessColor
}

function Write-Error-Message {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor $script:ErrorColor
}

function Write-Warning-Message {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor $script:WarningColor
}

function Find-Solution {
    Write-Step "Buscando archivo de solución..."
    
    if ($SolutionPath -and (Test-Path $SolutionPath)) {
        Write-Success "Solución encontrada: $SolutionPath"
        return $SolutionPath
    }
    
    $solutions = Get-ChildItem -Path . -Filter "*.sln" -Recurse -Depth 2 | Where-Object { $_.Name -like "*Back.sln" }
    
    if ($solutions.Count -eq 0) {
        throw "No se encontró ningún archivo .sln en el directorio actual"
    }
    
    if ($solutions.Count -gt 1) {
        Write-Warning-Message "Se encontraron múltiples soluciones:"
        $solutions | ForEach-Object { Write-Host "  - $($_.FullName)" }
        $solutionPath = $solutions[0].FullName
        Write-Warning-Message "Usando: $solutionPath"
    } else {
        $solutionPath = $solutions[0].FullName
        Write-Success "Solución encontrada: $solutionPath"
    }
    
    return $solutionPath
}

function Find-DataProject {
    param([string]$SolutionDir)
    
    Write-Step "Localizando proyecto Back.Data..."
    
    $dataProjects = Get-ChildItem -Path $SolutionDir -Filter "*.Back.Data.csproj" -Recurse
    
    if ($dataProjects.Count -eq 0) {
        throw "No se encontró el proyecto *.Back.Data.csproj"
    }
    
    $dataProject = $dataProjects[0].FullName
    $projectName = [System.IO.Path]::GetFileNameWithoutExtension($dataProject) -replace '\.Back\.Data$', ''
    
    Write-Success "Proyecto Data: $projectName.Back.Data"
    Write-Host "  Ruta: $dataProject" -ForegroundColor Gray
    
    return @{
        ProjectPath = $dataProject
        ProjectName = $projectName
        ProjectDir = [System.IO.Path]::GetDirectoryName($dataProject)
    }
}

function Find-ApiProject {
    param([string]$SolutionDir, [string]$ProjectName)
    
    $apiProject = Get-ChildItem -Path $SolutionDir -Filter "$ProjectName.Back.Api.csproj" -Recurse
    
    if ($apiProject.Count -eq 0) {
        throw "No se encontró el proyecto $ProjectName.Back.Api.csproj"
    }
    
    return $apiProject[0].FullName
}

function Get-ExistingMigrations {
    param([string]$DataProjectDir)
    
    Write-Step "Inventariando migraciones existentes..."
    
    $migrationsDir = Join-Path $DataProjectDir "Migrations"
    
    if (-not (Test-Path $migrationsDir)) {
        Write-Warning-Message "No se encontró la carpeta Migrations"
        return @()
    }
    
    $migrationFiles = Get-ChildItem -Path $migrationsDir -Filter "*.cs" | Where-Object { 
        $_.Name -notlike "*.Designer.cs" -and $_.Name -ne "EntityModelSnapshot.cs"
    }
    
    $migrations = $migrationFiles | ForEach-Object {
        $_.BaseName
    }
    
    Write-Host "`nMigraciones encontradas: $($migrations.Count)" -ForegroundColor $script:SuccessColor
    $migrations | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
    
    return $migrations
}

function Get-SqlScripts {
    param([string]$DataProjectDir)
    
    Write-Step "Inventariando scripts SQL..."
    
    $scriptsDir = Join-Path $DataProjectDir "Scripts"
    
    if (-not (Test-Path $scriptsDir)) {
        Write-Warning-Message "No se encontró la carpeta Scripts"
        return @()
    }
    
    $scriptFiles = Get-ChildItem -Path $scriptsDir -Filter "*.sql"
    
    $scripts = $scriptFiles | ForEach-Object {
        $_.BaseName
    }
    
    Write-Host "`nScripts SQL encontrados: $($scripts.Count)" -ForegroundColor $script:SuccessColor
    $scripts | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
    
    return $scripts
}

function Find-MissingMigrations {
    param([array]$Migrations, [array]$Scripts)
    
    Write-Step "Validando correspondencia Script-Migración..."
    
    $missing = @()
    
    foreach ($script in $Scripts) {
        $found = $false
        foreach ($migration in $Migrations) {
            if ($migration -like "*_$script") {
                $found = $true
                break
            }
        }
        
        if (-not $found) {
            $missing += $script
        }
    }
    
    if ($missing.Count -eq 0) {
        Write-Success "Todas las migraciones están creadas"
    } else {
        Write-Warning-Message "Faltan $($missing.Count) migraciones:"
        $missing | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
    }
    
    return $missing
}

function Create-Migration {
    param(
        [string]$ScriptName,
        [string]$DataProject,
        [string]$ApiProject,
        [string]$ProjectName,
        [string]$DataProjectDir
    )
    
    $migrationName = "Migration_$ScriptName"
    
    Write-Step "Creando migración: $migrationName"
    
    if (-not $SkipConfirmation) {
        $confirm = Read-Host "¿Desea crear la migración '$migrationName'? (S/N)"
        if ($confirm -ne 'S' -and $confirm -ne 's') {
            Write-Warning-Message "Migración omitida por el usuario"
            return $false
        }
    }
    
    try {
        $command = "dotnet ef migrations add $migrationName --project `"$DataProject`" --startup-project `"$ApiProject`""
        Write-Host "Ejecutando: $command" -ForegroundColor Gray
        
        Invoke-Expression $command
        
        if ($LASTEXITCODE -ne 0) {
            throw "Error al crear la migración"
        }
        
        Write-Success "Migración creada exitosamente"
        
        # Esperar a que el archivo se cree
        Start-Sleep -Seconds 2
        
        # Reemplazar contenido de la migración
        Replace-MigrationContent -MigrationName $migrationName -ScriptName $ScriptName -ProjectName $ProjectName -DataProjectDir $DataProjectDir
        
        return $true
        
    } catch {
        Write-Error-Message "Error al crear migración: $_"
        return $false
    }
}

function Replace-MigrationContent {
    param(
        [string]$MigrationName,
        [string]$ScriptName,
        [string]$ProjectName,
        [string]$DataProjectDir
    )
    
    Write-Step "Reemplazando contenido de la migración..."
    
    $migrationsDir = Join-Path $DataProjectDir "Migrations"
    
    # Buscar el archivo que CONTIENE el nombre de la migración (incluye timestamp)
    $migrationFile = Get-ChildItem -Path $migrationsDir -Filter "*$MigrationName.cs" | Where-Object { 
        $_.Name -notlike "*.Designer.cs" -and $_.Name -like "*_$MigrationName.cs"
    }
    
    if (-not $migrationFile) {
        throw "No se encontró el archivo de migración que contenga: $MigrationName.cs"
    }
    
    Write-Host "  Archivo encontrado: $($migrationFile.Name)" -ForegroundColor Gray
    
    $namespace = "$ProjectName.Back.Data.Migrations"
    $assemblyType = "$ProjectName.Back.Data.DataModel.EntityModel"
    $resourceName = "$ProjectName.Back.Data.Scripts.$ScriptName.sql"
    
    $content = @"
using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace $namespace
{
    /// <inheritdoc />
    public partial class $MigrationName : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            var assembly = typeof($assemblyType).Assembly;
            using var stream = assembly.GetManifestResourceStream("$resourceName");
            using var reader = new System.IO.StreamReader(stream!);
            var sql = reader.ReadToEnd();
            migrationBuilder.Sql(sql, suppressTransaction: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
        }
    }
}
"@
    
    Set-Content -Path $migrationFile.FullName -Value $content -Encoding UTF8
    
    Write-Success "Contenido de la migración actualizado"
}

function Get-ConnectionString {
    param([string]$ApiProjectPath)
    
    Write-Step "Obteniendo cadena de conexión..."
    
    $apiProjectDir = [System.IO.Path]::GetDirectoryName($ApiProjectPath)
    $appSettingsPath = Join-Path $apiProjectDir "appsettings.Development.json"
    
    if (-not (Test-Path $appSettingsPath)) {
        throw "No se encontró appsettings.Development.json"
    }
    
    $appSettings = Get-Content $appSettingsPath -Raw | ConvertFrom-Json
    $connectionString = $appSettings.ConnectionStrings.DefaultConnection
    
    if (-not $connectionString) {
        throw "No se encontró la cadena de conexión 'DefaultConnection'"
    }
    
    Write-Host "`nCadena de conexión:" -ForegroundColor $script:InfoColor
    # Ocultar password por seguridad
    $maskedConnection = $connectionString -replace '(Password=)[^;]+', '$1***'
    Write-Host "  $maskedConnection" -ForegroundColor Gray
    
    return $connectionString
}

function Update-Database {
    param(
        [string]$DataProject,
        [string]$ApiProject
    )
    
    Write-Step "Aplicando migraciones a la base de datos..."
    
    try {
        $command = "dotnet ef database update --project `"$DataProject`" --startup-project `"$ApiProject`" --verbose"
        Write-Host "Ejecutando: $command" -ForegroundColor Gray
        
        Invoke-Expression $command
        
        if ($LASTEXITCODE -ne 0) {
            throw "Error al aplicar migraciones"
        }
        
        Write-Success "Base de datos actualizada exitosamente"
        return $true
        
    } catch {
        Write-Error-Message "Error al actualizar base de datos: $_"
        return $false
    }
}

# ============================================
# MAIN EXECUTION
# ============================================

try {
    Write-Host "`n========================================" -ForegroundColor $script:InfoColor
    Write-Host "  UPDATE DATABASE - Helix6 Framework" -ForegroundColor $script:InfoColor
    Write-Host "========================================`n" -ForegroundColor $script:InfoColor
    
    # 1. Encontrar solución
    $solutionPath = Find-Solution
    $solutionDir = [System.IO.Path]::GetDirectoryName($solutionPath)
    
    # 2. Encontrar proyecto Data
    $dataInfo = Find-DataProject -SolutionDir $solutionDir
    
    if (-not $ProjectName) {
        $ProjectName = $dataInfo.ProjectName
    }
    
    # 3. Encontrar proyecto Api
    $apiProject = Find-ApiProject -SolutionDir $solutionDir -ProjectName $ProjectName
    Write-Host "Proyecto Api: $([System.IO.Path]::GetFileName($apiProject))" -ForegroundColor Gray
    
    # 4. Inventariar migraciones
    $migrations = Get-ExistingMigrations -DataProjectDir $dataInfo.ProjectDir
    
    # 5. Inventariar scripts
    $scripts = Get-SqlScripts -DataProjectDir $dataInfo.ProjectDir
    
    if ($scripts.Count -eq 0) {
        Write-Warning-Message "No se encontraron scripts SQL. No hay nada que procesar."
        exit 0
    }
    
    # 6. Encontrar migraciones faltantes
    $missingMigrations = Find-MissingMigrations -Migrations $migrations -Scripts $scripts
    
    # 7. Crear migraciones faltantes
    if ($missingMigrations.Count -gt 0) {
        Write-Step "Generando migraciones faltantes..."
        
        foreach ($script in $missingMigrations) {
            $success = Create-Migration `
                -ScriptName $script `
                -DataProject $dataInfo.ProjectPath `
                -ApiProject $apiProject `
                -ProjectName $ProjectName `
                -DataProjectDir $dataInfo.ProjectDir
            
            if (-not $success) {
                throw "No se pudo crear la migración para: $script"
            }
        }
    }
    
    # 8. Obtener cadena de conexión
    $connectionString = Get-ConnectionString -ApiProjectPath $apiProject
    
    # 9. Aplicar migraciones
    $updateSuccess = Update-Database -DataProject $dataInfo.ProjectPath -ApiProject $apiProject
    
    if ($updateSuccess) {
        Write-Host "`n========================================" -ForegroundColor $script:SuccessColor
        Write-Host "  PROCESO COMPLETADO EXITOSAMENTE" -ForegroundColor $script:SuccessColor
        Write-Host "========================================`n" -ForegroundColor $script:SuccessColor
        exit 0
    } else {
        exit 1
    }
    
} catch {
    Write-Host "`n========================================" -ForegroundColor $script:ErrorColor
    Write-Host "  ERROR EN EL PROCESO" -ForegroundColor $script:ErrorColor
    Write-Host "========================================" -ForegroundColor $script:ErrorColor
    Write-Error-Message $_.Exception.Message
    Write-Host "`nStack Trace:" -ForegroundColor Gray
    Write-Host $_.Exception.StackTrace -ForegroundColor Gray
    exit 1
}
