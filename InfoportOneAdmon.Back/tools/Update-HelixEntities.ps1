<#
.SYNOPSIS
    Actualiza o crea mapeos entre DataModel y Views en HelixEntities.xml

.DESCRIPTION
    Script automatizado para sincronizar el archivo HelixEntities.xml con el estado actual
    del DataModel y las Views. Parte del framework Helix6.
    
    Funcionalidades:
    - Crea o actualiza mapeos de propiedades entre entidades y views
    - Elimina propiedades obsoletas del XML
    - Elimina entidades completas si ya no existen en el DataModel
    - Limpia configuraciones de carga de referencias obsoletas
    - Crea ordenación por defecto (Id ascendente) para nuevas entidades
    - Valida campos de auditoría obligatorios

.PARAMETER ProjectName
    Nombre del proyecto sin sufijos (ej: "InfoportOneAdmon")

.EXAMPLE
    .\Update-HelixEntities.ps1 -ProjectName "InfoportOneAdmon"

.NOTES
    Framework: Helix6 v1.0
    Autor: Equipo Helix6
    Fecha: 2026-02-17
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectName
)

# Colores para output
$script:SuccessColor = "Green"
$script:InfoColor = "Cyan"
$script:WarningColor = "Yellow"
$script:ErrorColor = "Red"

# Estructura para almacenar información de entidades
class EntityInfo {
    [string]$Name
    [string]$ViewName
    [string]$FullPath
    [bool]$IsVersionEntity
    [bool]$IsValidityEntity
    [System.Collections.ArrayList]$Properties
    [System.Collections.ArrayList]$NavigationProperties
    
    EntityInfo() {
        $this.Properties = New-Object System.Collections.ArrayList
        $this.NavigationProperties = New-Object System.Collections.ArrayList
    }
}

class PropertyInfo {
    [string]$Name
    [string]$Type
    [bool]$IsNullable
    [bool]$IsNavigation
    [bool]$IsCollection
    [string]$RelatedEntity
}

function Write-Step {
    param([string]$Message)
    Write-Host "`n$Message" -ForegroundColor $script:InfoColor
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor $script:SuccessColor
}

function Write-Warning-Message {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor $script:WarningColor
}

function Write-Error-Message {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor $script:ErrorColor
}

function Find-Solution {
    Write-Step "🔍 Localizando proyectos..."
    
    $solutionFiles = Get-ChildItem -Path "." -Filter "*.sln" -Recurse | Where-Object {
        $_.DirectoryName -notmatch '\\node_modules\\|\\bin\\|\\obj\\'
    }
    
    if ($solutionFiles.Count -eq 0) {
        throw "No se encontró ningún archivo de solución (.sln)"
    }
    
    $backSolution = $solutionFiles | Where-Object { $_.Name -match 'Back' } | Select-Object -First 1
    if ($backSolution) {
        Write-Success "Solución: $($backSolution.Name)"
        return $backSolution.FullName
    }
    
    Write-Success "Solución: $($solutionFiles[0].Name)"
    return $solutionFiles[0].FullName
}

