# Building WinPebble PDF to Image

## Development environment

The current Windows x64 build requires:

1. .NET 8 SDK
2. Visual Studio 2022 Build Tools — **Desktop development with C++**
3. Windows 10/11 SDK with `MakeAppx.exe`, `SignTool.exe`, and `rc.exe`
4. NSIS for Setup EXE compilation

Install NSIS on a development machine with:

```powershell
winget install -e --id NSIS.NSIS
```

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

The Explorer development build uses a local self-signed certificate only for local sparse-package testing. Development certificates and private keys must never be committed or published as production credentials.

## Installer

The release-form installer is built with NSIS:

```powershell
.\scripts\Check-Installer-Prerequisites.ps1
.\scripts\Build-Installer.ps1
```

Expected output:

```text
artifacts\installer\WinPebble-PDF-to-Image-Setup-Beta-Dev.exe
```

The current beta development installer is **not production-signed**. It exists to validate the final Setup EXE form before SignPath Foundation signing.

## Tests

```powershell
.\scripts\Test-Hardening.ps1
```

Installer validation:

```powershell
.\scripts\Test-Installed-State.ps1
.\scripts\Test-Uninstalled-State.ps1
```

The local NSIS gate has passed:

- install succeeds;
- Explorer package registration succeeds;
- modern Windows 11 context-menu commands work;
- PDF → PNG succeeds;
- PDF → JPG succeeds;
- uninstall succeeds;
- Explorer package registration is removed;
- install directory is removed.

## Release signing

Production signing is intentionally separate from development signing.

Official signed releases must be produced from version-controlled source and CI configuration and must not require users to disable Smart App Control, Microsoft Defender, or other Windows security protections.

See [CODE_SIGNING_POLICY.md](CODE_SIGNING_POLICY.md).
