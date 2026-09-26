# Building WinPebble PDF to Image

## Development environment

The current Windows x64 development build requires:

1. .NET 8 SDK
2. Visual Studio 2022 Build Tools — **Desktop development with C++**
3. Windows 11 SDK with `MakeAppx.exe` and `SignTool.exe`
4. Inno Setup 7 for installer compilation

## Core executable

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
.\scripts\Build-Standalone.ps1
```

The self-contained executable is produced under `artifacts\standalone`.

## Explorer integration

```powershell
.\scripts\Check-Explorer-Prerequisites.ps1
.\scripts\Build-Explorer.ps1
```

The current Explorer scripts contain development-signing support for local testing. Do not publish development certificates or private keys.

## Installer

```powershell
.\scripts\Check-Installer-Prerequisites.ps1
.\scripts\Build-Installer.ps1
```

The current Inno Setup installer is an internal development installer and is not production-signed.

## Tests

```powershell
.\scripts\Test-Hardening.ps1
```

The hardening suite covers PNG/JPG conversion, 300 DPI output metadata, Unicode filenames, A3/landscape PDFs, multi-file conversion, multi-page atomic output, collision handling, damaged/password-protected inputs, cleanup, and process exit behavior.

## Release signing

Production signing is intentionally separate from local development signing. The project is preparing for SignPath Foundation Open Source code signing.

See [CODE_SIGNING_POLICY.md](CODE_SIGNING_POLICY.md).
