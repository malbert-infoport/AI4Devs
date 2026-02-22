<#
.SYNOPSIS
    Interactive manager to add/remove Helix6 endpoints for an entity using a single script.
#>

param(
    [Parameter(Mandatory=$true)] [string]$EntityName,
    [string]$SolutionPath,
    [switch]$DryRun,
    [switch]$Backup,
    [switch]$Force,
    [string]$Methods
)

Import-Module (Join-Path $PSScriptRoot 'lib\HelixHelpers.psm1') -Force -DisableNameChecking -ErrorAction SilentlyContinue

# discover helix entities xml
function Find-SolutionUp {
    param([string]$startDir)
    $dir = $startDir
    while ($dir) {
        $sln = Get-ChildItem -Path $dir -Filter '*.sln' -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($sln) { return $sln.FullName }
        $parent = Split-Path -Path $dir -Parent
        if ([string]::IsNullOrEmpty($parent) -or $parent -eq $dir) { break }
        $dir = $parent
    }
    return $null
}

if (-not $SolutionPath) {
    $start = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
    $found = Find-SolutionUp -startDir $start
    if (-not $found) { $found = Find-SolutionUp -startDir (Get-Location) }
    if ($found) { $SolutionPath = $found }
}
$solutionDir = if ($SolutionPath) { Split-Path -Path $SolutionPath -Parent } else { Split-Path -Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -Parent }
$apiProj = Get-ChildItem -Path $solutionDir -Filter '*Back.Api.csproj' -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
$helixEntitiesPath = if ($apiProj) { Join-Path $apiProj.DirectoryName 'HelixEntities.xml' } else { Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'HelixEntities.xml' }
if (-not (Test-Path $helixEntitiesPath)) { Write-Host "HelixEntities.xml not found at $helixEntitiesPath" -ForegroundColor Red; exit 1 }

# Debug prints to trace execution when running non-interactively
Write-Host "DEBUG: Manage-Controller started" -ForegroundColor DarkCyan
Write-Host "DEBUG: Parameters -> EntityName='$EntityName' SolutionPath='$SolutionPath' DryRun=$DryRun Backup=$Backup Force=$Force Methods='$Methods'"
if ($apiProj) { $ap = $apiProj.FullName } else { $ap = '<null>' }
Write-Host "DEBUG: solutionDir='$solutionDir' apiProj='$ap' helixEntitiesPath='$helixEntitiesPath'"

[xml]$helixXml = Get-Content -Path $helixEntitiesPath -Raw
$root = $helixXml.DocumentElement

# detect entity flags
$entityNode = $null
foreach ($child in $root.ChildNodes) { if ($child.SelectSingleNode('EntityName') -and $child.SelectSingleNode('EntityName').InnerText -eq $EntityName) { $entityNode = $child; break } }
$isVersion = $false; $isValidity = $false
if ($entityNode) {
    $vNode = $entityNode.SelectSingleNode('IsVersionEntity'); if ($vNode -and $vNode.InnerText -match 'true') { $isVersion = $true }
    $valNode = $entityNode.SelectSingleNode('IsValidityEntity'); if ($valNode -and $valNode.InnerText -match 'true') { $isValidity = $true }
}

# base available methods
$availableMethods = @(
    'GetAll','GetAllKendoFilter','GetNewEntity','GetById','GetByIds','Insert','InsertMany','Update','UpdateMany','DeleteById','DeleteByIds','DeleteUndeleteLogicById','DeleteUndeleteLogicByIds','GetNewAttachmentEntity','GetAllAttachments','GetAllVTAAttachmentsKendoFilter'
)
if ($isVersion) { $availableMethods += 'GetNewVersionEntity','GetVersionEntity','GetLastVersionEntity' }
if ($isValidity) { $availableMethods += 'GetNewValidityEntity','GetValidityEntity','GetAllValidity','GetAllValidityKendoFilter' }

