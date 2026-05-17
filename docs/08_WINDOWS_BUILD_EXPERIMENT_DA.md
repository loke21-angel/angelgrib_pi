# Windows build experiment

Denne workflow er første rigtige buildforsøg efter Testplugin-template-import.

## Workflow

```text
.github/workflows/windows-build-experiment.yml
```

## Hvad den gør

- kører på `windows-2022`
- henter submodules
- installerer hjælpeværktøjer
- henter wxWidgets 3.2.1 MSVC binaries
- henter OpenCPN Windows build support
- kører CMake
- bygger `package`
- uploader build output som artifact

## Forventning

Første run kan fejle. Det er okay.

Hvis den fejler, skal vi bruge de sidste 80-120 linjer fra GitHub Actions-loggen.

## Hvorfor Win32?

Testplugin-template/appveyor-opskriften bruger Win32 for Visual Studio 2022 og wxWidgets 3.2.1. Vi følger template-vejen først for at reducere variabler.

## Næste trin ved fejl

Typiske fejl:
- CMakeLists stadig peger på testplugin-filer
- API base class mismatch
- manglende submodule
- download-URL ændret
- package target kræver ekstra metadata

Vi retter én ting ad gangen, men nu i CI/template-strukturen.