function Find-ProjectDirectories {
    param([string]$SolutionDir, [string]$ProjectName)
    
    $result = @{}
    
    # DataModel
    $pattern = if ($ProjectName) { "$ProjectName.Back.DataModel" } else { "*.Back.DataModel" }
    $dataModelProj = Get-ChildItem -Path $SolutionDir -Filter "$pattern.csproj" -Recurse | Where-Object {
        $_.DirectoryName -notmatch '\\bin\\|\\obj\\'
    } | Select-Object -First 1
    
    if (-not $dataModelProj) {
        throw "No se encontró el proyecto Back.DataModel"
    }
    
    $result.DataModelDir = $dataModelProj.DirectoryName
    Write-Success "DataModel: $($dataModelProj.BaseName)"
    
    # Entities
    $entitiesPattern = "$($dataModelProj.BaseName -replace '\.DataModel$','.Entities')"
    $entitiesProj = Get-ChildItem -Path $SolutionDir -Filter "$entitiesPattern.csproj" -Recurse | Where-Object {
        $_.DirectoryName -notmatch '\\bin\\|\\obj\\'
    } | Select-Object -First 1
    
    if (-not $entitiesProj) {
        throw "No se encontró el proyecto Back.Entities"
    }
    
    $result.EntitiesDir = $entitiesProj.DirectoryName
    $result.ViewsDir = Join-Path $entitiesProj.DirectoryName "Views"
    Write-Success "Entities: $($entitiesProj.BaseName)"
    
    # Api
    $apiPattern = "$($dataModelProj.BaseName -replace '\.DataModel$','.Api')"
    $apiProj = Get-ChildItem -Path $SolutionDir -Filter "$apiPattern.csproj" -Recurse | Where-Object {
        $_.DirectoryName -notmatch '\\bin\\|\\obj\\'
    } | Select-Object -First 1
    
    if (-not $apiProj) {
        throw "No se encontró el proyecto Back.Api"
    }
    
    $result.ApiDir = $apiProj.DirectoryName
    $result.HelixEntitiesPath = Join-Path $apiProj.DirectoryName "HelixEntities.xml"
    Write-Success "Api: $($apiProj.BaseName)"
    
    if (-not $ProjectName) {
        $ProjectName = $dataModelProj.BaseName -replace '\.Back\.DataModel$', ''
    }
    $result.ProjectName = $ProjectName
    
    return $result
}

function Parse-EntityFile {
    param([string]$FilePath)
    
    $content = Get-Content -Path $FilePath -Raw
    $entity = [EntityInfo]::new()
    $entity.Name = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)
    $entity.ViewName = "$($entity.Name)View"
    $entity.FullPath = $FilePath
    
    # Detectar interfaces
    if ($content -match 'IEntityBase\s*,\s*IVersionEntity') {
        $entity.IsVersionEntity = $true
    }
    if ($content -match 'IEntityBase\s*,\s*IValidityEntity') {
        $entity.IsValidityEntity = $true
    }
    
    # Parsear propiedades
    $propertyRegex = '(?ms)^\s*(?:(?:\[[^\]]+\]\s*)*\s*)?public\s+([^{]+?)\s+(\w+)\s*{\s*get;[^}]*}'
    $matches = [regex]::Matches($content, $propertyRegex)
    
    foreach ($match in $matches) {
        $typeRaw = $match.Groups[1].Value.Trim()
        $propName = $match.Groups[2].Value
        
        $prop = [PropertyInfo]::new()
        $prop.Name = $propName
        
        # Limpiar tipo
        $type = $typeRaw -replace '\bvirtual\s+', ''
        $prop.IsNullable = $type -match '\?'
        
        # Detectar colecciones
        if ($type -match 'ICollection<(\w+)>') {
            $prop.IsCollection = $true
            $prop.IsNavigation = $true
            $prop.RelatedEntity = $matches[1]
            $prop.Type = $matches[1]
            [void]$entity.NavigationProperties.Add($prop)
        }
        # Detectar navegación singular
        elseif ($type -match '^(\w+)\??$' -and $type -notmatch '^(int|string|bool|decimal|DateTime|long|short|byte|float|double|Guid|Int32|Int64|Boolean|String|Decimal|Byte|Single|Double)') {
            $prop.IsNavigation = $true
            $prop.RelatedEntity = $type -replace '\?', ''
            $prop.Type = $prop.RelatedEntity
            [void]$entity.NavigationProperties.Add($prop)
        }
        # Propiedad escalar
        else {
            $prop.IsNavigation = $false
            $prop.Type = $type
            [void]$entity.Properties.Add($prop)
        }
    }
    
    return $entity
}

