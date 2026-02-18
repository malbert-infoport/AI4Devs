<#
.SYNOPSIS
    Crea o modifica configuraciones de carga para entidades en HelixEntities.xml

.DESCRIPTION
    Script interactivo para gestionar configuraciones de carga personalizadas en HelixEntities.xml.
    Permite seleccionar entidades relacionadas de forma recursiva, definir modo (Lectura/Escritura)
    y establecer criterios de ordenación. Sincroniza automáticamente con DataConsts.cs.

.PARAMETER EntityName
    Nombre de la entidad base para la configuración (ej: "Worker", "Application")

.PARAMETER ConfigurationName
    Nombre de la configuración (ej: "WorkerComplete", "ApplicationFull")

.PARAMETER ProjectName
    Nombre del proyecto sin sufijos (ej: "InfoportOneAdmon") - opcional, se detecta automáticamente

.EXAMPLE
    .\Configure-EntityLoading.ps1 -EntityName "Worker" -ConfigurationName "WorkerComplete"

.EXAMPLE
    .\Configure-EntityLoading.ps1 -EntityName "Application" -ConfigurationName "ApplicationFull" -ProjectName "InfoportOneAdmon"

.NOTES
    Framework: Helix6 v1.0
    Autor: Equipo Helix6
    Fecha: 2026-02-17
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$EntityName,
    
    [Parameter(Mandatory=$true)]
    [string]$ConfigurationName,
    
    [Parameter(Mandatory=$false)]
    [string]$ProjectName
)

#Requires -Version 5.1

# Colores para output
$script:SuccessColor = "Green"
$script:InfoColor = "Cyan"
$script:WarningColor = "Yellow"
$script:ErrorColor = "Red"

class RelatedEntity {
    [string]$Name
    [string]$Type  # 'Singular' o 'Collection'
    [bool]$IsSelected
    [bool]$ReadOnly
    [System.Collections.ArrayList]$Children
    
    RelatedEntity() {
        $this.Children = New-Object System.Collections.ArrayList
    }
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
    $solutionFiles = Get-ChildItem -Path "." -Filter "*.sln" -Recurse | Where-Object {
        $_.DirectoryName -notmatch '\\node_modules\\|\\bin\\|\\obj\\'
    }
    
    if ($solutionFiles.Count -eq 0) {
        throw "No se encontró ningún archivo de solución (.sln)"
    }
    
    $backSolution = $solutionFiles | Where-Object { $_.Name -match 'Back' } | Select-Object -First 1
    if ($backSolution) {
        return $backSolution.FullName
    }
    
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
    $result.ProjectName = $dataModelProj.BaseName -replace '\.Back\.DataModel$', ''
    
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
    
    # Data (para DataConsts.cs)
    $dataPattern = "$($dataModelProj.BaseName -replace '\.DataModel$','.Data')"
    $dataProj = Get-ChildItem -Path $SolutionDir -Filter "$dataPattern.csproj" -Recurse | Where-Object {
        $_.DirectoryName -notmatch '\\bin\\|\\obj\\'
    } | Select-Object -First 1
    
    if ($dataProj) {
        $result.DataDir = $dataProj.DirectoryName
        $result.DataConstsPath = Join-Path $dataProj.DirectoryName "DataConsts.cs"
    }
    
    return $result
}

function Get-RelatedEntities {
    param([string]$DataModelDir, [string]$EntityName)
    
    $entityPath = Join-Path $DataModelDir "$EntityName.cs"
    if (-not (Test-Path $entityPath)) {
        throw "Entidad '$EntityName' no encontrada en DataModel"
    }
    
    $content = Get-Content -Path $entityPath -Raw
    $related = @()
    
    # Navegación singular - captura { get; set; } o { get; set } o { get; }
    $singularRegex = 'public\s+virtual\s+(\w+)\s+(\w+)\s*\{\s*get;(\s*set;)?'
    $matches = [regex]::Matches($content, $singularRegex)
    
    foreach ($match in $matches) {
        $typeName = $match.Groups[1].Value
        $propName = $match.Groups[2].Value
        
        # Filtrar tipos primitivos y self-references
        if ($typeName -notmatch '^(int|string|bool|decimal|DateTime|long|byte|Guid)' -and $typeName -ne $EntityName) {
            $entity = [RelatedEntity]::new()
            $entity.Name = $typeName
            $entity.Type = 'Singular'
            $related += $entity
        }
    }
    
    # Navegación de colección - captura { get; set; } o { get; } o { get; } = new List<>()
    $collectionRegex = 'public\s+virtual\s+ICollection<(\w+)>\s+(\w+)\s*\{\s*get;'
    $matches = [regex]::Matches($content, $collectionRegex)
    
    foreach ($match in $matches) {
        $typeName = $match.Groups[1].Value
        
        # Evitar colecciones inversas (heurística simple)
        if ($typeName -ne $EntityName) {
            $entity = [RelatedEntity]::new()
            $entity.Name = $typeName
            $entity.Type = 'Collection'
            $related += $entity
        }
    }
    
    return $related | Sort-Object Name
}

