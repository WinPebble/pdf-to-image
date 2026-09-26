# WinPebble PDF to Image 0.9.0-beta

This is an **unsigned pre-release build** used to establish the release form and verifiable build pipeline before production code signing.

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

Release form:

```text
WinPebble-PDF-to-Image-Setup-Beta-Dev.exe
```

The installer is built from this repository by GitHub Actions on a GitHub-hosted Windows runner.

## Important signing status

This beta is **not production-signed**.

It exists so WinPebble can establish a public release in the same Setup EXE form that is intended to be signed through SignPath Foundation later.

Do not disable Windows security protections for normal use. Production releases are intended to install and run with Smart App Control and Microsoft Defender enabled.

## Version

```text
ProductVersion: 0.9.0-beta
FileVersion:    0.9.0.0
Architecture:   x64
```

## License

MIT License.

See the repository for source code, privacy information, build instructions, third-party notices and the code signing policy.
