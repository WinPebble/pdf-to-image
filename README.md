# WinPebble PDF to Image

A lightweight Windows utility that converts PDF pages to PNG or JPG directly from File Explorer.

> **Status:** version `1.0.2.0` was published on [Microsoft Store](https://apps.microsoft.com/detail/9NRZMPGMQPS4) on 2026-10-15, with Windows 10 build 19041+ / Windows 11 x64 support and Progress UI/Cancel. The source Store manifest now prepares `1.0.3.0` for the shared WinPebble logo update; that candidate is not released. See [development status](docs/DEVELOPMENT_STATUS.md).

Partner Center confirmed Submission 3 is live. [PR #12](https://github.com/WinPebble/pdf-to-image/pull/12) integrated Progress UI/Cancel and the Windows 10 dev manifest into `main`; PR #9/#10 were closed as superseded. Guided development-device checks passed on Windows 10 22H2 and Windows 11, with evidence limits recorded. Earlier admitted Windows 10 builds and installation/upgrade of the Store-delivered binary have not been independently tested here. See [the device test guide](docs/WIN10_PROGRESS_DEVICE_GUIDE.md).

## What it does

The Windows 10 + Progress UI release has a historical [preparation record](store-msix/RELEASE_CANDIDATE.md). The next [branding update](branding/SHARED_BRAND_ICON.md) changes icons, preserving conversion behavior and OS requirements.

- Adds **Convert PDF to PNG** and **Convert PDF to JPG** to the modern Windows 11 context menu.
- Supports Windows 10 build 19041+ x64 and Windows 11 x64.
- Displays progress during longer conversions, with cooperative cancellation that preserves completed output.
- Uses the Windows-native `Windows.Data.Pdf` renderer.
- Renders at 300 DPI and writes 300 × 300 DPI image metadata.
- Uses maximum JPEG encoder quality (`ImageQuality = 1.0`).
- Preserves the original PDF.
- Works offline.
- Does not use Poppler or another third-party PDF rendering runtime.
- Does not run a background service or collect telemetry.

## Development and distribution

Microsoft Store is the production distribution path. Full-MSIX development packages use a separate identity and self-signed test certificate. See [BUILDING.md](BUILDING.md), [the MSIX guide](store-msix/README.md) and [Store submission](store-msix/STORE_SUBMISSION.md).

The repository also retains the optional direct-download NSIS beta path below. Its development certificate is not required by the Store release.

## Legacy beta installer

WinPebble PDF to Image uses **NSIS** for the Setup EXE release form.

Retained development pre-release metadata:

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

The planned direct-download signing path names SignPath.io and SignPath Foundation as providers; approval and production signing have not been verified in this review.

The NSIS beta documentation records SignPath Foundation approval as pending and beta Setup binaries as unsigned. This signing path is separate from Microsoft Store distribution.

See [CODE_SIGNING_POLICY.md](CODE_SIGNING_POLICY.md) and [SIGNPATH_READINESS.md](SIGNPATH_READINESS.md).

## License

WinPebble PDF to Image is licensed under the [MIT License](LICENSE).

## Project

- Website: https://winpebble.com
- Product page: https://winpebble.com/tools/pdf-to-image/
- Repository: https://github.com/WinPebble/pdf-to-image
- Current beta release: https://github.com/WinPebble/pdf-to-image/releases/tag/v0.9.0-beta.1
