$ErrorActionPreference = "Stop"

$repo = Resolve-Path "."
if (-not (Test-Path (Join-Path $repo ".git"))) {
    throw "Run this from repository root."
}

$branch = (& git rev-parse --abbrev-ref HEAD).Trim()
if ($branch -ne "template-migration") {
    throw "Expected branch template-migration, got $branch"
}

$source = Join-Path (Split-Path -Parent $PSScriptRoot) ".github\workflows\windows-build-experiment.yml"
$dest = Join-Path $repo ".github\workflows\windows-build-experiment.yml"

if (-not (Test-Path $source)) {
    throw "Missing source workflow: $source"
}

Copy-Item $source $dest -Force

Write-Host "Replaced workflow with v0.9.7 Python metadata version."
Write-Host ""
Write-Host "Next:"
Write-Host "  git diff -- .github/workflows/windows-build-experiment.yml"
Write-Host "  git add .github/workflows/windows-build-experiment.yml"
Write-Host "  git commit -m ""Replace workflow with Python metadata tarball handling"""
Write-Host "  git push"
