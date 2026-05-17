# AngelGRIB_pi v0.9.7 — full workflow Python metadata fix

Denne patch overskriver hele `.github/workflows/windows-build-experiment.yml`.

Grunden er, at GitHub Actions stadig kørte den gamle v0.9.5-blok med `tar`, selv efter Python-fixet. Denne version fjerner al `tar` CLI fra metadata-step'et og bruger kun Python `tarfile`.

## Brug

```powershell
cd C:\Users\Administrator\Downloads\angelgrib_pi
git checkout template-migration

Copy-Item .\angelgrib_v097\angelgrib_pi_v0.9.7_full_workflow_python_metadata\.github\workflows\windows-build-experiment.yml `
  .\.github\workflows\windows-build-experiment.yml `
  -Force

git status
git add .github/workflows/windows-build-experiment.yml
git commit -m "Replace workflow with Python metadata tarball handling"
git push
```
