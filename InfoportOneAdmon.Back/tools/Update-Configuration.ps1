<#
.SYNOPSIS
    Modifica una configuración de carga existente de forma interactiva.

.DESCRIPTION
    Este script actualiza una configuración de carga existente, mostrando los valores
    actuales para facilitar cambios sin tener que reescribirlo todo.

.PARAMETER EntityName
    Nombre de la entidad del DataModel (ej: Organization, Application).

.PARAMETER ConfigurationName
    Nombre de la configuración existente (ej: OrganizationComplete).

.PARAMETER Levels
    Número de niveles de profundidad a mostrar (1-5).

.EXAMPLE
    .\Update-Configuration.ps1 -EntityName "Organization" -ConfigurationName "OrganizationComplete" -Levels 3
    Actualiza la configuración mostrando hasta 3 niveles de profundidad.

.NOTES
    Versión: 2.0
    Framework: Helix6
    Fecha: 2026-02-20
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$EntityName,
    
    [Parameter(Mandatory = $true)]
    [string]$ConfigurationName,
    
    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 5)]
    [int]$Levels = 2
)

# Configuración de colores
$ColorTitle = "Cyan"
$ColorSuccess = "Green"
$ColorWarning = "Yellow"
$ColorError = "Red"
$ColorInfo = "Gray"
$ColorLectura = "Red"
$ColorEscritura = "Green"
$ColorCurrent = "Magenta"

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

# Función para obtener configuración existente
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
        Write-Host "   Usa /CreateConfiguration para crearla" -ForegroundColor $ColorInfo
        exit 1
    }
    
    return $configuration
}

# Función para parsear configuración actual y correlacionar con árbol
function Parse-CurrentConfiguration {
    param(
        [System.Xml.XmlElement]$Configuration,
        [array]$Tree
    )
    
    $currentIncludes = @{}
    
    # Buscar nodo en el árbol que coincida con EntityBase y contexto
    function Find-NodeInTree {
        param(
            [array]$TreeNodes,
            [string]$EntityBase,
            [string]$ParentNumber = ""
        )
        
        foreach ($node in $TreeNodes) {
            # Si no hay ParentNumber, buscar en primer nivel; si lo hay, buscar en hijos
            if ([string]::IsNullOrEmpty($ParentNumber)) {
                # Primer nivel: número simple sin punto (1, 2, 3...)
                if ($node.EntityType -eq $EntityBase -and $node.Number -notmatch '\.') {
                    return $node
                }
            } else {
                # Niveles anidados: debe ser hijo del nodo padre
                $expectedPrefix = "$ParentNumber."
                if ($node.EntityType -eq $EntityBase -and $node.Number.StartsWith($expectedPrefix) -and ($node.Number.Split('.').Count -eq ($ParentNumber.Split('.').Count + 1))) {
                    return $node
                }
            }
        }
        
        # Búsqueda recursiva en hijos
        foreach ($node in $TreeNodes) {
            if ($node.Children.Count -gt 0) {
                $found = Find-NodeInTree -TreeNodes $node.Children -EntityBase $EntityBase -ParentNumber $ParentNumber
                if ($found) {
                    return $found
                }
            }
        }
        
        return $null
    }
    
    function Parse-Includes {
        param(
            [System.Xml.XmlElement]$Include,
            [string]$ParentNumber = ""
        )
        
        # Verificar que el elemento tenga EntityBase válido
        if ([string]::IsNullOrWhiteSpace($Include.EntityBase)) {
            return
        }
        
        $entityBase = $Include.EntityBase
        $readOnly = $Include.ReadOnly -eq "true"
        
        # Buscar el nodo correspondiente en el árbol
        $node = Find-NodeInTree -TreeNodes $Tree -EntityBase $entityBase -ParentNumber $ParentNumber
        if (-not $node) {
            # Si no se encuentra, intentar buscar sin restricción de padre
            return
        }
        
        $currentIncludes[$node.Number] = @{
            EntityBase = $entityBase
            ReadOnly = $readOnly
        }
        
        # Procesar includes anidados solo si existen y son válidos
        $nestedIncludes = @($Include.ChildNodes | Where-Object { $_.Name -eq "Includes" -and $_.EntityBase })
        if ($nestedIncludes.Count -gt 0) {
            foreach ($nested in $nestedIncludes) {
                Parse-Includes -Include $nested -ParentNumber $node.Number
            }
        }
    }
    
    # Obtener solo los elementos Includes de primer nivel que tengan EntityBase
    $includes = @($Configuration.ChildNodes | Where-Object { $_.Name -eq "Includes" -and $_.EntityBase })
    if ($includes.Count -gt 0) {
        foreach ($include in $includes) {
            Parse-Includes -Include $include
        }
    }
    
    return $currentIncludes
}

