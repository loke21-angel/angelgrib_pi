# v0.9.7 — Full workflow Python metadata

## Diagnose

GitHub Actions kørte stadig den gamle metadata-step med `tar` CLI:

```text
tar (child): Cannot connect to D: resolve failed
```

## Fix

Hele workflow-filen erstattes med en version hvor:

- build stadig bruger CMake/CPack
- metadata-injektion bruger kun Python `tarfile`
- verifikation bruger kun Python `tarfile`
- artifact hedder `angelgrib-plugin-manager-tarball`

## Forventet resultat

I Actions-loggen skal du se step-navnet:

```text
Inject metadata.xml into plugin tarball using Python
```

Ikke:

```text
Inject metadata.xml into plugin tarball
```

og ikke nogen `tar (child)` fejl.
