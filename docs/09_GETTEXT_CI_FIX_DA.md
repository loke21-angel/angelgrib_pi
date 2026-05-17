# Gettext CI fix

## Fejl

GitHub Actions build stoppede i CMake configure med:

```text
Could NOT find Gettext
missing: GETTEXT_MSGMERGE_EXECUTABLE GETTEXT_MSGFMT_EXECUTABLE
```

## Hvorfor

Template-CMake bruger Gettext til translations/po-filer. `poedit` alene gav ikke CMake de forventede `msgmerge.exe` og `msgfmt.exe` i PATH.

## Fix

Workflowet installerer Gettext via MSYS2:

```yaml
uses: msys2/setup-msys2@v2
with:
  install: gettext
```

Og CMake får eksplicit:

```text
-DGETTEXT_MSGMERGE_EXECUTABLE=C:/msys64/usr/bin/msgmerge.exe
-DGETTEXT_MSGFMT_EXECUTABLE=C:/msys64/usr/bin/msgfmt.exe
```

## Næste forventede fejl

Når Gettext er løst, vil næste fejl sandsynligvis være én af disse:

- CMake metadata/schema
- manglende testplugin-generated filer
- C++ API mismatch
- toolbar API-signatur
- package target metadata

Det er okay. Vi er nu i den rigtige template/CI-buildvej.
