<#
.SYNOPSIS
    Actualiza o crea Views y Metadata en Back.Entities desde Back.DataModel

.DESCRIPTION
    Script automatizado para sincronizar las vistas (Views) y sus clases Metadata
    en el proyecto Back.Entities a partir de las entidades del proyecto Back.DataModel.
    Parte del framework Helix6.

.PARAMETER SolutionPath
    Ruta al archivo .sln del proyecto backend (opcional, se detecta automáticamente)

.PARAMETER ProjectName
    Nombre del proyecto sin sufijos (ej: "InfoportOneAdmon")

.PARAMETER Force
    Sobrescribe vistas existentes sin preguntar

.EXAMPLE
    .\Update-Views.ps1
    Ejecución con detección automática

.EXAMPLE
    .\Update-Views.ps1 -ProjectName "InfoportOneAdmon" -Force
    Forzar regeneración de todas las vistas

.NOTES
    Framework: Helix6 v1.0
    Autor: Equipo Helix6
    Fecha: 2026-02-17
#>

param(
    [string]$SolutionPath,
    [string]$ProjectName,
    [switch]$Force
)

# Colores para output
$script:SuccessColor = "Green"
$script:InfoColor = "Cyan"
$script:WarningColor = "Yellow"
$script:ErrorColor = "Red"

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
    Write-Step "Buscando archivo de solución..."
    
    if ($SolutionPath -and (Test-Path $SolutionPath)) {
        Write-Success "Solución encontrada: $SolutionPath"
        return $SolutionPath
    }
    
    $solutionFiles = Get-ChildItem -Path "." -Filter "*.sln" -Recurse | Where-Object {
        $_.DirectoryName -notmatch '\\node_modules\\|\\bin\\|\\obj\\'
    }
    
    if ($solutionFiles.Count -eq 0) {
        throw "No se encontró ningún archivo de solución (.sln)"
    }
    
    if ($solutionFiles.Count -eq 1) {
        Write-Success "Solución encontrada: $($solutionFiles[0].FullName)"
        return $solutionFiles[0].FullName
    }
    
    # Si hay múltiples, buscar la que contenga "Back"
    $backSolution = $solutionFiles | Where-Object { $_.Name -match 'Back' } | Select-Object -First 1
    if ($backSolution) {
        Write-Success "Solución encontrada: $($backSolution.FullName)"
        return $backSolution.FullName
    }
    
    Write-Success "Solución encontrada: $($solutionFiles[0].FullName)"
    return $solutionFiles[0].FullName
}

function Find-DataModelProject {
    param([string]$SolutionDir, [string]$ProjectName)
    
    Write-Step "Localizando proyecto Back.DataModel..."
    
    $pattern = if ($ProjectName) { "$ProjectName.Back.DataModel" } else { "*.Back.DataModel" }
    $projects = Get-ChildItem -Path $SolutionDir -Filter "$pattern.csproj" -Recurse | Where-Object {
        $_.DirectoryName -notmatch '\\bin\\|\\obj\\'
    }
    
    if ($projects.Count -eq 0) {
        throw "No se encontró el proyecto Back.DataModel"
    }
    
    $project = $projects[0]
    $projectName = $project.BaseName -replace '\.Back\.DataModel$', ''
    
    Write-Success "Proyecto DataModel: $($project.BaseName)"
    Write-Host "  Ruta: $($project.FullName)" -ForegroundColor Gray
    
    return @{
        ProjectName = $projectName
        ProjectPath = $project.FullName
        ProjectDir = $project.DirectoryName
    }
}

function Find-EntitiesProject {
    param([string]$SolutionDir, [string]$ProjectName)
    
    Write-Step "Localizando proyecto Back.Entities..."
    
    $pattern = "$ProjectName.Back.Entities"
    $projects = Get-ChildItem -Path $SolutionDir -Filter "$pattern.csproj" -Recurse | Where-Object {
        $_.DirectoryName -notmatch '\\bin\\|\\obj\\'
    }
    
    if ($projects.Count -eq 0) {
        throw "No se encontró el proyecto Back.Entities"
    }
    
    $project = $projects[0]
    
    Write-Success "Proyecto Entities: $($project.BaseName)"
    Write-Host "  Ruta: $($project.FullName)" -ForegroundColor Gray
    
    # Verificar carpetas necesarias
    $viewsDir = Join-Path $project.DirectoryName "Views"
    $metadataDir = Join-Path $viewsDir "Metadata"
    
    if (-not (Test-Path $viewsDir)) {
        New-Item -Path $viewsDir -ItemType Directory -Force | Out-Null
        Write-Host "  ✓ Carpeta Views creada" -ForegroundColor Gray
    }
    
    if (-not (Test-Path $metadataDir)) {
        New-Item -Path $metadataDir -ItemType Directory -Force | Out-Null
        Write-Host "  ✓ Carpeta Metadata creada" -ForegroundColor Gray
    }
    
    return @{
        ProjectPath = $project.FullName
        ProjectDir = $project.DirectoryName
        ViewsDir = $viewsDir
        MetadataDir = $metadataDir
    }
}

