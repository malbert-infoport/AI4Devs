<#
.SYNOPSIS
    Aplica correcciones de compatibilidad con .NET Standard 2.0 en clases de entidad.

.DESCRIPTION
    Script independiente para corregir clases de entidad del DataModel:
    - Comenta atributos [Index] (requieren EF Core 5+)
    - Comenta referencias a Microsoft.EntityFrameworkCore
    - Elimina nullable en propiedades string
    - Elimina nullable en propiedades Id

.PARAMETER DataModelPath
    Ruta al proyecto Back.DataModel o carpeta con las clases de entidad.

.PARAMETER Backup
    Si se especifica, crea una copia de seguridad de cada archivo antes de modificarlo.

.PARAMETER WhatIf
    Muestra qué cambios se realizarían sin ejecutarlos.

.EXAMPLE
    .\Fix-DataModelNetStandard.ps1 -DataModelPath "C:\Proyectos\InfoportOneAdmon.Back.DataModel"
    Aplica todas las correcciones en las clases del proyecto.

.EXAMPLE
    .\Fix-DataModelNetStandard.ps1 -DataModelPath ".\InfoportOneAdmon.Back.DataModel" -Backup
    Aplica correcciones y crea backups de los archivos originales.

.EXAMPLE
    .\Fix-DataModelNetStandard.ps1 -DataModelPath ".\InfoportOneAdmon.Back.DataModel" -WhatIf
    Muestra los cambios sin aplicarlos (modo simulación).

.NOTES
    Framework: Helix6 v1.0
    Autor: Helix6 Development Team
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory=$true)]
    [string]$DataModelPath,
    
    [Parameter(Mandatory=$false)]
    [switch]$Backup,
    
    [Parameter(Mandatory=$false)]
    [switch]$WhatIf
)

# Configuración de colores
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

function Test-DataModelPath {
    param([string]$Path)
    
    if (-not (Test-Path $Path)) {
        throw "La ruta especificada no existe: $Path"
    }
    
    # Verificar si es un proyecto o una carpeta
    $csprojFiles = Get-ChildItem -Path $Path -Filter "*.csproj"
    
    if ($csprojFiles.Count -eq 0) {
        # Es una carpeta, verificar que tenga archivos .cs
        $csFiles = Get-ChildItem -Path $Path -Filter "*.cs"
        if ($csFiles.Count -eq 0) {
            throw "No se encontraron archivos .cs en: $Path"
        }
        return $Path
    } else {
        # Es un proyecto, devolver el directorio
        return (Get-Item $Path).FullName
    }
}

function Get-EntityFiles {
    param([string]$Path)
    
    $files = Get-ChildItem -Path $Path -Filter "*.cs" -File | Where-Object {
        $_.Name -ne "AssemblyInfo.cs" -and
        $_.Name -notlike "*.Designer.cs"
    }
    
    return $files
}

function Backup-File {
    param([string]$FilePath)
    
    $backupPath = "$FilePath.backup"
    $counter = 1
    
    # Si ya existe un backup, añadir número
    while (Test-Path $backupPath) {
        $backupPath = "$FilePath.backup$counter"
        $counter++
    }
    
    Copy-Item -Path $FilePath -Destination $backupPath -Force
    return $backupPath
}

function Fix-IndexAttributes {
    param([string]$Content)
    
    $fixes = 0
    $lines = $Content -split "`r?`n"
    $newLines = @()
    
    foreach ($line in $lines) {
        if ($line -match '^\s*\[Index\(') {
            # Comentar la línea completa del atributo
            $newLines += $line -replace '^(\s*)(\[Index\()', '$1// $2'
            $fixes++
        } else {
            $newLines += $line
        }
    }
    
    return @{
        Content = ($newLines -join "`n")
        Fixes = $fixes
    }
}

function Fix-EntityFrameworkUsings {
    param([string]$Content)
    
    $fixes = 0
    $lines = $Content -split "`r?`n"
    $newLines = @()
    
    foreach ($line in $lines) {
        if ($line -match '^\s*using Microsoft\.EntityFrameworkCore' -and 
            $line -notmatch 'DataAnnotations') {
            # Comentar la línea de using
            $newLines += "// $line"
            $fixes++
        } else {
            $newLines += $line
        }
    }
    
    return @{
        Content = ($newLines -join "`n")
        Fixes = $fixes
    }
}

