# WinPebble PDF to Image

A lightweight Windows utility that converts PDF pages to PNG or JPG directly from File Explorer.

> **Status:** public pre-release `v0.9.0-beta.1` is available. The Windows-native conversion core, Windows 11 Explorer integration, NSIS install/uninstall workflow, explicit development-certificate disclosure, and GitHub-hosted release-form build have been validated. Production code signing is still pending SignPath Foundation approval.

## What it does

- Adds **Convert PDF to PNG** and **Convert PDF to JPG** to the modern Windows 11 context menu.
- Uses the Windows-native `Windows.Data.Pdf` renderer.
- Renders at 300 DPI and writes 300 × 300 DPI image metadata.
- Uses maximum JPEG encoder quality (`ImageQuality = 1.0`).
- Preserves the original PDF.
- Works offline.
- Does not use Poppler or another third-party PDF rendering runtime.
- Does not run a background service or collect telemetry.

## Release-form installer

WinPebble PDF to Image uses **NSIS** for the Setup EXE release form.

Current public development pre-release:

```text
Release label : 0.9.0-beta.1
File version  : 0.9.0.1
Architecture  : x64
```

The unsigned development preview explicitly warns before adding the local `WinPebble Development` certificate to `Local Computer > Trusted People` for sparse-package registration. The uninstaller removes that exact development certificate. Production releases will not require this development/self-signed certificate.

## Privacy

PDF conversion is performed locally. No user data is collected or transmitted by PDF to Image. Conversion does not require Internet access.

See [PRIVACY.md](PRIVACY.md).

## Code signing policy

**Free code signing provided by SignPath.io, certificate by SignPath Foundation.**

SignPath Foundation approval is pending. Current public beta binaries are unsigned.

See [CODE_SIGNING_POLICY.md](CODE_SIGNING_POLICY.md) and [SIGNPATH_READINESS.md](SIGNPATH_READINESS.md).

## License

WinPebble PDF to Image is licensed under the [MIT License](LICENSE).

## Project

- Website: https://winpebble.com
- Product page: https://winpebble.com/tools/pdf-to-image/
- Repository: https://github.com/WinPebble/pdf-to-image
- Current beta release: https://github.com/WinPebble/pdf-to-image/releases/tag/v0.9.0-beta.1
