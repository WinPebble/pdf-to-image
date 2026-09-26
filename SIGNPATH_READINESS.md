# SignPath Foundation readiness

This document tracks the work required before WinPebble applies for free Open Source code signing from SignPath Foundation.

## Already addressed in this repository

- [x] Public GitHub repository
- [x] MIT License
- [x] Full WinPebble-owned core source
- [x] Native Explorer integration source
- [x] Version-controlled build scripts
- [x] GitHub Actions unsigned build on a GitHub-hosted Windows runner
- [x] Privacy statement
- [x] Code signing policy
- [x] Install/uninstall implementation documented
- [x] No telemetry/background service in the utility
- [x] Public release must not require disabling Windows security

## Still required before application

- [ ] Confirm all maintainers use GitHub 2FA
- [ ] Finalize named SignPath roles: authors/committers, reviewers, approvers
- [ ] Confirm the final installer technology is compatible with SignPath Foundation's OSI-license conditions
- [ ] Produce the release artifact in the same form that will ultimately be signed
- [ ] Publish a pre-release/release in that form
- [ ] Establish enough public project history/reputation for SignPath Foundation review
- [ ] Apply to SignPath Foundation
- [ ] After approval, install the SignPath GitHub App and configure GitHub as a Trusted Build System
- [ ] Add SignPath signing-request workflow with manual approval
- [ ] Enforce product/version metadata consistently on signed binaries

## Installer licensing note

The current development installer uses Inno Setup. It is convenient and technically successful, but SignPath Foundation requires OSI-approved Open Source licensing for project components. Before using Inno Setup in the artifact submitted for free Foundation signing, WinPebble should obtain clarification from SignPath or replace the installer layer with an installer technology whose licensing clearly satisfies that requirement.

The current GitHub Actions workflow therefore builds and uploads the unsigned WinPebble-owned EXE and shell DLL only. It does not represent the final SignPath signing workflow.
