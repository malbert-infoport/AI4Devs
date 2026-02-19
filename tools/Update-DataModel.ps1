<#
.SYNOPSIS
    Actualiza el DataModel de Entity Framework desde la base de datos mediante scaffolding.

.DESCRIPTION
    Script para proyectos Helix6 que:
    1. Localiza proyectos Back.Data y Back.DataModel
    2. Ejecuta scaffolding inverso desde PostgreSQL
    3. Mueve clases de entidad a Back.DataModel
    4. Aplica correcciones para .NET Standard 2.0

.PARAMETER SolutionPath
    Ruta al archivo .sln del proyecto backend. Si no se especifica, busca en el directorio actual.

.PARAMETER ProjectName
    Nombre del proyecto (ej: InfoportOneAdmon). Si no se especifica, se intenta detectar automáticamente.

.PARAMETER SkipFix
    Si se especifica, no aplica correcciones automáticas para .NET Standard 2.0.

.PARAMETER ConnectionString
    Cadena de conexión personalizada. Si no se especifica, se lee de appsettings.Development.json.

.PARAMETER Schemas
    Schemas de la base de datos a incluir en el scaffolding, separados por comas (ej: "public" o "public,audit").
    Si no se especifica, se solicita al usuario de forma interactiva.

.EXAMPLE
    .\Update-DataModel.ps1
    Ejecuta el proceso completo con detección automática del proyecto.

.EXAMPLE
    .\Update-DataModel.ps1 -ProjectName "InfoportOneAdmon" -SkipFix
    Ejecuta sin aplicar correcciones automáticas.

.EXAMPLE
    .\Update-DataModel.ps1 -Schemas "public"
    Ejecuta incluyendo solo el schema public.

.NOTES
    Requiere: .NET CLI, EF Core Tools, Npgsql.EntityFrameworkCore.PostgreSQL
    Framework: Helix6 v1.0
    Autor: Helix6 Development Team
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$SolutionPath,
    
    [Parameter(Mandatory=$false)]
    [string]$ProjectName,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipFix,
    
    [Parameter(Mandatory=$false)]
    [string]$ConnectionString,
    
    [Parameter(Mandatory=$false)]
    [string]$Schemas
)

# Configuración de colores para salida
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

function Find-Solution {
    Write-Step "Buscando archivo de solución..."
    
    if ($SolutionPath -and (Test-Path $SolutionPath)) {
        Write-Success "Solución encontrada: $SolutionPath"
        return $SolutionPath
    }
    
    $solutions = Get-ChildItem -Path . -Filter "*.sln" -Recurse -Depth 2 | Where-Object { $_.Name -like "*Back.sln" }
    
    if ($solutions.Count -eq 0) {
        throw "No se encontró ningún archivo .sln en el directorio actual"
    }
    
    if ($solutions.Count -gt 1) {
        Write-Warning-Message "Se encontraron múltiples soluciones:"
        $solutions | ForEach-Object { Write-Host "  - $($_.FullName)" }
        $solutionPath = $solutions[0].FullName
        Write-Warning-Message "Usando: $solutionPath"
    } else {
        $solutionPath = $solutions[0].FullName
        Write-Success "Solución encontrada: $solutionPath"
    }
    
    return $solutionPath
}

function Find-DataProject {
    param([string]$SolutionDir)
    
    Write-Step "Localizando proyecto Back.Data..."
    
    $dataProjects = Get-ChildItem -Path $SolutionDir -Filter "*.Back.Data.csproj" -Recurse
    
    if ($dataProjects.Count -eq 0) {
        throw "No se encontró el proyecto *.Back.Data.csproj"
    }
    
    $dataProject = $dataProjects[0].FullName
    $projectName = [System.IO.Path]::GetFileNameWithoutExtension($dataProject) -replace '\.Back\.Data$', ''
    
    Write-Success "Proyecto Data: $projectName.Back.Data"
    Write-Host "  Ruta: $dataProject" -ForegroundColor Gray
    
    return @{
        ProjectPath = $dataProject
        ProjectName = $projectName
        ProjectDir = [System.IO.Path]::GetDirectoryName($dataProject)
    }
}

