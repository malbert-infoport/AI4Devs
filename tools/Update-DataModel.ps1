<#
.SYNOPSIS
    Actualiza el DataModel de Entity Framework desde la base de datos mediante scaffolding.

.DESCRIPTION
    Script para proyectos Helix6 que:
    1. Localiza proyectos Back.Data y Back.DataModel
    2. Ejecuta scaffolding inverso desde PostgreSQL
    3. Mueve clases de entidad a Back.DataModel
    4. Aplica correcciones para .NET Standard 2.0

.PARAMETER SolutionPath
    Ruta al archivo .sln del proyecto backend. Si no se especifica, busca en el directorio actual.

.PARAMETER ProjectName
    Nombre del proyecto (ej: InfoportOneAdmon). Si no se especifica, se intenta detectar automáticamente.

.PARAMETER SkipFix
    Si se especifica, no aplica correcciones automáticas para .NET Standard 2.0.

.PARAMETER ConnectionString
    Cadena de conexión personalizada. Si no se especifica, se lee de appsettings.Development.json.

.EXAMPLE
    .\Update-DataModel.ps1
    Ejecuta el proceso completo con detección automática del proyecto.

.EXAMPLE
    .\Update-DataModel.ps1 -ProjectName "InfoportOneAdmon" -SkipFix
    Ejecuta sin aplicar correcciones automáticas.

.NOTES
    Requiere: .NET CLI, EF Core Tools, Npgsql.EntityFrameworkCore.PostgreSQL
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
    [switch]$SkipFix,
    
    [Parameter(Mandatory=$false)]
    [string]$ConnectionString
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