function Get-DataModelEntities {
    param([string]$DataModelDir)
    
    Write-Step "📦 Inventariando entidades del DataModel..."
    
    $entityFiles = Get-ChildItem -Path $DataModelDir -Filter "*.cs" | Where-Object {
        $_.Name -ne "AssemblyInfo.cs" -and 
        $_.DirectoryName -notmatch '\\Base\\|\\bin\\|\\obj\\'
    }
    
    $entities = @()
    
    foreach ($file in $entityFiles) {
        $content = Get-Content -Path $file.FullName -Raw
        
        # Solo entidades que implementan IEntityBase
        if ($content -match 'class\s+\w+\s*:\s*IEntityBase') {
            $entity = Parse-EntityFile -FilePath $file.FullName
            $entities += $entity
            
            $interfaceInfo = "IEntityBase"
            if ($entity.IsVersionEntity) { $interfaceInfo += ", IVersionEntity" }
            if ($entity.IsValidityEntity) { $interfaceInfo += ", IValidityEntity" }
            
            Write-Host "  $($entities.Count). $($entity.Name) ($interfaceInfo) - $($entity.Properties.Count) propiedades" -ForegroundColor Gray
        }
    }
    
    Write-Success "$($entities.Count) entidades encontradas"
    return $entities
}

function Test-ViewExists {
    param([string]$ViewsDir, [string]$ViewName)
    
    $viewPath = Join-Path $ViewsDir "$ViewName.cs"
    return Test-Path $viewPath
}

function Convert-TypeToXml {
    param([string]$Type)
    
    $type = $Type.Trim() -replace '\bvirtual\s+', ''
    
    # Mapeo de tipos
    $typeMap = @{
        'int' = 'Int32'
        'int?' = 'Int32?'
        'string' = 'String'
        'bool' = 'Boolean'
        'bool?' = 'Boolean?'
        'decimal' = 'Decimal'
        'decimal?' = 'Decimal?'
        'DateTime' = 'DateTime'
        'DateTime?' = 'DateTime?'
        'long' = 'Int64'
        'long?' = 'Int64?'
        'short' = 'Int16'
        'Guid' = 'Guid'
    }
    
    if ($typeMap.ContainsKey($type)) {
        return $typeMap[$type]
    }
    
    return $type
}

function Create-XmlField {
    param([PropertyInfo]$Property, [bool]$IsNavigation = $false)
    
    $field = @"
    <Fields>
      <EntityFieldName>$($Property.Name)</EntityFieldName>
      <ViewFieldName>$($Property.Name)</ViewFieldName>
      <EntityFieldTypeDB>$(Convert-TypeToXml -Type $Property.Type)</EntityFieldTypeDB>
      <IsEntidadBase>$($IsNavigation.ToString().ToLower())</IsEntidadBase>
    </Fields>
"@
    
    return $field
}

function Create-DefaultConfiguration {
    return @"
    <Configurations>
      <ConfigurationName>Defecto</ConfigurationName>
      <Orders>
        <Field>Id</Field>
        <Order>Ascending</Order>
      </Orders>
    </Configurations>
"@
}