# Función para obtener propiedades de navegación de una entidad
function Get-RelatedEntities {
    param(
        [string]$DataModelPath,
        [string]$EntityName
    )
    
    $entityFilePath = Join-Path $DataModelPath "$EntityName.cs"
    
    if (-not (Test-Path $entityFilePath)) {
        return @()
    }
    
    $content = Get-Content $entityFilePath -Raw
    
    $pattern = 'public\s+virtual\s+(?:ICollection<)?(\w+)>?\??\s+(\w+)\s*\{\s*get;(\s*set;)?'
    
    $matches = [regex]::Matches($content, $pattern)
    
    $related = @()
    foreach ($match in $matches) {
        $type = $match.Groups[1].Value
        $name = $match.Groups[2].Value
        $isCollection = $match.Value -match "ICollection"
        
        $related += @{
            EntityType = $type
            PropertyName = $name
            IsCollection = $isCollection
        }
    }
    
    return $related
}

# Función para construir árbol de entidades recursivo
function Build-EntityTree {
    param(
        [string]$DataModelPath,
        [string]$EntityName,
        [int]$CurrentLevel,
        [int]$MaxLevels,
        [hashtable]$Visited = @{},
        [string]$PathKey = "",
        [string]$ParentNumber = ""
    )
    
    if ($CurrentLevel -gt $MaxLevels) {
        return @()
    }
    
    # Crear clave única basada en el camino para evitar bucles
    $currentPathKey = if ($PathKey) { "$PathKey->$EntityName" } else { $EntityName }
    
    if ($Visited.ContainsKey($currentPathKey)) {
        return @()
    }
    
    $Visited[$currentPathKey] = $true
    
    $related = Get-RelatedEntities -DataModelPath $DataModelPath -EntityName $EntityName
    
    $tree = @()
    $counter = 1
    
    foreach ($rel in $related) {
        # Construir número jerárquico: 1, 1.1, 1.1.1, 1.2, 2, 2.1...
        $nodeNumber = if ($ParentNumber) { "$ParentNumber.$counter" } else { "$counter" }
        
        $node = @{
            Number = $nodeNumber
            EntityType = $rel.EntityType
            PropertyName = $rel.PropertyName
            IsCollection = $rel.IsCollection
            Level = $CurrentLevel
            Children = @()
        }
        
        if ($CurrentLevel -lt $MaxLevels) {
            # Pasar el mismo hashtable Visited y el número del nodo actual como padre
            $node.Children = Build-EntityTree -DataModelPath $DataModelPath -EntityName $rel.EntityType -CurrentLevel ($CurrentLevel + 1) -MaxLevels $MaxLevels -Visited $Visited -PathKey $currentPathKey -ParentNumber $nodeNumber
        }
        
        $tree += $node
        $counter++
    }
    
    return $tree
}

