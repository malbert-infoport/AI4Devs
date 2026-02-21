$DryRun = $false
$Backup = $true
function Write-FileSafely($path,$content) {
    if ($DryRun) { Write-Host "[DryRun] Would write: $path"; return }
    if (Test-Path $path -and $Backup) {
        $bak = "$path.$((Get-Date).ToString('yyyyMMddHHmmss')).bak"
        Copy-Item -Path $path -Destination $bak -Force
        Write-Host "Backup created: $bak"
    }
    Set-Content -Path $path -Value $content -Encoding UTF8 -NoNewline
    Write-Host "Wrote: $path"
}

Write-FileSafely -path "C:\temp\foo.txt" -content "hello"