function Get-EntityFiles {
    param([string]$DataModelDir)
    
    Write-Step "Inventariando entidades en DataModel..."
    
    $entityFiles = Get-ChildItem -Path $DataModelDir -Filter "*.cs" | Where-Object {
        $_.Name -ne "AssemblyInfo.cs" -and 
        $_.DirectoryName -notmatch '\\Base\\|\\bin\\|\\obj\\' -and
        $_.Name -notmatch '^VTA_|^VT_'
    }
    
    Write-Host "`nEntidades encontradas: $($entityFiles.Count)" -ForegroundColor $script:InfoColor
    
    return $entityFiles
}

function Parse-EntityClass {
    param([string]$FilePath)
    
    $content = Get-Content -Path $FilePath -Raw
    $entityName = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)
    
    # Extraer interfaces implementados
    $interfaces = @("IViewBase")
    if ($content -match 'IEntityBase\s*,\s*IVersionEntity') {
        $interfaces += "IVersionEntity"
    }
    elseif ($content -match 'IEntityBase\s*,\s*IValidityEntity') {
        $interfaces += "IValidityEntity"
    }
    
    # Extraer propiedades
    $properties = @()
    $propertyRegex = '(?ms)^\s*(?:\[[^\]]+\]\s*)*\s*public\s+([^{]+?)\s+(\w+)\s*{\s*get;[^}]*}'
    $matches = [regex]::Matches($content, $propertyRegex)
    
    foreach ($match in $matches) {
        $type = $match.Groups[1].Value.Trim()
        $name = $match.Groups[2].Value
        
        # Extraer atributos de esta propiedad
        $propertyStart = $match.Index
        $beforeProperty = $content.Substring(0, $propertyStart)
        $lastNewLine = $beforeProperty.LastIndexOf("`n")
        $attributeSection = $beforeProperty.Substring($lastNewLine + 1)
        
        $attributes = @()
        $attributeMatches = [regex]::Matches($attributeSection, '\[([^\]]+)\]')
        foreach ($attrMatch in $attributeMatches) {
            $attributes += $attrMatch.Groups[1].Value
        }
        
        $properties += @{
            Name = $name
            Type = $type
            Attributes = $attributes
            IsNavigation = $type -match 'ICollection<|virtual'
            IsCollection = $type -match 'ICollection<'
        }
    }
    
    return @{
        Name = $entityName
        Interfaces = $interfaces
        Properties = $properties
    }
}

function Convert-TypeToView {
    param([string]$Type)
    
    $type = $Type.Trim()
    
    # Eliminar 'virtual'
    $type = $type -replace '\bvirtual\s+', ''
    
    # Mapeo de tipos primitivos a alias completos
    $type = $type -replace '\bint\b', 'Int32'
    $type = $type -replace '\bstring\b', 'String'
    $type = $type -replace '\bbool\b', 'Boolean'
    $type = $type -replace '\bdecimal\b', 'Decimal'
    $type = $type -replace '\blong\b', 'Int64'
    $type = $type -replace '\bshort\b', 'Int16'
    $type = $type -replace '\bbyte\b', 'Byte'
    $type = $type -replace '\bfloat\b', 'Single'
    $type = $type -replace '\bdouble\b', 'Double'
    
    # Convertir ICollection<Entity> a List<EntityView>
    if ($type -match 'ICollection<(\w+)>') {
        $entityName = $matches[1]
        return "List<${entityName}View>"
    }
    
    # Convertir Entity a EntityView (navegación simple)
    if ($type -match '^\w+$' -and $type -notmatch '^(Int32|String|Boolean|Decimal|DateTime|Byte|Int16|Int64|Single|Double)') {
        return "${type}View"
    }
    
    return $type
}

function Convert-AttributeToView {
    param([string]$Attribute)
    
    # Reemplazar StringLength por HelixStringLength
    if ($Attribute -match '^StringLength\(') {
        return $Attribute -replace '^StringLength', 'HelixStringLength'
    }
    
    # Eliminar atributo Table (no aplica a Views)
    if ($Attribute -match '^Table\(') {
        return $null
    }
    
    return $Attribute
}

