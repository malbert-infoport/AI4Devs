<#
.SYNOPSIS
    Visualiza una configuración de carga específica con formato jerárquico y colores.

.DESCRIPTION
    Este script muestra la estructura completa de una configuración de carga específica,
    con códigos de colores para lectura (rojo) y escritura (verde), y numeración jerárquica.

.PARAMETER EntityName
    Nombre de la entidad del DataModel (ej: Organization, Application).

.PARAMETER ConfigurationName
    Nombre de la configuración a visualizar (ej: OrganizationComplete).

.EXAMPLE
    .\View-Configuration.ps1 -EntityName "Organization" -ConfigurationName "OrganizationComplete"
    Muestra la configuración OrganizationComplete con estructura jerárquica.

.NOTES
    Versión: 2.0
    Framework: Helix6
    Fecha: 2026-02-20
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$EntityName,
    
    [Parameter(Mandatory = $true)]
    [string]$ConfigurationName
)

# Configuración de colores
$ColorTitle = "Cyan"
$ColorSuccess = "Green"
$ColorError = "Red"
$ColorInfo = "Gray"
$ColorLectura = "Red"
$ColorEscritura = "Green"

# Función para detectar el proyecto
function Get-ProjectInfo {
    # Try multiple start points (current location and the script folder)
    $startPaths = @()
    try { $startPaths += (Get-Location).ProviderPath } catch { }
    if ($PSCommandPath) { $startPaths += (Split-Path -Path $PSCommandPath -Parent) }
    if ($PSScriptRoot) { $startPaths += $PSScriptRoot }

    foreach ($start in $startPaths | Where-Object { $_ -and (Test-Path $_) } ) {
        $dir = Get-Item -Path $start
        while ($dir -ne $null) {
            $slnFile = Get-ChildItem -Path $dir.FullName -Filter "*.Back.sln" -File -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($slnFile) {
                $projectName = $slnFile.Name -replace "\.Back\.sln$", ""
                $projectRoot = $slnFile.DirectoryName

                return @{
                    Name = $projectName
                    Root = $projectRoot
                    ApiPath = Join-Path $projectRoot "$projectName.Back.Api"
                }
            }

            if ($dir.Parent -ne $null) {
                $dir = $dir.Parent
            } else {
                $dir = $null
            }
        }
    }

    Write-Host "❌ No se encontró archivo .sln en los directorios ascendentes (buscado desde CWD y la carpeta del script)" -ForegroundColor $ColorError
    exit 1
}

# Función para cargar el XML
function Get-HelixEntitiesXml {
    param([string]$ApiPath)
    
    $xmlPath = Join-Path $ApiPath "HelixEntities.xml"
    
    if (-not (Test-Path $xmlPath)) {
        Write-Host "❌ No se encontró HelixEntities.xml en: $xmlPath" -ForegroundColor $ColorError
        exit 1
    }
    
    [xml]$xml = Get-Content $xmlPath -Encoding UTF8
    return $xml
}

# Función para obtener una configuración específica
function Get-ConfigurationFromXml {
    param(
        [xml]$Xml,
        [string]$EntityName,
        [string]$ConfigurationName
    )
    
    $entity = $Xml.HelixEntities.Entities | Where-Object { $_.EntityName -eq $EntityName } | Select-Object -First 1
    
    if ($null -eq $entity) {
        Write-Host "❌ Entidad '$EntityName' no encontrada en HelixEntities.xml" -ForegroundColor $ColorError
        exit 1
    }
    
    $configuration = $entity.Configurations | Where-Object { $_.ConfigurationName -eq $ConfigurationName } | Select-Object -First 1
    
    if ($null -eq $configuration) {
        Write-Host "❌ Configuración '$ConfigurationName' no encontrada para entidad '$EntityName'" -ForegroundColor $ColorError
        
        $availableConfigs = @($entity.Configurations | ForEach-Object { $_.ConfigurationName })
        if ($availableConfigs.Count -gt 0) {
            Write-Host "`nConfiguraciones disponibles:" -ForegroundColor $ColorInfo
            $availableConfigs | ForEach-Object { Write-Host "  - $_" -ForegroundColor $ColorInfo }
        }
        
        exit 1
    }
    
    return $configuration
}

