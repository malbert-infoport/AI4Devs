<#
.SYNOPSIS
    Add or remove endpoint methods for an entity in HelixEntities.xml (non-interactive).

.DESCRIPTION
    Modifies only the <Endpoints><Methods> section for a given entity in HelixEntities.xml.
    Designed for automation and returns a JSON summary on success or error.
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$EntityName,

    [Parameter(Mandatory=$true)]
    [string]$Methods,

    [ValidateSet('add','remove')]
    [string]$Operation = 'add',

    [string]$SolutionPath,
    [switch]$DryRun,
    [switch]$Backup,
    [switch]$Force
)

try {
    # discover solution / api project
    if (-not $SolutionPath) {
        if (Get-Command Find-Solution -ErrorAction SilentlyContinue) { $SolutionPath = Find-Solution } else { $solution = Get-ChildItem -Path '.' -Filter '*.sln' -Recurse -File | Select-Object -First 1; if (-not $solution) { throw 'Solution not found'; } $SolutionPath = $solution.FullName }
    }
    $solutionDir = Split-Path -Path $SolutionPath -Parent
    if (Get-Command Find-ProjectDirectories -ErrorAction SilentlyContinue) { $dirs = Find-ProjectDirectories -SolutionDir $solutionDir } else { $apiProj = Get-ChildItem -Path $solutionDir -Filter '*Back.Api.csproj' -Recurse -File | Select-Object -First 1; $dirs = @{ ApiDir = $apiProj.DirectoryName; HelixEntitiesPath = Join-Path $apiProj.DirectoryName 'HelixEntities.xml' } }

    if ($dirs -is [hashtable] -and $dirs.ContainsKey('HelixEntitiesPath')) { $helixEntitiesPath = $dirs.HelixEntitiesPath } elseif ($dirs.HelixEntitiesPath) { $helixEntitiesPath = $dirs.HelixEntitiesPath } else { $helixEntitiesPath = Join-Path $dirs.ApiDir 'HelixEntities.xml' }
    if (-not (Test-Path $helixEntitiesPath)) { throw "HelixEntities.xml not found at $helixEntitiesPath" }

    [xml]$xml = Get-Content -Path $helixEntitiesPath -Raw

    # canonical allowed methods
    $allMethods = @(
        'GetAll','GetAllKendoFilter','GetNewEntity','GetById','GetByIds','Insert','InsertMany','Update','UpdateMany','DeleteById','DeleteByIds','DeleteUndeleteLogicById','DeleteUndeleteLogicByIds','GetNewVersionEntity','GetVersionEntity','GetLastVersionEntity','GetNewValidityEntity','GetValidityEntity','GetAllValidity','GetAllValidityKendoFilter','GetNewAttachmentEntity','GetAllAttachments','GetAllVTAAttachmentsKendoFilter'
    )

    $requested = $Methods -split '[,;]+' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
    $unknown = $requested | Where-Object { $allMethods -notcontains $_ }
    if ($unknown.Count -gt 0) { throw "Unknown methods: $($unknown -join ', ')" }

    # find entity block (XML uses repeated <Entities> blocks)
    $root = $xml.DocumentElement
    $entityNode = $null
    foreach ($child in $root.ChildNodes) {
        if ($child -and $child.SelectSingleNode('EntityName') -and $child.SelectSingleNode('EntityName').InnerText -eq $EntityName) { $entityNode = $child; break }
    }
    if (-not $entityNode) {
        # create new Entities node
        $entityNode = $xml.CreateElement('Entities')
        $n = $xml.CreateElement('EntityName'); $n.InnerText = $EntityName; $entityNode.AppendChild($n) | Out-Null
        $v = $xml.CreateElement('ViewName'); $v.InnerText = "${EntityName}View"; $entityNode.AppendChild($v) | Out-Null
        $endpoints = $xml.CreateElement('Endpoints'); $methodsEl = $xml.CreateElement('Methods'); $endpoints.AppendChild($methodsEl) | Out-Null; $entityNode.AppendChild($endpoints) | Out-Null
        $root.AppendChild($entityNode) | Out-Null
    }

    $endpointsNode = $entityNode.SelectSingleNode('Endpoints')
    if (-not $endpointsNode) { $endpointsNode = $xml.CreateElement('Endpoints'); $entityNode.AppendChild($endpointsNode) | Out-Null }
    $methodsNode = $endpointsNode.SelectSingleNode('Methods')
    if (-not $methodsNode) { $methodsNode = $xml.CreateElement('Methods'); $endpointsNode.AppendChild($methodsNode) | Out-Null }

    $existing = @()
    foreach ($m in $methodsNode.ChildNodes) { if ($m -and $m.InnerText) { $existing += $m.InnerText } }

    $added = @(); $removed = @()
    if ($Operation -eq 'add') {
        foreach ($m in $requested) {
            if ($existing -notcontains $m) {
                $n = $xml.CreateElement('Method'); $n.InnerText = $m; $methodsNode.AppendChild($n) | Out-Null; $added += $m
            }
        }
    } else {
        foreach ($m in $requested) {
            $node = $methodsNode.ChildNodes | Where-Object { $_.InnerText -eq $m }
            if ($node) { foreach ($n in $node) { $methodsNode.RemoveChild($n) | Out-Null }; $removed += $m }
        }
    }

    if ($DryRun) {
        $result = @{ status = 'dryrun'; path = $helixEntitiesPath; added = $added; removed = $removed }
        $result | ConvertTo-Json -Depth 4
        exit 0
    }

    # create a backup before writing only if -Backup was specified
    $bak = $null
    if ($Backup) {
        $timestamp = (Get-Date).ToString('yyyyMMddHHmmss')
        $bak = "$helixEntitiesPath.$timestamp.bak"
        try {
            Copy-Item -Path $helixEntitiesPath -Destination $bak -Force -ErrorAction Stop
        } catch {
            Write-Host "Warning: could not create backup: $($_.Exception.Message)" -ForegroundColor Yellow
            $bak = $null
        }
    }

    # validate xml before saving
    if (-not $xml -or -not $xml.OuterXml -or $xml.OuterXml.Trim().Length -eq 0) {
        $err = @{ status = 'error'; message = 'XML content invalid or empty; aborting write.' }
        $err | ConvertTo-Json -Depth 4
        exit 1
    }

    try {
        $xml.Save($helixEntitiesPath)
    } catch {
        $err = @{ status = 'error'; message = "Failed to save XML: $($_.Exception.Message)" }
        $err | ConvertTo-Json -Depth 4
        exit 1
    }

    $result = @{ status = 'ok'; path = $helixEntitiesPath; added = $added; removed = $removed }
    if ($bak) { $result.backup = $bak }
    $result | ConvertTo-Json -Depth 4
    exit 0

} catch {
    $err = @{ status = 'error'; message = $_.Exception.Message }
    $err | ConvertTo-Json -Depth 4
    exit 1
}
