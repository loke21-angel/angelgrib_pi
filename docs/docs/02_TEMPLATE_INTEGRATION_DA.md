# Template-integration — anbefalet procedure

## 1. Opret repo

Opret et tomt GitHub repo:

```text
angelgrib_pi
```

## 2. Start fra OpenCPN ShipDriver/plugin-template

Brug et fungerende OpenCPN plugin-template/ShipDriver setup som base.

Dette projekt skal **ikke** selv håndtere:
- wxWidgets-installation
- opencpn-api download
- Windows compiler setup
- tarball metadata generation

Template/CI skal håndtere det.

## 3. Kopiér AngelGRIB-filer

Fra denne pakke kopieres:

```text
src/
include/
manual/
metadata/
Plugin.cmake.template
scripts/download-noaa-gfs-sample.ps1
```

ind i plugin-template repoet.

## 4. Tilpas Plugin.cmake

Brug `Plugin.cmake.template` som udgangspunkt.

Sørg for at plugin-navn, version, source files og manual metadata matcher.

## 5. Byg via CI

Push til GitHub og lad GitHub Actions / ShipDriver workflow bygge tarball.

## 6. Test i OpenCPN

Download Windows tarball-artifact fra GitHub Actions og importér den i OpenCPN:

```text
Options → Plugins → Import Plugin Tarball
```

## 7. Første release

Når den virker lokalt:
- tag `v0.1.0-beta`
- test tarball
- tag `v0.1.0`
- senere: PR til OpenCPN plugin-katalog, hvis den skal i officiel Plugin Manager-liste
