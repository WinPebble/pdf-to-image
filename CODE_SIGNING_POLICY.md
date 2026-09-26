# Code signing policy

WinPebble intends to use Open Source code signing for official Windows releases of PDF to Image.

**Free code signing provided by SignPath.io, certificate by SignPath Foundation.**

> SignPath Foundation approval is still pending. Current development builds are not production-signed.

## Team roles

- **Authors / committers:** maintainers with write access to `WinPebble/pdf-to-image`.
- **Reviewers:** WinPebble maintainers responsible for reviewing contributed changes before merge.
- **Approvers:** WinPebble organization owners responsible for approving release signing requests.

The final named/permission-group mapping will be completed before the SignPath Foundation application is submitted.

## Source and build provenance

- Official source repository: https://github.com/WinPebble/pdf-to-image
- Release binaries must be produced by version-controlled build scripts and CI configuration.
- Production signing requests must originate from an approved trusted build system and a permitted release branch.
- Build scripts, packaging scripts, CI workflows, and signing configuration are security-sensitive source code.
- Release signing requires manual approval.

## Privacy

See [PRIVACY.md](PRIVACY.md).

## Security and user trust

Official releases must not require users to disable Smart App Control, Microsoft Defender, or other Windows security features.

Development-only self-signed certificates are never a requirement for public releases.
