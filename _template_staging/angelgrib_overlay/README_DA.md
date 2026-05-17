# AngelGRIB_pi v0.7.0 — Testplugin staging kit

Denne pakke er næste trin til `template-migration` branchen.

Målet er at hente OpenCPN Testplugin-template som **staging**, uden at overskrive AngelGRIB-repoet blindt.

## Hvorfor staging?

Fordi Testplugin-template indeholder mange filer:
- CMake/buildsystem
- GitHub Actions
- plugin metadata
- manual-struktur
- scripts
- platformsspecifik CI

Hvis vi bare kopierer alt ind direkte, kan vi nemt smadre den rene AngelGRIB-struktur. Derfor gør denne pakke først staging og overlay.

## Anbefalet flow

Fra dit repo:

```powershell
cd C:\Users\Administrator\Downloads\angelgrib_pi
git checkout template-migration
git status
```

Pak denne kit ud og kopier `scripts/` + `docs/` ind i repoet.

Kør først dry-run/staging:

```powershell
.\scripts\stage-testplugin-template.ps1
```

Hvis staging ser fornuftig ud:

```powershell
.\scripts\stage-testplugin-template.ps1 -Apply
```

Derefter:

```powershell
git status
git add .
git commit -m "Stage OpenCPN testplugin template base"
git push
```

## Hvad scriptet gør

Uden `-Apply`:
- downloader Testplugin-template zip
- pakker den ud i `_template_staging`
- laver en AngelGRIB overlay-kopi i `_template_staging\angelgrib_overlay`
- viser hvad næste trin er

Med `-Apply`:
- kopierer template-filer ind i repoet
- bevarer `.git`
- forsøger at bevare AngelGRIB-filer
- kopierer AngelGRIB-filer tilbage ovenpå template-filerne
- skriver en log i `_template_staging\STAGING_REPORT.txt`

## Vigtigt

Dette er stadig en migrering. Efter `-Apply` skal vi forvente at rette:
- Plugin.cmake/CMakeLists
- plugin class/API-version
- toolbar-kald
- GitHub Actions secret/deploy settings