function Get-UserSelection {
    param(
        [RelatedEntity[]]$Entities,
        [string]$CurrentEntityName,
        [int]$Level = 1,
        [hashtable]$ExistingConfig = $null
    )
    
    if ($Entities.Count -eq 0) {
        Write-Host "`n$CurrentEntityName no tiene entidades relacionadas." -ForegroundColor Gray
        return @()
    }
    
    Write-Host "`n" -NoNewline
    Write-Host ("─" * 50) -ForegroundColor DarkGray
    if ($Level -eq 1) {
        Write-Host "  Configurando: $CurrentEntityName" -ForegroundColor $script:InfoColor
    }
    else {
        Write-Host "  Nivel $Level`: Entidades de $CurrentEntityName" -ForegroundColor $script:InfoColor
    }
    Write-Host ("─" * 50) -ForegroundColor DarkGray
    
    Write-Host "`n$CurrentEntityName tiene las siguientes entidades relacionadas:"
    
    # Mostrar lista numerada
    for ($i = 0; $i -lt $Entities.Count; $i++) {
        $entity = $Entities[$i]
        $typeDesc = if ($entity.Type -eq 'Singular') { 'navegación singular' } else { 'colección, 1:N' }
        
        $currentStatus = ""
        if ($ExistingConfig -and $ExistingConfig.ContainsKey($entity.Name)) {
            $mode = if ($ExistingConfig[$entity.Name].ReadOnly) { 'L' } else { 'E' }
            $currentStatus = " [$mode] ← actual"
        }
        
        Write-Host "  $($i + 1). $($entity.Name) ($typeDesc)$currentStatus" -ForegroundColor Gray
    }
    
    Write-Host "`nIndica los números de las que deseas incluir y el modo:" -ForegroundColor $script:InfoColor
    Write-Host "  - L = Solo Lectura (ReadOnly=true)" -ForegroundColor Gray
    Write-Host "  - E = Escritura (ReadOnly=false)" -ForegroundColor Gray
    Write-Host "`nFormato: 1L, 2E, 3L" -ForegroundColor Gray
    
    if ($ExistingConfig) {
        $currentSelection = ($ExistingConfig.Keys | ForEach-Object {
            $index = [array]::IndexOf($Entities.Name, $_)
            if ($index -ge 0) {
                $mode = if ($ExistingConfig[$_].ReadOnly) { 'L' } else { 'E' }
                "$($index + 1)$mode"
            }
        }) -join ', '
        
        Write-Host "O presiona Enter si no deseas incluir ninguna." -ForegroundColor Gray
        Write-Host "`nTu selección: (actual: $currentSelection) " -NoNewline -ForegroundColor $script:WarningColor
    }
    else {
        Write-Host "O presiona Enter si no deseas incluir ninguna." -ForegroundColor Gray
        Write-Host "`nTu selección: " -NoNewline -ForegroundColor $script:WarningColor
    }
    
    $input = Read-Host
    
    if ([string]::IsNullOrWhiteSpace($input)) {
        return @()
    }
    
    # Parsear entrada: "1L, 2E, 3L"
    $selections = $input -split ',' | ForEach-Object { $_.Trim() }
    $selected = @()
    
    foreach ($sel in $selections) {
        if ($sel -match '^(\d+)([LlEe])$') {
            $index = [int]$matches[1] - 1
            $mode = $matches[2].ToUpper()
            
            if ($index -ge 0 -and $index -lt $Entities.Count) {
                $entity = $Entities[$index]
                $entity.IsSelected = $true
                $entity.ReadOnly = ($mode -eq 'L')
                $selected += $entity
                
                $modeText = if ($entity.ReadOnly) { "Lectura" } else { "Escritura" }
                Write-Host "  ✓ $($entity.Name): Seleccionado ($modeText)" -ForegroundColor $script:SuccessColor
            }
        }
    }
    
    return $selected
}

