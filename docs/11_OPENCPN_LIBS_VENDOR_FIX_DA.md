# v0.9.3 — OpenCPN libs vendor fix

## Diagnose

CMake er nu tydeligt på AngelGRIB:

```text
PluginSetup: AngelGRIB Version: 0.1.0.0
PluginConfigure: *** Staging to build angelgrib_pi ***
CMakeLists: Adding target link libraries to angelgrib_pi
```

Men den stopper fordi `opencpn-libs` mangler de forventede undermapper.

## Fix

Workflowet sletter en eventuelt tom `opencpn-libs` mappe og prøver flere fallback sources:

- `OpenCPN/opencpn-libs`
- `jongough/opencpn-libs`
- `Rasbats/opencpn-libs`

Hvis ingen indeholder de nødvendige mapper, fejler workflowet tidligere og viser directory listing.

## Næste sandsynlige fejl

Hvis `opencpn-libs` bliver fundet, bliver næste fejl sandsynligvis en C++ compile/signatur-fejl i `angelgrib_pi.cpp`.

Det er fint; det betyder at buildsystemet nu er på plads.