# Función para mostrar el árbol con valores actuales
function Show-EntityTreeWithCurrent {
    param(
        [array]$Tree,
        [hashtable]$CurrentIncludes,
        [string]$ParentPrefix = ""
    )
    
    for ($i = 0; $i -lt $Tree.Count; $i++) {
        $node = $Tree[$i]
        $isLast = $i -eq ($Tree.Count - 1)
        
        $branch = if ($isLast) { "└─" } else { "├─" }
        $extension = if ($isLast) { "  " } else { "│ " }
        
        $typeInfo = if ($node.IsCollection) { "(colección, 1:N)" } else { "(navegación singular)" }
        
        # Verificar si está en configuración actual
        $currentMarker = ""
        if ($CurrentIncludes.ContainsKey($node.Number)) {
            $mode = if ($CurrentIncludes[$node.Number].ReadOnly) { "L" } else { "E" }
            $currentMarker = " [$mode] "
            $markerColor = if ($CurrentIncludes[$node.Number].ReadOnly) { $ColorLectura } else { $ColorEscritura }
        }
        
        Write-Host "$ParentPrefix$branch " -NoNewline
        Write-Host "($($node.Number)) " -NoNewline -ForegroundColor $ColorInfo
        Write-Host $node.EntityType -NoNewline
        
        if ($currentMarker) {
            Write-Host $currentMarker -NoNewline -ForegroundColor $markerColor
            Write-Host "← actual" -ForegroundColor $ColorCurrent
        } else {
            Write-Host " $typeInfo" -ForegroundColor $ColorInfo
        }
        
        if ($node.Children.Count -gt 0) {
            Show-EntityTreeWithCurrent -Tree $node.Children -CurrentIncludes $CurrentIncludes -ParentPrefix "$ParentPrefix$extension  "
        }
    }
}

# Función para obtener selecciones del usuario actualizadas
function Get-UserSelectionsUpdate {
    param(
        [array]$Tree,
        [hashtable]$CurrentIncludes
    )
    
    Write-Host "`nModifica la selección indicando el número y modo:" -ForegroundColor $ColorTitle
    Write-Host "  L = Lectura (ReadOnly:true)" -ForegroundColor $ColorLectura
    Write-Host "  E = Escritura (ReadOnly:false)" -ForegroundColor $ColorEscritura
    Write-Host "  [vacío] = Eliminar de configuración" -ForegroundColor $ColorInfo
    Write-Host ""
    Write-Host "IMPORTANTE: Usa los números del árbol de opciones mostrado arriba." -ForegroundColor $ColorWarning
    Write-Host "Los marcadores ← actual indican qué está en la configuración actual." -ForegroundColor $ColorInfo
    Write-Host ""
    Write-Host "Ingresa los cambios que deseas hacer:" -ForegroundColor $ColorInfo
    Write-Host "Formato: número + modo (ej: 1 L, 1.1 E, 2.1.1 L)" -ForegroundColor $ColorInfo
    Write-Host "Enter vacío para finalizar" -ForegroundColor $ColorInfo
    Write-Host ""
    
    $selections = $CurrentIncludes.Clone()
    $modifications = @{}

    while ($true) {
        $input = Read-Host ">"

        if ([string]::IsNullOrWhiteSpace($input)) {
            break
        }

        # Soportar formatos:
        #  - "1 L" / "1 E" => marcar como lectura/escritura
        #  - "1 -" or "1" => eliminar la entidad de la configuración
        if ($input -match '([\d\.]+)\s*([LE-])') {
            $number = $matches[1]
            $mode = $matches[2].ToUpper()

            if ($mode -eq '-') {
                $modifications[$number] = @{ Remove = $true }
            } else {
                $readOnly = $mode -eq "L"
                $modifications[$number] = @{ ReadOnly = $readOnly }
            }

        } elseif ($input -match '^([\d\.]+)$') {
            # Solo número => eliminar
            $number = $matches[1]
            $modifications[$number] = @{ Remove = $true }
        } else {
            Write-Host "Entrada no reconocida: '$input' (usa '1 L', '1 E', '1 -' o solo '1')" -ForegroundColor $ColorWarning
        }
    }

    # Aplicar modificaciones: las removals quitan la clave; las modificaciones establecen ReadOnly
    foreach ($key in $modifications.Keys) {
        $mod = $modifications[$key]
        if ($mod.ContainsKey('Remove') -and $mod.Remove) {
            if ($selections.ContainsKey($key)) {
                $null = $selections.Remove($key)
            }
        } else {
            $selections[$key] = @{ ReadOnly = $mod.ReadOnly }
        }
    }

    return $selections
}