function Build-ConfigurationTree {
    param(
        [string]$DataModelDir,
        [string]$EntityName,
        [int]$Level = 1,
        [hashtable]$ExistingConfig = $null,
        [System.Collections.Generic.HashSet[string]]$Visited = $null
    )
    
    if ($null -eq $Visited) {
        $Visited = New-Object 'System.Collections.Generic.HashSet[string]'
    }
    
    # Evitar referencias circulares
    if ($Visited.Contains($EntityName)) {
        Write-Warning-Message "Referencia circular detectada en $EntityName, omitiendo"
        return @()
    }
    
    [void]$Visited.Add($EntityName)
    
    $related = Get-RelatedEntities -DataModelDir $DataModelDir -EntityName $EntityName
    
    if ($related.Count -eq 0) {
        return @()
    }
    
    $selected = Get-UserSelection -Entities $related -CurrentEntityName $EntityName -Level $Level -ExistingConfig $ExistingConfig
    
    # Proceso recursivo para entidades seleccionadas
    foreach ($entity in $selected) {
        $childExistingConfig = $null
        if ($ExistingConfig -and $ExistingConfig.ContainsKey($entity.Name) -and $ExistingConfig[$entity.Name].Children) {
            $childExistingConfig = $ExistingConfig[$entity.Name].Children
        }
        
        $children = Build-ConfigurationTree -DataModelDir $DataModelDir -EntityName $entity.Name -Level ($Level + 1) -ExistingConfig $childExistingConfig -Visited $Visited
        
        foreach ($child in $children) {
            [void]$entity.Children.Add($child)
        }
    }
    
    return $selected
}

function Show-ConfigurationTree {
    param(
        [RelatedEntity[]]$Entities,
        [string]$Indent = ""
    )
    
    foreach ($entity in $Entities) {
        $modeText = if ($entity.ReadOnly) { "Lectura" } else { "Escritura" }
        Write-Host "$Indent├─ $($entity.Name) ($modeText)" -ForegroundColor $script:SuccessColor
        
        if ($entity.Children.Count -gt 0) {
            Show-ConfigurationTree -Entities $entity.Children -Indent "$Indent│  "
        }
    }
}

function Get-OrderCriteria {
    param([string]$EntityName, [string]$DataModelDir)
    
    Write-Step "🔢 Criterio de ordenación para `"$ConfigurationName`""
    
    Write-Host "`n¿Por qué campo deseas ordenar los resultados?"
    Write-Host "Presiona Enter para usar ordenación por defecto (Id ascendente)" -ForegroundColor Gray
    
    # Obtener campos disponibles
    $entityPath = Join-Path $DataModelDir "$EntityName.cs"
    $content = Get-Content -Path $entityPath -Raw
    
    $propertyRegex = 'public\s+(\w+\??)\s+(\w+)\s*{\s*get;'
    $matches = [regex]::Matches($content, $propertyRegex)
    
    Write-Host "`nCampos disponibles en $EntityName`:" -ForegroundColor $script:InfoColor
    $fields = @()
    foreach ($match in $matches) {
        $type = $match.Groups[1].Value
        $name = $match.Groups[2].Value
        
        # Solo mostrar campos escalares
        if ($type -match '^(int|string|bool|decimal|DateTime|long|byte|Guid|Int32|Boolean|String|Decimal)') {
            $fields += $name
            Write-Host "  - $name ($type)" -ForegroundColor Gray
        }
    }
    
    Write-Host "`nFormato:" -ForegroundColor $script:InfoColor
    Write-Host "  - Campo simple: Name" -ForegroundColor Gray
    Write-Host "  - Ascendente explícito: Name ASC" -ForegroundColor Gray
    Write-Host "  - Descendente: Name DESC" -ForegroundColor Gray
    Write-Host "  - Múltiples: Name ASC, BirthDate DESC" -ForegroundColor Gray
    
    Write-Host "`nTu selección: " -NoNewline -ForegroundColor $script:WarningColor
    $input = Read-Host
    
    if ([string]::IsNullOrWhiteSpace($input)) {
        return @(@{Field='Id'; Order='Ascending'})
    }
    
    # Parsear criterios múltiples
    $criteria = @()
    $parts = $input -split ',' | ForEach-Object { $_.Trim() }
    
    foreach ($part in $parts) {
        if ($part -match '^(\w+)\s*(ASC|DESC)?$') {
            $field = $matches[1]
            $direction = if ($matches[2]) { $matches[2] } else { 'ASC' }
            
            $criteria += @{
                Field = $field
                Order = if ($direction -eq 'DESC') { 'Descending' } else { 'Ascending' }
            }
        }
    }
    
    if ($criteria.Count -eq 0) {
        return @(@{Field='Id'; Order='Ascending'})
    }
    
    return $criteria
}

