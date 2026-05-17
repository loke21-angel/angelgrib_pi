$ErrorActionPreference = "Stop"

.\scripts\patch-opencpn-libs-vendor-v093.ps1

git status
git add .
git commit -m "Fix OpenCPN libs vendor fallback in Windows workflow"
git push
