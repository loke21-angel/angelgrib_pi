param(
    [Parameter(Mandatory = $true)]
    [string]$Directory,

    [string]$Tag = "v0.1.0-beta",

    [string]$RepoUrl = "https://github.com/loke21-angel/angelgrib_pi"
)

$ErrorActionPreference = "Stop"

$dir = Resolve-Path $Directory

Push-Location $dir
try {
    $tarball = Get-ChildItem -Filter "*.tar.gz" |
        Where-Object { $_.Name -notlike "*release-url.tar.gz" } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $tarball) {
        throw "No .tar.gz file found in $dir"
    }

    $xmlSidecar = Get-ChildItem -Filter "*.xml" |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $xmlSidecar) {
        throw "No .xml sidecar metadata file found in $dir"
    }

    $filename = $tarball.Name
    $releaseUrl = "$RepoUrl/releases/download/$Tag/$filename"

    Write-Host "Input tarball: $($tarball.FullName)"
    Write-Host "Sidecar XML:    $($xmlSidecar.FullName)"
    Write-Host "Release URL:    $releaseUrl"

    $work = Join-Path $env:TEMP ("angelgrib-release-url-" + [guid]::NewGuid().ToString())
    $extract = Join-Path $work "extract"
    New-Item -ItemType Directory -Force $extract | Out-Null

    tar -xzf "$($tarball.FullName)" -C "$extract"

    $metadataFiles = Get-ChildItem $extract -Recurse -Filter "metadata.xml"

    if ($metadataFiles.Count -eq 0) {
        $top = Get-ChildItem $extract -Directory | Select-Object -First 1
        if (-not $top) {
            throw "Could not find package top directory inside tarball."
        }

        Copy-Item $xmlSidecar.FullName (Join-Path $extract "metadata.xml") -Force
        Copy-Item $xmlSidecar.FullName (Join-Path $top.FullName "metadata.xml") -Force
        $metadataFiles = Get-ChildItem $extract -Recurse -Filter "metadata.xml"
    }

    foreach ($metadata in $metadataFiles) {
        Write-Host "Patching metadata: $($metadata.FullName)"

        [xml]$xml = Get-Content $metadata.FullName

        $tarballNode = $xml.SelectSingleNode("/plugin/tarball-url")

        if ($null -eq $tarballNode) {
            $tarballNode = $xml.CreateElement("tarball-url")
            [void]$xml.DocumentElement.AppendChild($tarballNode)
        }

        $tarballNode.InnerText = $releaseUrl

        $summaryNode = $xml.SelectSingleNode("/plugin/summary")
        if ($null -ne $summaryNode) {
            $summaryNode.InnerText = "Download NOAA GFS GRIB files and open them in OpenCPN GRIB plugin"
        }

        $descriptionNode = $xml.SelectSingleNode("/plugin/description")
        if ($null -ne $descriptionNode) {
            $descriptionNode.InnerText = "AngelGRIB downloads a small NOAA GFS GRIB2 file and opens it in OpenCPN's GRIB Weather plugin."
        }

        $xml.Save($metadata.FullName)
    }

    $outDir = Join-Path (Get-Location) "release_upload"
    New-Item -ItemType Directory -Force $outDir | Out-Null

    $fixedPath = Join-Path $outDir $filename

    if (Test-Path $fixedPath) {
        Remove-Item $fixedPath -Force
    }

    Push-Location $extract
    try {
        tar -czf "$fixedPath" *
    } finally {
        Pop-Location
    }

    Write-Host ""
    Write-Host "Created release-ready tarball:"
    Write-Host $fixedPath

    Write-Host ""
    Write-Host "Metadata entries:"
    tar -tzf "$fixedPath" | Select-String "metadata.xml"

    Write-Host ""
    Write-Host "Patched tarball-url:"
    Remove-Item ".\inspect_release_upload" -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory ".\inspect_release_upload" | Out-Null
    tar -xzf "$fixedPath" -C ".\inspect_release_upload"
    Get-ChildItem ".\inspect_release_upload" -Recurse -Filter "metadata.xml" |
        ForEach-Object {
            Write-Host "--- $($_.FullName)"
            Select-String -Path $_.FullName -Pattern "tarball-url|github.com|summary|description"
        }

    Write-Host ""
    Write-Host "Next:"
    Write-Host "1. Create GitHub Release tag: $Tag"
    Write-Host "2. Upload this exact file as release asset:"
    Write-Host "   $fixedPath"
    Write-Host "3. Import this exact tarball in OpenCPN."

} finally {
    Pop-Location
}