function Find-DataModelProject {
    param([string]$SolutionDir, [string]$ProjectName)
    
    Write-Step "Localizando proyecto Back.DataModel..."
    
    $dataModelProjects = Get-ChildItem -Path $SolutionDir -Filter "$ProjectName.Back.DataModel.csproj" -Recurse
    
    if ($dataModelProjects.Count -eq 0) {
        throw "No se encontró el proyecto $ProjectName.Back.DataModel.csproj"
    }
    
    $dataModelProject = $dataModelProjects[0].FullName
    
    Write-Success "Proyecto DataModel: $ProjectName.Back.DataModel"
    Write-Host "  Ruta: $dataModelProject" -ForegroundColor Gray
    
    return @{
        ProjectPath = $dataModelProject
        ProjectDir = [System.IO.Path]::GetDirectoryName($dataModelProject)
    }
}

function Find-ApiProject {
    param([string]$SolutionDir, [string]$ProjectName)
    
    $apiProject = Get-ChildItem -Path $SolutionDir -Filter "$ProjectName.Back.Api.csproj" -Recurse
    
    if ($apiProject.Count -eq 0) {
        throw "No se encontró el proyecto $ProjectName.Back.Api.csproj"
    }
    
    return $apiProject[0].FullName
}

function Get-ConnectionString {
    param([string]$ApiProjectPath)
    
    if ($ConnectionString) {
        Write-Step "Usando cadena de conexión proporcionada"
        $maskedConnection = $ConnectionString -replace '(Password=)[^;]+', '$1***'
        Write-Host "  $maskedConnection" -ForegroundColor Gray
        return $ConnectionString
    }
    
    Write-Step "Obteniendo cadena de conexión..."
    
    $apiProjectDir = [System.IO.Path]::GetDirectoryName($ApiProjectPath)
    $appSettingsPath = Join-Path $apiProjectDir "appsettings.Development.json"
    
    if (-not (Test-Path $appSettingsPath)) {
        throw "No se encontró appsettings.Development.json"
    }
    
    $appSettings = Get-Content $appSettingsPath -Raw | ConvertFrom-Json
    $connString = $appSettings.ConnectionStrings.DefaultConnection
    
    if (-not $connString) {
        throw "No se encontró la cadena de conexión 'DefaultConnection'"
    }
    
    Write-Host "`nCadena de conexión:" -ForegroundColor $script:InfoColor
    $maskedConnection = $connString -replace '(Password=)[^;]+', '$1***'
    Write-Host "  $maskedConnection" -ForegroundColor Gray
    
    return $connString
}

function Get-SchemasToInclude {
    Write-Step "Solicitando schemas a incluir en el scaffolding..."
    
    if ($Schemas) {
        Write-Host "`nSchemas especificados: $Schemas" -ForegroundColor Gray
        return $Schemas
    }
    
    Write-Host "`n¿Qué schemas de la base de datos desea incluir en el scaffolding?" -ForegroundColor $script:InfoColor
    Write-Host "  Nota: Los schemas Helix6_Internal y Helix6_Security ya están en el framework base" -ForegroundColor Gray
    Write-Host "  Ingrese los schemas separados por comas (ej: public o public,audit)" -ForegroundColor Gray
    Write-Host "  [Valor por defecto: public]" -ForegroundColor DarkGray
    
    $userInput = Read-Host "`nSchemas"
    
    if ([string]::IsNullOrWhiteSpace($userInput)) {
        $userInput = "public"
        Write-Host "Usando valor por defecto: public" -ForegroundColor DarkGray
    }
    
    Write-Host "`nSchemas a incluir: $userInput" -ForegroundColor $script:InfoColor
    return $userInput
}

