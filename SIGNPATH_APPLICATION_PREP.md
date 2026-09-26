# SignPath Foundation application preparation

This document collects the currently verified project information for the SignPath Foundation application.

## Project

- **Project name:** WinPebble PDF to Image
- **Repository:** https://github.com/WinPebble/pdf-to-image
- **Homepage:** https://winpebble.com
- **Product page:** https://winpebble.com/tools/pdf-to-image/
- **License:** MIT License
- **Platform:** Windows x64
- **Current public release:** https://github.com/WinPebble/pdf-to-image/releases/tag/v0.9.0-beta

## Project description

WinPebble PDF to Image is a small Windows utility that adds `Convert PDF to PNG` and `Convert PDF to JPG` commands to Windows File Explorer. It renders PDF pages locally using the Windows-native `Windows.Data.Pdf` API. It does not collect telemetry, upload PDF contents, run a background service, or require a user account.

## Intended signed artifact

Windows Setup EXE produced by GitHub Actions from version-controlled source and build scripts.

Current unsigned release-form artifact:

```text
WinPebble-PDF-to-Image-Setup-0.9.0-beta-unsigned.exe
```

SHA-256:

```text
a4591bfc9c844de580f81f8acfca9ffe2972649a91f934e76f079badd01e77e1
```

## Build provenance

- GitHub-hosted Windows runner
- Version-controlled GitHub Actions workflow
- .NET 8 core build
- native x64 Explorer shell extension build
- NSIS Setup EXE packaging
- CI verification of product name/version/file version
- CI-generated SHA-256
- release asset derived from the successful `main` workflow artifact

## Code signing policy

https://github.com/WinPebble/pdf-to-image/blob/main/CODE_SIGNING_POLICY.md

Required statement:

> Free code signing provided by SignPath.io, certificate by SignPath Foundation.

## Privacy policy

https://github.com/WinPebble/pdf-to-image/blob/main/PRIVACY.md

The application processes PDFs locally and does not transfer PDF contents or generated images to networked systems.

## Team roles

Current single-maintainer structure:

- **Authors / committers:** @AccidentalScholar95
- **Reviewers:** @AccidentalScholar95
- **Approvers:** @AccidentalScholar95

## MFA confirmation still required

Before submitting the application, explicitly confirm:

- GitHub MFA/2FA is enabled for the current maintainer.
- SignPath MFA will be enabled/used for the applicant account.

Do not mark these as completed without actual confirmation.

## Signing objective

Use SignPath Foundation Open Source code signing to establish verifiable provenance between the public source repository, the automated GitHub build, and official WinPebble Windows release binaries, while allowing users to keep Smart App Control, Microsoft Defender, and other Windows security protections enabled.

## Current limitation

WinPebble PDF to Image is a new project. SignPath Foundation may require additional public project history or reputation before accepting an executable end-user application.
