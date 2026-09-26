# WinPebble PDF to Image

A lightweight Windows utility that converts PDF pages to PNG or JPG directly from File Explorer.

> **Status:** public pre-release `v0.9.0-beta` is available. The Windows-native conversion core, Windows 11 Explorer integration, NSIS install/uninstall workflow, and GitHub-hosted release-form build have been validated. Production code signing is still pending SignPath Foundation approval.

## What it does

- Adds **Convert PDF to PNG** and **Convert PDF to JPG** to the modern Windows 11 context menu.
- Uses the Windows-native `Windows.Data.Pdf` renderer.
- Renders at 300 DPI and writes 300 × 300 DPI image metadata.
- Uses maximum JPEG encoder quality (`ImageQuality = 1.0`).
- Preserves the original PDF.
- Works offline.
- Does not use Poppler or another third-party PDF rendering runtime.
- Does not run a background service or collect telemetry.

## Output rules

For a one-page PDF, the image is created beside the PDF:

```text
Document.pdf
Document.png
```

For a multi-page PDF, a dedicated folder is created:

```text
Document.pdf
Document - PNG/
  Document_page_001.png
  Document_page_002.png
```

Existing outputs are never overwritten; `(2)`, `(3)`, and so on are used instead. Multi-page output is staged atomically so incomplete final folders are not exposed when conversion fails.

## Architecture

```text
Windows File Explorer
        ↓
WinPebble.PDFToImage.Shell.dll
(native x64 IExplorerCommand)
        ↓
WinPebble.PDFToImage.exe
(self-contained .NET 8 Windows executable)
        ↓
Windows.Data.Pdf
        ↓
PNG / JPG
```

## Release-form installer

WinPebble PDF to Image uses **NSIS** for the Setup EXE release form.

The project currently targets:

```text
Release label : 0.9.0-beta
File version  : 0.9.0.0
Architecture  : x64
```

The NSIS installer uses the zlib compressor. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

The public beta release is available from the repository's [Releases](https://github.com/WinPebble/pdf-to-image/releases) page.

## Build requirements

Development currently targets Windows x64 and uses:

- .NET 8 SDK
- Visual Studio 2022 Build Tools with Desktop development with C++
- Windows SDK (`MakeAppx`, `SignTool`, `rc.exe`)
- NSIS

See [BUILDING.md](BUILDING.md).

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
- Beta release: https://github.com/WinPebble/pdf-to-image/releases/tag/v0.9.0-beta
