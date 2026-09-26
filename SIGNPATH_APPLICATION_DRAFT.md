# SignPath Foundation application draft

Use this as a copy/paste source while completing the SignPath Foundation application.

## Project name
WinPebble PDF to Image

## Repository
https://github.com/WinPebble/pdf-to-image

## Homepage
https://winpebble.com

## Current release
https://github.com/WinPebble/pdf-to-image/releases/tag/v0.9.0-beta.1

## License
MIT License

## Short description
WinPebble PDF to Image is a lightweight Windows utility that adds “Convert PDF to PNG” and “Convert PDF to JPG” commands to Windows File Explorer. PDF rendering is performed locally with the Windows-native Windows.Data.Pdf API. The application does not collect telemetry, upload PDF contents, run a background service, or require a user account.

## Artifact to be signed
Windows x64 NSIS Setup EXE built by GitHub Actions from the public repository.

Current unsigned release-form example:

`WinPebble-PDF-to-Image-Setup-0.9.0-beta.1-unsigned.exe`

SHA-256:

`f0c13d6500dd1e8bacc0eedda56cd2663f2d6756b717ede6b63e96c67dd73872`

## Build system
GitHub Actions on a GitHub-hosted Windows runner. The build compiles the .NET 8 conversion executable, native x64 Explorer shell extension, sparse package identity, and NSIS Setup EXE. CI verifies ProductName, ProductVersion, FileVersion and SHA-256.

## Code signing policy
https://github.com/WinPebble/pdf-to-image/blob/main/CODE_SIGNING_POLICY.md

## Privacy policy
https://github.com/WinPebble/pdf-to-image/blob/main/PRIVACY.md

## Team roles
- Authors / committers: @AccidentalScholar95
- Reviewers: @AccidentalScholar95
- Approvers: @AccidentalScholar95

## Why code signing is requested
To give Windows users a verifiable trust chain between the public WinPebble source repository, the automated GitHub build, and official release binaries, while allowing users to keep Smart App Control, Microsoft Defender and other Windows security protections enabled.

## MFA
- GitHub MFA/2FA: [confirm before submission]
- SignPath MFA: [enable/confirm for applicant account]
