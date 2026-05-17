param([Parameter(Mandatory = $true)][string]$Directory)
$ErrorActionPreference = "Stop"
$dir = Resolve-Path $Directory
Push-Location $dir
try {
    $tarball = Get-ChildItem -Filter "*.tar.gz" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $tarball) { throw "No .tar.gz found in $dir" }
    Write-Host "Tarball: $($tarball.FullName)"
    Write-Host "`nArchive entries:"
    tar -tzf $tarball.FullName | Select-String "metadata.xml|angel_cpn_weather_pi.dll"
    Remove-Item ".\inspect_angel_cpn_weather" -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory ".\inspect_angel_cpn_weather" | Out-Null
    tar -xzf $tarball.FullName -C ".\inspect_angel_cpn_weather"
    Write-Host "`nMetadata:"
    Get-ChildItem ".\inspect_angel_cpn_weather" -Recurse -Filter "metadata.xml" | ForEach-Object {
        Write-Host "--- $($_.FullName)"
        Select-String -Path $_.FullName -Pattern "name|version|summary|description|tarball-url|github.com|target-arch"
    }
    Write-Host "`nUpload this exact file as GitHub Release asset:"
    Write-Host $tarball.FullName
} finally {
    Pop-Location
}