function Find-DataModelProject {
    param([string]$SolutionDir, [string]$ProjectName)
    
    Write-Step "Localizando proyecto Back.DataModel..."
    
    $dataModelProjects = Get-ChildItem -Path $SolutionDir -Filter "$ProjectName.Back.DataModel.csproj" -Recurse
    
    if ($dataModelProjects.Count -eq 0) {
        throw "No se encontró el proyecto $ProjectName.Back.DataModel.csproj"
    }
    
    $dataModelProject = $dataModelProjects[0].FullName
    
    Write-Success "Proyecto DataModel: $ProjectName.Back.DataModel"
    Write-Host "  Ruta: $dataModelProject" -ForegroundColor Gray
    
    return @{
        ProjectPath = $dataModelProject
        ProjectDir = [System.IO.Path]::GetDirectoryName($dataModelProject)
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

function Get-ConnectionString {
    param([string]$ApiProjectPath)
    
    if ($ConnectionString) {
        Write-Step "Usando cadena de conexión proporcionada"
        $maskedConnection = $ConnectionString -replace '(Password=)[^;]+', '$1***'
        Write-Host "  $maskedConnection" -ForegroundColor Gray
        return $ConnectionString
    }
    
    Write-Step "Obteniendo cadena de conexión..."
    
    $apiProjectDir = [System.IO.Path]::GetDirectoryName($ApiProjectPath)
    $appSettingsPath = Join-Path $apiProjectDir "appsettings.Development.json"
    
    if (-not (Test-Path $appSettingsPath)) {
        throw "No se encontró appsettings.Development.json"
    }
    
    $appSettings = Get-Content $appSettingsPath -Raw | ConvertFrom-Json
    $connString = $appSettings.ConnectionStrings.DefaultConnection
    
    if (-not $connString) {
        throw "No se encontró la cadena de conexión 'DefaultConnection'"
    }
    
    Write-Host "`nCadena de conexión:" -ForegroundColor $script:InfoColor
    $maskedConnection = $connString -replace '(Password=)[^;]+', '$1***'
    Write-Host "  $maskedConnection" -ForegroundColor Gray
    
    return $connString
}

function Execute-Scaffolding {
    param(
        [string]$ConnectionString,
        [string]$DataProject,
        [string]$ProjectName
    )
    
    Write-Step "Ejecutando scaffolding de Entity Framework..."
    Write-Warning-Message "Este proceso puede tardar varios minutos..."
    
    try {
        $command = "dotnet ef dbcontext scaffold " +
                   "--namespace `"$ProjectName.Back.DataModel`" " +
                   "--no-pluralize " +
                   "`"$ConnectionString`" " +
                   "Npgsql.EntityFrameworkCore.PostgreSQL " +
                   "--output-dir `"DataModel`" " +
                   "--context EntityModel " +
                   "--force " +
                   "--use-database-names " +
                   "--verbose " +
                   "--data-annotations " +
                   "--no-onconfiguring " +
                   "--no-build " +
                   "--schema-exclude `"Helix6_Internal`" " +
                   "--schema-exclude `"Helix6_Security`" " +
                   "--project `"$DataProject`""
        
        Write-Host "`nEjecutando comando:" -ForegroundColor Gray
        Write-Host $command -ForegroundColor DarkGray
        
        $output = Invoke-Expression $command 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host $output -ForegroundColor Red
            throw "Error al ejecutar scaffolding"
        }
        
        Write-Success "Scaffolding completado exitosamente"
        return $true
        
    } catch {
        Write-Error-Message "Error al ejecutar scaffolding: $_"
        return $false
    }
}

function Move-EntityClasses {
    param(
        [string]$DataProjectDir,
        [string]$DataModelProjectDir
    )
    
    Write-Step "Moviendo clases de entidad a Back.DataModel..."
    
    $sourceDir = Join-Path $DataProjectDir "DataModel"
    
    if (-not (Test-Path $sourceDir)) {
        throw "No se encontró la carpeta DataModel en el proyecto Data"
    }
    
    # Obtener todos los archivos excepto EntityModel.cs y la carpeta Base
    $filesToMove = Get-ChildItem -Path $sourceDir -Filter "*.cs" | Where-Object {
        $_.Name -ne "EntityModel.cs" -and $_.DirectoryName -notlike "*\Base"
    }
    
    if ($filesToMove.Count -eq 0) {
        Write-Warning-Message "No se encontraron archivos para mover"
        return 0
    }
    
    Write-Host "`nArchivos a mover: $($filesToMove.Count)" -ForegroundColor $script:InfoColor
    
    $movedCount = 0
    foreach ($file in $filesToMove) {
        try {
            $destPath = Join-Path $DataModelProjectDir $file.Name
            
            # Si el archivo ya existe, hacer backup
            if (Test-Path $destPath) {
                $backupPath = "$destPath.backup"
                Move-Item -Path $destPath -Destination $backupPath -Force
            }
            
            Move-Item -Path $file.FullName -Destination $destPath -Force
            Write-Host "  ✓ $($file.Name)" -ForegroundColor $script:SuccessColor
            $movedCount++
            
        } catch {
            Write-Error-Message "Error al mover $($file.Name): $_"
        }
    }
    
    Write-Success "Archivos movidos: $movedCount"
    return $movedCount
}

function Fix-NetStandardCompatibility {
    param([string]$DataModelProjectDir)
    
    Write-Step "Aplicando correcciones para .NET Standard 2.0..."
    
    $entityFiles = Get-ChildItem -Path $DataModelProjectDir -Filter "*.cs" | Where-Object {
        $_.Name -ne "AssemblyInfo.cs"
    }
    
    if ($entityFiles.Count -eq 0) {
        Write-Warning-Message "No se encontraron archivos para corregir"
        return
    }
    
    Write-Host "`nArchivos a procesar: $($entityFiles.Count)" -ForegroundColor $script:InfoColor
    
    $fixedCount = 0
    $totalFixes = 0
    
    foreach ($file in $entityFiles) {
        try {
            $content = Get-Content -Path $file.FullName -Raw
            $originalContent = $content
            $fileFixes = 0
            
            # 1. Comentar atributos [Index]
            if ($content -match '\[Index\(') {
                $content = $content -replace '(\s*)(\[Index\([^\]]+\]\])', '$1// $2'
                $fileFixes++
            }
            
            # 2. Eliminar usar de Entity Framework (excepto DataAnnotations)
            $lines = $content -split "`r?`n"
            $newLines = @()
            foreach ($line in $lines) {
                if ($line -match 'using Microsoft\.EntityFrameworkCore' -and 
                    $line -notmatch 'DataAnnotations') {
                    $newLines += "// $line"
                    $fileFixes++
                } else {
                    $newLines += $line
                }
            }
            $content = $newLines -join "`n"
            
            # 3. Eliminar nullable en strings
            $stringNullablePattern = 'public\s+string\?\s+(\w+)\s*{\s*get;\s*set;\s*}'
            if ($content -match $stringNullablePattern) {
                $content = $content -replace $stringNullablePattern, 'public string $1 { get; set; } = string.Empty;'
                $fileFixes++
            }
            
            # 4. Eliminar nullable en propiedades Id
            $idNullablePattern = 'public\s+int\?\s+Id\s*{\s*get;\s*set;\s*}'
            if ($content -match $idNullablePattern) {
                $content = $content -replace $idNullablePattern, 'public int Id { get; set; }'
                $fileFixes++
            }
            
            # Solo guardar si hubo cambios
            if ($content -ne $originalContent) {
                Set-Content -Path $file.FullName -Value $content -Encoding UTF8
                Write-Host "  ✓ $($file.Name) - $fileFixes correcciones" -ForegroundColor $script:SuccessColor
                $fixedCount++
                $totalFixes += $fileFixes
            } else {
                Write-Host "  - $($file.Name) - sin cambios" -ForegroundColor Gray
            }
            
        } catch {
            Write-Error-Message "Error al procesar $($file.Name): $_"
        }
    }
    
    Write-Success "Archivos corregidos: $fixedCount (Total de correcciones: $totalFixes)"
}

function Build-DataModelProject {
    param([string]$DataModelProject)
    
    Write-Step "Compilando proyecto Back.DataModel..."
    
    try {
        $command = "dotnet build `"$DataModelProject`" --no-restore"
        Write-Host "Ejecutando: $command" -ForegroundColor Gray
        
        $output = Invoke-Expression $command 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error-Message "Error en la compilación:"
            Write-Host $output -ForegroundColor Red
            return $false
        }
        
        Write-Success "Proyecto compilado exitosamente"
        return $true
        
    } catch {
        Write-Error-Message "Error al compilar: $_"
        return $false
    }
}

# ============================================
# MAIN EXECUTION
# ============================================

try {
    Write-Host "`n========================================" -ForegroundColor $script:InfoColor
    Write-Host "  UPDATE DATAMODEL - Helix6 Framework" -ForegroundColor $script:InfoColor
    Write-Host "========================================`n" -ForegroundColor $script:InfoColor
    
    # 1. Encontrar solución
    $solutionPath = Find-Solution
    $solutionDir = [System.IO.Path]::GetDirectoryName($solutionPath)
    
    # 2. Encontrar proyecto Data
    $dataInfo = Find-DataProject -SolutionDir $solutionDir
    
    if (-not $ProjectName) {
        $ProjectName = $dataInfo.ProjectName
    }
    
    # 3. Encontrar proyecto DataModel
    $dataModelInfo = Find-DataModelProject -SolutionDir $solutionDir -ProjectName $ProjectName
    
    # 4. Encontrar proyecto Api
    $apiProject = Find-ApiProject -SolutionDir $solutionDir -ProjectName $ProjectName
    Write-Host "Proyecto Api: $([System.IO.Path]::GetFileName($apiProject))" -ForegroundColor Gray
    
    # 5. Obtener cadena de conexión
    $connString = Get-ConnectionString -ApiProjectPath $apiProject
    
    # 6. Ejecutar scaffolding
    $scaffoldSuccess = Execute-Scaffolding `
        -ConnectionString $connString `
        -DataProject $dataInfo.ProjectPath `
        -ProjectName $ProjectName
    
    if (-not $scaffoldSuccess) {
        throw "El scaffolding falló"
    }
    
    # 7. Mover clases de entidad
    $movedCount = Move-EntityClasses `
        -DataProjectDir $dataInfo.ProjectDir `
        -DataModelProjectDir $dataModelInfo.ProjectDir
    
    if ($movedCount -eq 0) {
        Write-Warning-Message "No se movieron archivos. Verifique el proceso de scaffolding."
    }
    
    # 8. Aplicar correcciones para .NET Standard 2.0
    if (-not $SkipFix) {
        Fix-NetStandardCompatibility -DataModelProjectDir $dataModelInfo.ProjectDir
    } else {
        Write-Warning-Message "Correcciones automáticas omitidas (--SkipFix)"
    }
    
    # 9. Compilar proyecto DataModel
    $buildSuccess = Build-DataModelProject -DataModelProject $dataModelInfo.ProjectPath
    
    if ($buildSuccess) {
        Write-Host "`n========================================" -ForegroundColor $script:SuccessColor
        Write-Host "  PROCESO COMPLETADO EXITOSAMENTE" -ForegroundColor $script:SuccessColor
        Write-Host "========================================`n" -ForegroundColor $script:SuccessColor
        
        Write-Host "Siguiente paso recomendado:" -ForegroundColor $script:InfoColor
        Write-Host "  Ejecutar Helix Generator para regenerar Views y Endpoints" -ForegroundColor Gray
        
        exit 0
    } else {
        Write-Warning-Message "El proceso se completó pero hubo errores de compilación"
        Write-Warning-Message "Revise manualmente los archivos en Back.DataModel"
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
