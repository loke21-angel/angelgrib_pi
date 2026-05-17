$ErrorActionPreference = "Stop"

.\scripts\patch-tarball-metadata-v094.ps1

git status
git add .
git commit -m "Include metadata.xml inside plugin tarball"
git push