function Fix-StringNullables {
    param([string]$Content)
    
    $fixes = 0
    
    # Patrón: public string? PropertyName { get; set; }
    $pattern = '(public\s+string)\?\s+(\w+)\s*{\s*get;\s*set;\s*}'
    $replacement = '$1 $2 { get; set; } = string.Empty;'
    
    $newContent = $Content
    while ($newContent -match $pattern) {
        $newContent = $newContent -replace $pattern, $replacement
        $fixes++
    }
    
    return @{
        Content = $newContent
        Fixes = $fixes
    }
}

function Fix-IdNullables {
    param([string]$Content)
    
    $fixes = 0
    
    # Patrón: public int? Id { get; set; }
    $pattern = '(public\s+int)\?\s+(Id)\s*{\s*get;\s*set;\s*}'
    $replacement = '$1 $2 { get; set; }'
    
    $newContent = $Content
    while ($newContent -match $pattern) {
        $newContent = $newContent -replace $pattern, $replacement
        $fixes++
    }
    
    return @{
        Content = $newContent
        Fixes = $fixes
    }
}

function Fix-NavigationNullables {
    param([string]$Content)
    
    $fixes = 0
    
    # Patrón: public virtual Type? PropertyName { get; set; }
    # Esto es válido para navegaciones, pero corregir si es necesario
    $lines = $Content -split "`r?`n"
    $newLines = @()
    
    foreach ($line in $lines) {
        # Mantener nullable en navegaciones virtuales (es correcto)
        $newLines += $line
    }
    
    return @{
        Content = ($newLines -join "`n")
        Fixes = $fixes
    }
}

function Process-EntityFile {
    param(
        [string]$FilePath,
        [bool]$CreateBackup,
        [bool]$DryRun
    )
    
    $fileName = [System.IO.Path]::GetFileName($FilePath)
    Write-Host "`nProcesando: $fileName" -ForegroundColor $script:InfoColor
    
    try {
        $originalContent = Get-Content -Path $FilePath -Raw
        $content = $originalContent
        $totalFixes = 0
        
        # 1. Comentar atributos [Index]
        $result = Fix-IndexAttributes -Content $content
        $content = $result.Content
        if ($result.Fixes -gt 0) {
            Write-Host "  - Atributos [Index] comentados: $($result.Fixes)" -ForegroundColor Gray
            $totalFixes += $result.Fixes
        }
        
        # 2. Comentar usings de EntityFrameworkCore
        $result = Fix-EntityFrameworkUsings -Content $content
        $content = $result.Content
        if ($result.Fixes -gt 0) {
            Write-Host "  - Usings de EF Core comentados: $($result.Fixes)" -ForegroundColor Gray
            $totalFixes += $result.Fixes
        }
        
        # 3. Eliminar nullable en strings
        $result = Fix-StringNullables -Content $content
        $content = $result.Content
        if ($result.Fixes -gt 0) {
            Write-Host "  - Propiedades string corregidas: $($result.Fixes)" -ForegroundColor Gray
            $totalFixes += $result.Fixes
        }
        
        # 4. Eliminar nullable en Id
        $result = Fix-IdNullables -Content $content
        $content = $result.Content
        if ($result.Fixes -gt 0) {
            Write-Host "  - Propiedades Id corregidas: $($result.Fixes)" -ForegroundColor Gray
            $totalFixes += $result.Fixes
        }
        
        if ($totalFixes -eq 0) {
            Write-Host "  ℹ Sin cambios necesarios" -ForegroundColor DarkGray
            return @{
                FileName = $fileName
                Fixes = 0
                Changed = $false
            }
        }
        
        # Aplicar cambios si no es simulación
        if (-not $DryRun) {
            if ($CreateBackup) {
                $backupPath = Backup-File -FilePath $FilePath
                Write-Host "  - Backup creado: $([System.IO.Path]::GetFileName($backupPath))" -ForegroundColor DarkGray
            }
            
            Set-Content -Path $FilePath -Value $content -Encoding UTF8 -NoNewline
            Write-Success "  Total de correcciones aplicadas: $totalFixes"
        } else {
            Write-Host "  [SIMULACIÓN] Se aplicarían $totalFixes correcciones" -ForegroundColor $script:WarningColor
        }
        
        return @{
            FileName = $fileName
            Fixes = $totalFixes
            Changed = $true
        }
        
    } catch {
        Write-Error-Message "  Error al procesar archivo: $_"
        return @{
            FileName = $fileName
            Fixes = 0
            Changed = $false
            Error = $_
        }
    }
}

