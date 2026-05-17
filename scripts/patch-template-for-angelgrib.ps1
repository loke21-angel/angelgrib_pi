$ErrorActionPreference = "Stop"

function Replace-Text {
    param(
        [string]$Path,
        [string]$Pattern,
        [string]$Replacement
    )

    $text = Get-Content $Path -Raw
    $newText = [regex]::Replace($text, $Pattern, $Replacement, "Singleline")
    if ($newText -eq $text) {
        Write-Warning "No change for pattern in $Path: $Pattern"
    } else {
        Set-Content -Path $Path -Value $newText -Encoding UTF8
        Write-Host "Patched: $Path"
    }
}

$repo = Resolve-Path "."
if (-not (Test-Path (Join-Path $repo ".git"))) {
    throw "Run this from the repository root."
}

$branch = (& git rev-parse --abbrev-ref HEAD).Trim()
if ($branch -ne "template-migration") {
    throw "Expected branch template-migration, got $branch"
}

$cmake = Join-Path $repo "CMakeLists.txt"
if (-not (Test-Path $cmake)) {
    throw "CMakeLists.txt not found."
}

$backup = Join-Path $repo "CMakeLists.txt.before-angelgrib-v090"
if (-not (Test-Path $backup)) {
    Copy-Item $cmake $backup
    Write-Host "Backup created: $backup"
}

Write-Host "Patching CMakeLists.txt metadata..."

$replacements = @{
    'set\(VERBOSE_NAME\s+"[^"]+"\)' = 'set(VERBOSE_NAME "AngelGRIB")'
    'set\(COMMON_NAME\s+"[^"]+"\)' = 'set(COMMON_NAME "AngelGRIB")'
    'set\(TITLE_NAME\s+"[^"]+"\)' = 'set(TITLE_NAME "angelgrib")'
    'set\(PACKAGE_CONTACT\s+"[^"]+"\)' = 'set(PACKAGE_CONTACT "Rasmus Jessen")'
    'set\(PACKAGE\s+"[^"]+"\)' = 'set(PACKAGE "angelgrib")'
    'set\(SHORT_DESCRIPTION\s+"[^"]*"\s*\)' = 'set(SHORT_DESCRIPTION "Download NOAA GFS GRIB files and open them in OpenCPN GRIB plugin")'
    'set\(LONG_DESCRIPTION\s+"[^"]*"\s*\)' = 'set(LONG_DESCRIPTION "AngelGRIB adds a toolbar button to download a small NOAA GFS GRIB2 file and pass it to OpenCPN''s built-in GRIB Weather plugin.")'
    'set\(VERSION_MAJOR\s+"[^"]+"\)' = 'set(VERSION_MAJOR "0")'
    'set\(VERSION_MINOR\s+"[^"]+"\)' = 'set(VERSION_MINOR "1")'
    'set\(VERSION_PATCH\s+"[^"]+"\)' = 'set(VERSION_PATCH "0")'
    'set\(VERSION_TWEAK\s+"[^"]+"\)' = 'set(VERSION_TWEAK "0")'
    'set\(VERSION_DATE\s+"[^"]+"\)' = 'set(VERSION_DATE "17/05/2026")'
    'set\(CLOUDSMITH_BASE_REPOSITORY\s+"[^"]+"\)' = 'set(CLOUDSMITH_BASE_REPOSITORY "angelgrib")'
    'set\(XML_INFO_URL\s+"[^"]*"\s*\)' = 'set(XML_INFO_URL "https://github.com/loke21-angel/angelgrib_pi")'
}

foreach ($kv in $replacements.GetEnumerator()) {
    Replace-Text -Path $cmake -Pattern $kv.Key -Replacement $kv.Value
}

Write-Host "Patching CMakeLists.txt source/header lists..."

$srcBlock = @'
set(SRCS
    src/angelgrib_pi.cpp
    src/grib_url_builder.cpp
)
'@

$hdrBlock = @'
set(HDRS
    include/angelgrib_pi.h
    include/grib_url_builder.h
)
'@

Replace-Text -Path $cmake -Pattern 'set\(SRCS\s+.*?\)' -Replacement $srcBlock
Replace-Text -Path $cmake -Pattern 'set\(HDRS\s+.*?\)' -Replacement $hdrBlock

Write-Host "Disabling OD JSON schema validator for AngelGRIB MVP..."
Replace-Text -Path $cmake -Pattern 'set\(OD_JSON_SCHEMA_VALIDATOR\s+ON\)' -Replacement 'set(OD_JSON_SCHEMA_VALIDATOR OFF)'

# Keep template libs for now; only source/header swap is required for first experiment.
# Remove old testplugin generated/demo files from build by source list only.

Write-Host "Patching AngelGRIB source for API 1.18 template..."

$header = Join-Path $repo "include\angelgrib_pi.h"
$cpp = Join-Path $repo "src\angelgrib_pi.cpp"

if (-not (Test-Path $header)) { throw "Missing $header" }
if (-not (Test-Path $cpp)) { throw "Missing $cpp" }

Replace-Text -Path $header -Pattern 'opencpn_plugin_117' -Replacement 'opencpn_plugin_118'
Replace-Text -Path $cpp -Pattern 'opencpn_plugin_117' -Replacement 'opencpn_plugin_118'
Replace-Text -Path $cpp -Pattern 'int angelgrib_pi::GetAPIVersionMinor\(\) \{ return 17; \}' -Replacement 'int angelgrib_pi::GetAPIVersionMinor() { return 18; }'
Replace-Text -Path $cpp -Pattern 'ANGELGRIB_TOOL_POSITION' -Replacement '-1'

Write-Host ""
Write-Host "Patch complete."
Write-Host "Recommended next commands:"
Write-Host "  git diff -- CMakeLists.txt include/angelgrib_pi.h src/angelgrib_pi.cpp"
Write-Host "  git add ."
Write-Host "  git commit -m ""Adapt testplugin template for AngelGRIB build"""
Write-Host "  git push"
