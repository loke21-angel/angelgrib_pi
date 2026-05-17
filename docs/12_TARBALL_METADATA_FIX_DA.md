# v0.9.4 — Tarball metadata fix

## Diagnose

OpenCPN viser:

```text
Error, import plugin tarball does not contain required metadata.
```

Det betyder, at `.tar.gz`-filen blev bygget, men at den ikke indeholder den metadatafil, som Plugin Manager-importeren kræver.

I artifacten ligger der en `.xml` ved siden af `.tar.gz`, men den skal også være inde i tarballen som `metadata.xml`.

## Fix

GitHub Actions workflowet får et ekstra step:

```text
Inject metadata.xml into plugin tarball
```

Det pakker tarballen ud, kopierer den genererede XML ind som `metadata.xml`, og pakker tarballen igen.

## Test

Efter ny build:

1. Download artifact.
2. Pak artifact-zip ud.
3. Importér `.tar.gz` i OpenCPN.
4. Fejlen om manglende metadata bør være væk.
