# Release checklist — v0.1.0-beta

## Før tag

- [ ] README.md opdateret
- [ ] Licensfil tilføjet
- [ ] Manual findes i `manual/index.adoc`
- [ ] Testscript downloader GRIB
- [ ] GRIB kan åbnes manuelt i OpenCPN
- [ ] Plugin bygger i CI
- [ ] Windows tarball artifact findes

## Lokal OpenCPN-test

- [ ] Importér tarball via Options → Plugins → Import Plugin Tarball
- [ ] Plugin kan aktiveres
- [ ] Toolbar-knap vises
- [ ] Klik downloader fil
- [ ] Fil åbnes i GRIB Weather-plugin eller brugeren får filsti
- [ ] OpenCPN crasher ikke ved DeInit/disable

## Tag

```powershell
git tag v0.1.0-beta
git push origin v0.1.0-beta
```

## Efter tag

- [ ] Download release artifact
- [ ] Gem tarball
- [ ] Opret issues for v0.2
