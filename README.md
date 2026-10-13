# WinPebble PDF to Image

A lightweight Windows utility that converts PDF pages to PNG or JPG directly from File Explorer.

> **Status:** released on [Microsoft Store](https://apps.microsoft.com/detail/9NRZMPGMQPS4) for Windows 11 x64. The source Store manifest is release candidate `1.0.2.0`; this is not a published Store version. Windows 10 compatibility and a cancellable progress window are under development; they are not yet production support commitments. See [development status](docs/DEVELOPMENT_STATUS.md).

Store availability is confirmed by the maintainer. The manifest version describes this repository's packaging baseline, not an independently verified version currently delivered by the Store. [PR #12](https://github.com/WinPebble/pdf-to-image/pull/12) integrated development Progress UI/Cancel and the Windows 10 dev manifest into `main`; PR #9/#10 were closed as superseded. Guided development-device checks passed on Windows 10 and Windows 11, with evidence limits recorded. These are not released Store features. See [the device test guide](docs/WIN10_PROGRESS_DEVICE_GUIDE.md).

## What it does

The proposed Windows 10 + Progress UI Store update is documented in [release candidate preparation](store-msix/RELEASE_CANDIDATE.md); development integration does not change the currently delivered Store binary.

- Adds **Convert PDF to PNG** and **Convert PDF to JPG** to the modern Windows 11 context menu.
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
