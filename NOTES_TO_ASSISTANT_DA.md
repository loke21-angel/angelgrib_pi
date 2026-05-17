# Noter til næste udviklingstrin

Dette projekt skal ikke bygges med det gamle lokale vcpkg/CMake setup.

Næste rigtige opgave:
- tage OpenCPN ShipDriver/template repo
- merge denne MVP-kode ind
- få CI til at producere tarball
- rette eventuelle API-signaturer i template-kontekst

Vigtigt:
`ANGELGRIB_TOOL_POSITION` i src/angelgrib_pi.cpp er en placeholder. I den rigtige template/API kan det være nødvendigt at erstatte den med en faktisk toolbar-positionkonstant eller `-1`, afhængigt af template-eksempel.