function Execute-Scaffolding {
    param(
        [string]$ConnectionString,
        [string]$DataProject,
        [string]$ProjectName,
        [string]$SchemasToInclude
    )
    
    Write-Step "Ejecutando scaffolding de Entity Framework..."
    Write-Warning-Message "Este proceso puede tardar varios minutos..."
    
    try {
        # Convertir schemas separados por comas a múltiples parámetros --schema
        $schemaParams = ""
        if ($SchemasToInclude) {
            $schemaList = $SchemasToInclude -split ',' | ForEach-Object { $_.Trim() }
            foreach ($schema in $schemaList) {
                $schemaParams += "--schema $schema "
            }
        }
        
        $command = "dotnet ef dbcontext scaffold " +
                   "--namespace `"$ProjectName.Back.DataModel`" " +
                   "--no-pluralize " +
                   "`"$ConnectionString`" " +
                   "Npgsql.EntityFrameworkCore.PostgreSQL " +
                   "--output-dir `"DataModel`" " +
                   "--context EntityModel " +
                   "--force " +
                   "--use-database-names " +
                   "--verbose " +
                   "--data-annotations " +
                   "--no-onconfiguring " +
                   "--no-build " +
                   $schemaParams +
                   "--project `"$DataProject`""
        
        Write-Host "`nEjecutando comando:" -ForegroundColor Gray
        Write-Host $command -ForegroundColor DarkGray
        
        $output = Invoke-Expression $command 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host $output -ForegroundColor Red
            throw "Error al ejecutar scaffolding"
        }
        
        Write-Success "Scaffolding completado exitosamente"
        return $true
        
    } catch {
        Write-Error-Message "Error al ejecutar scaffolding: $_"
        return $false
    }
}

function Fix-EntityModelNamespace {
    param(
        [string]$DataProjectDir,
        [string]$ProjectName
    )
    
    Write-Step "Corrigiendo namespace de EntityModel.cs..."
    
    $entityModelPath = Join-Path $DataProjectDir "DataModel\EntityModel.cs"
    
    if (-not (Test-Path $entityModelPath)) {
        Write-Warning-Message "No se encontró EntityModel.cs en $entityModelPath"
        return $false
    }
    
    try {
        $content = Get-Content $entityModelPath -Raw
        
        # Reemplazar namespace incorrecto por el correcto
        $wrongNamespace = "namespace $ProjectName.Back.DataModel"
        $correctNamespace = "namespace $ProjectName.Back.Data.DataModel"
        
        if ($content -match [regex]::Escape($wrongNamespace)) {
            $content = $content -replace [regex]::Escape($wrongNamespace), $correctNamespace
            Set-Content -Path $entityModelPath -Value $content -NoNewline
            Write-Success "Namespace corregido: $correctNamespace"
            return $true
        } else {
            Write-Host "  El namespace ya es correcto o no se encontró el patrón esperado" -ForegroundColor $script:InfoColor
            return $true
        }
        
    } catch {
        Write-Error-Message "Error al corregir namespace de EntityModel: $_"
        return $false
    }
}

function Move-EntityClasses {
    param(
        [string]$DataProjectDir,
        [string]$DataModelProjectDir
    )
    
    Write-Step "Moviendo clases de entidad a Back.DataModel..."
    
    $sourceDir = Join-Path $DataProjectDir "DataModel"
    
    if (-not (Test-Path $sourceDir)) {
        throw "No se encontró la carpeta DataModel en el proyecto Data"
    }
    
    # Obtener todos los archivos excepto EntityModel.cs y la carpeta Base
    $filesToMove = Get-ChildItem -Path $sourceDir -Filter "*.cs" | Where-Object {
        $_.Name -ne "EntityModel.cs" -and $_.DirectoryName -notlike "*\Base"
    }
    
    if ($filesToMove.Count -eq 0) {
        Write-Warning-Message "No se encontraron archivos para mover"
        return 0
    }
    
    Write-Host "`nArchivos a mover: $($filesToMove.Count)" -ForegroundColor $script:InfoColor
    
    $movedCount = 0
    foreach ($file in $filesToMove) {
        try {
            $destPath = Join-Path $DataModelProjectDir $file.Name
            
            # Sobrescribir sin crear backup (los cambios están en Git)
            Move-Item -Path $file.FullName -Destination $destPath -Force
            Write-Host "  ✓ $($file.Name)" -ForegroundColor $script:SuccessColor
            $movedCount++
            
        } catch {
            Write-Error-Message "Error al mover $($file.Name): $_"
        }
    }
    
    Write-Success "Archivos movidos: $movedCount"
    return $movedCount
}

