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

$backup = Join-Path $repo ".github\workflows\windows-build-experiment.yml.before-v094"
if (-not (Test-Path $backup)) {
    Copy-Item $workflow $backup
    Write-Host "Backup created: $backup"
}

$text = Get-Content $workflow -Raw

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
            New-Item -ItemType Directory -Force $work | Out-Null

            $patchScript = Join-Path $work "inject_metadata.py"

            @'
import os
import sys
import tarfile
import shutil

tarball = sys.argv[1]
metadata_xml = sys.argv[2]
work = sys.argv[3]

extract_dir = os.path.join(work, "extract")
os.makedirs(extract_dir, exist_ok=True)

with tarfile.open(tarball, "r:gz") as tar:
    tar.extractall(extract_dir)

shutil.copyfile(metadata_xml, os.path.join(extract_dir, "metadata.xml"))

tmp_tarball = tarball + ".tmp"

with tarfile.open(tmp_tarball, "w:gz") as tar:
    for root, dirs, files in os.walk(extract_dir):
        dirs.sort()
        files.sort()
        for filename in files:
            path = os.path.join(root, filename)
            arcname = os.path.relpath(path, extract_dir).replace("\\", "/")
            tar.add(path, arcname=arcname)

os.replace(tmp_tarball, tarball)
print(f"Injected metadata.xml into {tarball}")
'@ | Set-Content -Path $patchScript -Encoding UTF8

            python $patchScript "$($tarball.FullName)" "$($xml.FullName)" "$work"

            tar -tzf "$($tarball.FullName)" | Select-String -Pattern "metadata.xml" -SimpleMatch
          }

      - name: List build output
        if: always()
        shell: pwsh
        run: |
          Get-ChildItem -Recurse build -ErrorAction SilentlyContinue | Select-Object FullName, Length | Out-String -Width 240
'@

if (-not $text.Contains($needle)) {
    throw "Could not find insertion point in workflow. The workflow may have changed."
}

$text = $text.Replace($needle, $insert)
Set-Content -Path $workflow -Value $text -Encoding UTF8

Write-Host "Patched workflow to inject metadata.xml into tarball."
Write-Host ""
Write-Host "Next:"
Write-Host "  git diff -- .github/workflows/windows-build-experiment.yml"
Write-Host "  git add ."
Write-Host "  git commit -m ""Include metadata.xml inside plugin tarball"""
Write-Host "  git push"
