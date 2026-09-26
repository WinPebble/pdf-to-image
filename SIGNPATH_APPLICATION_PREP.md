# SignPath Foundation application preparation

## Project

- **Project name:** WinPebble PDF to Image
- **Repository:** https://github.com/WinPebble/pdf-to-image
- **Homepage:** https://winpebble.com
- **Product page:** https://winpebble.com/tools/pdf-to-image/
- **License:** MIT License
- **Platform:** Windows x64
- **Current public release:** https://github.com/WinPebble/pdf-to-image/releases/tag/v0.9.0-beta.1

## Project description

WinPebble PDF to Image is a small Windows utility that adds `Convert PDF to PNG` and `Convert PDF to JPG` commands to Windows File Explorer. It renders PDF pages locally using the Windows-native `Windows.Data.Pdf` API. It does not collect telemetry, upload PDF contents, run a background service, or require a user account.

## Intended signed artifact

Windows Setup EXE produced by GitHub Actions from version-controlled source and build scripts.

Current unsigned artifact:

```text
WinPebble-PDF-to-Image-Setup-0.9.0-beta.1-unsigned.exe
```

SHA-256:

```text
f0c13d6500dd1e8bacc0eedda56cd2663f2d6756b717ede6b63e96c67dd73872
```

Source/build commit:

```text
6ad99e83e4b13469a47a06883181bbecb3491587
```

## Build provenance

- GitHub-hosted Windows runner
- version-controlled GitHub Actions workflow
- .NET 8 conversion core
- native x64 Explorer shell extension
- NSIS Setup EXE
- CI metadata verification
- CI-generated SHA-256
- release asset derived from successful `main` workflow artifact

## System changes and uninstall

The unsigned development beta uses a local `WinPebble Development` certificate in `Local Computer > Trusted People` to register the development sparse package used for modern Windows 11 File Explorer integration.

The installer explicitly discloses this change and requires user confirmation. The uninstaller removes the exact development certificate. Production releases are intended not to require this development/self-signed certificate.

## Code signing policy

https://github.com/WinPebble/pdf-to-image/blob/main/CODE_SIGNING_POLICY.md

## Privacy policy

https://github.com/WinPebble/pdf-to-image/blob/main/PRIVACY.md

## Team roles

- **Authors / committers:** @AccidentalScholar95
- **Reviewers:** @AccidentalScholar95
- **Approvers:** @AccidentalScholar95

## MFA confirmation still required

- GitHub MFA/2FA: confirm before submission.
- SignPath MFA: enable/use for the applicant account.
