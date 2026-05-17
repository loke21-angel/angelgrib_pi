# v0.9.5 — dual metadata tarball fix

## Diagnose

Lokal test viste:

```powershell
tar -tzf $tarball.FullName | Select-String metadata
```

gav intet output. Det betyder, at den importerede tarball stadig mangler metadata.

## Fix

Metadata XML lægges nu to steder i tarballen:

```text
metadata.xml
<pakkenavn>/metadata.xml
```

Det gør pakken mere tolerant overfor hvordan OpenCPN importereren scanner arkivet.

## Lokal test

Du kan også rette den allerede-downloadede artifact lokalt:

```powershell
cd C:\Users\Administrator\Desktop\plugin
.\scripts\local-inject-metadata.ps1
```

eller hvis scriptet ligger i repoet:

```powershell
C:\Users\Administrator\Downloads\angelgrib_pi\scripts\local-inject-metadata.ps1 `
  -Directory C:\Users\Administrator\Desktop\plugin
```

Den laver en ny fil:

```text
*-with-metadata.tar.gz
```

Importér den i OpenCPN.
