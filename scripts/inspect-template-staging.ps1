$ErrorActionPreference = "Stop"

$root = Resolve-Path "."
$staging = Join-Path $root "_template_staging"
$template = Join-Path $staging "testplugin_pi"
$overlay = Join-Path $staging "angelgrib_overlay"

if (-not (Test-Path $staging)) {
    throw "No _template_staging directory found. Run .\scripts\stage-testplugin-template.ps1 first."
}

Write-Host "Template root:"
Write-Host $template
Write-Host ""
Write-Host "Top-level template files:"
Get-ChildItem $template | Select-Object Mode, Length, Name

Write-Host ""
Write-Host "AngelGRIB overlay:"
Get-ChildItem $overlay | Select-Object Mode, Length, Name
