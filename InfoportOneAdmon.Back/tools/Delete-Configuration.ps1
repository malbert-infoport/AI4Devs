<#
.SYNOPSIS
    Elimina una configuración de carga específica de una entidad.

.DESCRIPTION
    Este script elimina una configuración de carga del archivo HelixEntities.xml y
    su constante correspondiente de Consts.cs.

.PARAMETER EntityName
    Nombre de la entidad del DataModel (ej: Organization, Application).

.PARAMETER ConfigurationName
    Nombre de la configuración a eliminar (ej: OrganizationComplete).

.EXAMPLE
    .\Delete-Configuration.ps1 -EntityName "Organization" -ConfigurationName "OrganizationComplete"
    Elimina la configuración OrganizationComplete del sistema.

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
$ColorWarning = "Yellow"
$ColorError = "Red"
$ColorInfo = "Gray"

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
                    DataPath = Join-Path $projectRoot "$projectName.Back.Data"
                    EntitiesPath = Join-Path $projectRoot "$projectName.Back.Entities"
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
        exit 1
    }
    
    return @{
        Entity = $entity
        Configuration = $configuration
    }
}

# Función para eliminar configuración del XML
function Remove-ConfigurationFromXml {
    param(
        [System.Xml.XmlElement]$Entity,
        [System.Xml.XmlElement]$Configuration
    )
    
    $Entity.RemoveChild($Configuration) | Out-Null
}

# Función para eliminar constante de Consts
function Remove-ConstantFromConsts {
    param(
        [string]$EntitiesPath,
        [string]$EntityName,
        [string]$ConfigurationName
    )
    if ([string]::IsNullOrWhiteSpace($EntitiesPath) -or -not (Test-Path $EntitiesPath)) {
        Write-Host "⚠️  Ruta de Entities inválida o inexistente, omitiendo sincronización de Consts.cs" -ForegroundColor $ColorWarning
        return
    }

    $constsFilePath = Join-Path $EntitiesPath "Consts.cs"

    if (-not (Test-Path $constsFilePath)) {
        Write-Host "⚠️  Archivo Consts.cs no encontrado en: $constsFilePath, omitiendo sincronización" -ForegroundColor $ColorWarning
        return
    }
    
    # Convertir PascalCase a UPPER_CASE
    $constName = $ConfigurationName -creplace '([a-z])([A-Z])', '$1_$2'
    $constName = $constName.ToUpper()
    
    $content = Get-Content $constsFilePath -Raw
    
    # Buscar y eliminar la constante
    $pattern = "\s*public\s+const\s+string\s+$constName\s*=\s*`"$ConfigurationName`";\s*"
    $content = $content -replace $pattern, ""
    
    # Si el struct queda vacío, eliminarlo también
    $structPattern = "public\s+struct\s+$EntityName\s*\{\s*\}"
    if ($content -match $structPattern) {
        $content = $content -replace $structPattern, ""
    }
    
    Set-Content -Path $constsFilePath -Value $content -Encoding UTF8 -NoNewline
}

# Script principal
try {
    Write-Host "═══════════════════════════════════════" -ForegroundColor $ColorTitle
    Write-Host "  DELETE CONFIGURATION" -ForegroundColor $ColorTitle
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
    $result = Get-ConfigurationFromXml -Xml $xml -EntityName $EntityName -ConfigurationName $ConfigurationName
    $entity = $result.Entity
    $configuration = $result.Configuration
    
    # Verificar que no sea "Defecto"
    if ($ConfigurationName -eq "Defecto") {
        Write-Host "❌ No se puede eliminar la configuración `"Defecto`"" -ForegroundColor $ColorError
        Write-Host "   La configuración por defecto es obligatoria" -ForegroundColor $ColorInfo
        exit 1
    }
    
    # Mostrar advertencia
    Write-Host "⚠️  Vas a eliminar la configuración de carga" -ForegroundColor $ColorWarning
    Write-Host ""
    Write-Host "Entidad: " -NoNewline
    Write-Host $EntityName -ForegroundColor $ColorTitle
    Write-Host "Configuración: " -NoNewline
    Write-Host $ConfigurationName -ForegroundColor $ColorError
    Write-Host ""
    Write-Host "Esta acción eliminará:" -ForegroundColor $ColorInfo
    Write-Host "  - El bloque <Configurations> del XML" -ForegroundColor $ColorInfo
    Write-Host "  - La constante en Consts.cs" -ForegroundColor $ColorInfo
    Write-Host ""
    
    # Confirmar eliminación
    $confirm = Read-Host "¿Confirmas la eliminación? (s/N)"
    
    if ($confirm -ne "s" -and $confirm -ne "S") {
        Write-Host "❌ Eliminación cancelada" -ForegroundColor $ColorWarning
        exit 0
    }
    
    # Eliminar configuración
    Write-Host "`n🗑️  Eliminando configuración..." -ForegroundColor $ColorWarning
    
    # Eliminar del XML
    Remove-ConfigurationFromXml -Entity $entity -Configuration $configuration
    
    $xmlPath = Join-Path $project.ApiPath "HelixEntities.xml"
    $xml.Save($xmlPath)
    
    Write-Host "  ✓ Configuración `"$ConfigurationName`" eliminada de HelixEntities.xml" -ForegroundColor $ColorSuccess
    
    # Eliminar de Consts
    Remove-ConstantFromConsts -EntitiesPath $project.EntitiesPath -EntityName $EntityName -ConfigurationName $ConfigurationName
    Write-Host "  ✓ Constante eliminada de Consts.cs" -ForegroundColor $ColorSuccess
    
    Write-Host "`n✅ Configuración eliminada exitosamente" -ForegroundColor $ColorSuccess
    Write-Host ""
    
} catch {
    Write-Host "`n❌ Error: $_" -ForegroundColor $ColorError
    Write-Host $_.ScriptStackTrace -ForegroundColor $ColorError
    exit 1
}