# read currently configured methods for entity
$configured = @()
if ($entityNode) {
    $methodsNode = $entityNode.SelectSingleNode('Endpoints/Methods')
    if ($methodsNode) { foreach ($n in $methodsNode.ChildNodes) { if ($n -and $n.InnerText) { $configured += $n.InnerText } } }
}

# path to helper script (used by interactive flow)
$setScript = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'Set-EntityEndpoints.ps1'

function ShowMenu {
    Write-Host "Available methods (green = configured):" -ForegroundColor Cyan
    for ($i = 0; $i -lt $availableMethods.Count; $i++) {
        $idx = $i + 1
        $m = $availableMethods[$i]
        if ($configured -contains $m) { Write-Host ("{0,2}) {1}" -f $idx, $m) -ForegroundColor Green } else { Write-Host ("{0,2}) {1}" -f $idx, $m) }
    }
}

# Ensure Update-EndpointFiles is available, then interactive handling
function Update-EndpointFiles {
    param(
        [string]$EntityName,
        [array]$Methods,
        [string]$ApiProjectDir,
        [string]$SolutionName,
        [switch]$DryRun
    )

    $baseDir = Join-Path $ApiProjectDir 'Endpoints\Base'
    $genDir = Join-Path $baseDir 'Generator'
    if (-not (Test-Path $baseDir)) { New-Item -ItemType Directory -Path $baseDir -Force | Out-Null }
    if (-not (Test-Path $genDir)) { New-Item -ItemType Directory -Path $genDir -Force | Out-Null }

    $rootName = $SolutionName -replace '\.Api$',''

    # Update GenericEndpoints.cs
    $genericPath = Join-Path $baseDir 'GenericEndpoints.cs'
    if (-not (Test-Path $genericPath)) {
        $genericContent = @"
// ------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by Helix 6 Generator.
//
//     Changes to this file could cause incorrect behavior and will be lost if the code is regenerated.
// </auto-generated>
// ------------------------------------------------------------------------------
using $rootName.Api.Endpoints.Base.Generator;

namespace $rootName.Api.Endpoints.Base
{
    public static class GenericEndpoints
    {
        public static void MapGenericEndpoints(this WebApplication app)
        {
        }
    }
}
"@
        if ($DryRun) { Write-Host "Would create $genericPath"; Write-Host $genericContent; } else { $genericContent | Out-File -FilePath $genericPath -Encoding utf8 }
    }

    # ensure Map{Entity}Endpoints call is present in GenericEndpoints.cs
    $genCall = "            app.Map${EntityName}Endpoints();"
    $gText = Get-Content -Path $genericPath -Raw
    if ($gText -notmatch [regex]::Escape($genCall)) {
        $gText = $gText -replace '(public static void MapGenericEndpoints\(this WebApplication app\)\s*\{)\s*\}', "`$1`r`n$genCall`r`n        }"
        if ($DryRun) { Write-Host "Would update $genericPath to add map call for $EntityName"; } else { $gText | Out-File -FilePath $genericPath -Encoding utf8 }
    }

    # Generate entity endpoints file
    $entityFile = Join-Path $genDir ("${EntityName}Endpoints.cs")
    $svc = "${EntityName}Service"
    $view = "${EntityName}View"
    $entityType = $EntityName
    $meta = "${EntityName}ViewMetadata"

    $usings = @(
        'Helix6.Base.Domain',
        'Helix6.Base.Domain.Endpoints',
        'Helix6.Base.Helpers',
        "$rootName.DataModel",
        "$rootName.Entities.Views",
        "$rootName.Entities.Views.Metadata",
        "$rootName.Entities.Views.Base"
    )
    # include services using if services project exists
    if (Test-Path (Join-Path (Split-Path -Parent $ApiProjectDir) ("$rootName.Services"))) { $usings += "$rootName.Services" }

    $lines = @()
    $lines += '// ------------------------------------------------------------------------------'
    $lines += '// <auto-generated>'
    $lines += "//     This code was generated by Helix 6 Generator."
    $lines += '//  '
    $lines += "//     Changes to this file could cause incorrect behavior and will be lost if the code is regenerated."
    $lines += '// </auto-generated>'
    $lines += '// ------------------------------------------------------------------------------'
    foreach ($u in $usings) { $lines += "using $u;" }
    $lines += ''
    $lines += "namespace $rootName.Api.Endpoints.Base.Generator"
    $lines += '{'
    $lines += "    public static class ${EntityName}Endpoints"
    $lines += '    {'
    $lines += "        /// <summary>"
    $lines += "        /// Maps selected endpoints of the entity <type>$EntityName</type>."
    $lines += "        /// </summary>"
    $lines += '        /// <param name="app"></param>'
    $lines += "        public static void Map${EntityName}Endpoints(this WebApplication app)"
    $lines += "        {"

    foreach ($m in $Methods) {
        switch ($m) {
            'GetAll' { $lines += '            EndpointHelper.GenerateGetAllEndpoint<' + $svc + ', ' + $view + ', ' + $entityType + ', ' + $meta + '>(app, "/api/' + $EntityName + '/GetAll", new EndpointAccess(HelixEnums.SecurityLevel.Read));' }
            'GetAllKendoFilter' { $lines += '            EndpointHelper.GenerateGetAllKendoFilterEndpoint<' + $svc + ', ' + $view + ', ' + $entityType + ', ' + $meta + '>(app, "/api/' + $EntityName + '/GetAllKendoFilter", new EndpointAccess(HelixEnums.SecurityLevel.Read));' }
            'GetNewEntity' { $lines += '            EndpointHelper.GenerateGetNewEntityEndpoint<' + $svc + ', ' + $view + ', ' + $entityType + ', ' + $meta + '>(app, "/api/' + $EntityName + '/GetNewEntity", new EndpointAccess(HelixEnums.SecurityLevel.Modify));' }
            'GetById' { $lines += '            EndpointHelper.GenerateGetByIdEndpoint<' + $svc + ', ' + $view + ', ' + $entityType + ', ' + $meta + '>(app, "/api/' + $EntityName + '/GetById", new EndpointAccess(HelixEnums.SecurityLevel.Read));' }
            'GetByIds' { $lines += '            EndpointHelper.GenerateGetByIdsEndpoint<' + $svc + ', ' + $view + ', ' + $entityType + ', ' + $meta + '>(app, "/api/' + $EntityName + '/GetByIds", new EndpointAccess(HelixEnums.SecurityLevel.Read));' }
            'Insert' { $lines += '            EndpointHelper.GenerateInsertEndpoint<' + $svc + ', ' + $view + ', ' + $entityType + ', ' + $meta + '>(app, "/api/' + $EntityName + '/Insert", new EndpointAccess(HelixEnums.SecurityLevel.Modify));' }
            'InsertMany' { $lines += '            EndpointHelper.GenerateInsertManyEndpoint<' + $svc + ', ' + $view + ', ' + $entityType + ', ' + $meta + '>(app, "/api/' + $EntityName + '/InsertMany", new EndpointAccess(HelixEnums.SecurityLevel.Modify));' }
            'Update' { $lines += '            EndpointHelper.GenerateUpdateEndpoint<' + $svc + ', ' + $view + ', ' + $entityType + ', ' + $meta + '>(app, "/api/' + $EntityName + '/Update", new EndpointAccess(HelixEnums.SecurityLevel.Modify));' }
            'UpdateMany' { $lines += '            EndpointHelper.GenerateUpdateManyEndpoint<' + $svc + ', ' + $view + ', ' + $entityType + ', ' + $meta + '>(app, "/api/' + $EntityName + '/UpdateMany", new EndpointAccess(HelixEnums.SecurityLevel.Modify));' }
            'DeleteById' { $lines += '            EndpointHelper.GenerateDeleteByIdEndpoint<' + $svc + ', ' + $view + ', ' + $entityType + ', ' + $meta + '>(app, "/api/' + $EntityName + '/DeleteById", new EndpointAccess(HelixEnums.SecurityLevel.Modify));' }
            'DeleteByIds' { $lines += '            EndpointHelper.GenerateDeleteByIdsEndpoint<' + $svc + ', ' + $view + ', ' + $entityType + ', ' + $meta + '>(app, "/api/' + $EntityName + '/DeleteByIds", new EndpointAccess(HelixEnums.SecurityLevel.Modify));' }
            'DeleteUndeleteLogicById' { $lines += '            EndpointHelper.GenerateDeleteUndeleteLogicByIdEndpoint<' + $svc + ', ' + $view + ', ' + $entityType + ', ' + $meta + '>(app, "/api/' + $EntityName + '/DeleteUndeleteLogicById", new EndpointAccess(HelixEnums.SecurityLevel.Modify));' }
            'DeleteUndeleteLogicByIds' { $lines += '            EndpointHelper.GenerateDeleteUndeleteLogicByIdsEndpoint<' + $svc + ', ' + $view + ', ' + $entityType + ', ' + $meta + '>(app, "/api/' + $EntityName + '/DeleteUndeleteLogicByIds", new EndpointAccess(HelixEnums.SecurityLevel.Modify));' }
            'GetNewAttachmentEntity' { $lines += '            EndpointHelper.GenerateGetNewAttachmentEntityEndpoint<' + $svc + ', ' + $view + ', ' + $entityType + ', AttachmentView, ' + $meta + '>(app, "/api/' + $EntityName + '/GetNewAttachmentEntity", new EndpointAccess(HelixEnums.SecurityLevel.Modify));' }
            'GetAllAttachments' { $lines += '            EndpointHelper.GenerateGetAllAttachmentsEndpoint<' + $svc + ', ' + $view + ', ' + $entityType + ', AttachmentView, ' + $meta + '>(app, "/api/' + $EntityName + '/GetAllAttachments", new EndpointAccess(HelixEnums.SecurityLevel.Read));' }
            'GetAllVTAAttachmentsKendoFilter' { $lines += '            VTA_AttachmentEndpoints.GenerateGetAllVTAAttachmentsKendoFilterEndpoint<' + $svc + ', ' + $view + ', ' + $entityType + ', ' + $meta + '>(app, "/api/' + $EntityName + '/GetAllVTAAttachmentsKendoFilter", new EndpointAccess(HelixEnums.SecurityLevel.Read));' }
            'GetAllValidity' { $lines += '            EndpointHelper.GenerateGetAllValidityEndpoint<' + $svc + ', ' + $view + ', ' + $entityType + ', ' + $meta + '>(app, "/api/' + $EntityName + '/GetAllValidity", new EndpointAccess(HelixEnums.SecurityLevel.Read));' }
            'GetAllValidityKendoFilter' { $lines += '            EndpointHelper.GenerateGetAllValidityKendoFilterEndpoint<' + $svc + ', ' + $view + ', ' + $entityType + ', ' + $meta + '>(app, "/api/' + $EntityName + '/GetAllValidityKendoFilter", new EndpointAccess(HelixEnums.SecurityLevel.Read));' }
            'GetNewValidityEntity' { $lines += '            EndpointHelper.GenerateGetNewValidityEntityEndpoint<' + $svc + ', ' + $view + ', ' + $entityType + ', ' + $meta + '>(app, "/api/' + $EntityName + '/GetNewValidityEntity", new EndpointAccess(HelixEnums.SecurityLevel.Modify));' }
            'GetValidityEntity' { $lines += '            EndpointHelper.GenerateGetValidityEntityEndpoint<' + $svc + ', ' + $view + ', ' + $entityType + ', ' + $meta + '>(app, "/api/' + $EntityName + '/GetValidityEntity", new EndpointAccess(HelixEnums.SecurityLevel.Read));' }
            'GetNewVersionEntity' { $lines += '            EndpointHelper.GenerateGetNewVersionEntityEndpoint<' + $svc + ', ' + $view + ', ' + $entityType + ', ' + $meta + '>(app, "/api/' + $EntityName + '/GetNewVersionEntity", new EndpointAccess(HelixEnums.SecurityLevel.Modify));' }
            'GetVersionEntity' { $lines += '            EndpointHelper.GenerateGetVersionEntityEndpoint<' + $svc + ', ' + $view + ', ' + $entityType + ', ' + $meta + '>(app, "/api/' + $EntityName + '/GetVersionEntity", new EndpointAccess(HelixEnums.SecurityLevel.Read));' }
            'GetLastVersionEntity' { $lines += '            EndpointHelper.GenerateGetLastVersionEntityEndpoint<' + $svc + ', ' + $view + ', ' + $entityType + ', ' + $meta + '>(app, "/api/' + $EntityName + '/GetLastVersionEntity", new EndpointAccess(HelixEnums.SecurityLevel.Read));' }
            default { $lines += '            // Unsupported endpoint: ' + $m }
        }
    }

    $lines += "        }"
    $lines += "    }"
    $lines += '}'

    $content = $lines -join "`r`n"
    if ($DryRun) { Write-Host "Would write $entityFile"; Write-Host $content } else { $content | Out-File -FilePath $entityFile -Encoding utf8 }

}

