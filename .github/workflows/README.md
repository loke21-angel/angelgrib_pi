# GitHub Actions note

This package intentionally does not include a fake full build workflow.

Use the OpenCPN ShipDriver/plugin-template workflow as the base. The CI configuration should come from the template, not from this MVP package.

Reason: OpenCPN plugin builds depend on template-managed platform build files, tarball generation, metadata, checksums and deployment details.
