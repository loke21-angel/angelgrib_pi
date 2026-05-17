# AngelGRIB_pi v0.6.0 — Template Migration Kit

Denne pakke er næste strukturerede trin efter MVP-repoet.

Målet er at gøre `https://github.com/loke21-angel/angelgrib_pi` klar til at blive migreret ind i OpenCPN's plugin-template/ShipDriver workflow uden at gentage den gamle lokale Windows build-sump.

## Hvad denne pakke er

En migreringspakke med:
- konkret checklist
- template-adapterfiler
- foreslået README til repoets forside
- GitHub Actions placeholder med forklaring
- issue templates
- release checklist
- forbedret testscript

## Hvad denne pakke ikke er

Den er ikke en færdig OpenCPN tarball-builder. Selve build-/tarball-flowet skal komme fra OpenCPN ShipDriver/testplugin-template, ikke fra vores egne scripts.

## Anbefalet brug

1. Pak denne zip ud.
2. Kopiér indholdet ind i dit repo `angelgrib_pi`.
3. Commit som `Prepare template migration`.
4. Brug derefter ShipDriver/testplugin-template som base eller merge template-filer ind.
5. Lad CI bygge Plugin Manager-tarball.

## Første release-mål

`v0.1.0-beta`

Funktion:
- toolbar-knap
- download fast NOAA GFS GRIB2
- gem fil
- åbn i OpenCPN GRIB Weather-plugin
