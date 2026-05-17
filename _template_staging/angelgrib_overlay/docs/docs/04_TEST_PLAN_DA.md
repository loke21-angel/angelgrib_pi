# Testplan

## Test A — Download uden OpenCPN

Kør:

```powershell
cd scripts
.\download-noaa-gfs-sample.ps1
```

Forventet:
- fil oprettes i `scripts/out/angel_gfs_latest.grb2`
- filstørrelse > 0
- OpenCPN GRIB-plugin kan åbne filen manuelt

## Test B — Plugin-knap

Forventet:
- knap vises i toolbar
- klik downloader fil
- statusbesked vises
- fil åbnes i GRIB-plugin

## Test C — Netværksfejl

Simulér dårlig URL eller intet netværk.

Forventet:
- plugin crasher ikke
- brugeren får fejlbesked
- gammel fil overskrives ikke med tom fil

## Test D — GRIB-plugin ikke aktivt

Forventet:
- download virker stadig
- plugin viser besked om at aktivere/åbne GRIB Weather-plugin