function Add-VersionValidityInterfaces {
    param([string]$DataModelProjectDir)
    
    Write-Step "Detectando entidades con versionado/vigencia..."
    
    $entityFiles = Get-ChildItem -Path $DataModelProjectDir -Filter "*.cs" | Where-Object {
        $_.Name -ne "AssemblyInfo.cs" -and $_.Name -notmatch '^VTA_'
    }
    
    if ($entityFiles.Count -eq 0) {
        Write-Warning-Message "No se encontraron archivos de entidades para analizar"
        return
    }
    
    Write-Host "`nArchivos a analizar: $($entityFiles.Count)" -ForegroundColor $script:InfoColor
    
    $versionEntitiesCount = 0
    $validityEntitiesCount = 0
    
    foreach ($file in $entityFiles) {
        try {
            $content = Get-Content -Path $file.FullName -Raw
            $originalContent = $content
            
            # Buscar propiedades requeridas (tipos más flexibles para capturar List<int>, int?, etc.)
            $hasVersionKey = $content -match 'public\s+[\w<>]+\s+VersionKey\s*{'
            $hasVersionNumber = $content -match 'public\s+[\w<>]+\s+VersionNumber\s*{'
            $hasValidityFrom = $content -match 'public\s+DateTime\??\s+ValidityFrom\s*{'
            $hasValidityTo = $content -match 'public\s+DateTime\??\s+ValidityTo\s*{'
            
            $interfaceToAdd = ""
            $entityType = ""
            
            # Criterio 1: ValidityEntity (tiene los 4 campos)
            if ($hasVersionKey -and $hasVersionNumber -and $hasValidityFrom -and $hasValidityTo) {
                $interfaceToAdd = "IValidityEntity"
                $entityType = "ValidityEntity"
                $validityEntitiesCount++
            }
            # Criterio 2: VersionEntity (solo tiene VersionKey y VersionNumber)
            elseif ($hasVersionKey -and $hasVersionNumber) {
                $interfaceToAdd = "IVersionEntity"
                $entityType = "VersionEntity"
                $versionEntitiesCount++
            }
            
            if ($interfaceToAdd -ne "") {
                # Verificar si ya tiene la interfaz
                if ($content -match ":\s*IEntityBase\s*,\s*$interfaceToAdd") {
                    Write-Host "  ℹ $($file.Name) ya implementa $interfaceToAdd" -ForegroundColor Gray
                    continue
                }
                
                # Añadir la interfaz después de IEntityBase
                if ($content -match '(class\s+\w+\s*:\s*IEntityBase)') {
                    $content = $content -replace '(class\s+\w+\s*:\s*IEntityBase)', "`$1, $interfaceToAdd"
                    Set-Content -Path $file.FullName -Value $content -NoNewline
                    Write-Host "  ✓ $($file.Name) → $entityType" -ForegroundColor $script:SuccessColor
                }
                else {
                    Write-Warning-Message "$($file.Name): No se encontró patrón 'class X : IEntityBase'"
                }
            }
            
        } catch {
            Write-Error-Message "Error al procesar $($file.Name): $_"
        }
    }
    
    if ($versionEntitiesCount -gt 0 -or $validityEntitiesCount -gt 0) {
        Write-Host ""
        if ($versionEntitiesCount -gt 0) {
            Write-Host "  ✓ $versionEntitiesCount entidades marcadas como IVersionEntity" -ForegroundColor $script:SuccessColor
        }
        if ($validityEntitiesCount -gt 0) {
            Write-Host "  ✓ $validityEntitiesCount entidades marcadas como IValidityEntity" -ForegroundColor $script:SuccessColor
        }
    } else {
        Write-Host "  ℹ No se detectaron entidades con versionado/vigencia" -ForegroundColor Gray
    }
}

