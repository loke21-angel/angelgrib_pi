$ErrorActionPreference = "Stop"

$required = @(
  "README.md",
  "MIGRATION_PLAN_DA.md",
  ".gitattributes",
  "src/angelgrib_pi.cpp",
  "src/grib_url_builder.cpp",
  "include/angelgrib_pi.h",
  "include/grib_url_builder.h",
  "manual/index.adoc",
  "scripts/download-noaa-gfs-sample.ps1"
)

$missing = @()

foreach ($file in $required) {
    if (-not (Test-Path (Join-Path $PSScriptRoot "..\$file"))) {
        $missing += $file
    }
}

if ($missing.Count -gt 0) {
    Write-Host "Missing files:"
    $missing | ForEach-Object { Write-Host " - $_" }
    exit 1
}

Write-Host "AngelGRIB repo structure looks ready for template migration."
