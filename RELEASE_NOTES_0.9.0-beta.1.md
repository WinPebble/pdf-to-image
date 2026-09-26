# WinPebble PDF to Image 0.9.0-beta.1

This is an **unsigned development pre-release** used to validate WinPebble PDF to Image's intended Windows Setup EXE release form before production code signing.

## Important development-certificate notice

To enable the modern Windows 11 File Explorer integration before production signing is available, this development preview installs a local **WinPebble Development** certificate into:

```text
Local Computer > Trusted People
```

The installer displays this system change before installation and requires explicit confirmation.

The WinPebble uninstaller removes the exact development certificate it installed.

**Production releases will not require this development/self-signed certificate.**

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

## Signing status

This beta is not production-signed.

**Free code signing provided by SignPath.io, certificate by SignPath Foundation.**

SignPath Foundation approval is pending.

## Version

```text
ProductVersion: 0.9.0-beta.1
FileVersion:    0.9.0.1
Architecture:   x64
```
