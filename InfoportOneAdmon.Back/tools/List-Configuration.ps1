<#
.SYNOPSIS
    Lista todas las configuraciones de carga definidas para una entidad específica.

.DESCRIPTION
    Este script analiza el archivo HelixEntities.xml y muestra todas las configuraciones
    de carga definidas para una entidad, incluyendo su estructura jerárquica.

.PARAMETER EntityName
    Nombre de la entidad del DataModel (ej: Organization, Application).

.EXAMPLE
    .\List-Configuration.ps1 -EntityName "Organization"
    Lista todas las configuraciones de Organization con su estructura.

.NOTES
    Versión: 2.0
    Framework: Helix6
    Fecha: 2026-02-20
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$EntityName
)

# Configuración de colores
$ColorTitle = "Cyan"
$ColorSuccess = "Green"
$ColorWarning = "Yellow"
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
                    DataModelPath = Join-Path $projectRoot "$projectName.Back.DataModel"
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

# Función para obtener una entidad del XML
function Get-EntityFromXml {
    param(
        [xml]$Xml,
        [string]$EntityName
    )
    
    $entity = $Xml.HelixEntities.Entities | Where-Object { $_.EntityName -eq $EntityName } | Select-Object -First 1
    
    if ($null -eq $entity) {
        Write-Host "❌ Entidad '$EntityName' no encontrada en HelixEntities.xml" -ForegroundColor $ColorError
        
        $availableEntities = $Xml.HelixEntities.Entities | ForEach-Object { $_.EntityName }
        Write-Host "`nEntidades disponibles:" -ForegroundColor $ColorInfo
        $availableEntities | ForEach-Object { Write-Host "  - $_" -ForegroundColor $ColorInfo }
        
        exit 1
    }
    
    return $entity
}

# Función para mostrar un include de forma recursiva
function Show-IncludeStructure {
    param(
        [System.Xml.XmlElement]$Include,
        [int]$Level = 1,
        [string]$Prefix = "  "
    )
    
    $entityBase = $Include.EntityBase
    $readOnly = $Include.ReadOnly -eq "true"
    $mode = if ($readOnly) { "(L)" } else { "(E)" }
    $modeColor = if ($readOnly) { $ColorLectura } else { $ColorEscritura }
    
    Write-Host "$Prefix($Level.$($Script:IncludeCounter)) " -NoNewline
    Write-Host $entityBase -NoNewline
    Write-Host " $mode" -ForegroundColor $modeColor
    
    $Script:IncludeCounter++
    
    # Procesar includes anidados
    if ($Include.Includes) {
        foreach ($nestedInclude in $Include.Includes) {
            Show-IncludeStructure -Include $nestedInclude -Level ($Level + 1) -Prefix "$Prefix  "
        }
    }
}

# Función para mostrar una configuración
function Show-Configuration {
    param(
        [System.Xml.XmlElement]$Configuration,
        [string]$EntityName
    )
    
    $configName = $Configuration.ConfigurationName
    
    Write-Host "`nConfiguración: " -NoNewline -ForegroundColor $ColorTitle
    Write-Host $configName -ForegroundColor $ColorSuccess
    
    Write-Host $EntityName
    
    $includes = @($Configuration.Includes)
    
    if ($includes.Count -eq 0 -or $null -eq $Configuration.Includes) {
        Write-Host "  (Sin includes - configuración básica)" -ForegroundColor $ColorInfo
    } else {
        $Script:IncludeCounter = 1
        foreach ($include in $includes) {
            Show-IncludeStructure -Include $include
        }
    }
    
    # Mostrar ordenación
    if ($Configuration.Orders) {
        $orders = @($Configuration.Orders)
        $orderText = $orders | ForEach-Object {
            $direction = if ($_.Order -eq "Ascending") { "ASC" } else { "DESC" }
            "$($_.Field) $direction"
        }
        Write-Host "  Ordenación: " -NoNewline -ForegroundColor $ColorInfo
        Write-Host ($orderText -join ", ")
    }
}

# Script principal
try {
    Write-Host "═══════════════════════════════════════" -ForegroundColor $ColorTitle
    Write-Host "  LIST CONFIGURATION" -ForegroundColor $ColorTitle
    Write-Host "═══════════════════════════════════════" -ForegroundColor $ColorTitle
    Write-Host ""
    
    # Detectar proyecto
    $project = Get-ProjectInfo
    Write-Host "📁 Proyecto: " -NoNewline
    Write-Host $project.Name -ForegroundColor $ColorSuccess
    Write-Host ""
    
    # Cargar XML
    $xml = Get-HelixEntitiesXml -ApiPath $project.ApiPath
    
    # Obtener entidad
    $entity = Get-EntityFromXml -Xml $xml -EntityName $EntityName
    
    Write-Host $EntityName -ForegroundColor $ColorTitle
    Write-Host ("-" * 23) -ForegroundColor $ColorTitle
    
    # Obtener todas las configuraciones
    $configurations = @($entity.Configurations)
    
    if ($configurations.Count -eq 0) {
        Write-Host "`n⚠️  No hay configuraciones definidas para $EntityName" -ForegroundColor $ColorWarning
        exit 0
    }
    
    # Mostrar cada configuración
    foreach ($config in $configurations) {
        Show-Configuration -Configuration $config -EntityName $EntityName
    }
    
    # Resumen
    Write-Host "`n" + ("-" * 23) -ForegroundColor $ColorTitle
    Write-Host "Total: " -NoNewline
    Write-Host "$($configurations.Count) configuraciones" -ForegroundColor $ColorSuccess
    Write-Host ""
    
} catch {
    Write-Host "`n❌ Error: $_" -ForegroundColor $ColorError
    Write-Host $_.ScriptStackTrace -ForegroundColor $ColorError
    exit 1
}
