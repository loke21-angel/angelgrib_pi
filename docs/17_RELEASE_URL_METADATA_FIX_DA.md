# v0.9.9 — Release URL metadata fix

## Diagnose

Metadata findes nu, men indeholder stadig denne template-placeholder:

```xml
<tarball-url>
  https://dl.cloudsmith.io/public/--pkg_repo--/raw/names/--name--/versions/--version--/--filename--
</tarball-url>
```

OpenCPN forsøger at hente denne URL, og den giver 404.

## Fix

Metadata skal pege på en rigtig download-URL.

Til første test bruger vi GitHub Releases:

```text
https://github.com/loke21-angel/angelgrib_pi/releases/download/v0.1.0-beta/<filnavn>.tar.gz
```

## Vigtigt

Release asset skal findes før OpenCPN kan downloade den.

Hvis du importerer en tarball med GitHub Release URL, men ikke har uploadet tarballen til den release, får du stadig 404.

## Testsekvens

1. Patch tarball lokalt med `fix-local-tarball-release-url.ps1`.
2. Opret GitHub Release `v0.1.0-beta`.
3. Upload den patch'ede tarball.
4. Importér den patch'ede tarball i OpenCPN.
5. Enable plugin.
