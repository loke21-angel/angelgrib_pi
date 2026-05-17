# AngelGRIB_pi v0.9.3 — OpenCPN libs vendor fix

Buildet er nu korrekt omdøbt til AngelGRIB og Gettext virker. Den aktuelle fejl er kun, at template-CMake forventer mapper under `opencpn-libs/`, men de findes ikke i GitHub Actions-runneren.

Denne patch gør workflowet mere robust:

1. Sletter en tom/ufuldstændig `opencpn-libs` mappe.
2. Henter OpenCPN libs fra flere mulige GitHub-repo URLs.
3. Verificerer at disse mapper findes:
   - `WindowsHeaders`
   - `api-18`
   - `tinyxml`
   - `odapi`
   - `jsonlib`
   - `wxJSON`
   - `plugin_dc`
4. Fejler tidligt med tydelig directory-listing hvis de stadig mangler.

## Brug

```powershell
cd C:\Users\Administrator\Downloads\angelgrib_pi
git checkout template-migration

.\scripts\patch-opencpn-libs-vendor-v093.ps1

git status
git add .
git commit -m "Fix OpenCPN libs vendor fallback in Windows workflow"
git push
```