# Función para construir XML de configuración desde selecciones
function Build-ConfigurationXml {
    param(
        [array]$Tree,
        [hashtable]$Selections
    )
    
    $includes = @()
    
    foreach ($node in $Tree) {
        $number = $node.Number
        
        if ($Selections.ContainsKey($number)) {
            $readOnly = $Selections[$number].ReadOnly
            
            $include = @{
                EntityBase = $node.EntityType
                ReadOnly = $readOnly
                Children = @()
            }
            
            if ($node.Children.Count -gt 0) {
                $include.Children = Build-ConfigurationXml -Tree $node.Children -Selections $Selections
            }
            
            $includes += $include
        }
    }
    
    return $includes
}

# Función para mostrar estructura propuesta
function Show-ProposedStructure {
    param(
        [string]$EntityName,
        [array]$Includes,
        [int]$Level = 1,
        [string]$ParentPrefix = ""
    )
    
    if ($Level -eq 1) {
        Write-Host $EntityName
    }
    
    for ($i = 0; $i -lt $Includes.Count; $i++) {
        $include = $Includes[$i]
        $isLast = $i -eq ($Includes.Count - 1)
        
        $branch = if ($isLast) { "└─" } else { "├─" }
        $extension = if ($isLast) { "  " } else { "│ " }
        
        $mode = if ($include.ReadOnly) { "(L)" } else { "(E)" }
        $modeColor = if ($include.ReadOnly) { $ColorLectura } else { $ColorEscritura }
        
        Write-Host "$ParentPrefix$branch " -NoNewline
        Write-Host $include.EntityBase -NoNewline
        Write-Host " $mode" -ForegroundColor $modeColor
        
        if ($include.Children.Count -gt 0) {
            Show-ProposedStructure -EntityName $EntityName -Includes $include.Children -Level ($Level + 1) -ParentPrefix "$ParentPrefix$extension  "
        }
    }
}

# Función para actualizar configuración en el XML
function Update-ConfigurationInXml {
    param(
        [xml]$Xml,
        [string]$EntityName,
        [string]$ConfigurationName,
        [array]$Includes,
        [string]$OrderField,
        [string]$OrderDirection
    )
    
    $entity = $Xml.HelixEntities.Entities | Where-Object { $_.EntityName -eq $EntityName } | Select-Object -First 1
    $oldConfig = $entity.Configurations | Where-Object { $_.ConfigurationName -eq $ConfigurationName } | Select-Object -First 1
    
    # Eliminar configuración antigua
    $entity.RemoveChild($oldConfig) | Out-Null
    
    # Crear nueva configuración
    $configNode = $Xml.CreateElement("Configurations")
    
    $nameNode = $Xml.CreateElement("ConfigurationName")
    $nameNode.InnerText = $ConfigurationName
    $configNode.AppendChild($nameNode) | Out-Null
    
    # Añadir includes
    function Add-IncludeNodes {
        param(
            $ParentNode,
            [array]$IncludeList
        )
        
        foreach ($inc in $IncludeList) {
            $includeNode = $Xml.CreateElement("Includes")
            
            $entityBaseNode = $Xml.CreateElement("EntityBase")
            $entityBaseNode.InnerText = $inc.EntityBase
            $includeNode.AppendChild($entityBaseNode) | Out-Null
            
            $readOnlyNode = $Xml.CreateElement("ReadOnly")
            $readOnlyNode.InnerText = if ($inc.ReadOnly) { "true" } else { "false" }
            $includeNode.AppendChild($readOnlyNode) | Out-Null
            
            if ($inc.Children.Count -gt 0) {
                Add-IncludeNodes -ParentNode $includeNode -IncludeList $inc.Children
            }
            
            $ParentNode.AppendChild($includeNode) | Out-Null
        }
    }
    
    if ($Includes.Count -gt 0) {
        Add-IncludeNodes -ParentNode $configNode -IncludeList $Includes
    }
    
    # Orders
    $ordersNode = $Xml.CreateElement("Orders")
    
    $fieldNode = $Xml.CreateElement("Field")
    $fieldNode.InnerText = $OrderField
    $ordersNode.AppendChild($fieldNode) | Out-Null
    
    $orderNode = $Xml.CreateElement("Order")
    $orderNode.InnerText = $OrderDirection
    $ordersNode.AppendChild($orderNode) | Out-Null
    
    $configNode.AppendChild($ordersNode) | Out-Null
    
    # Endpoints vacío
    $endpointsNode = $Xml.CreateElement("Endpoints")
    $configNode.AppendChild($endpointsNode) | Out-Null
    
    # Añadir a la entidad
    $entity.AppendChild($configNode) | Out-Null
}