function Fix-NetStandardCompatibility {
    param([string]$DataModelProjectDir)
    
    Write-Step "Aplicando correcciones para .NET Standard 2.0..."
    
    $entityFiles = Get-ChildItem -Path $DataModelProjectDir -Filter "*.cs" | Where-Object {
        $_.Name -ne "AssemblyInfo.cs"
    }
    
    if ($entityFiles.Count -eq 0) {
        Write-Warning-Message "No se encontraron archivos para corregir"
        return
    }
    
    Write-Host "`nArchivos a procesar: $($entityFiles.Count)" -ForegroundColor $script:InfoColor
    
    $fixedCount = 0
    $totalFixes = 0
    
    foreach ($file in $entityFiles) {
        try {
            $content = Get-Content -Path $file.FullName -Raw
            $originalContent = $content
            $fileFixes = 0
            
            # 1. Comentar TODOS los atributos [Index(...)] - pueden ser multilínea
            $indexMatches = [regex]::Matches($content, '\[Index\([^\]]*\)\]', [System.Text.RegularExpressions.RegexOptions]::Singleline)
            foreach ($match in $indexMatches | Sort-Object -Property Index -Descending) {
                $beforeMatch = $content.Substring(0, $match.Index)
                $lastNewLine = $beforeMatch.LastIndexOf("`n")
                $indent = ""
                if ($lastNewLine -ge 0) {
                    $lineStart = $lastNewLine + 1
                    $indentText = $beforeMatch.Substring($lineStart)
                    if ($indentText -match '^(\s+)') {
                        $indent = $matches[1]
                    }
                }
                
                $replacement = "// " + $match.Value
                $content = $content.Substring(0, $match.Index) + $replacement + $content.Substring($match.Index + $match.Length)
                $fileFixes++
            }
            
            # 2. Comentar TODOS los atributos [Keyless]
            $keylessMatches = [regex]::Matches($content, '\[Keyless\]', [System.Text.RegularExpressions.RegexOptions]::Singleline)
            foreach ($match in $keylessMatches | Sort-Object -Property Index -Descending) {
                $replacement =  "// " + $match.Value
                $content = $content.Substring(0, $match.Index) + $replacement + $content.Substring($match.Index + $match.Length)
                $fileFixes++
            }
            
            # 3. Eliminar using Microsoft.EntityFrameworkCore (excepto DataAnnotations) línea por línea
            $lines = $content -split "`r?`n"
            $newLines = @()
            foreach ($line in $lines) {
                if ($line -match 'using Microsoft\.EntityFrameworkCore' -and 
                    $line -notmatch 'DataAnnotations') {
                    $newLines += "// $line"
                    $fileFixes++
                } else {
                    $newLines += $line
                }
            }
            $content = $newLines -join "`n"
            
            # 4. Remover IEntityFramework de vistas (Vta*) - no tienen propiedades de auditoría
            if ($file.Name -match '^Vta[A-Z]') {
                if ($content -match ':\s*IEntityFramework') {
                    # Remover la implementación de la interfaz
                    $content = $content -replace ':\s*IEntityFramework\s*', ''
                    $fileFixes++
                    Write-Host "  ⚠ Vista $($file.Name): removida interfaz IEntityFramework" -ForegroundColor $script:WarningColor
                }
            }
            
            # 5. Eliminar TODOS los nullable en strings
            while ($content -match 'public\s+string\?\s+(\w+)\s*{\s*get;\s*set;\s*}') {
                $content = $content -replace 'public\s+string\?\s+(\w+)\s*{\s*get;\s*set;\s*}', 'public string $1 { get; set; } = string.Empty;'
                $fileFixes++
            }
            
            # 6. Eliminar TODOS los nullable en propiedades Id (solo si es clave primaria)
            while ($content -match 'public\s+int\?\s+Id\s*{\s*get;\s*set;\s*}') {
                $content = $content -replace 'public\s+int\?\s+Id\s*{\s*get;\s*set;\s*}', 'public int Id { get; set; }'
                $fileFixes++
            }
            
            # Solo guardar si hubo cambios
            if ($content -ne $originalContent) {
                Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
                if ($fileFixes -gt 0) {
                    Write-Host "  ✓ $($file.Name) - $fileFixes correcciones" -ForegroundColor $script:SuccessColor
                    $fixedCount++
                    $totalFixes += $fileFixes
                }
            } else {
                Write-Host "  - $($file.Name) - sin cambios" -ForegroundColor Gray
            }
            
        } catch {
            Write-Error-Message "Error al procesar $($file.Name): $_"
        }
    }
    
    Write-Success "Archivos corregidos: $fixedCount (Total de correcciones: $totalFixes)"
}

