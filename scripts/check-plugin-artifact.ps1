param(
    [Parameter(Mandatory = $true)]
    [string]$Directory
)

$ErrorActionPreference = "Stop"

$dir = Resolve-Path $Directory

Push-Location $dir
try {
    $tarball = Get-ChildItem -Filter "*.tar.gz" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $tarball) {
        throw "No .tar.gz found in $dir"
    }

    Write-Host "Checking: $($tarball.FullName)"
    Write-Host ""
    Write-Host "Metadata entries:"
    tar -tzf $tarball.FullName | Select-String metadata

    Write-Host ""
    Write-Host "DLL entries:"
    tar -tzf $tarball.FullName | Select-String "angelgrib_pi.dll"

    Remove-Item ".\inspect_plugin" -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory ".\inspect_plugin" | Out-Null
    tar -xzf $tarball.FullName -C ".\inspect_plugin"

    Write-Host ""
    Write-Host "Metadata content:"
    Get-ChildItem ".\inspect_plugin" -Recurse -Filter "metadata.xml" |
        ForEach-Object {
            Write-Host "--- $($_.FullName)"
            Get-Content $_.FullName
        }

} finally {
    Pop-Location
}
