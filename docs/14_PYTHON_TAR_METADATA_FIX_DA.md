# v0.9.6 — Python tar metadata fix

## Diagnose

GitHub Actions fejlede i metadata-step'et med:

```text
tar (child): Cannot connect to D: resolve failed
```

Det sker fordi MSYS tar fortolker Windows-stier som `D:\a\...` forkert.

## Fix

Workflowet bruger nu Python `tarfile` i stedet for `tar` CLI.

Metadata lægges ind som:

```text
metadata.xml
<pakkenavn>/metadata.xml
```

og scriptet verificerer med Python, at mindst én `metadata.xml` findes i arkivet.

## Test

Efter grøn build:

```powershell
cd C:\Users\Administrator\Desktop\plugin
$tarball = Get-ChildItem -Filter "*.tar.gz" | Select-Object -First 1
tar -tzf $tarball.FullName | Select-String metadata
```

Forventet output:

```text
metadata.xml
angelgrib_pi-.../metadata.xml
```