function Build-DataModelProject {
    param([string]$DataModelProject)
    
    Write-Step "Compilando proyecto Back.DataModel..."
    
    try {
        $command = "dotnet build `"$DataModelProject`" --no-restore"
        Write-Host "Ejecutando: $command" -ForegroundColor Gray
        
        $output = Invoke-Expression $command 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error-Message "Error en la compilación:"
            Write-Host $output -ForegroundColor Red
            return $false
        }
        
        Write-Success "Proyecto compilado exitosamente"
        return $true
        
    } catch {
        Write-Error-Message "Error al compilar: $_"
        return $false
    }
}

function Show-DataModelChanges {
    param([string]$DataModelProjectDir)
    
    Write-Step "Enumerando cambios en el DataModel..."
    
    try {
        # Verificar si estamos en un repositorio Git
        $gitCheck = git rev-parse --git-dir 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Warning-Message "No se detectó repositorio Git. Omitiendo enumeración de cambios."
            return
        }
        
        # Obtener el estado de Git para los archivos del DataModel
        $gitStatus = git status --porcelain $DataModelProjectDir 2>&1
        
        if ([string]::IsNullOrWhiteSpace($gitStatus)) {
            Write-Host "`nℹ No hay cambios en el DataModel" -ForegroundColor $script:InfoColor
            return
        }
        
        Write-Host "`nCambios en el DataModel:" -ForegroundColor $script:InfoColor
        Write-Host "────────────────────────" -ForegroundColor $script:InfoColor
        
        $addedFiles = @()
        $modifiedFiles = @()
        $deletedFiles = @()
        
        # Parsear el output de git status
        $gitStatus -split "`n" | ForEach-Object {
            $line = $_.Trim()
            if ($line) {
                $status = $line.Substring(0, 2).Trim()
                $file = $line.Substring(3).Trim()
                $fileName = Split-Path $file -Leaf
                
                switch ($status) {
                    "A" { $addedFiles += $fileName }
                    "??" { $addedFiles += $fileName }
                    "M" { $modifiedFiles += $fileName }
                    "D" { $deletedFiles += $fileName }
                }
            }
        }
        
        # Mostrar archivos nuevos
        if ($addedFiles.Count -gt 0) {
            Write-Host "`n📄 Archivos nuevos ($($addedFiles.Count)):" -ForegroundColor Green
            foreach ($file in $addedFiles) {
                Write-Host "  + $file" -ForegroundColor Green
            }
        }
        
        # Mostrar archivos modificados con detalles
        if ($modifiedFiles.Count -gt 0) {
            Write-Host "`n📝 Archivos modificados ($($modifiedFiles.Count)):" -ForegroundColor Yellow
            foreach ($file in $modifiedFiles) {
                $fullPath = Get-ChildItem $DataModelProjectDir -Filter $file -Recurse -File | Select-Object -First 1
                if ($fullPath) {
                    Write-Host "  M $file" -ForegroundColor Yellow
                    
                    # Obtener diff detallado
                    $diff = git diff $fullPath.FullName 2>&1
                    if ($diff) {
                        $diff -split "`n" | ForEach-Object {
                            $line = $_
                            if ($line -match "^-(?!--)(.*)") {
                                # Línea eliminada (roja)
                                Write-Host "    $line" -ForegroundColor Red
                            }
                            elseif ($line -match "^\+(?!\+\+)(.*)") {
                                # Línea añadida (verde)
                                Write-Host "    $line" -ForegroundColor Green
                            }
                            elseif ($line -match "^@@") {
                                # Cabecera de sección (cyan)
                                Write-Host "    $line" -ForegroundColor Cyan
                            }
                            elseif ($line -match "^(diff|index|---|\+\+\+)") {
                                # Metadata del diff (gris)
                                Write-Host "    $line" -ForegroundColor DarkGray
                            }
                            else {
                                # Líneas de contexto
                                Write-Host "    $line" -ForegroundColor Gray
                            }
                        }
                        Write-Host "" # Línea en blanco entre archivos
                    }
                }
            }
        }
        
        # Mostrar archivos eliminados
        if ($deletedFiles.Count -gt 0) {
            Write-Host "`n🗑️  Archivos eliminados ($($deletedFiles.Count)):" -ForegroundColor Red
            foreach ($file in $deletedFiles) {
                Write-Host "  - $file" -ForegroundColor Red
            }
        }
        
        # Mostrar resumen total
        $totalChanges = $addedFiles.Count + $modifiedFiles.Count + $deletedFiles.Count
        Write-Host "`n📊 Total de archivos afectados: $totalChanges" -ForegroundColor $script:InfoColor
        
    } catch {
        Write-Warning-Message "Error al enumerar cambios: $_"
    }
}

# ============================================
# MAIN EXECUTION
# ============================================

