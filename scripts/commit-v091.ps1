$ErrorActionPreference = "Stop"

.\scripts\patch-ci-gettext.ps1

git status
git add .
git commit -m "Fix Gettext tools in Windows build workflow"
git push
