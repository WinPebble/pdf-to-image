# SignPath Foundation readiness

This document tracks the work required before and after WinPebble applies for free Open Source code signing from SignPath Foundation.

## Already addressed

- [x] Public GitHub repository
- [x] MIT License
- [x] Full WinPebble-owned core source
- [x] Native Explorer integration source
- [x] Version-controlled build and packaging scripts
- [x] GitHub-hosted Windows CI build
- [x] Privacy statement
- [x] Code signing policy
- [x] Named SignPath roles for the current maintainer
- [x] Install/uninstall implementation documented
- [x] No telemetry/background service in the utility
- [x] Public release must not require disabling Windows security
- [x] Release-form installer technology selected: NSIS
- [x] NSIS installer explicitly uses zlib compression
- [x] Local NSIS install/use/uninstall gate passed end-to-end
- [x] Product/version metadata aligned to `0.9.0-beta` / `0.9.0.0`
- [x] GitHub Actions builds the Setup EXE successfully from `main`
- [x] GitHub Actions verifies product/version metadata
- [x] GitHub Actions generates SHA-256 for the Setup EXE
- [x] Public `v0.9.0-beta` GitHub pre-release published in the intended Setup EXE release form

## Current public release

Release:

```text
v0.9.0-beta
```

Public release page:

https://github.com/WinPebble/pdf-to-image/releases/tag/v0.9.0-beta

Public artifact:

```text
WinPebble-PDF-to-Image-Setup-0.9.0-beta-unsigned.exe
```

Setup SHA-256:

```text
a4591bfc9c844de580f81f8acfca9ffe2972649a91f934e76f079badd01e77e1
```

The beta is intentionally unsigned. It establishes the release form and verifiable build path that is intended to be production-signed after SignPath Foundation approval.

## Required before application submission

- [ ] Confirm all current maintainers use GitHub multi-factor authentication
- [ ] Confirm the SignPath applicant will enable/use SignPath multi-factor authentication
- [ ] Ensure the public release page includes a visible **Code signing policy** link/section
- [ ] Review the application preparation document for accuracy
- [ ] Submit the SignPath Foundation application

## External review consideration

SignPath Foundation evaluates project reputation and control, especially for executable programs distributed to end users.

WinPebble PDF to Image is a new project. Technical eligibility work can be completed now, but acceptance remains subject to SignPath Foundation's review and may depend on additional public project history or reputation.

## After SignPath Foundation approval

- [ ] Install/configure the SignPath GitHub integration required for the approved project
- [ ] Configure GitHub as the trusted/verifiable build system
- [ ] Define artifact configuration and enforce product/version metadata restrictions
- [ ] Add the production signing-request workflow
- [ ] Require manual approval for each production signing request
- [ ] Replace development signing/trust with SignPath production signing
- [ ] Validate the signed installer with Smart App Control and Microsoft Defender enabled
- [ ] Publish the first production-signed WinPebble PDF to Image release
