# AngelGRIB_pi v0.5.0 — template-integration MVP

Dette er en ren, struktureret projektpakke til næste skridt: at flytte AngelGRIB-koden ind i et rigtigt OpenCPN ShipDriver/plugin-template workflow.

**Vigtigt:** Dette er ikke længere et selvstændigt Windows buildprojekt. Den gamle lokale build-strategi med vcpkg/wxWidgets/API-hacks er bevidst droppet.

## Målet for første version

**AngelGRIB Downloader v0.1**

Én knap i OpenCPN:

1. Henter NOAA GFS 0.25° GRIB2 for et fast område.
2. Gemmer filen som `angel_gfs_latest.grb2`.
3. Sender filen til OpenCPN's eksisterende GRIB Weather-plugin.
4. Viser en simpel fejlbesked ved downloadfejl.

## Det vi allerede har bevist

PowerShell-testen virker:

```powershell
cd scripts
.\download-noaa-gfs-sample.ps1
```

og OpenCPN GRIB-plugin'et kan åbne filen manuelt.

## Anbefalet næste vej

1. Opret et GitHub repo: `angelgrib_pi`.
2. Start fra et eksisterende OpenCPN/ShipDriver-template plugin.
3. Kopiér filerne fra denne pakke ind i template-repoet.
4. Tilpas `Plugin.cmake`.
5. Lad GitHub Actions bygge Windows tarball.
6. Importér tarball i OpenCPN via:
   `Options → Plugins → Import Plugin Tarball`.

## Hvorfor denne retning?

OpenCPN's ShipDriver-template håndterer:
- tarballs til Plugin Installer
- metadata og checksums
- CI-builds
- Cloudsmith/download-URL flow
- platformsspecifikke builddetaljer

Det er præcis den del, vi ikke skal genopfinde.
