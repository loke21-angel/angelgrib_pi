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

$backup = Join-Path $repo ".github\workflows\windows-build-experiment.yml.before-v096"
if (-not (Test-Path $backup)) {
    Copy-Item $workflow $backup
    Write-Host "Backup created: $backup"
}

$text = Get-Content $workflow -Raw

# Remove previous metadata injection block, if any.
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

          $script = Join-Path $env:RUNNER_TEMP "inject_metadata_into_tarball.py"

          @'
import os
import sys
import tarfile
import shutil
import tempfile

metadata_xml = sys.argv[1]
tarballs = sys.argv[2:]

if not os.path.exists(metadata_xml):
    raise SystemExit(f"metadata xml does not exist: {metadata_xml}")

for tarball in tarballs:
    if not os.path.exists(tarball):
        raise SystemExit(f"tarball does not exist: {tarball}")

    print(f"Patching tarball: {tarball}")

    with tempfile.TemporaryDirectory(prefix="angelgrib_tarball_") as tmp:
        extract_dir = os.path.join(tmp, "extract")
        os.makedirs(extract_dir, exist_ok=True)

        with tarfile.open(tarball, "r:gz") as tar:
            tar.extractall(extract_dir)

        # Add metadata in both likely locations:
        # 1. archive root: metadata.xml
        # 2. package root: <top-level-dir>/metadata.xml
        root_metadata = os.path.join(extract_dir, "metadata.xml")
        shutil.copyfile(metadata_xml, root_metadata)

        top_dirs = [
            os.path.join(extract_dir, name)
            for name in os.listdir(extract_dir)
            if os.path.isdir(os.path.join(extract_dir, name))
        ]

        for top_dir in top_dirs:
            shutil.copyfile(metadata_xml, os.path.join(top_dir, "metadata.xml"))

        tmp_tarball = tarball + ".tmp"

        with tarfile.open(tmp_tarball, "w:gz") as out:
            for root, dirs, files in os.walk(extract_dir):
                dirs.sort()
                files.sort()
                for filename in files:
                    path = os.path.join(root, filename)
                    arcname = os.path.relpath(path, extract_dir).replace(os.sep, "/")
                    out.add(path, arcname=arcname)

        os.replace(tmp_tarball, tarball)

    print("Verifying metadata entries:")
    with tarfile.open(tarball, "r:gz") as tar:
        names = tar.getnames()
        metadata_names = [name for name in names if name.endswith("metadata.xml")]
        for name in metadata_names:
            print(f"  {name}")

        if not metadata_names:
            raise SystemExit(f"No metadata.xml found after patching {tarball}")

print("Metadata injection complete.")
'@ | Set-Content -Path $script -Encoding UTF8

          $tarballArgs = @($xml.FullName) + @($tarballs | ForEach-Object { $_.FullName })
          python $script @tarballArgs

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

# Keep the clearer artifact name if v0.9.5 already set it, or set it now.
$text = $text.Replace(
    "name: angelgrib-windows-build-output",
    "name: angelgrib-plugin-manager-tarball"
)

Set-Content -Path $workflow -Value $text -Encoding UTF8

Write-Host "Patched workflow to use Python tarfile for metadata injection."
Write-Host ""
Write-Host "Next:"
Write-Host "  git diff -- .github/workflows/windows-build-experiment.yml"
Write-Host "  git add ."
Write-Host "  git commit -m ""Use Python to inject metadata into plugin tarball"""
Write-Host "  git push"
