$ErrorActionPreference = "Stop"

.\scripts\patch-template-build-v092.ps1

git status
git add .
git commit -m "Fix OpenCPN libs and AngelGRIB template build config"
git push
