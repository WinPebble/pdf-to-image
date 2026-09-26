# SignPath Foundation readiness

This document tracks the work required before WinPebble applies for free Open Source code signing from SignPath Foundation.

## Already addressed

- [x] Public GitHub repository
- [x] MIT License
- [x] Full WinPebble-owned core source
- [x] Native Explorer integration source
- [x] Version-controlled build and packaging scripts
- [x] GitHub-hosted Windows CI build
- [x] Privacy statement
- [x] Code signing policy
- [x] Install/uninstall implementation documented
- [x] No telemetry/background service in the utility
- [x] Public release must not require disabling Windows security
- [x] Release-form installer technology selected: NSIS
- [x] NSIS installer explicitly uses zlib compression
- [x] Local NSIS install/use/uninstall gate passed end-to-end
- [x] Product/version metadata aligned to `0.9.0-beta` / `0.9.0.0`

## Current release-form gate

The intended signed artifact is a Windows Setup EXE.

GitHub Actions must therefore build and upload:

```text
WinPebble-PDF-to-Image-Setup-Beta-Dev.exe
```

from repository source on a GitHub-hosted Windows runner before the project proceeds to the first GitHub pre-release.

The development Setup EXE is not production-signed and still uses a development certificate internally for sparse-package testing. That certificate model is not the public signing model.

## Still required before SignPath Foundation application

- [ ] Confirm all maintainers use GitHub 2FA
- [ ] Finalize named SignPath roles: authors/committers, reviewers, approvers
- [ ] GitHub Actions builds the Setup EXE successfully from `main`
- [ ] Publish `v0.9.0-beta` as a GitHub pre-release in the same Setup EXE form intended for signing
- [ ] Establish enough public project history/reputation for SignPath Foundation review
- [ ] Apply to SignPath Foundation
- [ ] After approval, install the SignPath GitHub App and configure GitHub as a Trusted Build System
- [ ] Add SignPath signing-request workflow with manual approval
- [ ] Replace development signing/trust with SignPath production signing
- [ ] Validate signed installer with Smart App Control / Microsoft Defender enabled
