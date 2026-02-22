param(
    [Parameter(Mandatory=$true)] [string]$EntityName
)

$helixPath = 'c:\Ai4Devs\AI4Devs\InfoportOneAdmon.Back\InfoportOneAdmon.Back.Api\HelixEntities.xml'
if (-not (Test-Path $helixPath)) { Write-Host "HelixEntities.xml not found at $helixPath" -ForegroundColor Red; exit 1 }

[xml]$x = Get-Content -Path $helixPath -Raw
$root = $x.DocumentElement
$entity = $null
foreach ($child in $root.ChildNodes) { if ($child.SelectSingleNode('EntityName') -and $child.SelectSingleNode('EntityName').InnerText -eq $EntityName) { $entity = $child; break } }
if (-not $entity) { Write-Host "Entity $EntityName not found in HelixEntities.xml"; exit 0 }

$isVersion = $false; $isValidity = $false
$vNode = $entity.SelectSingleNode('IsVersionEntity'); if ($vNode -and $vNode.InnerText -match 'true') { $isVersion = $true }
$valNode = $entity.SelectSingleNode('IsValidityEntity'); if ($valNode -and $valNode.InnerText -match 'true') { $isValidity = $true }

$available = @(
    'GetAll','GetAllKendoFilter','GetNewEntity','GetById','GetByIds','Insert','InsertMany','Update','UpdateMany','DeleteById','DeleteByIds','DeleteUndeleteLogicById','DeleteUndeleteLogicByIds','GetNewAttachmentEntity','GetAllAttachments','GetAllVTAAttachmentsKendoFilter'
)
if ($isVersion) { $available += 'GetNewVersionEntity','GetVersionEntity','GetLastVersionEntity' }
if ($isValidity) { $available += 'GetNewValidityEntity','GetValidityEntity','GetAllValidity','GetAllValidityKendoFilter' }

$configured = @()
$methodsNode = $entity.SelectSingleNode('Endpoints/Methods')
if ($methodsNode) { foreach ($n in $methodsNode.ChildNodes) { if ($n -and $n.InnerText) { $configured += $n.InnerText } } }

Write-Host "Available methods (green = configured):" -ForegroundColor Cyan
for ($i=0; $i -lt $available.Count; $i++) {
    $idx = $i + 1
    $m = $available[$i]
    if ($configured -contains $m) { Write-Host ("{0,2}) {1} (configured)" -f $idx, $m) -ForegroundColor Green } else { Write-Host ("{0,2}) {1}" -f $idx, $m) }
}

Write-Host ("`nConfigured for {0}:" -f $EntityName) -ForegroundColor Cyan
if ($configured.Count -eq 0) { Write-Host '(none)' } else { Write-Host ($configured -join ', ') }