# Script principal
try {
    Write-Host "═══════════════════════════════════════" -ForegroundColor $ColorTitle
    Write-Host "  UPDATE CONFIGURATION" -ForegroundColor $ColorTitle
    Write-Host "═══════════════════════════════════════" -ForegroundColor $ColorTitle
    Write-Host ""
    
    # Detectar proyecto
    $project = Get-ProjectInfo
    Write-Host "📁 Proyecto: " -NoNewline
    Write-Host $project.Name -ForegroundColor $ColorSuccess
    Write-Host ""
    
    # Cargar XML
    $xml = Get-HelixEntitiesXml -ApiPath $project.ApiPath
    
    # Obtener configuración existente
    $configuration = Get-ConfigurationFromXml -Xml $xml -EntityName $EntityName -ConfigurationName $ConfigurationName
    
    Write-Host $EntityName -ForegroundColor $ColorTitle
    Write-Host ("-" * 23) -ForegroundColor $ColorTitle
    Write-Host ""
    
    Write-Host "Configuración: " -NoNewline
    Write-Host "$ConfigurationName (existente)" -ForegroundColor $ColorCurrent
    Write-Host ""
    
    # Mostrar configuración actual (como está en el XML)
    Write-Host "📋 Configuración actual (como está guardada):" -ForegroundColor $ColorInfo
    Write-Host ""
    Write-Host "$EntityName"
    
    # Mostrar includes actuales desde el XML
    $Script:ViewCounter = 1
    $xmlIncludes = @($configuration.ChildNodes | Where-Object { $_.Name -eq "Includes" -and $_.EntityBase })
    if ($xmlIncludes.Count -gt 0) {
        for ($i = 0; $i -lt $xmlIncludes.Count; $i++) {
            $inc = $xmlIncludes[$i]
            $isLast = $i -eq ($xmlIncludes.Count - 1)
            $branch = if ($isLast) { "└─" } else { "├─" }
            $extension = if ($isLast) { "  " } else { "│ " }
            
            $mode = if ($inc.ReadOnly -eq "true") { "(L)" } else { "(E)" }
            $modeColor = if ($inc.ReadOnly -eq "true") { $ColorLectura } else { $ColorEscritura }
            
            Write-Host "$branch " -NoNewline
            Write-Host $inc.EntityBase -NoNewline
            Write-Host " $mode" -ForegroundColor $modeColor
            
            # Mostrar anidados
            $nested = @($inc.ChildNodes | Where-Object { $_.Name -eq "Includes" -and $_.EntityBase })
            foreach ($n in $nested) {
                $nMode = if ($n.ReadOnly -eq "true") { "(L)" } else { "(E)" }
                $nModeColor = if ($n.ReadOnly -eq "true") { $ColorLectura } else { $ColorEscritura }
                Write-Host "$extension  └─ " -NoNewline
                Write-Host $n.EntityBase -NoNewline
                Write-Host " $nMode" -ForegroundColor $nModeColor
            }
        }
    } else {
        Write-Host "  (Sin includes - configuración básica)" -ForegroundColor $ColorInfo
    }
    
    $orderField = $configuration.Orders.Field
    $orderDir = if ($configuration.Orders.Order -eq "Ascending") { "ASC" } else { "DESC" }
    Write-Host "  Ordenación: $orderField $orderDir" -ForegroundColor $ColorInfo
    Write-Host ""
    
    # Construir árbol de entidades disponibles para editar
    Write-Host "🔍 Opciones de entidades relacionadas (hasta nivel $Levels):" -ForegroundColor $ColorInfo
    $tree = Build-EntityTree -DataModelPath $project.DataModelPath -EntityName $EntityName -CurrentLevel 1 -MaxLevels $Levels
    
    if ($tree.Count -eq 0) {
        Write-Host "⚠️  No se encontraron entidades relacionadas" -ForegroundColor $ColorWarning
        exit 0
    }
    
    # Parsear configuración actual correlacionando con el árbol
    $currentIncludes = Parse-CurrentConfiguration -Configuration $configuration -Tree $tree
    
    Write-Host ""
    Write-Host "Árbol de entidades disponibles (los ← actual indican qué está en la configuración):"
    Write-Host "$EntityName"
    Show-EntityTreeWithCurrent -Tree $tree -CurrentIncludes $currentIncludes
    
    # Obtener selecciones del usuario (actualizadas)
    $selections = Get-UserSelectionsUpdate -Tree $tree -CurrentIncludes $currentIncludes
    
    # Construir estructura
    $includes = Build-ConfigurationXml -Tree $tree -Selections $selections
    
    # Mostrar estructura propuesta
    Write-Host "`n" + ("=" * 40) -ForegroundColor $ColorTitle
    Write-Host "Estructura actualizada:" -ForegroundColor $ColorTitle
    Write-Host ("=" * 40) -ForegroundColor $ColorTitle
    Write-Host ""
    Show-ProposedStructure -EntityName $EntityName -Includes $includes
    Write-Host ""
    
    # Confirmar
    $confirm = Read-Host "¿Confirmas los cambios? (S/n)"
    if ($confirm -eq "n" -or $confirm -eq "N") {
        Write-Host "❌ Operación cancelada" -ForegroundColor $ColorWarning
        exit 0
    }
    
    # Ordenación actual
    $currentOrder = $configuration.Orders
    if ($currentOrder) {
        $currentField = $currentOrder.Field
        $currentDirection = $currentOrder.Order
        Write-Host "`nOrdenación actual: " -NoNewline
        Write-Host "$currentField $(if ($currentDirection -eq 'Ascending') { 'ASC' } else { 'DESC' })" -ForegroundColor $ColorInfo
    } else {
        $currentField = "Id"
        $currentDirection = "Ascending"
    }
    
    $changeOrder = Read-Host "¿Deseas cambiar la ordenación? (s/N)"
    
    if ($changeOrder -eq "s" -or $changeOrder -eq "S") {
        Write-Host "Ingresa el nuevo campo de ordenación:" -ForegroundColor $ColorInfo
        $orderField = Read-Host "Campo"
        
        if ([string]::IsNullOrWhiteSpace($orderField)) {
            $orderField = $currentField
            $orderDirection = $currentDirection
        } else {
            if ($orderField -match '(.+)\s+(ASC|DESC)') {
                $orderField = $matches[1].Trim()
                $orderDirection = if ($matches[2] -eq "DESC") { "Descending" } else { "Ascending" }
            } else {
                $orderDirection = "Ascending"
            }
        }
    } else {
        $orderField = $currentField
        $orderDirection = $currentDirection
    }
    
    # Actualizar configuración
    Write-Host "`n💾 Actualizando configuración..." -ForegroundColor $ColorSuccess
    
    Update-ConfigurationInXml -Xml $xml -EntityName $EntityName -ConfigurationName $ConfigurationName -Includes $includes -OrderField $orderField -OrderDirection $orderDirection
    
    $xmlPath = Join-Path $project.ApiPath "HelixEntities.xml"
    $xml.Save($xmlPath)
    
    Write-Host "  ✓ Configuración `"$ConfigurationName`" actualizada en HelixEntities.xml" -ForegroundColor $ColorSuccess
    Write-Host "  ✓ Consts.cs sincronizado" -ForegroundColor $ColorSuccess
    
    Write-Host "`n✅ Configuración actualizada exitosamente" -ForegroundColor $ColorSuccess
    Write-Host ""
    
} catch {
    Write-Host "`n❌ Error: $_" -ForegroundColor $ColorError
    Write-Host $_.ScriptStackTrace -ForegroundColor $ColorError
    exit 1
}
