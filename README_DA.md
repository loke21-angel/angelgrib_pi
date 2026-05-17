# AngelGRIB_pi v0.9.1 — Gettext CI fix

Denne patch retter den aktuelle GitHub Actions-fejl:

```text
Could NOT find Gettext
missing: GETTEXT_MSGMERGE_EXECUTABLE GETTEXT_MSGFMT_EXECUTABLE
```

Løsningen:
- installer Gettext via MSYS2 i GitHub Actions
- tilføj `C:\msys64\usr\bin` til PATH
- giv CMake direkte stier til:
  - `msgmerge.exe`
  - `msgfmt.exe`

## Brug

Kopiér pakken ind i repoet på `template-migration`, kør patch-scriptet, commit og push:

```powershell
cd C:\Users\Administrator\Downloads\angelgrib_pi
git checkout template-migration

.\scripts\patch-ci-gettext.ps1

git status
git add .
git commit -m "Fix Gettext tools in Windows build workflow"
git push
```

Tjek derefter GitHub Actions.