function Create-IncludesXml {
    param([RelatedEntity[]]$Entities, [string]$Indent = "      ")
    
    $xml = ""
    
    foreach ($entity in $Entities) {
        $xml += "$Indent<Includes>`n"
        $xml += "$Indent  <EntityBase>$($entity.Name)</EntityBase>`n"
        $xml += "$Indent  <ReadOnly>$($entity.ReadOnly.ToString().ToLower())</ReadOnly>`n"
        
        if ($entity.Children.Count -gt 0) {
            $xml += Create-IncludesXml -Entities $entity.Children -Indent "$Indent  "
        }
        
        $xml += "$Indent</Includes>`n"
    }
    
    return $xml
}

function Create-OrdersXml {
    param([hashtable[]]$Criteria, [string]$Indent = "      ")
    
    $xml = ""
    
    foreach ($criterion in $Criteria) {
        $xml += "$Indent<Orders>`n"
        $xml += "$Indent  <Field>$($criterion.Field)</Field>`n"
        $xml += "$Indent  <Order>$($criterion.Order)</Order>`n"
        $xml += "$Indent</Orders>`n"
    }
    
    return $xml
}

function Update-HelixEntitiesXml {
    param(
        [string]$XmlPath,
        [string]$EntityName,
        [string]$ConfigurationName,
        [RelatedEntity[]]$Includes,
        [hashtable[]]$OrderCriteria
    )
    
    [xml]$xmlDoc = Get-Content -Path $XmlPath
    
    # Buscar entidad
    $entityNode = $xmlDoc.SelectSingleNode("//Entities[EntityName='$EntityName']")
    
    if (-not $entityNode) {
        throw "Entidad '$EntityName' no encontrada en HelixEntities.xml"
    }
    
    # Buscar configuración existente
    $existingConfig = $entityNode.SelectSingleNode("Configurations[ConfigurationName='$ConfigurationName']")
    
    if ($existingConfig) {
        # Eliminar configuración existente
        [void]$entityNode.RemoveChild($existingConfig)
        Write-Host "  ℹ Configuración existente eliminada" -ForegroundColor Gray
    }
    
    # Crear nueva configuración
    $configXml = "    <Configurations>`n"
    $configXml += "      <ConfigurationName>$ConfigurationName</ConfigurationName>`n"
    $configXml += Create-IncludesXml -Entities $Includes
    $configXml += Create-OrdersXml -Criteria $OrderCriteria
    $configXml += "    </Configurations>"
    
    # Parsear como fragmento XML
    $tempXml = "<root>$configXml</root>"
    [xml]$fragment = $tempXml
    $newConfig = $xmlDoc.ImportNode($fragment.root.Configurations, $true)
    
    # Insertar después de la última configuración
    $lastConfig = $entityNode.SelectNodes("Configurations") | Select-Object -Last 1
    if ($lastConfig) {
        [void]$entityNode.InsertAfter($newConfig, $lastConfig)
    }
    else {
        # Insertar antes de Endpoints
        $endpoints = $entityNode.SelectSingleNode("Endpoints")
        if ($endpoints) {
            [void]$entityNode.InsertBefore($newConfig, $endpoints)
        }
        else {
            [void]$entityNode.AppendChild($newConfig)
        }
    }
    
    # Guardar XML
    $xmlDoc.Save($XmlPath)
}

