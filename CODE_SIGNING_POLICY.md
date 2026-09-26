# Code signing policy

WinPebble intends to use Open Source code signing for official Windows releases of PDF to Image.

**Free code signing provided by SignPath.io, certificate by SignPath Foundation.**

> SignPath Foundation approval is still pending. Current public beta builds are not production-signed.

## Team roles

WinPebble PDF to Image is currently a single-maintainer Open Source project. The same maintainer currently fills the SignPath team roles below:

- **Authors / committers:** [`@AccidentalScholar95`](https://github.com/AccidentalScholar95)
- **Reviewers:** [`@AccidentalScholar95`](https://github.com/AccidentalScholar95)
- **Approvers:** [`@AccidentalScholar95`](https://github.com/AccidentalScholar95)

Role responsibilities:

- **Authors / committers** are trusted to modify source code and build configuration in the project repository.
- **Reviewers** review changes proposed by people who are not committers before merge.
- **Approvers** manually approve production signing requests.

All people assigned to SignPath roles must use multi-factor authentication for both the source-code repository account and SignPath account.

## Source and build provenance

- Official source repository: https://github.com/WinPebble/pdf-to-image
- Release binaries must be produced by version-controlled build scripts and CI configuration.
- Production signing requests must originate from an approved trusted build system and a permitted release branch.
- Build scripts, packaging scripts, CI workflows, and signing configuration are security-sensitive source code.
- Release signing requires manual approval.
- Upstream or third-party binaries must not be signed using the WinPebble project signing identity unless they are WinPebble-owned source artifacts permitted by the SignPath Foundation policy.

## Release form

The intended signed public artifact is the Windows Setup EXE produced by the repository's GitHub Actions release-form workflow.

Unsigned development previews may use a local development certificate to register the sparse Windows package required for the modern File Explorer integration. When such a preview does this, the installer must explicitly disclose the certificate-store change before installation and the uninstaller must remove that exact development certificate.

Production releases must not require a development/self-signed certificate.

## Privacy

See [PRIVACY.md](PRIVACY.md).

This program will not transfer any information to other networked systems unless specifically requested by the user or the person installing or operating it.

## Security and user trust

Official production releases must not require users to disable Smart App Control, Microsoft Defender, or other Windows security features.

Development-only self-signed certificates are never a requirement for production releases.