function Generate-ViewFile {
    param(
        [hashtable]$Entity,
        [string]$ProjectName,
        [string]$ViewsDir
    )
    
    $viewName = "$($Entity.Name)View"
    $viewPath = Join-Path $ViewsDir "$viewName.cs"
    
    $sb = New-Object System.Text.StringBuilder
    
    # Encabezado
    [void]$sb.AppendLine("// ------------------------------------------------------------------------------")
    [void]$sb.AppendLine("// <auto-generated>")
    [void]$sb.AppendLine("//     This code was generated by Helix 6 Generator.")
    [void]$sb.AppendLine("//  ")
    [void]$sb.AppendLine("//     Changes to this file could cause incorrect behavior and will be lost if the code is regenerated.")
    [void]$sb.AppendLine("// </auto-generated>")
    [void]$sb.AppendLine("// ------------------------------------------------------------------------------")
    
    # Usings
    [void]$sb.AppendLine("using Helix6.Base.Domain.BaseInterfaces;")
    [void]$sb.AppendLine("using Helix6.Base.Domain.Validations.ModelValidations;")
    [void]$sb.AppendLine("using Mapster;")
    [void]$sb.AppendLine("using System.ComponentModel.DataAnnotations;")
    [void]$sb.AppendLine("using System.ComponentModel.DataAnnotations.Schema;")
    [void]$sb.AppendLine("using $ProjectName.Back.Entities.Views.Metadata;")
    [void]$sb.AppendLine("")
    
    # Namespace
    [void]$sb.AppendLine("namespace $ProjectName.Back.Entities.Views")
    [void]$sb.AppendLine("{")
    
    # Atributo MetadataType
    [void]$sb.AppendLine("`t[MetadataType(typeof($($viewName)Metadata))]")
    
    # Declaración de clase
    $interfaces = $Entity.Interfaces -join ", "
    [void]$sb.AppendLine("`tpublic partial class $viewName : $interfaces")
    [void]$sb.AppendLine("`t{")
    
    # Propiedades
    foreach ($prop in $Entity.Properties) {
        # Convertir atributos
        $validAttributes = @()
        foreach ($attr in $prop.Attributes) {
            $convertedAttr = Convert-AttributeToView -Attribute $attr
            if ($convertedAttr) {
                $validAttributes += $convertedAttr
            }
        }
        
        # Escribir atributos
        foreach ($attr in $validAttributes) {
            [void]$sb.AppendLine("`t`t[$attr]")
        }
        
        # Convertir tipo
        $viewType = Convert-TypeToView -Type $prop.Type
        
        # Escribir propiedad
        if ($prop.IsCollection) {
            [void]$sb.AppendLine("`t`tpublic $viewType $($prop.Name) { get; set; } = new $viewType();")
        }
        else {
            [void]$sb.AppendLine("`t`tpublic $viewType $($prop.Name) { get; set; }")
        }
        
        [void]$sb.AppendLine("")
    }
    
    # Cerrar clase y namespace
    [void]$sb.AppendLine("`t}")
    [void]$sb.AppendLine("}")
    [void]$sb.AppendLine("")
    
    return @{
        Path = $viewPath
        Content = $sb.ToString()
    }
}

function Generate-MetadataFile {
    param(
        [string]$EntityName,
        [string]$ProjectName,
        [string]$MetadataDir
    )
    
    $metadataName = "$($EntityName)ViewMetadata"
    $metadataPath = Join-Path $MetadataDir "$metadataName.cs"
    
    $sb = New-Object System.Text.StringBuilder
    
    [void]$sb.AppendLine("using Helix6.Base.Domain.BaseInterfaces;")
    [void]$sb.AppendLine("using Helix6.Base.Domain.Validations.ModelValidations;")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("namespace $ProjectName.Back.Entities.Views.Metadata")
    [void]$sb.AppendLine("{")
    [void]$sb.AppendLine("`tpublic class $metadataName : IViewBaseMetadata")
    [void]$sb.AppendLine("`t{")
    [void]$sb.AppendLine("`t}")
    [void]$sb.AppendLine("}")
    [void]$sb.AppendLine("")
    
    return @{
        Path = $metadataPath
        Content = $sb.ToString()
    }
}

