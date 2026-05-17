$ErrorActionPreference = "Stop"

$repo = Resolve-Path "."
if (-not (Test-Path (Join-Path $repo ".git"))) {
    throw "Run this from repository root."
}

$branch = (& git rev-parse --abbrev-ref HEAD).Trim()
if ($branch -ne "template-migration") {
    throw "Expected branch template-migration, got $branch"
}

$workflow = Join-Path $repo ".github\workflows\windows-build-experiment.yml"
if (-not (Test-Path $workflow)) {
    throw "Missing workflow: $workflow"
}

$backup = Join-Path $repo ".github\workflows\windows-build-experiment.yml.before-v095"
if (-not (Test-Path $backup)) {
    Copy-Item $workflow $backup
    Write-Host "Backup created: $backup"
}

$text = Get-Content $workflow -Raw

# Remove any previous v0.9.4 metadata injection block if present.
$text = [regex]::Replace(
    $text,
    '\n      - name: Inject metadata\.xml into plugin tarball[\s\S]*?(?=\n      - name: List build output)',
    '',
    'Singleline'
)

$needle = @'
      - name: List build output
        if: always()
        shell: pwsh
        run: |
          Get-ChildItem -Recurse build -ErrorAction SilentlyContinue | Select-Object FullName, Length | Out-String -Width 240
'@

$insert = @'
      - name: Inject metadata.xml into plugin tarball
        shell: pwsh
        run: |
          $ErrorActionPreference = "Stop"

          $tarballs = Get-ChildItem -Path build -Recurse -Filter "*.tar.gz"
          $xmlFiles = Get-ChildItem -Path build -Recurse -Filter "*.xml" |
            Where-Object { $_.Name -like "angelgrib_pi-*.xml" -or $_.Name -like "*angelgrib*.xml" }

          if ($tarballs.Count -eq 0) {
            throw "No .tar.gz plugin tarball found under build."
          }

          if ($xmlFiles.Count -eq 0) {
            throw "No AngelGRIB metadata XML found under build."
          }

          $xml = $xmlFiles | Select-Object -First 1
          Write-Host "Using metadata XML: $($xml.FullName)"

          foreach ($tarball in $tarballs) {
            Write-Host "Patching tarball: $($tarball.FullName)"

            $work = Join-Path $env:RUNNER_TEMP ("angelgrib-tarball-" + [guid]::NewGuid().ToString())
            $extract = Join-Path $work "extract"
            New-Item -ItemType Directory -Force $extract | Out-Null

            tar -xzf "$($tarball.FullName)" -C "$extract"

            Copy-Item "$($xml.FullName)" (Join-Path $extract "metadata.xml") -Force

            $topDirs = Get-ChildItem $extract -Directory
            foreach ($dir in $topDirs) {
              Copy-Item "$($xml.FullName)" (Join-Path $dir.FullName "metadata.xml") -Force
              Write-Host "Injected package metadata: $($dir.FullName)\metadata.xml"
            }

            Remove-Item "$($tarball.FullName)" -Force

            Push-Location $extract
            try {
              tar -czf "$($tarball.FullName)" *
            } finally {
              Pop-Location
            }

            Write-Host "Verifying metadata in tarball:"
            tar -tzf "$($tarball.FullName)" | Select-String -Pattern "metadata.xml" -SimpleMatch
          }

      - name: List build output
        if: always()
        shell: pwsh
        run: |
          Get-ChildItem -Recurse build -ErrorAction SilentlyContinue | Select-Object FullName, Length | Out-String -Width 240
'@

if (-not $text.Contains($needle)) {
    throw "Could not find List build output insertion point in workflow."
}

$text = $text.Replace($needle, $insert)

# Make artifact name clearer while preserving output paths.
$text = $text.Replace(
    "name: angelgrib-windows-build-output",
    "name: angelgrib-plugin-manager-tarball"
)

Set-Content -Path $workflow -Value $text -Encoding UTF8

Write-Host "Patched workflow with dual metadata.xml injection."
Write-Host ""
Write-Host "Next:"
Write-Host "  git diff -- .github/workflows/windows-build-experiment.yml"
Write-Host "  git add ."
Write-Host "  git commit -m ""Add metadata.xml inside plugin tarball"""
Write-Host "  git push"
