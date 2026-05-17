# AngelGRIB_pi v0.9.8 — Workflow YAML fix

GitHub afviser workflowet med:

```text
Invalid workflow file: .github/workflows/windows-build-experiment.yml#L194
You have an error in your yaml syntax on line 194
```

Årsagen er sandsynligvis den store inline Python/heredoc-blok i workflow YAML-filen.

Denne patch gør workflowet simplere:

- Python-koden flyttes til `scripts/inject_metadata_into_tarball.py`
- workflowet kalder scriptet med almindelige argumenter
- ingen inline Python heredoc i YAML
- ingen `tar` CLI i metadata-step'et

## Brug

```powershell
cd C:\Users\Administrator\Downloads\angelgrib_pi
git checkout template-migration

.\scripts\apply-v098.ps1

git status
git add .
git commit -m "Fix workflow YAML by moving metadata injection to script"
git push
```
