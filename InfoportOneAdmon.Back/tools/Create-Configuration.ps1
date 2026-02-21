<#
.SYNOPSIS
    Crea una nueva configuración de carga de forma interactiva.

.DESCRIPTION
    Este script crea una nueva configuración de carga mostrando el árbol de entidades
    relacionadas hasta el nivel especificado y permitiendo seleccionar qué incluir.

.PARAMETER EntityName
    Nombre de la entidad del DataModel (ej: Organization, Application).

.PARAMETER ConfigurationName
    Nombre para la nueva configuración (ej: OrganizationFull).

.PARAMETER Levels
    Número de niveles de profundidad a mostrar (1-5).

.EXAMPLE
    .\Create-Configuration.ps1 -EntityName "Organization" -ConfigurationName "OrganizationFull" -Levels 3
    Crea una nueva configuración mostrando hasta 3 niveles de profundidad.

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

# Función para verificar que la configuración NO existe
function Test-ConfigurationExists {
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
    
    return $null -ne $configuration
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
    
    # Regex para detectar navegación (tanto { get; set; } como { get; })
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

# Función para mostrar el árbol de entidades
function Show-EntityTree {
    param(
        [array]$Tree,
        [string]$ParentPrefix = ""
    )
    
    for ($i = 0; $i -lt $Tree.Count; $i++) {
        $node = $Tree[$i]
        $isLast = $i -eq ($Tree.Count - 1)
        
        $branch = if ($isLast) { "└─" } else { "├─" }
        $extension = if ($isLast) { "  " } else { "│ " }
        
        $typeInfo = if ($node.IsCollection) { "(colección, 1:N)" } else { "(navegación singular)" }
        
        Write-Host "$ParentPrefix$branch " -NoNewline
        Write-Host "($($node.Number)) " -NoNewline -ForegroundColor $ColorInfo
        Write-Host $node.EntityType -NoNewline
        Write-Host " $typeInfo" -ForegroundColor $ColorInfo
        
        if ($node.Children.Count -gt 0) {
            Show-EntityTree -Tree $node.Children -ParentPrefix "$ParentPrefix$extension  "
        }
    }
}

# Función para obtener selecciones del usuario
function Get-UserSelections {
    param([array]$Tree)
    
    Write-Host "`nSelecciona las entidades a incluir indicando el número y modo:" -ForegroundColor $ColorTitle
    Write-Host "  L = Lectura (ReadOnly:true)" -ForegroundColor $ColorLectura
    Write-Host "  E = Escritura (ReadOnly:false)" -ForegroundColor $ColorEscritura
    Write-Host "  [vacío] = No incluir" -ForegroundColor $ColorInfo
    Write-Host ""
    Write-Host "Formato: número + modo (ej: 1 L, 1.1 E, 2.1.1 L)" -ForegroundColor $ColorInfo
    Write-Host "Ingresa las selecciones (una por línea, Enter vacío para finalizar):" -ForegroundColor $ColorInfo
    Write-Host ""
    
    $selections = @{}
    
    while ($true) {
        $input = Read-Host ">"
        
        if ([string]::IsNullOrWhiteSpace($input)) {
            break
        }
        
        # Parsear input: "1 L", "1.1 L", "1.1.1 E" (números jerárquicos)
        if ($input -match '([\d\.]+)\s*([LE])') {
            $number = $matches[1]
            $mode = $matches[2].ToUpper()
            $readOnly = $mode -eq "L"
            
            $selections[$number] = $readOnly
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
            $readOnly = $Selections[$number]
            
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

# Función para aplicar configuración al XML
function Add-ConfigurationToXml {
    param(
        [xml]$Xml,
        [string]$EntityName,
        [string]$ConfigurationName,
        [array]$Includes,
        [string]$OrderField,
        [string]$OrderDirection
    )
    
    $entity = $Xml.HelixEntities.Entities | Where-Object { $_.EntityName -eq $EntityName } | Select-Object -First 1
    
    # Crear nuevo nodo Configurations
    $configNode = $Xml.CreateElement("Configurations")
    
    # ConfigurationName
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

# Función para sincronizar Consts
function Update-Consts {
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

    # Convertir PascalCase a UPPER_CASE
    $constName = $ConfigurationName -creplace '([a-z])([A-Z])', '$1_$2'
    $constName = $constName.ToUpper()

    if (Test-Path $constsFilePath) {
        $content = Get-Content $constsFilePath -Raw
        
        # Buscar struct de la entidad
        $structPattern = "public struct $EntityName\s*\{[^}]*\}"
        
        if ($content -match $structPattern) {
            # Ya existe el struct, añadir constante
            $replacement = $matches[0] -replace '(\})$', "`n            public const string $constName = `"$ConfigurationName`";`n        `$1"
            $content = $content -replace [regex]::Escape($matches[0]), $replacement
        } else {
            # No existe el struct, crearlo dentro de LoadingConfigurations
            $loadingPattern = "public struct LoadingConfigurations\s*\{" 
            
            $newStruct = @"
            public struct $EntityName
            {
                public const string $constName = "$ConfigurationName";
            }
"@
            
            $content = $content -replace $loadingPattern, "`$0`n$newStruct"
        }
        
        Set-Content -Path $constsFilePath -Value $content -Encoding UTF8 -NoNewline
    }
}

# Script principal
try {
    Write-Host "═══════════════════════════════════════" -ForegroundColor $ColorTitle
    Write-Host "  CREATE CONFIGURATION" -ForegroundColor $ColorTitle
    Write-Host "═══════════════════════════════════════" -ForegroundColor $ColorTitle
    Write-Host ""
    
    # Detectar proyecto
    $project = Get-ProjectInfo
    Write-Host "📁 Proyecto: " -NoNewline
    Write-Host $project.Name -ForegroundColor $ColorSuccess
    Write-Host ""
    
    # Cargar XML
    $xml = Get-HelixEntitiesXml -ApiPath $project.ApiPath
    
    # Verificar que NO existe
    if (Test-ConfigurationExists -Xml $xml -EntityName $EntityName -ConfigurationName $ConfigurationName) {
        Write-Host "❌ La configuración '$ConfigurationName' ya existe para '$EntityName'" -ForegroundColor $ColorError
        Write-Host "   Usa /UpdateConfiguration para modificarla" -ForegroundColor $ColorInfo
        exit 1
    }
    
    Write-Host $EntityName -ForegroundColor $ColorTitle
    Write-Host ("-" * 23) -ForegroundColor $ColorTitle
    Write-Host ""
    
    Write-Host "Configuración: " -NoNewline
    Write-Host "$ConfigurationName (nueva)" -ForegroundColor $ColorSuccess
    Write-Host ""
    
    # Construir árbol de entidades
    Write-Host "🔍 Analizando entidades relacionadas hasta nivel $Levels..." -ForegroundColor $ColorInfo
    $tree = Build-EntityTree -DataModelPath $project.DataModelPath -EntityName $EntityName -CurrentLevel 1 -MaxLevels $Levels
    
    if ($tree.Count -eq 0) {
        Write-Host "⚠️  No se encontraron entidades relacionadas" -ForegroundColor $ColorWarning
        exit 0
    }
    
    Write-Host "`n$EntityName"
    Show-EntityTree -Tree $tree
    
    # Obtener selecciones del usuario
    $selections = Get-UserSelections -Tree $tree
    
    if ($selections.Count -eq 0) {
        Write-Host "⚠️  No se seleccionaron entidades. Operación cancelada." -ForegroundColor $ColorWarning
        exit 0
    }
    
    # Construir estructura
    $includes = Build-ConfigurationXml -Tree $tree -Selections $selections
    
    # Mostrar estructura propuesta
    Write-Host "`n" + ("=" * 40) -ForegroundColor $ColorTitle
    Write-Host "Estructura propuesta:" -ForegroundColor $ColorTitle
    Write-Host ("=" * 40) -ForegroundColor $ColorTitle
    Write-Host ""
    Show-ProposedStructure -EntityName $EntityName -Includes $includes
    Write-Host ""
    
    # Confirmar
    $confirm = Read-Host "¿Confirmas esta configuración? (S/n)"
    if ($confirm -eq "n" -or $confirm -eq "N") {
        Write-Host "❌ Operación cancelada" -ForegroundColor $ColorWarning
        exit 0
    }
    
    # Criterio de ordenación
    Write-Host "`nCriterio de ordenación:" -ForegroundColor $ColorTitle
    Write-Host "Ingresa el campo de ordenación (Enter para Id ASC):" -ForegroundColor $ColorInfo
    $orderField = Read-Host "Campo"
    
    if ([string]::IsNullOrWhiteSpace($orderField)) {
        $orderField = "Id"
        $orderDirection = "Ascending"
    } else {
        # Detectar dirección
        if ($orderField -match '(.+)\s+(ASC|DESC)') {
            $orderField = $matches[1].Trim()
            $orderDirection = if ($matches[2] -eq "DESC") { "Descending" } else { "Ascending" }
        } else {
            $orderDirection = "Ascending"
        }
    }
    
    # Aplicar configuración
    Write-Host "`n💾 Creando configuración..." -ForegroundColor $ColorSuccess
    
    Add-ConfigurationToXml -Xml $xml -EntityName $EntityName -ConfigurationName $ConfigurationName -Includes $includes -OrderField $orderField -OrderDirection $orderDirection
    
    $xmlPath = Join-Path $project.ApiPath "HelixEntities.xml"
    $xml.Save($xmlPath)
    
    Write-Host "  ✓ Configuración `"$ConfigurationName`" añadida a HelixEntities.xml" -ForegroundColor $ColorSuccess
    
    # Sincronizar Consts
    Update-Consts -EntitiesPath $project.EntitiesPath -EntityName $EntityName -ConfigurationName $ConfigurationName
    Write-Host "  ✓ Constante sincronizada en Consts.cs" -ForegroundColor $ColorSuccess
    
    Write-Host "`n✅ Configuración creada exitosamente" -ForegroundColor $ColorSuccess
    Write-Host ""
    
} catch {
    Write-Host "`n❌ Error: $_" -ForegroundColor $ColorError
    Write-Host $_.ScriptStackTrace -ForegroundColor $ColorError
    exit 1
}