# Interactive handling: if -Methods not provided, prompt user for commands (loop until empty)
$interactiveMode = $false
if (-not $Methods) {
    $interactiveMode = $true
    Write-Host "Entering interactive mode for entity '$EntityName'. Enter blank line to finish." -ForegroundColor Cyan
    while ($true) {
        ShowMenu
        $input = Read-Host "Enter commands (e.g. 1C,2C,3D, +Insert, -GetById). Empty to finish"
        if ([string]::IsNullOrWhiteSpace($input)) { break }

        $tokens = $input -split '[, ]+' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
        $addedLocal = @(); $removedLocal = @()
        foreach ($cmd in $tokens) {
            if ($cmd -match '^\+(.*)') {
                $m = $matches[1].Trim()
                if ($availableMethods -contains $m) { if ($addedLocal -notcontains $m -and -not ($configured -contains $m)) { $addedLocal += $m } }
                else { Write-Host "Método no disponible: $m" -ForegroundColor Yellow }
                continue
            }
            if ($cmd -match '^-(.*)') {
                $m = $matches[1].Trim()
                if ($availableMethods -contains $m) { if ($removedLocal -notcontains $m -and ($configured -contains $m)) { $removedLocal += $m } }
                else { Write-Host "Método no disponible: $m" -ForegroundColor Yellow }
                continue
            }
            if ($cmd -match '^(\d+)(C|E|D)$') {
                $idx = [int]$matches[1] - 1; $action = $matches[2]
                if ($idx -ge 0 -and $idx -lt $availableMethods.Count) {
                    $method = $availableMethods[$idx]
                    if ($action -match '[cC]') { if ($addedLocal -notcontains $method -and -not ($configured -contains $method)) { $addedLocal += $method } }
                    else { if ($removedLocal -notcontains $method -and ($configured -contains $method)) { $removedLocal += $method } }
                }
                continue
            }
            # bare method name: toggle
            if ($availableMethods -contains $cmd) {
                if ($configured -contains $cmd) {
                    if ($removedLocal -notcontains $cmd) { $removedLocal += $cmd }
                } else {
                    if ($addedLocal -notcontains $cmd) { $addedLocal += $cmd }
                }
                continue
            }
            Write-Host "Comando no reconocido: $cmd" -ForegroundColor Yellow
        }

        if (($addedLocal.Count -eq 0) -and ($removedLocal.Count -eq 0)) { Write-Host "No changes for this input." -ForegroundColor Yellow; continue }

        # apply changes for this iteration
        if ($addedLocal.Count -gt 0) {
            $meth = $addedLocal -join ','
            $args = @('-EntityName', $EntityName, '-Methods', $meth, '-Operation', 'add')
            if ($SolutionPath) { $args += @('-SolutionPath', $SolutionPath) }
            if ($DryRun) { $args += '-DryRun' }
            if ($Backup) { $args += '-Backup' }
            if ($Force) { $args += '-Force' }
            Write-Host "Invoking Set-EntityEndpoints to add: $meth"
            & pwsh -NoProfile -File $setScript @args
        }
        if ($removedLocal.Count -gt 0) {
            $meth = $removedLocal -join ','
            $args = @('-EntityName', $EntityName, '-Methods', $meth, '-Operation', 'remove')
            if ($SolutionPath) { $args += @('-SolutionPath', $SolutionPath) }
            if ($DryRun) { $args += '-DryRun' }
            if ($Backup) { $args += '-Backup' }
            if ($Force) { $args += '-Force' }
            Write-Host "Invoking Set-EntityEndpoints to remove: $meth"
            & pwsh -NoProfile -File $setScript @args
        }

        # refresh configured methods from file so menu shows updated state
        [xml]$helixXml = Get-Content -Path $helixEntitiesPath -Raw
        $root = $helixXml.DocumentElement
        $entityNode = $null
        foreach ($child in $root.ChildNodes) { if ($child.SelectSingleNode('EntityName') -and $child.SelectSingleNode('EntityName').InnerText -eq $EntityName) { $entityNode = $child; break } }
        $configured = @()
        if ($entityNode) {
            $methodsNode = $entityNode.SelectSingleNode('Endpoints/Methods')
            if ($methodsNode) { foreach ($n in $methodsNode.ChildNodes) { if ($n -and $n.InnerText) { $configured += $n.InnerText } } }
        }
        Write-Host "Updated configured endpoints: $($configured -join ', ')" -ForegroundColor Cyan
    }
} else {
    # Methods parameter provided: split into command tokens
    $commands = $Methods -split '[, ]+' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
}

    

