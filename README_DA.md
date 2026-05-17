# AngelGRIB_pi v0.9.6 — Python tar metadata fix

v0.9.5 fejlede i GitHub Actions med:

```text
tar (child): Cannot connect to D: resolve failed
```

Årsagen er, at workflowet fik MSYS `tar` i PATH, og MSYS tar fortolker Windows-stier som `D:\...` forkert.

Denne patch erstatter hele metadata-injektionen med ren Python:

- ingen `tar -xzf`
- ingen `tar -czf`
- ingen `tar -tzf`
- Python `tarfile` håndterer Windows-stier korrekt

## Brug

```powershell
cd C:\Users\Administrator\Downloads\angelgrib_pi
git checkout template-migration

.\scripts\patch-python-tar-metadata-v096.ps1

git status
git add .
git commit -m "Use Python to inject metadata into plugin tarball"
git push
```

Efter build:
1. Download artifact
2. Test:
   ```powershell
   tar -tzf .\angelgrib_pi-*.tar.gz | Select-String metadata
   ```
3. Importér `.tar.gz` i OpenCPN
