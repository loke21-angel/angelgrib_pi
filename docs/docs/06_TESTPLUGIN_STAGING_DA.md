# Testplugin staging

Denne fase henter OpenCPN Testplugin-template som staging.

## Kommandoer

```powershell
cd C:\Users\Administrator\Downloads\angelgrib_pi
git checkout template-migration
git status

.\scripts\stage-testplugin-template.ps1
.\scripts\inspect-template-staging.ps1
```

Hvis det ser rigtigt ud:

```powershell
.\scripts\stage-testplugin-template.ps1 -Apply

git status
git add .
git commit -m "Stage OpenCPN testplugin template base"
git push
```

## Hvorfor ikke merge direkte med git remote?

Fordi repoet allerede har vores MVP-struktur, og template-repoet har en helt anden historik og mange filer. En kontrolleret staging-copy er lettere at forstå og nemmere at rulle tilbage.

## Rollback

Hvis Apply giver rod:

```powershell
git reset --hard HEAD
Remove-Item .\_template_staging -Recurse -Force
```

Hvis du allerede har committed, lav en revert:

```powershell
git revert HEAD
git push
```
