$ErrorActionPreference = "Stop"

.\scripts\patch-template-for-angelgrib.ps1

git status
git add .
git commit -m "Adapt testplugin template for AngelGRIB build"
git push