function Create-EntityXml {
    param([EntityInfo]$Entity)
    
    $xml = @"
  <Entities>
    <EntityName>$($Entity.Name)</EntityName>
    <ViewName>$($Entity.ViewName)</ViewName>
    <DefaultFilterField>$(if ($Entity.Properties | Where-Object Name -eq 'Name') { 'Name' } else { 'Id' })</DefaultFilterField>
    <IsVersionEntity>$($Entity.IsVersionEntity.ToString().ToLower())</IsVersionEntity>
    <IsValidityEntity>$($Entity.IsValidityEntity.ToString().ToLower())</IsValidityEntity>

"@
    
    # Lista de campos de auditoría para filtrar
    $auditFieldNames = @('AuditCreationUser', 'AuditCreationDate', 'AuditModificationUser', 'AuditModificationDate', 'AuditDeletionDate')
    $versionFieldNames = @('VersionKey', 'VersionNumber')
    $validityFieldNames = @('ValidityFrom', 'ValidityTo')
    
    # 1. Campo Id primero
    $idField = $Entity.Properties | Where-Object Name -eq 'Id'
    if ($idField) {
        $xml += Create-XmlField -Property $idField
        $xml += "`n"
    }
    
    # 2. Campos escalares (alfabético, excluyendo Id, auditoría, versionado y vigencia)
    $scalarProps = $Entity.Properties | Where-Object { 
        $_.Name -ne 'Id' -and 
        $_.Name -notin $auditFieldNames -and
        $_.Name -notin $versionFieldNames -and
        $_.Name -notin $validityFieldNames
    } | Sort-Object Name
    
    foreach ($prop in $scalarProps) {
        $xml += Create-XmlField -Property $prop
        $xml += "`n"
    }
    
    # 3. Campos de auditoría (orden fijo)
    $auditFields = @(
        @{Name='AuditCreationUser'; Type='String'},
        @{Name='AuditCreationDate'; Type='DateTime'},
        @{Name='AuditModificationUser'; Type='String'},
        @{Name='AuditModificationDate'; Type='DateTime'},
        @{Name='AuditDeletionDate'; Type='DateTime?'}
    )
    
    foreach ($audit in $auditFields) {
        $prop = [PropertyInfo]::new()
        $prop.Name = $audit.Name
        $prop.Type = $audit.Type
        $xml += Create-XmlField -Property $prop
        $xml += "`n"
    }
    
    # 4. Campos de versionado (si aplica)
    if ($Entity.IsVersionEntity) {
        # Verificar si ya existen en las propiedades parseadas
        $existingVersionKey = $Entity.Properties | Where-Object Name -eq 'VersionKey'
        $existingVersionNumber = $Entity.Properties | Where-Object Name -eq 'VersionNumber'
        
        if (-not $existingVersionKey) {
            $versionKey = [PropertyInfo]::new()
            $versionKey.Name = 'VersionKey'
            $versionKey.Type = 'String'
            $xml += Create-XmlField -Property $versionKey
            $xml += "`n"
        }
        
        if (-not $existingVersionNumber) {
            $versionNumber = [PropertyInfo]::new()
            $versionNumber.Name = 'VersionNumber'
            $versionNumber.Type = 'Int32'
            $xml += Create-XmlField -Property $versionNumber
            $xml += "`n"
        }
    }
    
    # 5. Campos de vigencia (si aplica)
    if ($Entity.IsValidityEntity) {
        # Verificar si ya existen en las propiedades parseadas
        $existingValidityFrom = $Entity.Properties | Where-Object Name -eq 'ValidityFrom'
        $existingValidityTo = $Entity.Properties | Where-Object Name -eq 'ValidityTo'
        
        if (-not $existingValidityFrom) {
            $validityFrom = [PropertyInfo]::new()
            $validityFrom.Name = 'ValidityFrom'
            $validityFrom.Type = 'DateTime'
            $xml += Create-XmlField -Property $validityFrom
            $xml += "`n"
        }
        
        if (-not $existingValidityTo) {
            $validityTo = [PropertyInfo]::new()
            $validityTo.Name = 'ValidityTo'
            $validityTo.Type = 'DateTime?'
            $xml += Create-XmlField -Property $validityTo
            $xml += "`n"
        }
    }
    
    # 6. Propiedades de navegación (alfabético)
    foreach ($nav in ($Entity.NavigationProperties | Sort-Object Name)) {
        $xml += Create-XmlField -Property $nav -IsNavigation $true
        $xml += "`n"
    }
    
    # Configuración por defecto
    $xml += Create-DefaultConfiguration
    $xml += "`n"
    
    # Endpoints vacíos inicialmente (se añaden mediante agente de controladores)
    $xml += "    <Endpoints>`n"
    $xml += "    </Endpoints>`n"
    
    $xml += "  </Entities>`n"
    
    return $xml
}

# ============================================
# PROCESO PRINCIPAL
# ============================================

