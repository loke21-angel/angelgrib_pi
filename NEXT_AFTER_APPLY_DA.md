# Næste trin efter Apply

Når Testplugin-template er staged ind i repoet, skal vi ikke forvente at det bygger direkte.

Næste opgave er at åbne template-filerne og mappe AngelGRIB ind korrekt:

1. Find template's primære CMakeLists/Plugin.cmake.
2. Erstat testplugin-navn med AngelGRIB metadata.
3. Fjern eller isolér testplugin demo-kode.
4. Sørg for at kun AngelGRIB src/include bygges.
5. Ret base class til template API-version.
6. Push og se GitHub Actions.
7. Ret CI-fejl én ad gangen, men nu i template-strukturen.

Definition of done:
- GitHub Actions producerer Windows artifact/tarball.
- Tarball kan importeres i OpenCPN.
