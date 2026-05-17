$ErrorActionPreference = "Stop"

function Replace-Exact {
    param(
        [string]$Text,
        [string]$Old,
        [string]$New,
        [string]$Label
    )

    if (-not $Text.Contains($Old)) {
        Write-Warning "Pattern not found for $Label"
        return $Text
    }

    Write-Host "Patched CMake: $Label"
    return $Text.Replace($Old, $New)
}

function Replace-Regex {
    param(
        [string]$Text,
        [string]$Pattern,
        [string]$Replacement,
        [string]$Label
    )

    $newText = [System.Text.RegularExpressions.Regex]::Replace(
        $Text,
        $Pattern,
        $Replacement,
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    )

    if ($newText -eq $Text) {
        Write-Warning "Regex pattern not found for $Label"
    } else {
        Write-Host "Patched CMake: $Label"
    }

    return $newText
}

$repo = Resolve-Path "."
if (-not (Test-Path (Join-Path $repo ".git"))) {
    throw "Run this from repository root."
}

$branch = (& git rev-parse --abbrev-ref HEAD).Trim()
if ($branch -ne "template-migration") {
    throw "Expected branch template-migration, got $branch"
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$patchRoot = Join-Path (Split-Path -Parent $scriptDir) "patch-files"

if (-not (Test-Path $patchRoot)) {
    throw "Missing patch-files directory: $patchRoot"
}

Write-Host "Copying clean AngelGRIB source files..."

$copyItems = @(
    "include\angelgrib_pi.h",
    "include\grib_url_builder.h",
    "src\angelgrib_pi.cpp",
    "src\grib_url_builder.cpp",
    "data\angelgrib.svg"
)

foreach ($item in $copyItems) {
    $src = Join-Path $patchRoot $item
    $dst = Join-Path $repo $item
    if (-not (Test-Path $src)) {
        throw "Missing patch file: $src"
    }
    New-Item -ItemType Directory -Force (Split-Path $dst -Parent) | Out-Null
    Copy-Item $src $dst -Force
    Write-Host "Copied: $item"
}

$cmake = Join-Path $repo "CMakeLists.txt"
if (-not (Test-Path $cmake)) {
    throw "Missing CMakeLists.txt"
}

$backup = Join-Path $repo "CMakeLists.txt.before-v092"
if (-not (Test-Path $backup)) {
    Copy-Item $cmake $backup
    Write-Host "Backup created: $backup"
}

$text = Get-Content $cmake -Raw

$text = Replace-Exact $text 'set(VERBOSE_NAME "Testplugin")' 'set(VERBOSE_NAME "AngelGRIB")' 'VERBOSE_NAME'
$text = Replace-Exact $text 'set(COMMON_NAME "Testplugin")' 'set(COMMON_NAME "AngelGRIB")' 'COMMON_NAME'
$text = Replace-Exact $text 'set(TITLE_NAME "testplugin")' 'set(TITLE_NAME "angelgrib")' 'TITLE_NAME'
$text = Replace-Exact $text 'set(PACKAGE_CONTACT "Jon Gough")' 'set(PACKAGE_CONTACT "Rasmus Jessen")' 'PACKAGE_CONTACT'
$text = Replace-Exact $text 'set(PACKAGE "testplugin")' 'set(PACKAGE "angelgrib")' 'PACKAGE'
$text = Replace-Exact $text 'set(SHORT_DESCRIPTION "Plugin to test examples of the ODAPI and JSON interface for ODRAW" )' 'set(SHORT_DESCRIPTION "Download NOAA GFS GRIB files and open them in OpenCPN GRIB plugin" )' 'SHORT_DESCRIPTION'
$text = Replace-Exact $text 'set(LONG_DESCRIPTION "testplugin Plugin is used to test out the ODraw API and demonstrate how to use it successfully from another plugin" )' 'set(LONG_DESCRIPTION "AngelGRIB downloads a small NOAA GFS GRIB2 file and opens it in OpenCPN GRIB Weather plugin." )' 'LONG_DESCRIPTION'
$text = Replace-Exact $text 'set(VERSION_MAJOR "1")' 'set(VERSION_MAJOR "0")' 'VERSION_MAJOR'
$text = Replace-Exact $text 'set(VERSION_MINOR "0")' 'set(VERSION_MINOR "1")' 'VERSION_MINOR'
$text = Replace-Exact $text 'set(VERSION_PATCH "361")' 'set(VERSION_PATCH "0")' 'VERSION_PATCH'
$text = Replace-Exact $text 'set(VERSION_DATE "15/05/2026")' 'set(VERSION_DATE "17/05/2026")' 'VERSION_DATE'
$text = Replace-Exact $text 'set(CLOUDSMITH_BASE_REPOSITORY "testplugin")' 'set(CLOUDSMITH_BASE_REPOSITORY "angelgrib")' 'CLOUDSMITH_BASE_REPOSITORY'
$text = Replace-Regex $text 'set\(XML_INFO_URL\s+"[^"]*"\s*\)' 'set(XML_INFO_URL "https://github.com/loke21-angel/angelgrib_pi" )' 'XML_INFO_URL'

$projectBlock = 'add_definitions(-DUSE_S57) # ---- Section Below - Add your project SET(SRCS and SET(HDRS etc.. set(SRCS src/tpControlDialogDef.cpp src/tpControlDialogImpl.cpp src/tpicons.cpp src/tpJSON.cpp src/testplugin_pi.cpp src/tpUtils.cpp ) set(HDRS include/testplugin_pi.h include/tpicons.h include/tpControlDialogDef.h include/tpControlDialogImpl.h include/tpIconCombo.h include/tpJSON.h include/tpUtils.h ) add_definitions(-DPLUGIN_USE_SVG)'
$newProjectBlock = 'add_definitions(-DUSE_S57) # ---- Section Below - Add your project SET(SRCS and SET(HDRS etc.. set(SRCS src/angelgrib_pi.cpp src/grib_url_builder.cpp ) set(HDRS include/angelgrib_pi.h include/grib_url_builder.h ) add_definitions(-DPLUGIN_USE_SVG)'
$text = Replace-Exact $text $projectBlock $newProjectBlock 'SRCS/HDRS block'

$text = Replace-Exact $text 'option(OD_JSON_SCHEMA_VALIDATOR "Use JSON Schema validator" ON)' 'option(OD_JSON_SCHEMA_VALIDATOR "Use JSON Schema validator" OFF)' 'OD_JSON_SCHEMA_VALIDATOR option'
$text = Replace-Exact $text 'set(OD_JSON_SCHEMA_VALIDATOR ON)' 'set(OD_JSON_SCHEMA_VALIDATOR OFF)' 'OD_JSON_SCHEMA_VALIDATOR forced setting'

Set-Content -Path $cmake -Value $text -Encoding UTF8

$workflowSrc = Join-Path (Split-Path -Parent $scriptDir) ".github\workflows\windows-build-experiment.yml"
$workflowDst = Join-Path $repo ".github\workflows\windows-build-experiment.yml"
if (-not (Test-Path $workflowSrc)) {
    throw "Missing workflow patch file: $workflowSrc"
}
New-Item -ItemType Directory -Force (Split-Path $workflowDst -Parent) | Out-Null
if ((Resolve-Path $workflowSrc).Path -ne (Resolve-Path $workflowDst).Path) {
    Copy-Item $workflowSrc $workflowDst -Force
} else {
    Write-Host "Workflow already in place; skipping self-copy."
}
Write-Host "Updated workflow: .github/workflows/windows-build-experiment.yml"

Write-Host ""
Write-Host "Patch v0.9.2 complete."
Write-Host "Recommended:"
Write-Host "  git diff -- CMakeLists.txt src include .github/workflows/windows-build-experiment.yml"
Write-Host "  git add ."
Write-Host "  git commit -m ""Fix OpenCPN libs and AngelGRIB template build config"""
Write-Host "  git push"
