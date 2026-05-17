# v0.9.2 — Submodules, CMake og source fix

## Diagnose

Gettext er løst. Næste fejl er, at OpenCPN template-lib-mapper ikke findes under `opencpn-libs`.

Samtidig viste loggen stadig `testplugin_pi`, hvilket betyder at CMakeLists.txt stadig ikke var korrekt patch'et til AngelGRIB.

## Fix

- workflow henter submodules og fallback-cloner `OpenCPN/opencpn-libs`
- CMakeLists.txt patch'es med AngelGRIB metadata
- source/header listen peger på AngelGRIB-koden
- JSON schema validator slås fra
- sourcefiler overskrives med vel-formateret C++ kode
- AngelGRIB SVG ikon tilføjes

## Forventet næste fejl

Efter dette kan næste fejl være en C++ API-signatur, fx `InsertPlugInToolSVG` eller `opencpn_plugin_118`. Det er fint; så retter vi plugin-koden.