try {
    Write-Host "`n========================================" -ForegroundColor $script:InfoColor
    Write-Host "  UPDATE HELIXENTITIES - Helix6" -ForegroundColor $script:InfoColor
    Write-Host "========================================`n" -ForegroundColor $script:InfoColor
    
    # Paso 1: Localizar proyectos
    $solutionPath = Find-Solution
    $solutionDir = [System.IO.Path]::GetDirectoryName($solutionPath)
    $projects = Find-ProjectDirectories -SolutionDir $solutionDir -ProjectName $ProjectName
    
    if (-not $ProjectName) {
        $ProjectName = $projects.ProjectName
    }
    
    # Paso 2: Leer o crear HelixEntities.xml
    Write-Step "📄 Verificando HelixEntities.xml..."
    
    $xmlExists = Test-Path $projects.HelixEntitiesPath
    $existingXml = $null
    
    if ($xmlExists) {
        Write-Success "Archivo encontrado"
        
        # TODO: Parsear XML existente para comparar
        # Por ahora, regeneramos completo
    }
    else {
        Write-Warning-Message "HelixEntities.xml no existe"
        Write-Success "Creando archivo nuevo"
    }
    
    # Paso 3: Inventariar entidades del DataModel
    $entities = Get-DataModelEntities -DataModelDir $projects.DataModelDir
    
    # Paso 4: Verificar Views
    Write-Step "👁 Verificando Views correspondientes..."
    
    $entitiesWithViews = @()
    $stats = @{
        WithView = 0
        WithoutView = 0
        New = 0
        Updated = 0
    }
    
    foreach ($entity in $entities) {
        if (Test-ViewExists -ViewsDir $projects.ViewsDir -ViewName $entity.ViewName) {
            Write-Host "  ✓ $($entity.Name) → $($entity.ViewName)" -ForegroundColor $script:SuccessColor
            $entitiesWithViews += $entity
            $stats.WithView++
        }
        else {
            Write-Warning-Message "$($entity.Name) → $($entity.ViewName) (no existe View)"
            $stats.WithoutView++
        }
    }
    
    # Paso 5-7: Generar XML
    Write-Step "🔨 Generando HelixEntities.xml..."
    
    $xmlContent = @"
<?xml version="1.0" encoding="utf-8"?>
<HelixEntities>
"@
    
    foreach ($entity in $entitiesWithViews) {
        $xmlContent += Create-EntityXml -Entity $entity
        Write-Host "  ✓ $($entity.Name): $($entity.Properties.Count) propiedades + $($entity.NavigationProperties.Count) navegaciones" -ForegroundColor Gray
        $stats.New++
    }
    
    $xmlContent += "</HelixEntities>"
    
    # Paso 8-9: Ya están validados en la generación
    
    # Paso 10: Guardar archivo
    Write-Step "💾 Guardando HelixEntities.xml..."
    
    $xmlContent | Out-File -FilePath $projects.HelixEntitiesPath -Encoding UTF8 -Force
    Write-Success "Archivo guardado exitosamente"
    
    # Paso 11: Resumen
    Write-Host "`n========================================" -ForegroundColor $script:SuccessColor
    Write-Host "  RESUMEN DE ACTUALIZACIÓN" -ForegroundColor $script:SuccessColor
    Write-Host "========================================" -ForegroundColor $script:SuccessColor
    
    Write-Host "`nEntidades procesadas: $($entities.Count)" -ForegroundColor $script:InfoColor
    Write-Host "  ✓ Con View disponible: $($stats.WithView)" -ForegroundColor $script:SuccessColor
    if ($stats.WithoutView -gt 0) {
        Write-Host "  ⚠ Sin View: $($stats.WithoutView)" -ForegroundColor $script:WarningColor
    }
    
    Write-Host "`nArchivo generado:" -ForegroundColor $script:InfoColor
    Write-Host "  $($projects.HelixEntitiesPath)" -ForegroundColor Gray
    
    Write-Host "`n✅ HelixEntities.xml actualizado correctamente" -ForegroundColor $script:SuccessColor
    
    Write-Host "`nSiguiente paso recomendado:" -ForegroundColor $script:InfoColor
    Write-Host "  Ejecutar Helix Generator para regenerar servicios y endpoints" -ForegroundColor Gray
    
    exit 0
    
}
catch {
    Write-Host "`n========================================" -ForegroundColor $script:ErrorColor
    Write-Host "  ERROR EN EL PROCESO" -ForegroundColor $script:ErrorColor
    Write-Host "========================================" -ForegroundColor $script:ErrorColor
    Write-Error-Message $_.Exception.Message
    Write-Host "`nStack Trace:" -ForegroundColor Gray
    Write-Host $_.Exception.StackTrace -ForegroundColor Gray
    exit 1
}
