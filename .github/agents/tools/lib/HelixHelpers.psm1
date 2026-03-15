function Find-Solution {
    param(
        [string]$StartPath = (Get-Location).ProviderPath
    )

    $dir = Get-Item -Path $StartPath
    while ($dir -ne $null) {
        $sln = Get-ChildItem -Path $dir.FullName -Filter "*.Back.sln" -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($sln) { return $sln.FullName }
        $dir = $dir.Parent
    }

    throw "No se encontró archivo .Back.sln en los directorios ascendentes desde $StartPath"
}

function Find-ProjectDirectories {
    param(
        [string]$SolutionDir
    )

    $result = @{}

    $dataModelProj = Get-ChildItem -Path $SolutionDir -Filter "*.Back.DataModel.csproj" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $dataModelProj) { throw "No se encontró proyecto Back.DataModel bajo $SolutionDir" }
    $result.DataModelDir = $dataModelProj.DirectoryName

    $dataProj = Get-ChildItem -Path $SolutionDir -Filter "*.Back.Data.csproj" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $dataProj) { throw "No se encontró proyecto Back.Data bajo $SolutionDir" }
    $result.DataDir = $dataProj.DirectoryName

    # Default repo dir inside Data project
    $result.RepoDir = Join-Path $result.DataDir "Repository"

    return $result
}

function Get-EntityFilePath {
    param(
        [string]$DataModelDir,
        [string]$EntityName
    )
    $path = Join-Path $DataModelDir ("$EntityName.cs")
    if (Test-Path $path) { return $path }

    # try search recursively
    $found = Get-ChildItem -Path $DataModelDir -Filter "$EntityName.cs" -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) { return $found.FullName }

    throw "No se encontró el archivo de entidad '$EntityName.cs' en $DataModelDir"
}

function Get-EntityProperties {
    param(
        [string]$EntityFilePath
    )
    $content = Get-Content $EntityFilePath -Raw
    $pattern = '(?ms)public\s+([\w\?<>, ]+)\s+(\w+)\s*\{\s*get;'
    $matches = [regex]::Matches($content, $pattern)
    $props = @()
    foreach ($m in $matches) { $props += $m.Groups[2].Value }
    return $props
}

function Is-VersionEntity {
    param([string[]]$Properties)
    $required = @('VersionKey','VersionNumber')
    return ($required | ForEach-Object { $_ -in $Properties }) -notcontains $false
}

function Is-ValidityEntity {
    param([string[]]$Properties)
    $required = @('VersionKey','VersionNumber','ValidityFrom','ValidityTo')
    return ($required | ForEach-Object { $_ -in $Properties }) -notcontains $false
}

Export-ModuleMember -Function Find-Solution,Find-ProjectDirectories,Get-EntityFilePath,Get-EntityProperties,Is-VersionEntity,Is-ValidityEntity
