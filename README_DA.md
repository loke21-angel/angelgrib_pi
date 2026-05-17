# AngelGRIB_pi v0.9.9 — Release URL metadata fix

OpenCPN finder nu metadata, men metadataen indeholder stadig template/Cloudsmith-placeholder:

```xml
<tarball-url>
  https://dl.cloudsmith.io/public/--pkg_repo--/raw/names/--name--/versions/--version--/--filename--
</tarball-url>
```

Det giver 404, fordi URL'en ikke findes.

Denne pakke indeholder et lokalt script, som patcher metadata inde i `.tar.gz`, så `tarball-url` peger på en GitHub Release asset.

## Standard release URL

For tag `v0.1.0-beta` bliver URL'en:

```text
https://github.com/loke21-angel/angelgrib_pi/releases/download/v0.1.0-beta/<tarball-filnavn>
```

## Brug

1. Kør scriptet på den udpakkede artifact-mappe:

```powershell
C:\Users\Administrator\Downloads\angelgrib_pi\scripts\fix-local-tarball-release-url.ps1 `
  -Directory C:\Users\Administrator\Desktop\plugin `
  -Tag v0.1.0-beta
```

2. Scriptet laver en ny tarball:

```text
*-release-url.tar.gz
```

3. Opret en GitHub Release med tag `v0.1.0-beta`.

4. Upload den nye `*-release-url.tar.gz` som release asset.

5. Importér den nye `*-release-url.tar.gz` i OpenCPN.

Hvis OpenCPN forsøger at downloade efter import, henter den nu tarballen fra GitHub Release i stedet for Cloudsmith-placeholderen.