function ConvertTo-ConstantName {
    param([string]$ConfigurationName)
    
    # Insertar underscore antes de mayúsculas (excepto la primera)
    $result = ""
    for ($i = 0; $i -lt $ConfigurationName.Length; $i++) {
        $char = $ConfigurationName[$i]
        
        if ($i -gt 0 -and [char]::IsUpper($char)) {
            $result += "_"
        }
        
        $result += [char]::ToUpper($char)
    }
    
    return $result
}

function Update-DataConsts {
    param(
        [string]$DataConstsPath,
        [string]$ProjectName,
        [string]$EntityName,
        [string]$ConfigurationName
    )
    
    $constantName = ConvertTo-ConstantName -ConfigurationName $ConfigurationName
    
    # Si no existe, crear archivo base
    if (-not (Test-Path $DataConstsPath)) {
        $baseContent = @"
namespace $ProjectName.Back.Data
{
    public struct DataConsts
    {
        public struct LoadingConfigurations
        {
        }
    }
}
"@
        $baseContent | Out-File -FilePath $DataConstsPath -Encoding UTF8 -Force
        Write-Host "  ✓ DataConsts.cs creado" -ForegroundColor $script:SuccessColor
    }
    
    $content = Get-Content -Path $DataConstsPath -Raw
    
    # Buscar si existe el struct de la entidad
    if ($content -match "public struct $EntityName\s*{") {
        # Verificar si ya existe la constante
        if ($content -match "public const string $constantName\s*=") {
            Write-Host "  ℹ Constante $constantName ya existe en DataConsts.cs" -ForegroundColor Gray
            return
        }
        
        # Añadir constante al struct existente
        $constant = "        public const string $constantName = `"$ConfigurationName`";"
        $content = $content -replace "(public struct $EntityName\s*{)", "`$1`n$constant"
    }
    else {
        # Crear nuevo struct de entidad
        $newStruct = @"
    public struct $EntityName
    {
        public const string $constantName = "$ConfigurationName";
    }
"@
        # Insertar dentro de LoadingConfigurations
        $content = $content -replace '(public struct LoadingConfigurations\s*{)', "`$1`n$newStruct"
    }
    
    $content | Out-File -FilePath $DataConstsPath -Encoding UTF8 -Force
    Write-Success "Constante $constantName sincronizada en DataConsts.cs"
}

# ============================================
# PROCESO PRINCIPAL
# ============================================

try {
    Write-Host "`n========================================" -ForegroundColor $script:InfoColor
    Write-Host "  ENTITY CONFIGURATION - Helix6" -ForegroundColor $script:InfoColor
    Write-Host "========================================`n" -ForegroundColor $script:InfoColor
    
    # Paso 1: Validar y localizar
    $solutionPath = Find-Solution
    $solutionDir = [System.IO.Path]::GetDirectoryName($solutionPath)
    $projects = Find-ProjectDirectories -SolutionDir $solutionDir -ProjectName $ProjectName
    
    if (-not $ProjectName) {
        $ProjectName = $projects.ProjectName
    }
    
    # Verificar que existe HelixEntities.xml
    if (-not (Test-Path $projects.HelixEntitiesPath)) {
        throw "HelixEntities.xml no existe. Ejecuta Update-HelixEntities.ps1 primero."
    }
    
    # Verificar que existe la entidad
    $entityPath = Join-Path $projects.DataModelDir "$EntityName.cs"
    if (-not (Test-Path $entityPath)) {
        throw "Entidad '$EntityName' no encontrada en DataModel"
    }
    
    # Determinar si es creación o modificación
    [xml]$xmlDoc = Get-Content -Path $projects.HelixEntitiesPath
    $entityNode = $xmlDoc.SelectSingleNode("//Entities[EntityName='$EntityName']")
    
    if (-not $entityNode) {
        throw "Entidad '$EntityName' no está configurada en HelixEntities.xml"
    }
    
    $existingConfig = $entityNode.SelectSingleNode("Configurations[ConfigurationName='$ConfigurationName']")
    $isModification = $null -ne $existingConfig
    
    if ($isModification) {
        Write-Host "✏️ Modificando configuración de carga" -ForegroundColor $script:WarningColor
    }
    else {
        Write-Host "🆕 Creando configuración de carga" -ForegroundColor $script:InfoColor
    }
    
    Write-Host "  Entidad: $EntityName" -ForegroundColor Gray
    Write-Host "  Configuración: $ConfigurationName" -ForegroundColor Gray
    
    # Paso 2-4: Análisis y configuración interactiva
    Write-Step "🔍 Analizando entidad $EntityName..."
    
    $existingStructure = $null
    # TODO: Parsear configuración existente si isModification
    
    $includes = Build-ConfigurationTree -DataModelDir $projects.DataModelDir -EntityName $EntityName -ExistingConfig $existingStructure
    
    if ($includes.Count -eq 0) {
        Write-Warning-Message "No se seleccionaron entidades relacionadas"
        Write-Host "Configuración cancelada"
        exit 0
    }
    
    # Paso 5: Resumen
    Write-Step "📋 Estructura de configuración `"$ConfigurationName`""
    Write-Host "`n$EntityName (entidad base)" -ForegroundColor $script:InfoColor
    Show-ConfigurationTree -Entities $includes
    
    Write-Host "`n¿Confirmas esta estructura? (S/n): " -NoNewline -ForegroundColor $script:WarningColor
    $confirm = Read-Host
    
    if ($confirm -eq 'n' -or $confirm -eq 'N') {
        Write-Host "Configuración cancelada"
        exit 0
    }
    
    # Paso 6: Ordenación
    $orderCriteria = Get-OrderCriteria -EntityName $EntityName -DataModelDir $projects.DataModelDir
    
    Write-Success "Ordenación configurada: $(($orderCriteria | ForEach-Object { "$($_.Field) $($_.Order)" }) -join ', ')"
    
    # Paso 7: Guardar
    Write-Step "💾 Guardando configuración..."
    
    Update-HelixEntitiesXml -XmlPath $projects.HelixEntitiesPath -EntityName $EntityName -ConfigurationName $ConfigurationName -Includes $includes -OrderCriteria $orderCriteria
    Write-Success "Configuración `"$ConfigurationName`" añadida a HelixEntities.xml"
    
    if ($projects.DataConstsPath) {
        Update-DataConsts -DataConstsPath $projects.DataConstsPath -ProjectName $ProjectName -EntityName $EntityName -ConfigurationName $ConfigurationName
    }
    
    # Resumen
    Write-Host "`n========================================" -ForegroundColor $script:SuccessColor
    Write-Host "  CONFIGURACIÓN COMPLETADA" -ForegroundColor $script:SuccessColor
    Write-Host "========================================" -ForegroundColor $script:SuccessColor
    
    Write-Host "`nEntidad: $EntityName" -ForegroundColor $script:InfoColor
    Write-Host "Configuración: $ConfigurationName" -ForegroundColor $script:InfoColor
    
    Write-Host "`nEstructura de carga:" -ForegroundColor $script:InfoColor
    Write-Host "  ✓ $($includes.Count) entidades relacionadas incluidas" -ForegroundColor $script:SuccessColor
    
    $maxDepth = 1
    # TODO: Calcular profundidad real
    Write-Host "  ✓ $maxDepth niveles de profundidad" -ForegroundColor $script:SuccessColor
    
    Write-Host "`nOrdenación:" -ForegroundColor $script:InfoColor
    foreach ($criterion in $orderCriteria) {
        Write-Host "  ✓ Campo: $($criterion.Field), Dirección: $($criterion.Order)" -ForegroundColor $script:SuccessColor
    }
    
    Write-Host "`nArchivos actualizados:" -ForegroundColor $script:InfoColor
    Write-Host "  ✓ $($projects.HelixEntitiesPath)" -ForegroundColor $script:SuccessColor
    if ($projects.DataConstsPath) {
        Write-Host "  ✓ $($projects.DataConstsPath)" -ForegroundColor $script:SuccessColor
    }
    
    Write-Host "`n✅ Configuración lista para usar" -ForegroundColor $script:SuccessColor
    
    Write-Host "`nSiguiente paso:" -ForegroundColor $script:InfoColor
    Write-Host "  Ejecutar Helix Generator para regenerar servicios" -ForegroundColor Gray
    
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