# non-interactive path (old behaviour)
if (-not $interactiveMode) {
    $added = @(); $removed = @()
    foreach ($cmd in $commands) {
    if ($cmd -match '^\+(.*)') {
        $m = $matches[1].Trim()
        if ($availableMethods -contains $m) { if ($added -notcontains $m -and -not ($configured -contains $m)) { $added += $m } }
        else { Write-Host "Método no disponible: $m" -ForegroundColor Yellow }
        continue
    }
    if ($cmd -match '^-(.*)') {
        $m = $matches[1].Trim()
        if ($availableMethods -contains $m) { if ($removed -notcontains $m -and ($configured -contains $m)) { $removed += $m } }
        else { Write-Host "Método no disponible: $m" -ForegroundColor Yellow }
        continue
    }
    if ($cmd -match '^(\d+)(C|E|D)$') {
        $idx = [int]$matches[1] - 1; $action = $matches[2]
        if ($idx -ge 0 -and $idx -lt $availableMethods.Count) {
            $method = $availableMethods[$idx]
            if ($action -match '[cC]') { if ($added -notcontains $method -and -not ($configured -contains $method)) { $added += $method } }
            else { if ($removed -notcontains $method -and ($configured -contains $method)) { $removed += $method } }
        }
        continue
    }
    # bare method name: toggle
    if ($availableMethods -contains $cmd) {
        if ($configured -contains $cmd) {
            if ($removed -notcontains $cmd) { $removed += $cmd }
        } else {
            if ($added -notcontains $cmd) { $added += $cmd }
        }
        continue
    }
    Write-Host "Comando no reconocido: $cmd" -ForegroundColor Yellow
    }

    if (($added.Count -eq 0) -and ($removed.Count -eq 0)) { Write-Host 'No changes requested.'; exit 0 }

    # delegate to Set-EntityEndpoints.ps1
    if ($added.Count -gt 0) {
    $meth = $added -join ','
    $args = @('-EntityName', $EntityName, '-Methods', $meth, '-Operation', 'add')
    if ($SolutionPath) { $args += @('-SolutionPath', $SolutionPath) }
    if ($DryRun) { $args += '-DryRun' }
    if ($Backup) { $args += '-Backup' }
    if ($Force) { $args += '-Force' }
    Write-Host "Invoking Set-EntityEndpoints to add: $meth"
    & pwsh -NoProfile -File $setScript @args
}
if ($removed.Count -gt 0) {
    $meth = $removed -join ','
    $args = @('-EntityName', $EntityName, '-Methods', $meth, '-Operation', 'remove')
    if ($SolutionPath) { $args += @('-SolutionPath', $SolutionPath) }
    if ($DryRun) { $args += '-DryRun' }
    if ($Backup) { $args += '-Backup' }
    if ($Force) { $args += '-Force' }
    Write-Host "Invoking Set-EntityEndpoints to remove: $meth"
    & pwsh -NoProfile -File $setScript @args
}
}

