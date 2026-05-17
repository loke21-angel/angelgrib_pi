# AngelGRIB_pi v0.9.5 — dual metadata tarball fix

Din lokale test viste, at tarballen stadig ikke indeholder metadata:

```powershell
tar -tzf $tarball.FullName | Select-String metadata
```

gav intet output.

Denne patch gør metadata-injektionen mere robust:

- finder `.tar.gz` og `.xml` i build-output
- pakker tarballen ud
- kopierer XML ind som:
  - `metadata.xml`
  - `<pakkenavn>/metadata.xml`
- pakker tarballen igen
- verificerer at metadata nu findes i tarballen

Den uploader også artifacten med et tydeligere navn:

```text
angelgrib-plugin-manager-tarball
```

## Brug

```powershell
cd C:\Users\Administrator\Downloads\angelgrib_pi
git checkout template-migration

.\scripts\patch-dual-metadata-tarball-v095.ps1

git status
git add .
git commit -m "Add metadata.xml inside plugin tarball"
git push
```
