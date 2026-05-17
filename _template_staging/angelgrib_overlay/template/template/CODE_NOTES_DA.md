# Kodenoter til template-migration

## API-version

Den nuværende kode er skrevet som draft omkring:

```cpp
opencpn_plugin_117
```

Men den endelige base class skal følge den template/API-version, som det valgte OpenCPN-template bruger.

Hvis template bruger API 1.18, skal koden rettes til den base class og dens signaturer.

## Toolbar position

I `angelgrib_pi.cpp` kan denne placeholder kræve rettelse:

```cpp
ANGELGRIB_TOOL_POSITION
```

Hvis template/API ikke definerer den, brug template-eksemplets mønster eller en simpel placering, fx `-1`, afhængigt af API-signatur.

## GRIB plugin message

MVP'en bruger:

```cpp
SendPluginMessage("GRIB_APPLY_JSON_CONFIG", json);
```

Hvis GRIB-plugin'et ikke har sit kontrolvindue oprettet, kan første version kræve at GRIB Weather-plugin'et er aktiveret/åbnet først.

## Første robuste fallback

Hvis plugin-message ikke åbner filen, skal v0.1 stadig gemme filen og vise stien, så brugeren kan åbne filen manuelt.
