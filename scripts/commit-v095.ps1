$ErrorActionPreference = "Stop"

.\scripts\patch-dual-metadata-tarball-v095.ps1

git status
git add .
git commit -m "Add metadata.xml inside plugin tarball"
git push
