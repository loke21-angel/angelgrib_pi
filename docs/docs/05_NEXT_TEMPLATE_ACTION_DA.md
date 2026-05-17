# Næste konkrete template-handling

## Det bedste næste skridt

Lav en ny branch:

```powershell
git checkout -b template-migration
```

Derefter skal vi vælge én base:

## Mulighed 1: Testplugin som base

Brug når målet er hurtigst at få en plugin-knap bygget i CI.

Handling:
- kopier template-buildfiler fra testplugin_pi
- fjern demo-specifik kode
- behold AngelGRIB src/include
- ret Plugin.cmake/CMakeLists

## Mulighed 2: ShipDriver som base

Brug når målet er tættere på managed Plugin Manager-publicering.

Handling:
- brug ShipDriver-template update-scripts
- tilpas metadata
- tilpas manual/asciidoc
- byg tarball via CI

## Min anbefaling

Start med Testplugin-template til første Windows tarball. Når plugin'et kan installeres og knappen virker, kan vi stramme op mod ShipDriver/managed catalog flow.

## Definition of done for næste trin

- GitHub Actions kører
- Windows artifact/tarball findes
- tarball kan importeres i OpenCPN
