# AngelGRIB_pi v0.8.0 — GitHub Actions smoke test

Denne pakke tilføjer en helt enkel GitHub Actions workflow, så vi kan bevise at repoets CI kører.

Den bygger ikke plugin'et endnu. Den gør kun:

- checkout repo
- viser filer
- tjekker at AngelGRIB-filer findes
- kører PowerShell GRIB download-scriptet
- uploader den downloadede `.grb2` som artifact

Når denne workflow virker, er næste trin at tilføje rigtig OpenCPN/Testplugin build workflow.