# Función para mostrar un include de forma recursiva con formato jerárquico
function Show-IncludeHierarchy {
    param(
        [System.Xml.XmlElement]$Include,
        [int]$Level = 1,
        [string]$Prefix = "  ",
        [bool]$IsLast = $false,
        [string]$ParentPrefix = ""
    )
    
    $entityBase = $Include.EntityBase
    $readOnly = $Include.ReadOnly -eq "true"
    $mode = if ($readOnly) { "(L)" } else { "(E)" }
    $modeColor = if ($readOnly) { $ColorLectura } else { $ColorEscritura }
    
    # Símbolos para el árbol
    $branch = if ($IsLast) { "└─" } else { "├─" }
    $extension = if ($IsLast) { "  " } else { "│ " }
    
    # Mostrar el include
    Write-Host "$ParentPrefix$branch " -NoNewline
    Write-Host "($Level.$($Script:IncludeCounter)) " -NoNewline -ForegroundColor $ColorInfo
    Write-Host $entityBase -NoNewline
    Write-Host " $mode" -ForegroundColor $modeColor
    
    $Script:IncludeCounter++
    
    # Procesar includes anidados
    $nestedIncludes = @($Include.Includes)
    if ($nestedIncludes.Count -gt 0 -and $null -ne $Include.Includes) {
        for ($i = 0; $i -lt $nestedIncludes.Count; $i++) {
            $isLastNested = $i -eq ($nestedIncludes.Count - 1)
            Show-IncludeHierarchy -Include $nestedIncludes[$i] -Level ($Level + 1) -ParentPrefix "$ParentPrefix$extension  " -IsLast $isLastNested
        }
    }
}

# Script principal
try {
    Write-Host "═══════════════════════════════════════" -ForegroundColor $ColorTitle
    Write-Host "  VIEW CONFIGURATION" -ForegroundColor $ColorTitle
    Write-Host "═══════════════════════════════════════" -ForegroundColor $ColorTitle
    Write-Host ""
    
    # Detectar proyecto
    $project = Get-ProjectInfo
    Write-Host "📁 Proyecto: " -NoNewline
    Write-Host $project.Name -ForegroundColor $ColorSuccess
    Write-Host ""
    
    # Cargar XML
    $xml = Get-HelixEntitiesXml -ApiPath $project.ApiPath
    
    # Obtener configuración
    $configuration = Get-ConfigurationFromXml -Xml $xml -EntityName $EntityName -ConfigurationName $ConfigurationName
    
    Write-Host $EntityName -ForegroundColor $ColorTitle
    Write-Host ("-" * 23) -ForegroundColor $ColorTitle
    Write-Host ""
    
    Write-Host "Configuración: " -NoNewline
    Write-Host $ConfigurationName -ForegroundColor $ColorSuccess
    Write-Host ""
    
    # Mostrar estructura
    Write-Host $EntityName
    
    $includes = @($configuration.Includes)
    
    if ($includes.Count -eq 0 -or $null -eq $configuration.Includes) {
        Write-Host "  (Sin includes - configuración básica)" -ForegroundColor $ColorInfo
    } else {
        $Script:IncludeCounter = 1
        for ($i = 0; $i -lt $includes.Count; $i++) {
            $isLast = $i -eq ($includes.Count - 1)
            Show-IncludeHierarchy -Include $includes[$i] -IsLast $isLast
        }
    }
    
    Write-Host ""
    
    # Mostrar ordenación
    if ($configuration.Orders) {
        $orders = @($configuration.Orders)
        $orderText = $orders | ForEach-Object {
            $direction = if ($_.Order -eq "Ascending") { "ASC" } else { "DESC" }
            "$($_.Field) $direction"
        }
        Write-Host "Ordenación: " -NoNewline -ForegroundColor $ColorInfo
        Write-Host ($orderText -join ", ")
    } else {
        Write-Host "Ordenación: " -NoNewline -ForegroundColor $ColorInfo
        Write-Host "Id ASC (por defecto)"
    }
    
    # Leyenda
    Write-Host "`nLeyenda:" -ForegroundColor $ColorInfo
    Write-Host "  (L) = ReadOnly: true  (solo lectura)" -ForegroundColor $ColorLectura
    Write-Host "  (E) = ReadOnly: false (escritura)" -ForegroundColor $ColorEscritura
    Write-Host ""
    
} catch {
    Write-Host "`n❌ Error: $_" -ForegroundColor $ColorError
    Write-Host $_.ScriptStackTrace -ForegroundColor $ColorError
    exit 1
}
