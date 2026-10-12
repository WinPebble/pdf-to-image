# Code signing policy

Microsoft Store is the production distribution path for PDF to Image. Its full MSIX identity and submission process are documented in [store-msix/STORE_IDENTITY.md](store-msix/STORE_IDENTITY.md) and [store-msix/STORE_SUBMISSION.md](store-msix/STORE_SUBMISSION.md). Store packages are submitted unsigned and signed through the Store process; this does not depend on SignPath approval.

The following SignPath policy applies to the separate direct-download Setup EXE path.

The planned provider attribution is: **Free code signing provided by SignPath.io, certificate by SignPath Foundation.** This is not a statement that approval has been granted or any production artifact has been signed.

> Existing beta/readiness documents record SignPath Foundation approval as pending and beta Setup binaries as not production-signed. The review on 2026-10-12 did not verify current SignPath account/approval state. Do not claim production signing without approval and artifact evidence.

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

For the direct-download signing path, the intended signed public artifact is the Windows Setup EXE produced by the repository's GitHub Actions release-form workflow. A successful build does not authorize signing, publication or Store submission.

Unsigned development previews may use a local development certificate to register the sparse Windows package required for the modern File Explorer integration. When such a preview does this, the installer must explicitly disclose the certificate-store change before installation and the uninstaller must remove that exact development certificate.

Production releases must not require a development/self-signed certificate.

## Privacy

See [PRIVACY.md](PRIVACY.md).

This program will not transfer any information to other networked systems unless specifically requested by the user or the person installing or operating it.

## Security and user trust

Official production releases must not require users to disable Smart App Control, Microsoft Defender, or other Windows security features.

Development-only self-signed certificates are never a requirement for production releases.