# ============================================
# MAIN EXECUTION
# ============================================

try {
    Write-Host "`n========================================" -ForegroundColor $script:InfoColor
    Write-Host "  FIX .NET STANDARD 2.0 COMPATIBILITY" -ForegroundColor $script:InfoColor
    Write-Host "========================================`n" -ForegroundColor $script:InfoColor
    
    if ($WhatIf) {
        Write-Warning-Message "MODO SIMULACIÓN - No se aplicarán cambios"
    }
    
    # 1. Validar ruta
    Write-Step "Validando ruta del DataModel..."
    $projectPath = Test-DataModelPath -Path $DataModelPath
    Write-Success "Ruta validada: $projectPath"
    
    # 2. Obtener archivos de entidad
    Write-Step "Buscando archivos de entidad..."
    $entityFiles = Get-EntityFiles -Path $projectPath
    
    if ($entityFiles.Count -eq 0) {
        Write-Warning-Message "No se encontraron archivos de entidad para procesar"
        exit 0
    }
    
    Write-Success "Archivos encontrados: $($entityFiles.Count)"
    
    # 3. Procesar cada archivo
    Write-Step "Aplicando correcciones..."
    
    $results = @()
    foreach ($file in $entityFiles) {
        $result = Process-EntityFile `
            -FilePath $file.FullName `
            -CreateBackup $Backup `
            -DryRun $WhatIf
        
        $results += $result
    }
    
    # 4. Resumen
    Write-Host "`n========================================" -ForegroundColor $script:InfoColor
    Write-Host "  RESUMEN DE CORRECCIONES" -ForegroundColor $script:InfoColor
    Write-Host "========================================" -ForegroundColor $script:InfoColor
    
    $totalFiles = $results.Count
    $changedFiles = ($results | Where-Object { $_.Changed }).Count
    $totalFixes = ($results | Measure-Object -Property Fixes -Sum).Sum
    $errorFiles = ($results | Where-Object { $_.Error }).Count
    
    Write-Host "`nArchivos procesados: $totalFiles" -ForegroundColor Gray
    Write-Host "Archivos modificados: $changedFiles" -ForegroundColor $script:SuccessColor
    Write-Host "Total de correcciones: $totalFixes" -ForegroundColor $script:SuccessColor
    
    if ($errorFiles -gt 0) {
        Write-Host "Archivos con errores: $errorFiles" -ForegroundColor $script:ErrorColor
    }
    
    if ($WhatIf) {
        Write-Host "`nEjecute sin -WhatIf para aplicar los cambios" -ForegroundColor $script:WarningColor
    }
    
    # 5. Mostrar tabla de resultados
    Write-Host "`nDetalle de archivos:" -ForegroundColor $script:InfoColor
    $results | Where-Object { $_.Changed } | ForEach-Object {
        Write-Host "  ✓ $($_.FileName) - $($_.Fixes) correcciones" -ForegroundColor $script:SuccessColor
    }
    
    Write-Host "`n========================================`n" -ForegroundColor $script:SuccessColor
    
    exit 0
    
} catch {
    Write-Host "`n========================================" -ForegroundColor $script:ErrorColor
    Write-Host "  ERROR EN EL PROCESO" -ForegroundColor $script:ErrorColor
    Write-Host "========================================" -ForegroundColor $script:ErrorColor
    Write-Error-Message $_.Exception.Message
    Write-Host "`nStack Trace:" -ForegroundColor Gray
    Write-Host $_.Exception.StackTrace -ForegroundColor Gray
    exit 1
}
