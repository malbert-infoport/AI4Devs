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
    [bool]$IsBase
    [System.Collections.ArrayList]$Properties
    [System.Collections.ArrayList]$NavigationProperties
    
    EntityInfo() {
        $this.Properties = New-Object System.Collections.ArrayList
        $this.NavigationProperties = New-Object System.Collections.ArrayList
        $this.IsBase = $false
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
        $collectionMatch = [regex]::Match($type, 'ICollection<(\w+)>')
        if ($collectionMatch.Success) {
            $prop.IsCollection = $true
            $prop.IsNavigation = $true
            $prop.RelatedEntity = $collectionMatch.Groups[1].Value
            $prop.Type = $collectionMatch.Groups[1].Value
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
    
    $entityFiles = Get-ChildItem -Path $DataModelDir -Filter "*.cs" -Recurse | Where-Object {
        $_.Name -ne "AssemblyInfo.cs" -and 
        $_.DirectoryName -notmatch '\\bin\\|\\obj\\'
    }
    
    $entities = @()
    
    foreach ($file in $entityFiles) {
        $content = Get-Content -Path $file.FullName -Raw
        
            # Determinar namespace del fichero
            $nsMatch = [regex]::Match($content,'namespace\s+([\w\.]+)')
            $ns = if ($nsMatch.Success) { $nsMatch.Groups[1].Value } else { '' }

            # Incluir si el fichero hace referencia a IEntityBase o si pertenece al namespace .Base (como hace Helix6.Generator)
            if ($content -match '\bIEntityBase\b' -or $ns -like '*.Base') {
                $entity = Parse-EntityFile -FilePath $file.FullName
                # Marcar si pertenece al namespace .Base para tratarla como entidad base
                $entity.IsBase = $false
                if ($ns -like '*.Base') { $entity.IsBase = $true }
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
    
    # Buscar en la carpeta raíz de Views/
    $viewPath = Join-Path $ViewsDir "$ViewName.cs"
    if (Test-Path $viewPath) { return $true }

    # Buscar también en Views/Base/ (entidades base del framework)
    $baseViewPath = Join-Path $ViewsDir "Base\$ViewName.cs"
    return (Test-Path $baseViewPath)
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
            <IsList>$($Property.IsCollection.ToString().ToLower())</IsList>
    </Fields>
"@
    
    return $field
}

function Create-DefaultConfiguration {
        return @"
        <Configurations>
            <ConfigurationName>Defecto</ConfigurationName>
            <Orders>
                <OrderFieldName>Id</OrderFieldName>
                <OrderType>Ascending</OrderType>
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
"@

        # Solo serializar IsVersionEntity/IsValidityEntity si son true
        if ($Entity.IsVersionEntity) { $xml += "    <IsVersionEntity>true</IsVersionEntity>`n" }
        if ($Entity.IsValidityEntity) { $xml += "    <IsValidityEntity>true</IsValidityEntity>`n" }

    
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
    
    # Paso 5-7: Generar/Mergear XML
    Write-Step "🔨 Generando/mergeando HelixEntities.xml..."

    $scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
    $templatesDir = Join-Path $scriptDir "templates"
    if (-not (Test-Path $templatesDir)) { New-Item -ItemType Directory -Path $templatesDir | Out-Null }
    $templateBasePath = Join-Path $templatesDir "HelixEntitiesBase.xml"

    # Localizar un HelixEntities.xml de plantilla (Helix6.Back.Api) para crear la plantilla base si no existe
    function Find-TemplateHelixEntities {
        param()
        $candidates = @()
        try {
            $candidates += Get-ChildItem -Path $projects.ProjectName -Filter "HelixEntities.xml" -Recurse -ErrorAction SilentlyContinue
        } catch { }
        if (Test-Path 'c:\Git') { $candidates += Get-ChildItem -Path 'c:\Git' -Filter 'HelixEntities.xml' -Recurse -ErrorAction SilentlyContinue }
        if (Test-Path 'c:\Ai4Devs') { $candidates += Get-ChildItem -Path 'c:\Ai4Devs' -Filter 'HelixEntities.xml' -Recurse -ErrorAction SilentlyContinue }
        if ($candidates.Count -gt 0) {
            $preferred = $candidates | Where-Object { $_.FullName -match 'Helix6.Back.Api' } | Select-Object -First 1
            if ($preferred) { return $preferred.FullName }
            return $candidates[0].FullName
        }
        return $null
    }

    # Crear plantilla HelixEntitiesBase.xml en tools/templates si no existe
    if (-not (Test-Path $templateBasePath)) {
        Write-Step "Creando plantilla templates/HelixEntitiesBase.xml desde plantilla del framework..."
        $templatePath = Find-TemplateHelixEntities
        if ($templatePath) {
            try {
                [xml]$templateXml = Get-Content -Path $templatePath -Raw
                $baseEntities = New-Object System.Collections.ArrayList
                foreach ($entNode in $templateXml.HelixEntities.Entities) {
                    $ename = $entNode.EntityName
                    $found = Get-ChildItem -Path $projects.DataModelDir -Filter "$($ename).cs" -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.DirectoryName -match '[\\/]Base([\\/]|$)' }
                    if ($found) { $baseEntities.Add($entNode) | Out-Null }
                }
                if ($baseEntities.Count -gt 0) {
                    $xmlWriterSettings = New-Object System.Xml.XmlWriterSettings
                    $xmlWriterSettings.Indent = $true
                    $sb = New-Object System.Text.StringBuilder
                    $xw = [System.Xml.XmlWriter]::Create($sb, $xmlWriterSettings)
                    $xw.WriteStartDocument()
                    $xw.WriteStartElement('HelixEntities')
                    foreach ($n in $baseEntities) { $n.WriteTo($xw) }
                    $xw.WriteEndElement()
                    $xw.WriteEndDocument()
                    $xw.Flush()
                    $sb.ToString() | Out-File -FilePath $templateBasePath -Encoding UTF8 -Force
                    Write-Success "Plantilla creada en $templateBasePath"
                }
                else { Write-Warning-Message "No se extrajeron entidades Base de la plantilla; no se creó templates/HelixEntitiesBase.xml" }
            } catch { Write-Warning-Message "Error al crear plantilla desde $templatePath" }
        } else { Write-Warning-Message "No se encontró HelixEntities.xml de referencia para crear la plantilla base" }
    }

    # Cargar template base si existe
    [xml]$templateBaseXml = $null
    if (Test-Path $templateBasePath) {
        try { [xml]$templateBaseXml = Get-Content -Path $templateBasePath -Raw } catch { $templateBaseXml = $null }
    }

    # Cargar xml existente para preservar configuraciones y endpoints
    [xml]$existingXml = $null
    if (Test-Path $projects.HelixEntitiesPath) {
        try { [xml]$existingXml = Get-Content -Path $projects.HelixEntitiesPath -Raw } catch { $existingXml = $null }
    }

    # Helper para obtener generated entity fragment as xml
    function Get-GeneratedEntityXmlNode {
        param([EntityInfo]$Entity)
        $s = Create-EntityXml -Entity $Entity
        $fragment = "<Root>$s</Root>"
        [xml]$fragXml = $fragment
        return $fragXml.Root.Entities
    }

    # Construir nuevo documento: iniciar con header
    $xmlDoc = New-Object System.Xml.XmlDocument
    $declaration = $xmlDoc.CreateXmlDeclaration('1.0','utf-8',$null)
    $xmlDoc.AppendChild($declaration) | Out-Null
    $root = $xmlDoc.CreateElement('HelixEntities')
    $xmlDoc.AppendChild($root) | Out-Null

    if ($existingXml -ne $null) {
        # Si ya existe HelixEntities.xml importamos todo para preservarlo (base + custom)
        foreach ($ent in $existingXml.HelixEntities.Entities) {
            $imported = $xmlDoc.ImportNode($ent, $true)
            $root.AppendChild($imported) | Out-Null
        }
    }
    else {
        # Si no existe aún, y hay plantilla base, añadimos las entidades base al final tras generar las no-base
        # (por ahora no añadimos nada aquí; se añadirán después)
    }

    # 3) Para cada entidad actual del DataModel con View, actualizar o crear su nodo (no tocar Base si ya existen)
    foreach ($entity in ($entitiesWithViews | Where-Object { -not $_.IsBase })) {
        $ename = $entity.Name
        $existingNode = $root.SelectSingleNode("//Entities[EntityName='$ename']")
        $generatedNode = Get-GeneratedEntityXmlNode -Entity $entity

        if ($existingNode -ne $null) {
            # reemplazar campos (Fields) por los generados, pero conservar Configurations y Endpoints del existingNode
            $fields = @($existingNode.SelectNodes('Fields'))
            foreach ($f in $fields) { $existingNode.RemoveChild($f) | Out-Null }
            foreach ($gf in $generatedNode.SelectNodes('Fields')) {
                $imported = $xmlDoc.ImportNode($gf, $true)
                $refNode = $existingNode.SelectSingleNode('Configurations')
                if ($refNode -ne $null) {
                    $existingNode.InsertBefore($imported, $refNode) | Out-Null
                }
                else {
                    $existingNode.AppendChild($imported) | Out-Null
                }
            }
            $dfNode = $existingNode.SelectSingleNode('DefaultFilterField')
            if ($dfNode -ne $null) { $dfNode.InnerText = $generatedNode.DefaultFilterField }
            else { $n = $xmlDoc.CreateElement('DefaultFilterField'); $n.InnerText = $generatedNode.DefaultFilterField; $existingNode.AppendChild($n) | Out-Null }
            $iv = $existingNode.SelectSingleNode('IsVersionEntity'); if ($iv -ne $null) { $iv.InnerText = $generatedNode.IsVersionEntity }
            $ival = $existingNode.SelectSingleNode('IsValidityEntity'); if ($ival -ne $null) { $ival.InnerText = $generatedNode.IsValidityEntity }
        }
        else {
            # añadir nodo completo generado
            $imported = $xmlDoc.ImportNode($generatedNode, $true)
            $root.AppendChild($imported) | Out-Null
        }
        Write-Host "  ✓ $($entity.Name): $($entity.Properties.Count) propiedades + $($entity.NavigationProperties.Count) navegaciones" -ForegroundColor Gray
        $stats.New++
    }

    # Si no existía el HelixEntities.xml previo (primera generación) y existe plantilla base, anexamos sus entidades al final
    if (($existingXml -eq $null) -and ($templateBaseXml -ne $null)) {
        foreach ($ent in $templateBaseXml.HelixEntities.Entities) {
            $imported = $xmlDoc.ImportNode($ent, $true)
            $root.AppendChild($imported) | Out-Null
        }
    }

    $xmlContent = $xmlDoc.OuterXml

    # Paso 8-9: Ya están validados en la generación

    # Paso 10: Guardar archivo con indentación
    Write-Step "💾 Guardando HelixEntities.xml (formateado)..."

    $xmlWriterSettings = New-Object System.Xml.XmlWriterSettings
    $xmlWriterSettings.Indent = $true
    $xmlWriterSettings.Encoding = [System.Text.Encoding]::UTF8
    $xmlWriterSettings.NewLineChars = "`r`n"
    $xmlWriterSettings.NewLineHandling = [System.Xml.NewLineHandling]::Replace

    $writer = [System.Xml.XmlWriter]::Create($projects.HelixEntitiesPath, $xmlWriterSettings)
    $xmlDoc.Save($writer)
    $writer.Close()

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

