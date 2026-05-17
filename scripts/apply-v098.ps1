$ErrorActionPreference = "Stop"

$repo = Resolve-Path "."
if (-not (Test-Path (Join-Path $repo ".git"))) {
    throw "Run this from repository root."
}

$branch = (& git rev-parse --abbrev-ref HEAD).Trim()
if ($branch -ne "template-migration") {
    throw "Expected branch template-migration, got $branch"
}

$sourceRoot = Split-Path -Parent $PSScriptRoot

$workflowSrc = Join-Path $sourceRoot ".github\workflows\windows-build-experiment.yml"
$workflowDst = Join-Path $repo ".github\workflows\windows-build-experiment.yml"

$pythonSrc = Join-Path $sourceRoot "scripts\inject_metadata_into_tarball.py"
$pythonDst = Join-Path $repo "scripts\inject_metadata_into_tarball.py"

if ((Resolve-Path $workflowSrc).Path -ne (Resolve-Path $workflowDst).Path) {
    Copy-Item $workflowSrc $workflowDst -Force
}

if ((Resolve-Path $pythonSrc).Path -ne (Resolve-Path $pythonDst -ErrorAction SilentlyContinue).Path) {
    Copy-Item $pythonSrc $pythonDst -Force
}

Write-Host "Applied v0.9.8 workflow YAML fix."
Write-Host ""
Write-Host "Next:"
Write-Host "  git diff -- .github/workflows/windows-build-experiment.yml scripts/inject_metadata_into_tarball.py"
Write-Host "  git add ."
Write-Host "  git commit -m ""Fix workflow YAML by moving metadata injection to script"""
Write-Host "  git push"
