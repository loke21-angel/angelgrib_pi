# GitHub repo checklist

## Repo

- [ ] Create repo: `angelgrib_pi`
- [ ] Add README
- [ ] Add license, preferably compatible with OpenCPN plugin ecosystem
- [ ] Add this MVP code
- [ ] Add manual directory

## Template

- [ ] Start from OpenCPN ShipDriver/plugin-template workflow
- [ ] Add/merge `Plugin.cmake`
- [ ] Confirm CI builds tarballs
- [ ] Confirm Windows artifact exists

## Testing

- [ ] Download sample GRIB works
- [ ] Manual OpenCPN GRIB import works
- [ ] Plugin button downloads file
- [ ] Plugin opens file in GRIB plugin
- [ ] Plugin behaves gracefully if GRIB plugin is disabled

## Release

- [ ] Tag `v0.1.0-beta`
- [ ] Test artifact
- [ ] Tag `v0.1.0`