function Build-EntitiesProject {
    param([string]$ProjectPath)
    
    Write-Step "Compilando proyecto Back.Entities..."
    
    Write-Host "Ejecutando: dotnet build `"$ProjectPath`" --no-restore" -ForegroundColor Gray
    
    $output = & dotnet build "$ProjectPath" --no-restore 2>&1
    $exitCode = $LASTEXITCODE
    
    if ($exitCode -eq 0) {
        Write-Success "Proyecto compilado exitosamente"
        return $true
    }
    else {
        Write-Error-Message "Error al compilar el proyecto"
        Write-Host $output -ForegroundColor $script:ErrorColor
        return $false
    }
}

# ============================================
# PROCESO PRINCIPAL
# ============================================

try {
    Write-Host "`n========================================" -ForegroundColor $script:InfoColor
    Write-Host "  UPDATE VIEWS - Helix6 Framework" -ForegroundColor $script:InfoColor
    Write-Host "========================================`n" -ForegroundColor $script:InfoColor
    
    # 1. Localizar solución
    $solutionPath = Find-Solution
    $solutionDir = [System.IO.Path]::GetDirectoryName($solutionPath)
    
    # 2. Localizar proyecto DataModel
    $dataModelInfo = Find-DataModelProject -SolutionDir $solutionDir -ProjectName $ProjectName
    
    if (-not $ProjectName) {
        $ProjectName = $dataModelInfo.ProjectName
    }
    
    # 3. Localizar proyecto Entities
    $entitiesInfo = Find-EntitiesProject -SolutionDir $solutionDir -ProjectName $ProjectName
    
    # 4. Obtener entidades del DataModel
    $entityFiles = Get-EntityFiles -DataModelDir $dataModelInfo.ProjectDir
    
    if ($entityFiles.Count -eq 0) {
        Write-Warning-Message "No se encontraron entidades en el DataModel"
        exit 0
    }
    
    # 5. Procesar cada entidad
    Write-Step "Generando vistas desde entidades..."
    
    $stats = @{
        ViewsCreated = 0
        ViewsUpdated = 0
        MetadataCreated = 0
        ViewsSkipped = 0
    }
    
    foreach ($entityFile in $entityFiles) {
        try {
            $entity = Parse-EntityClass -FilePath $entityFile.FullName
            
            # Generar View
            $viewFile = Generate-ViewFile -Entity $entity -ProjectName $ProjectName -ViewsDir $entitiesInfo.ViewsDir
            
            if (Test-Path $viewFile.Path) {
                if ($Force) {
                    Set-Content -Path $viewFile.Path -Value $viewFile.Content -NoNewline
                    Write-Host "  ✓ $($entity.Name)View actualizada" -ForegroundColor $script:SuccessColor
                    $stats.ViewsUpdated++
                }
                else {
                    Write-Host "  ℹ $($entity.Name)View ya existe (usa -Force para sobrescribir)" -ForegroundColor Gray
                    $stats.ViewsSkipped++
                }
            }
            else {
                Set-Content -Path $viewFile.Path -Value $viewFile.Content -NoNewline
                Write-Host "  ✓ $($entity.Name)View creada" -ForegroundColor $script:SuccessColor
                $stats.ViewsCreated++
            }
            
            # Generar Metadata (solo si no existe)
            $metadataFile = Generate-MetadataFile -EntityName $entity.Name -ProjectName $ProjectName -MetadataDir $entitiesInfo.MetadataDir
            
            if (-not (Test-Path $metadataFile.Path)) {
                Set-Content -Path $metadataFile.Path -Value $metadataFile.Content -NoNewline
                Write-Host "  ✓ $($entity.Name)ViewMetadata creada" -ForegroundColor $script:SuccessColor
                $stats.MetadataCreated++
            }
            
        }
        catch {
            Write-Error-Message "Error al procesar $($entityFile.Name): $_"
        }
    }
    
    # 6. Limpiar vistas huérfanas
    Write-Step "Buscando vistas huérfanas..."
    
    $viewFiles = Get-ChildItem -Path $entitiesInfo.ViewsDir -Filter "*View.cs"
    $orphanedViews = @()
    
    foreach ($viewFile in $viewFiles) {
        $entityName = $viewFile.BaseName -replace 'View$', ''
        $entityPath = Join-Path $dataModelInfo.ProjectDir "$entityName.cs"
        
        if (-not (Test-Path $entityPath)) {
            $orphanedViews += $viewFile
        }
    }
    
    if ($orphanedViews.Count -gt 0) {
        Write-Host "`nVistas huérfanas encontradas: $($orphanedViews.Count)" -ForegroundColor $script:WarningColor
        
        foreach ($orphanView in $orphanedViews) {
            $entityName = $orphanView.BaseName -replace 'View$', ''
            $metadataPath = Join-Path $entitiesInfo.MetadataDir "$($orphanView.BaseName)Metadata.cs"
            
            Remove-Item -Path $orphanView.FullName -Force
            Write-Host "  ✓ Eliminada: $($orphanView.Name)" -ForegroundColor $script:WarningColor
            
            if (Test-Path $metadataPath) {
                Remove-Item -Path $metadataPath -Force
                Write-Host "  ✓ Eliminada: $($orphanView.BaseName)Metadata.cs" -ForegroundColor $script:WarningColor
            }
        }
    }
    else {
        Write-Host "  ℹ No se encontraron vistas huérfanas" -ForegroundColor Gray
    }
    
    # 6b. Limpiar PartialViews huérfanas
    Write-Step "Buscando PartialViews huérfanos..."
    
    $partialViewsDir = Join-Path $entitiesInfo.ProjectDir "PartialViews"
    $orphanedPartialViews = @()
    
    if (Test-Path $partialViewsDir) {
        $partialViewFiles = Get-ChildItem -Path $partialViewsDir -Filter "*.cs" | Where-Object {
            $_.Name -notmatch '^Base' -and $_.DirectoryName -notmatch '\\Base\\'
        }
        
        foreach ($partialViewFile in $partialViewFiles) {
            # Extraer nombre de entidad del archivo (puede ser EntityView.cs, EntityPartialView.cs, etc.)
            $entityName = $partialViewFile.BaseName -replace 'View$|PartialView$', ''
            $entityPath = Join-Path $dataModelInfo.ProjectDir "$entityName.cs"
            
            if (-not (Test-Path $entityPath)) {
                $orphanedPartialViews += $partialViewFile
            }
        }
        
        if ($orphanedPartialViews.Count -gt 0) {
            Write-Host "`nPartialViews huérfanos encontrados: $($orphanedPartialViews.Count)" -ForegroundColor $script:WarningColor
            
            foreach ($orphanPartial in $orphanedPartialViews) {
                Remove-Item -Path $orphanPartial.FullName -Force
                Write-Host "  ✓ Eliminado: $($orphanPartial.Name)" -ForegroundColor $script:WarningColor
            }
        }
        else {
            Write-Host "  ℹ No se encontraron PartialViews huérfanos" -ForegroundColor Gray
        }
    }
    else {
        Write-Host "  ℹ No existe carpeta PartialViews" -ForegroundColor Gray
    }
    
    # 7. Compilar proyecto Entities
    $buildSuccess = Build-EntitiesProject -ProjectPath $entitiesInfo.ProjectPath
    
    # 8. Resumen
    Write-Host "`n========================================" -ForegroundColor $script:SuccessColor
    Write-Host "  RESUMEN DEL PROCESO" -ForegroundColor $script:SuccessColor
    Write-Host "========================================" -ForegroundColor $script:SuccessColor
    
    Write-Host "`nVistas:" -ForegroundColor $script:InfoColor
    Write-Host "  ✓ Creadas: $($stats.ViewsCreated)" -ForegroundColor $script:SuccessColor
    Write-Host "  ✓ Actualizadas: $($stats.ViewsUpdated)" -ForegroundColor $script:SuccessColor
    if ($stats.ViewsSkipped -gt 0) {
        Write-Host "  ℹ Omitidas: $($stats.ViewsSkipped)" -ForegroundColor Gray
    }
    
    Write-Host "`nMetadata:" -ForegroundColor $script:InfoColor
    Write-Host "  ✓ Creadas: $($stats.MetadataCreated)" -ForegroundColor $script:SuccessColor
    
    if ($orphanedViews.Count -gt 0) {
        Write-Host "`nLimpieza:" -ForegroundColor $script:InfoColor
        Write-Host "  ✓ Vistas eliminadas: $($orphanedViews.Count)" -ForegroundColor $script:WarningColor
    }
    
    if ($orphanedPartialViews.Count -gt 0) {
        if ($orphanedViews.Count -eq 0) {
            Write-Host "`nLimpieza:" -ForegroundColor $script:InfoColor
        }
        Write-Host "  ✓ PartialViews eliminadas: $($orphanedPartialViews.Count)" -ForegroundColor $script:WarningColor
    }
    
    $totalViews = (Get-ChildItem -Path $entitiesInfo.ViewsDir -Filter "*View.cs").Count
    Write-Host "`nTotal de vistas en proyecto: $totalViews" -ForegroundColor $script:InfoColor
    
    if ($buildSuccess) {
        Write-Host "`n✓ Compilación exitosa" -ForegroundColor $script:SuccessColor
        Write-Host "`nSiguiente paso recomendado:" -ForegroundColor $script:InfoColor
        Write-Host "  Ejecutar Helix Generator para regenerar servicios y endpoints" -ForegroundColor Gray
        exit 0
    }
    else {
        Write-Warning-Message "`nHubo errores de compilación. Revise los archivos generados."
        exit 1
    }
    
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