try {
    Write-Host "`n========================================" -ForegroundColor $script:InfoColor
    Write-Host "  UPDATE DATAMODEL - Helix6 Framework" -ForegroundColor $script:InfoColor
    Write-Host "========================================`n" -ForegroundColor $script:InfoColor
    
    # 1. Encontrar solución
    $solutionPath = Find-Solution
    $solutionDir = [System.IO.Path]::GetDirectoryName($solutionPath)
    
    # 2. Encontrar proyecto Data
    $dataInfo = Find-DataProject -SolutionDir $solutionDir
    
    if (-not $ProjectName) {
        $ProjectName = $dataInfo.ProjectName
    }
    
    # 3. Encontrar proyecto DataModel
    $dataModelInfo = Find-DataModelProject -SolutionDir $solutionDir -ProjectName $ProjectName
    
    # 4. Encontrar proyecto Api
    $apiProject = Find-ApiProject -SolutionDir $solutionDir -ProjectName $ProjectName
    Write-Host "Proyecto Api: $([System.IO.Path]::GetFileName($apiProject))" -ForegroundColor Gray
    
    # 5. Obtener cadena de conexión
    $connString = Get-ConnectionString -ApiProjectPath $apiProject
    
    # 6. Obtener schemas a incluir
    $schemasToInclude = Get-SchemasToInclude
    
    # 7. Ejecutar scaffolding
    $scaffoldSuccess = Execute-Scaffolding `
        -ConnectionString $connString `
        -DataProject $dataInfo.ProjectPath `
        -ProjectName $ProjectName `
        -SchemasToInclude $schemasToInclude
    
    if (-not $scaffoldSuccess) {
        throw "El scaffolding falló"
    }
    
    # 8. Corregir namespace de EntityModel.cs
    $namespaceFixed = Fix-EntityModelNamespace `
        -DataProjectDir $dataInfo.ProjectDir `
        -ProjectName $ProjectName
    
    if (-not $namespaceFixed) {
        Write-Warning-Message "No se pudo corregir el namespace de EntityModel.cs"
    }
    
    # 9. Mover clases de entidad
    $movedCount = Move-EntityClasses `
        -DataProjectDir $dataInfo.ProjectDir `
        -DataModelProjectDir $dataModelInfo.ProjectDir
    
    if ($movedCount -eq 0) {
        Write-Warning-Message "No se movieron archivos. Verifique el proceso de scaffolding."
    }
    
    # 10. Aplicar correcciones para .NET Standard 2.0
    if (-not $SkipFix) {
        Fix-NetStandardCompatibility -DataModelProjectDir $dataModelInfo.ProjectDir
    } else {
        Write-Warning-Message "Correcciones automáticas omitidas (--SkipFix)"
    }
    
    # 11. Detectar y añadir interfaces IVersionEntity / IValidityEntity
    Add-VersionValidityInterfaces -DataModelProjectDir $dataModelInfo.ProjectDir
    
    # 12. Compilar proyecto DataModel
    $buildSuccess = Build-DataModelProject -DataModelProject $dataModelInfo.ProjectPath
    
    # 13. Mostrar cambios en el DataModel
    if ($buildSuccess) {
        Show-DataModelChanges -DataModelProjectDir $dataModelInfo.ProjectDir
    }
    
    if ($buildSuccess) {
        Write-Host "`n========================================" -ForegroundColor $script:SuccessColor
        Write-Host "  PROCESO COMPLETADO EXITOSAMENTE" -ForegroundColor $script:SuccessColor
        Write-Host "========================================`n" -ForegroundColor $script:SuccessColor
        
        Write-Host "Siguiente paso recomendado:" -ForegroundColor $script:InfoColor
        Write-Host "  Ejecutar /UpdateViews para sincronizar Views con el DataModel actualizado" -ForegroundColor Gray
        
        exit 0
    } else {
        Write-Warning-Message "El proceso se completó pero hubo errores de compilación"
        Write-Warning-Message "Revise manualmente los archivos en Back.DataModel"
        exit 1
    }
    
} catch {
    Write-Host "`n========================================" -ForegroundColor $script:ErrorColor
    Write-Host "  ERROR EN EL PROCESO" -ForegroundColor $script:ErrorColor
    Write-Host "========================================" -ForegroundColor $script:ErrorColor
    Write-Error-Message $_.Exception.Message
    Write-Host "`nStack Trace:" -ForegroundColor Gray
    Write-Host $_.Exception.StackTrace -ForegroundColor Gray
    exit 1
}
