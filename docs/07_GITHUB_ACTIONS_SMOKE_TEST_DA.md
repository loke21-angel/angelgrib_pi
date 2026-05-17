# GitHub Actions smoke test

Denne workflow er kun en første CI-test.

## Hvad den tester

- repo kan checkes ud
- AngelGRIB-filer findes
- NOAA download-script virker på GitHub runner
- GRIB-filen uploades som artifact

## Den bygger ikke OpenCPN-plugin endnu

Det er bevidst.

Først skal vi have CI til at køre stabilt. Derefter tilføjer vi OpenCPN/Testplugin build workflow.

## Sådan tilføjes den

Fra repoet:

```powershell
cd C:\Users\Administrator\Downloads\angelgrib_pi
git checkout template-migration
```

Kopiér denne pakkes indhold ind i repoet, commit og push:

```powershell
git status
git add .
git commit -m "Add GitHub Actions smoke test"
git push
```

Tjek derefter:

```text
https://github.com/loke21-angel/angelgrib_pi/actions
```

## Forventet resultat

Workflow: `AngelGRIB smoke test`

Resultat: grøn checkmark.

Hvis den fejler, er det sandsynligvis:
- filsti mismatch
- download-scriptet returnerer fejl
- NOAA endpoint midlertidigt utilgængeligt
