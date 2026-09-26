# WinPebble PDF to Image 0.9.0-beta

This is an **unsigned public pre-release** establishing WinPebble PDF to Image's release form and verifiable GitHub build pipeline before production code signing.

## Highlights

- Convert PDF to PNG or JPG from Windows File Explorer.
- Windows-native PDF rendering (`Windows.Data.Pdf`).
- 300 DPI output with 300 × 300 DPI image metadata.
- Maximum-quality JPEG encoding.
- Unicode filenames.
- Multi-file conversion.
- Atomic multi-page output.
- No Poppler.
- No telemetry.
- No background service.

## Installer

Public release asset:

```text
WinPebble-PDF-to-Image-Setup-0.9.0-beta-unsigned.exe
```

The installer is built from this repository by GitHub Actions on a GitHub-hosted Windows runner.

SHA-256:

```text
a4591bfc9c844de580f81f8acfca9ffe2972649a91f934e76f079badd01e77e1
```

## Important signing status

This beta is **not production-signed**.

It exists so WinPebble can establish a public release in the same Setup EXE form that is intended to be signed through SignPath Foundation later.

Do not disable Windows security protections for normal use. Production releases are intended to install and run with Smart App Control and Microsoft Defender enabled.

## Code signing policy

**Free code signing provided by SignPath.io, certificate by SignPath Foundation.**

See the project's [Code signing policy](CODE_SIGNING_POLICY.md).

## Version

```text
ProductVersion: 0.9.0-beta
FileVersion:    0.9.0.0
Architecture:   x64
```

## Privacy

Conversion happens locally on the Windows device. PDF contents and generated images are not uploaded by the application.

See [PRIVACY.md](PRIVACY.md).

## License

MIT License.
