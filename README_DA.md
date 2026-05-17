# AngelGRIB_pi v0.9.0 — Build adaptation kit

Denne pakke er næste trin efter at Testplugin-template er staged ind i `template-migration`.

Formålet er at lave første rigtige build-forsøg i GitHub Actions.

## Hvad pakken gør

Den tilføjer:

- `scripts/patch-template-for-angelgrib.ps1`
- `.github/workflows/windows-build-experiment.yml`
- `docs/08_WINDOWS_BUILD_EXPERIMENT_DA.md`

Patch-scriptet forsøger at tilpasse Testplugin-template til AngelGRIB:

- metadata i `CMakeLists.txt`
- source/header-liste
- API-base class fra `117` til `118`
- `GetAPIVersionMinor()` fra `17` til `18`
- toolbar-position placeholder til `-1`
- deaktiverer JSON schema validator i template-CMake

Workflowet forsøger derefter et Windows build med wxWidgets 3.2.1 og Visual Studio 2022.

## Vigtigt

Det her er et **første build-experiment**. Det kan stadig fejle, men nu fejler det i den rigtige template-struktur og i GitHub Actions, ikke i lokal vcpkg/CMake-sump.

## Brug

Kopiér pakken ind i repoet på `template-migration`, kør patch-scriptet, commit og push.

```powershell
cd C:\Users\Administrator\Downloads\angelgrib_pi
git checkout template-migration

.\scripts\patch-template-for-angelgrib.ps1

git status
git add .
git commit -m "Adapt testplugin template for AngelGRIB build"
git push
```

Tjek derefter:

```text
https://github.com/loke21-angel/angelgrib_pi/actions
```
