# AngelGRIB_pi

AngelGRIB is an OpenCPN plugin project aiming to add a single toolbar action:

> Download a small NOAA GFS GRIB2 file and open it in OpenCPN's existing GRIB Weather plugin.

## Current status

This repository is in MVP/template-migration stage.

Already validated:

- NOAA GFS 0.25° GRIB2 URL generation
- PowerShell download of GRIB2 file
- Manual opening of downloaded file in OpenCPN GRIB Weather plugin

## MVP goal

AngelGRIB v0.1.0:

- Add toolbar button: **Download GRIB**
- Download fixed-area NOAA GFS GRIB2
- Save as `angel_gfs_latest.grb2`
- Send the file path to OpenCPN's GRIB plugin
- Show simple error message if download/open fails

## Not in v0.1

- No custom GRIB renderer
- No custom GRIB parser
- No settings dialog
- No dynamic viewport area
- No official plugin catalog submission yet

## Development strategy

The plugin should be built using OpenCPN's plugin-template/ShipDriver/Testplugin workflow.

Local ad-hoc Windows build scripts were intentionally abandoned because OpenCPN plugin builds require the correct API, wxWidgets, metadata and platform packaging flow.

## Quick test: GRIB download only

```powershell
cd scripts
.\download-noaa-gfs-sample.ps1
```

Then open:

```text
scripts\out\angel_gfs_latest.grb2
```

manually in OpenCPN's GRIB Weather plugin.

## Roadmap

See:

- `MIGRATION_PLAN_DA.md`
- `docs/03_ROADMAP_DA.md`
- `release/CHECKLIST_v0.1.0-beta_DA.md`
