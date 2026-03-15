<#
.SYNOPSIS
    Generate or update a Helix6 service from a DataModel/View.

.DESCRIPTION
    PowerShell generator that renders a service class into the Back.Services project
    using tokenized templates. Supports DryRun and Backup. Detects Version/Validity
    entities and chooses appropriate base service.
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$EntityName,

    [string]$SolutionPath,
    [string]$ProjectName,
    [switch]$DryRun,
    [switch]$Backup,
    [switch]$Force,
    [switch]$WithSkeletonOverrides
)

Import-Module (Join-Path $PSScriptRoot 'lib\HelixHelpers.psm1') -Force -DisableNameChecking

try {
    if (-not $SolutionPath) { $SolutionPath = Find-Solution }
    $solutionDir = Split-Path -Path $SolutionPath -Parent
    $dirs = Find-ProjectDirectories -SolutionDir $solutionDir
    Write-Verbose "Found project directories keys: $($dirs.Keys -join ', ')"

    # determine Services project directory (look for *.Back.Services.csproj)
    $servicesProj = Get-ChildItem -Path $solutionDir -Filter "*.Back.Services.csproj" -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($servicesProj) {
        $servicesDir = $servicesProj.DirectoryName
    } else {
        # fallback: if helper provided a ServicesDir use it, otherwise use default under solution
        if ($dirs.ContainsKey('ServicesDir')) { $servicesDir = $dirs.ServicesDir } else { $servicesDir = Join-Path $solutionDir 'Services' }
    }
    Write-Verbose "servicesDir = $servicesDir"
    if (-not (Test-Path $servicesDir)) { New-Item -Path $servicesDir -ItemType Directory -Force | Out-Null }

    # locate DataModel and entity file
    $dataModelDir = $dirs.DataModelDir
    Write-Verbose "dataModelDir = $dataModelDir"
    $entityFile = Get-EntityFilePath -DataModelDir $dataModelDir -EntityName $EntityName
    Write-Verbose "entityFile = $entityFile"
    $props = Get-EntityProperties -EntityFilePath $entityFile
    Write-Verbose "props count = $($props.Count)"

    $isValidity = Is-ValidityEntity -Properties $props
    $isVersion = (-not $isValidity) -and (Is-VersionEntity -Properties $props)

    if ($isValidity) {
        $baseService = "BaseValidityService<__VIEW__, __ENTITY__, __VIEW__Metadata>"
    } elseif ($isVersion) {
        $baseService = "BaseVersionService<__VIEW__, __ENTITY__, __VIEW__Metadata>"
    } else {
        $baseService = "BaseService<__VIEW__, __ENTITY__, __VIEW__Metadata>"
    }

    # names/namespaces
    $solutionFolder = if ($ProjectName) { $ProjectName } else { Split-Path -Leaf $solutionDir }
    if ($solutionFolder -match '\.Back$') { $rootName = $solutionFolder -replace '\.Back$','' } else { $rootName = $solutionFolder }
    $servicesNamespace = "$rootName.Back.Services"
    $dataModelNamespace = "$rootName.Back.DataModel"
    $viewsNamespace = "$rootName.Back.Entities.Views"
    $metadataNamespace = "$rootName.Back.Entities.Views.Metadata"

    $serviceTarget = Join-Path $servicesDir "${EntityName}Service.cs"

    # choose template: default simple template or skeleton overrides
    if ($WithSkeletonOverrides) {
        if ($isValidity) {
            $templateFile = Join-Path $PSScriptRoot 'templates\ServiceValidity.template.cs'
        } elseif ($isVersion) {
            $templateFile = Join-Path $PSScriptRoot 'templates\ServiceVersion.template.cs'
        } else {
            $templateFile = Join-Path $PSScriptRoot 'templates\ServiceFull.template.cs'
        }
    } else {
        $templateFile = Join-Path $PSScriptRoot 'templates\Service.template.cs'
    }

    $tpl = Get-Content -Path $templateFile -Raw

    # detect repository presence
    $repoInterfacePath = Join-Path (Join-Path $dirs.RepoDir 'Interfaces') ("I${EntityName}Repository.cs")
    $hasRepository = Test-Path $repoInterfacePath

    if ($hasRepository) {
        $repoUsing = "using $rootName.Back.Data.Repository.Interfaces;"
        $repoField = "private readonly I${EntityName}Repository _repository;"
        $repoParam = "I${EntityName}Repository repository"
        $repoAssign = "_repository = repository;"
        $repoBaseArg = "repository"
    } else {
        $repoUsing = ""
        $repoField = ""
        $repoParam = "IBaseRepository<$EntityName> repository"
        $repoAssign = ""
        $repoBaseArg = "repository"
    }

    # render tokens
    $render = @{ }
    $render['__NAMESPACE__'] = $servicesNamespace
    $render['__ENTITY_NAME__'] = $EntityName
    $render['__VIEW__'] = "${EntityName}View"
    $render['__BASE_SERVICE__'] = $baseService -replace '__VIEW__', "${EntityName}View" -replace '__ENTITY__', $EntityName -replace '__VIEW__Metadata', "${EntityName}ViewMetadata"
    $render['__ENTITY_NAMESPACE__'] = $dataModelNamespace
    $render['__VIEWS_NAMESPACE__'] = $viewsNamespace
    $render['__METADATA_NAMESPACE__'] = $metadataNamespace
    $render['__REPO_USING__'] = $repoUsing
    $render['__REPO_FIELD__'] = $repoField
    $render['__REPO_PARAM__'] = $repoParam
    $render['__REPO_ASSIGN__'] = $repoAssign
    $render['__REPO_BASE__'] = $repoBaseArg

    Write-Verbose "Starting token replacements (count=$($render.Keys.Count))"
    foreach ($k in $render.Keys) {
        Write-Verbose "replacing token $k"
        $tpl = $tpl -replace [regex]::Escape($k), [string]$render[$k]
    }
    Write-Verbose "Token replacements completed; tpl length=$($tpl.Length)"

    function Write-FileSafely($path,$content) {
        if ($DryRun) { Write-Host "[DryRun] Would write: $path"; return }
        if ((Test-Path $path) -and $Backup) {
            $bak = "$path.$((Get-Date).ToString('yyyyMMddHHmmss')).bak"
            Copy-Item -Path $path -Destination $bak -Force
            Write-Host "Backed up: $path -> $bak" -ForegroundColor Yellow
        }
        if (-not (Test-Path $path) -or $Force) {
            Set-Content -Path $path -Value $content -Encoding UTF8 -NoNewline
            Write-Host "Wrote: $path" -ForegroundColor Green
        } else {
            $existing = Get-Content -Path $path -Raw
            if ($existing -ne $content) {
                Set-Content -Path $path -Value $content -Encoding UTF8 -NoNewline
                Write-Host "Updated: $path" -ForegroundColor Green
            } else {
                Write-Host "Skipped (up-to-date): $path"
            }
        }
    }

    Write-FileSafely -path $serviceTarget -content $tpl

    Write-Host "Done. Service rendered for entity: $EntityName" -ForegroundColor Green
    if ($DryRun) { exit 0 }
    exit 0

} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