# show final configured endpoints for entity
[xml]$helixXml = Get-Content -Path $helixEntitiesPath -Raw
$root = $helixXml.DocumentElement
$entityNode = $null
foreach ($child in $root.ChildNodes) { if ($child.SelectSingleNode('EntityName') -and $child.SelectSingleNode('EntityName').InnerText -eq $EntityName) { $entityNode = $child; break } }
if ($entityNode) {
    $methodsNode = $entityNode.SelectSingleNode('Endpoints/Methods')
    $final = @()
    if ($methodsNode) { foreach ($n in $methodsNode.ChildNodes) { if ($n -and $n.InnerText) { $final += $n.InnerText } } }
    Write-Host ("Final configured endpoints for {0}: {1}" -f $EntityName, ($final -join ', ')) -ForegroundColor Cyan
} else {
    Write-Host "Entity $EntityName not found after changes." -ForegroundColor Yellow
}
    # attempt to generate/update C# endpoint files (DryRun will only show)
    try {
        if ($apiProj) {
            $solutionName = [System.IO.Path]::GetFileNameWithoutExtension($apiProj.Name)
            $cmd = Get-Command Update-EndpointFiles -ErrorAction SilentlyContinue
            if ($cmd) {
                Update-EndpointFiles -EntityName $EntityName -Methods $final -ApiProjectDir $apiProj.DirectoryName -SolutionName $solutionName -DryRun:$DryRun

                # After generating endpoint files, ensure the corresponding Service exists; if not, invoke Create-Service.ps1
                try {
                    $servicesProj = Get-ChildItem -Path $solutionDir -Filter "*.Back.Services.csproj" -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
                    if ($servicesProj) { $servicesDir = $servicesProj.DirectoryName } else { $servicesDir = Join-Path $solutionDir 'Services' }
                    $serviceFile = Join-Path $servicesDir ("${EntityName}Service.cs")
                    if (-not (Test-Path $serviceFile)) {
                        $createServiceScript = Join-Path $PSScriptRoot 'Create-Service.ps1'
                        if (Test-Path $createServiceScript) {
                            Write-Host "Service not found: $serviceFile. Invoking Create-Service.ps1 to generate it." -ForegroundColor Yellow
                            $csArgs = @('-EntityName', $EntityName)
                            if ($SolutionPath) { $csArgs += @('-SolutionPath', $SolutionPath) }
                            if ($DryRun) { $csArgs += '-DryRun' }
                            if ($Backup) { $csArgs += '-Backup' }
                            if ($Force) { $csArgs += '-Force' }
                            & pwsh -NoProfile -File $createServiceScript @csArgs
                        } else {
                            Write-Host "Create-Service.ps1 not found at $createServiceScript; skipping service generation." -ForegroundColor Yellow
                        }
                    } else {
                        Write-Host "Service exists: $serviceFile" -ForegroundColor Green
                    }
                } catch {
                    Write-Host "Warning: failed to invoke Create-Service.ps1: $($_.Exception.Message)" -ForegroundColor Yellow
                }

            } else {
                Write-Host "Update-EndpointFiles function not available at runtime." -ForegroundColor Yellow
            }
        } else {
            Write-Host "No API project detected; skipping endpoint files generation." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Warning: failed to generate endpoint files: $($_.Exception.Message)" -ForegroundColor Yellow
    }

