# AngelGRIB Downloader v0.1 — MVP specifikation

## Formål

Gøre det muligt at hente og åbne en GRIB-fil i OpenCPN med ét klik.

## Brugerflow

1. Brugeren klikker på toolbar-knappen **Download GRIB**.
2. Plugin'et downloader en lille NOAA GFS GRIB2-fil.
3. Filen gemmes lokalt.
4. Plugin'et sender en besked til GRIB-plugin'et om at åbne filen.
5. GRIB-plugin'et viser vejret på kortet.

## Første faste parametre

| Parameter | Værdi |
|---|---|
| Model | NOAA GFS 0.25° |
| Run | 00z |
| Forecast | +6 timer |
| Område | leftlon=-8, rightlon=16, toplat=60, bottomlat=50 |
| Variabler | UGRD, VGRD, GUST, PRMSL, APCP |
| Outputfil | angel_gfs_latest.grb2 |

## Ikke med i v0.1

- Ingen settings-dialog.
- Ingen egen GRIB-rendering.
- Ingen egen GRIB-parser.
- Ingen viewport-baseret område endnu.
- Ingen valg af forecast-tid endnu.
- Ingen automatisk valg af nyeste NOAA run endnu.

## Succeskriterium

Når plugin'et trykker download, åbnes en GRIB-fil i OpenCPN's GRIB-plugin, svarende til den fil der allerede blev testet manuelt.
