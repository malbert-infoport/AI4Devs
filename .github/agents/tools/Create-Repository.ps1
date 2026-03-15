<#
.SYNOPSIS
    Crea/actualiza repositorios para una entidad del DataModel usando plantillas.
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$EntityName,

    [string]$SolutionPath,
    [string]$ProjectName,
    [string]$BaseRepository = 'BaseRepository',
    [switch]$DryRun,
    [switch]$Backup
)

Import-Module (Join-Path $PSScriptRoot 'lib\HelixHelpers.psm1') -Force -DisableNameChecking

try {
    if (-not $SolutionPath) { $SolutionPath = Find-Solution }
    $solutionDir = Split-Path -Path $SolutionPath -Parent
    $dirs = Find-ProjectDirectories -SolutionDir $solutionDir

    $dataModelDir = $dirs.DataModelDir
    $repoDir = $dirs.RepoDir
    if (-not (Test-Path $repoDir)) { New-Item -Path $repoDir -ItemType Directory -Force | Out-Null }
    $interfacesDir = Join-Path $repoDir 'Interfaces'
    if (-not (Test-Path $interfacesDir)) { New-Item -Path $interfacesDir -ItemType Directory -Force | Out-Null }

    try {
        $entityFile = Get-EntityFilePath -DataModelDir $dataModelDir -EntityName $EntityName
    } catch {
        Write-Host "Entity '$EntityName' not found under DataModel: $dataModelDir" -ForegroundColor Yellow
        Write-Host "Available entities:" -ForegroundColor Cyan
        Get-ChildItem -Path $dataModelDir -Filter "*.cs" -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object { ($_.FullName -notmatch '\\bin\\') -and ($_.FullName -notmatch '\\obj\\') -and ($_.Name -notmatch 'AssemblyInfo|AssemblyAttributes|\.Designer\.cs$') } |
            ForEach-Object {
                $content = Get-Content -Path $_.FullName -Raw -ErrorAction SilentlyContinue
                if ($null -ne $content -and ($content -match 'IEntityBase' -or $content -match 'IVersionEntity' -or $content -match 'IValidityEntity')) {
                    Write-Host " - $($_.BaseName)"
                }
            }
        exit 1
    }
    $props = Get-EntityProperties -EntityFilePath $entityFile

    $isValidity = Is-ValidityEntity -Properties $props
    $isVersion = (-not $isValidity) -and (Is-VersionEntity -Properties $props)

    if ($isValidity) {
        $baseRepoType = "BaseValidityRepository<$EntityName>"
        $baseInterface = "IBaseValidityRepository<$EntityName>"
    } elseif ($isVersion) {
        $baseRepoType = "BaseVersionRepository<$EntityName>"
        $baseInterface = "IBaseVersionRepository<$EntityName>"
    } else {
        $baseRepoType = "$BaseRepository<$EntityName>"
        $baseInterface = "I$BaseRepository<$EntityName>"
    }

    # tokens
    $solutionFolder = if ($ProjectName) { $ProjectName } else { Split-Path -Leaf $solutionDir }
    if ($solutionFolder -match '\.Back$') {
        $rootName = $solutionFolder -replace '\.Back$',''
    } else {
        $rootName = $solutionFolder
    }
    $repoNamespace = "$rootName.Back.Data.Repository"
    $entityNamespace = "$rootName.Back.DataModel"

    $interfaceTarget = Join-Path $interfacesDir "I${EntityName}Repository.cs"
    $repoTarget = Join-Path $repoDir "${EntityName}Repository.cs"

    $tplInterface = Get-Content -Path (Join-Path $PSScriptRoot 'templates\IRepository.template.cs') -Raw
    $tplRepo = Get-Content -Path (Join-Path $PSScriptRoot 'templates\Repository.template.cs') -Raw

    $render = @{ }
    $render['__NAMESPACE__'] = $repoNamespace
    $render['__ENTITY_NAME__'] = $EntityName
    $render['__BASE_REPOSITORY__'] = $baseRepoType
    $render['__BASE_INTERFACE__'] = $baseInterface
    $render['__ENTITY_NAMESPACE__'] = $entityNamespace

    foreach ($k in $render.Keys) {
        $tplInterface = $tplInterface -replace [regex]::Escape($k), [string]$render[$k]
        $tplRepo = $tplRepo -replace [regex]::Escape($k), [string]$render[$k]
    }

    function Write-FileSafely($path,$content) {
        if ($DryRun) { Write-Host "[DryRun] Would write: $path"; return }
        if ((Test-Path $path) -and $Backup) {
            $bak = "$path.$((Get-Date).ToString('yyyyMMddHHmmss')).bak"
            Copy-Item -Path $path -Destination $bak -Force
            # backup message suppressed in normal run
        }
        Set-Content -Path $path -Value $content -Encoding UTF8 -NoNewline
        # file write message suppressed in normal run
    }

    # Interface
    if ((-not (Test-Path $interfaceTarget)) -or ((Get-Content $interfaceTarget -Raw) -ne $tplInterface)) {
        Write-FileSafely -path $interfaceTarget -content $tplInterface
    } else { Write-Host "Skipped (up-to-date): $interfaceTarget" }

    # Repository
    if ((-not (Test-Path $repoTarget)) -or ((Get-Content $repoTarget -Raw) -ne $tplRepo)) {
        Write-FileSafely -path $repoTarget -content $tplRepo
    } else { Write-Host "Skipped (up-to-date): $repoTarget" }

    # Optional: update service files to use I{Entity}Repository instead of IBase... (best-effort)
    $servicesProj = Get-ChildItem -Path $solutionDir -Filter "*.Back.Services.csproj" -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($servicesProj) {
        $serviceDir = $servicesProj.DirectoryName
        $serviceFile = Get-ChildItem -Path $serviceDir -Filter "*${EntityName}Service*.cs" -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($serviceFile) {
            $sf = Get-Content -Path $serviceFile.FullName -Raw
            $sfNew = $sf -replace "IBase(Version|Validity)?Repository<${EntityName}>", "I${EntityName}Repository"
            if ($sfNew -ne $sf) {
                if ($DryRun) { Write-Host "[DryRun] Would update service: $($serviceFile.FullName)" } else {
                    if ($Backup) { Copy-Item $serviceFile.FullName "$($serviceFile.FullName).$((Get-Date).ToString('yyyyMMddHHmmss')).bak" -Force }
                    Set-Content -Path $serviceFile.FullName -Value $sfNew -Encoding UTF8 -NoNewline
                    Write-Host "Updated service file: $($serviceFile.FullName)"
                }
            }
        }
    }

    Write-Host "\nDone. Repository created/updated for entity: $EntityName" -ForegroundColor Green
    if ($DryRun) { exit 0 }
    exit 0
} catch {
    Write-Host "Error message: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Exception: $($_.Exception.ToString())"
    Write-Host "ScriptStackTrace: $($_.ScriptStackTrace)"
    Write-Host "Error object: $_"
    exit 1
}
