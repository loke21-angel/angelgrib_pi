# GitHub Actions

This folder intentionally contains documentation, not a fake CI workflow.

The actual build workflow should come from the OpenCPN ShipDriver/Testplugin template.

Why:
- OpenCPN plugin CI needs platform-specific builders
- Tarball generation and metadata are template-managed
- Recreating it here caused wxWidgets/API/linking problems

After importing a real template, replace this README with the template's workflow files.
