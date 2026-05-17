# v0.9.8 — Workflow YAML fix

## Diagnose

GitHub afviste workflowet før kørsel:

```text
Invalid workflow file: .github/workflows/windows-build-experiment.yml#L194
You have an error in your yaml syntax on line 194
```

## Fix

Den store inline Python-blok er flyttet ud i:

```text
scripts/inject_metadata_into_tarball.py
```

Workflowet kalder nu kun:

```powershell
python scripts/inject_metadata_into_tarball.py --metadata ... --tarball ...
```

Det fjerner YAML/heredoc-problemet.
