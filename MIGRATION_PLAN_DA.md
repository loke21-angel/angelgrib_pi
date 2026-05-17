# Migreringsplan: AngelGRIB → OpenCPN template-plugin

## Status nu

Vi har:
- GitHub repo
- struktureret MVP-kode
- dokumentation
- bevist NOAA GRIB-download
- bevist manuel OpenCPN GRIB-import

## Næste mål

Få GitHub Actions til at producere en Windows tarball, som kan importeres i OpenCPN:

```text
Options → Plugins → Import Plugin Tarball
```

## Valg af template

Der er to realistiske veje:

### A. ShipDriver-template

Fordele:
- brugt i OpenCPN plugin-økosystemet
- fokuseret på tarballs, metadata, Cloudsmith og katalog
- god til managed plugins

Ulemper:
- tungere at sætte op første gang

### B. Testplugin-template

Fordele:
- designet som eksempel/template
- dokumentationen siger, at plugin-ændringer typisk begrænses til CMakeLists/source/header
- god som udviklingsreference

Ulemper:
- kan være bredere/større end nødvendigt

## Anbefaling

Start med **Testplugin-template** som praktisk udviklingsbase, og brug ShipDriver-dokumentationen som guideline for Plugin Manager/tarball-flow.

Grunden: AngelGRIB er lille, og vi skal først bare have én toolbar-knap og én tarball.

## Fase 1 — repo clean-up

- [ ] Sørg for at README.md findes
- [ ] Tilføj COPYING/LICENSE
- [ ] Tilføj `.gitattributes`
- [ ] Tilføj `docs/`
- [ ] Tilføj `manual/index.adoc`
- [ ] Behold `scripts/download-noaa-gfs-sample.ps1`

## Fase 2 — template import

- [ ] Lav branch: `template-migration`
- [ ] Importér template-filer
- [ ] Behold AngelGRIB-koden i `src/` og `include/`
- [ ] Map plugin metadata til template-konventioner
- [ ] Ret API-base class efter template/API-version

## Fase 3 — CI build

- [ ] Push branch
- [ ] Kør GitHub Actions
- [ ] Download Windows artifact
- [ ] Importér tarball i OpenCPN
- [ ] Test plugin enable/disable
- [ ] Test GRIB-knap

## Fase 4 — beta release

- [ ] Tag `v0.1.0-beta`
- [ ] Gem tarball artifact
- [ ] Test på Windows/OpenCPN
- [ ] Lav issues for v0.2
