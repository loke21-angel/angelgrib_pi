param(
    [switch]$Apply,
    [string]$RepoRoot = (Resolve-Path ".").Path
)

$ErrorActionPreference = "Stop"

function Write-Step($msg) {
    Write-Host ""
    Write-Host "=== $msg ===" -ForegroundColor Cyan
}

Write-Step "AngelGRIB Testplugin staging"

if (-not (Test-Path (Join-Path $RepoRoot ".git"))) {
    throw "RepoRoot does not look like a git repository: $RepoRoot"
}

Push-Location $RepoRoot
try {
    $branch = (& git rev-parse --abbrev-ref HEAD).Trim()
    Write-Host "Current branch: $branch"

    if ($branch -ne "template-migration") {
        throw "Please switch to template-migration first: git checkout template-migration"
    }

    $status = (& git status --porcelain)
    if ($status) {
        Write-Host "Git working tree is not clean:"
        $status | ForEach-Object { Write-Host $_ }
        throw "Commit or stash changes before staging template import."
    }

    $stagingRoot = Join-Path $RepoRoot "_template_staging"
    $downloadDir = Join-Path $stagingRoot "download"
    $templateDir = Join-Path $stagingRoot "testplugin_pi"
    $overlayDir = Join-Path $stagingRoot "angelgrib_overlay"
    $report = Join-Path $stagingRoot "STAGING_REPORT.txt"

    if (Test-Path $stagingRoot) {
        Remove-Item $stagingRoot -Recurse -Force
    }

    New-Item -ItemType Directory -Force $downloadDir | Out-Null
    New-Item -ItemType Directory -Force $overlayDir | Out-Null

    Write-Step "Backing up AngelGRIB overlay files"

    $overlayItems = @(
        "README.md",
        "README_DA.md",
        "MIGRATION_PLAN_DA.md",
        "LICENSE_NOTE_DA.md",
        "docs",
        "src",
        "include",
        "scripts/download-noaa-gfs-sample.ps1",
        "scripts/check-repo-ready.ps1",
        "manual",
        "metadata",
        "template",
        "release"
    )

    foreach ($item in $overlayItems) {
        $src = Join-Path $RepoRoot $item
        if (Test-Path $src) {
            $dest = Join-Path $overlayDir $item
            New-Item -ItemType Directory -Force (Split-Path $dest -Parent) | Out-Null
            Copy-Item $src $dest -Recurse -Force
            Write-Host "Overlay saved: $item"
        }
    }

    Write-Step "Downloading OpenCPN Testplugin template"

    $zipPath = Join-Path $downloadDir "testplugin_pi.zip"
    $urls = @(
        "https://github.com/jongough/testplugin_pi/archive/refs/heads/master.zip",
        "https://github.com/jongough/testplugin_pi/archive/refs/heads/main.zip"
    )

    $downloaded = $false
    foreach ($url in $urls) {
        try {
            Write-Host "Trying: $url"
            Invoke-WebRequest -Uri $url -OutFile $zipPath
            $downloaded = $true
            break
        } catch {
            Write-Host "Failed: $url"
        }
    }

    if (-not $downloaded) {
        throw "Could not download testplugin_pi template zip."
    }

    Expand-Archive $zipPath -DestinationPath $downloadDir -Force

    $expanded = Get-ChildItem $downloadDir -Directory | Where-Object { $_.Name -like "testplugin_pi-*" } | Select-Object -First 1
    if (-not $expanded) {
        throw "Could not find expanded testplugin_pi directory."
    }

    Copy-Item $expanded.FullName $templateDir -Recurse -Force

    Write-Step "Writing report"

    $reportText = @"
AngelGRIB Testplugin staging report
===================================

RepoRoot:
$RepoRoot

Branch:
$branch

Template staged at:
$templateDir

AngelGRIB overlay staged at:
$overlayDir

Apply mode:
$Apply

Notes:
- This script intentionally stages first.
- The testplugin template is copied from jongough/testplugin_pi.
- After Apply, expect manual CMake/Plugin.cmake integration work.
"@
    $reportText | Set-Content $report -Encoding UTF8

    Write-Host "Report: $report"

    if (-not $Apply) {
        Write-Step "Dry-run complete"
        Write-Host "Template is staged but NOT applied."
        Write-Host "Inspect:"
        Write-Host "  $templateDir"
        Write-Host "  $overlayDir"
        Write-Host ""
        Write-Host "To apply:"
        Write-Host "  .\scripts\stage-testplugin-template.ps1 -Apply"
        return
    }

    Write-Step "Applying template to repository"

    $excludeNames = @(".git", "_template_staging")

    Get-ChildItem $templateDir -Force | ForEach-Object {
        if ($excludeNames -contains $_.Name) {
            return
        }
        $dest = Join-Path $RepoRoot $_.Name
        Copy-Item $_.FullName $dest -Recurse -Force
        Write-Host "Template copied: $($_.Name)"
    }

    Write-Step "Restoring AngelGRIB overlay files"

    Get-ChildItem $overlayDir -Force | ForEach-Object {
        $dest = Join-Path $RepoRoot $_.Name
        Copy-Item $_.FullName $dest -Recurse -Force
        Write-Host "Overlay restored: $($_.Name)"
    }

    Write-Step "Apply complete"

    Write-Host "Now run:"
    Write-Host "  git status"
    Write-Host "  .\scripts\check-repo-ready.ps1"
    Write-Host "  git add ."
    Write-Host "  git commit -m ""Stage OpenCPN testplugin template base"""
    Write-Host "  git push"

} finally {
    Pop-Location
}
