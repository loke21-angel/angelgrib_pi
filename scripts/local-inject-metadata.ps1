param(
    [string]$Directory = "."
)

$ErrorActionPreference = "Stop"

Push-Location $Directory
try {
    $tarball = Get-ChildItem -Filter "*.tar.gz" | Select-Object -First 1
    $xml = Get-ChildItem -Filter "*.xml" | Select-Object -First 1

    if (-not $tarball) {
        throw "No .tar.gz file found in $Directory"
    }

    if (-not $xml) {
        throw "No .xml metadata file found in $Directory"
    }

    Write-Host "Tarball: $($tarball.FullName)"
    Write-Host "XML:     $($xml.FullName)"

    $work = Join-Path $env:TEMP ("angelgrib-local-tarball-" + [guid]::NewGuid().ToString())
    $extract = Join-Path $work "extract"
    New-Item -ItemType Directory -Force $extract | Out-Null

    tar -xzf "$($tarball.FullName)" -C "$extract"

    Copy-Item "$($xml.FullName)" (Join-Path $extract "metadata.xml") -Force

    $topDirs = Get-ChildItem $extract -Directory
    foreach ($dir in $topDirs) {
        Copy-Item "$($xml.FullName)" (Join-Path $dir.FullName "metadata.xml") -Force
    }

    $fixed = Join-Path (Get-Location) ($tarball.BaseName + "-with-metadata.tar.gz")

    Push-Location $extract
    try {
        tar -czf "$fixed" *
    } finally {
        Pop-Location
    }

    Write-Host "Created: $fixed"
    Write-Host "Metadata entries:"
    tar -tzf "$fixed" | Select-String metadata

} finally {
    Pop-Location
}
