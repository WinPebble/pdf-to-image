# Shared WinPebble branding validation

This records the initial PR #15 candidate. Device review subsequently requested
Duplicator-aligned sizing and menu icons; see [the follow-up record](VALIDATION-2026-10-16-MENU-ICON.md)
for the new uncommitted artifacts. Hashes below remain specific to the initial build.

## Provenance

- Date: 2026-10-16, Asia/Bangkok. Automated checks executed by Codex locally.
- Branch: `codex/shared-winpebble-branding`, base `8c32618ffef8b002a3a21a9af3236110375b0931`.
- Dirty working tree: shared logo assets, EXE/Progress icon resources, NSIS ICO,
  Store 1.0.3.0 packaging references and affected documentation. No commit or CI run yet.
- Host: Windows x64, build 26300.9457, display version 26H2. Registry ProductName
  retains the legacy Windows 10 Pro string; the build is the Windows 11 test host.
- Tooling: .NET SDK 8.0.425, VS 2022 Build Tools, Windows SDK 10.0.26100.0.
- MSIX: `artifacts/msix-store/out/WinPebble-PDF-to-Image-0.9.0-beta.1-Store-v1.0.3.0.msix`.
- MSIX SHA-256: `d7c622d707a7d49668c1b6fc45442c2a06b2500e8dd3f8a7d41a018dc5ac217a`.
- Packaged EXE SHA-256: `a71699cc81f36d1bb881981ff160c2bf45b9ecb357eaba20274f100c044d8452`.
- Packaged DLL SHA-256: `d87bf53e1dc380b014689c8403fc7a9d26c5e069d00eedf171d29ac677140a3c`.
- Official Store name/publisher retained; x64, version 1.0.3.0, minimum OS 10.0.19041.0.
- No installation/removal, trust change, Explorer restart, upload, submission or publication.

## Results

| Case | Result | Evidence / limit |
|---|---|---|
| Standalone, native DLL and Store MSIX build | PASS | Canonical `Build-MSIX-Store.ps1`, exit 0. Existing LNK4104 warnings remain. |
| Packed identity, version and minimum OS | PASS | Read from packed AppxManifest.xml. |
| Packed logo bytes | PASS | Each of the three PNG entries matches its repository asset hash. |
| Signing material exclusion | PASS | No CER/PFX/P12/PEM/KEY or AppxSignature.p7x entries. Unsigned Store candidate only. |
| ICO encoding | PASS | Three PNG frames, 32/44/150 px, retain supplied image bytes. No redraw or resize. |
| Native EXE icon | PASS | ExtractAssociatedIcon succeeded; inspected extracted bitmap. |
| NSIS ICO support | PASS | Isolated installer/uninstaller fixture compiled with the final PNG-frame ICO. It was not run. |
| Complete NSIS build / installation | NOT RUN | Fixture compilation is not full installer or lifecycle validation. |
| Conversion/cancellation regression | PASS | 17/17 with final ICO resource, including locked/read-only outputs and hidden Progress state. |
| Core hardening | PASS | All 12 sections against the final standalone EXE; source preservation, dimensions/DPI, collisions, Unicode, batch, invalid inputs, cleanup. |
| PowerShell syntax, manifest XML, diff whitespace | PASS | Parser/XML load and `git diff --check`. |
| Installed logo / Progress icon / scaling on Windows 10 and Windows 11 | NOT RUN | No installed UI or device acceptance claims for this artifact. |
| Store upgrade and signed delivery | NOT RUN | Candidate has not been submitted. |

Windows.Data.Pdf tests require execution outside the sandbox; restricted runs returned
access errors. The initial invocation without the required repository argument was
corrected. Neither failed invocation is counted as runtime acceptance.

## Scope and decision

Partner Center was read on 2026-10-16: Submission 3 / 1.0.2.0 is active, with no update
draft on the overview. GitHub main matches the base SHA and no open PRs were returned.
The existing product/file versions (0.9.0-beta.1 / 0.9.0.1), native RC, NSIS metadata,
dev/sparse identities and OS requirements are deliberately unchanged. Only the Store
package version advances to 1.0.3.0; names/assertions/workflow artifact references agree.

This is a local candidate review, not release approval. Conversion logic and native
shell behavior are unchanged. Next: review the diff, authorize Git publication, run CI
and check installed icon display/upgrade before a separately approved Store submission.
