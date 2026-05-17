$ErrorActionPreference = "Stop"

.\scripts\patch-python-tar-metadata-v096.ps1

git status
git add .
git commit -m "Use Python to inject metadata into plugin tarball"
git push
