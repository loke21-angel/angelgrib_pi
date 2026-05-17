# AngelGRIB_pi v0.9.4 — Tarball metadata fix

OpenCPN accepterer ikke den byggede `.tar.gz`, fordi tarballen mangler den påkrævede metadatafil inde i selve arkivet.

Fejlen i OpenCPN:

```text
Error, import plugin tarball does not contain required metadata.
```

Artifacten indeholder allerede en `.xml` ved siden af `.tar.gz`, men OpenCPN Import Plugin Tarball kræver metadata inde i tarballen.

Denne patch tilføjer et GitHub Actions step efter `Build package`, som:

1. Finder `build/*.tar.gz`
2. Finder den byggede `build/*.xml`
3. Pakker tarballen ud
4. Kopierer XML-filen ind som `metadata.xml`
5. Pakker tarballen igen
6. Uploader den rettede tarball som artifact

## Brug

```powershell
cd C:\Users\Administrator\Downloads\angelgrib_pi
git checkout template-migration

.\scripts\patch-tarball-metadata-v094.ps1

git status
git add .
git commit -m "Include metadata.xml inside plugin tarball"
git push
```
