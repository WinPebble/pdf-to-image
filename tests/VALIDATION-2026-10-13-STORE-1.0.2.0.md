# Store 1.0.2.0 candidate validation

## Provenance

- Date/time context: 2026-10-13, Asia/Bangkok. Tester: Codex, actual local automated checks.
- Branch: `codex/store-release-preparation`, from main `cf9f7ad0180c26cc987f4d22251979d1f717e6d5`; dirty working tree at build time. PR #13 documentation work remains separate.
- Host: Windows 11 Pro 26H2, previously recorded build 26300.9457. Build tools: .NET SDK 8.0.425, VS 2022 BuildTools, Windows SDK packaging tools 10.0.26100.0.
- Version decision: maintainer reports highest Partner Center package including pending submissions is 1.0.1.0. Candidate version 1.0.2.0; verify again before uploading.
- Minimum OS: 10.0.19041.0 x64, aligned with existing dev manifest. Maintainer explicitly declined further Windows 10 device tests. That decision does not establish every admitted OS version as tested.
- Build: canonical Build-MSIX-Store.ps1, local execution, unsigned package; no dev certificate/signing, package installation/removal, Explorer restart, Store submission, tag or release.
- No new GitHub Actions run at the time of local build; PR packaging checks are separate evidence when available.

## Artifact identity and hashes

- File: `artifacts/msix-store/out/WinPebble-PDF-to-Image-0.9.0-beta.1-Store-v1.0.2.0.msix` (72,341,460 bytes).
- Name: `TrungHieuNguyen-WinPebble.WinPebblePDFtoImage`.
- Publisher: `CN=6BD09250-A4F3-4F78-9DA7-2D9751735950`; package 1.0.2.0, x64, MinVersion 10.0.19041.0.
- MSIX SHA-256: `bbb2140ff6612ccbc9c05c2bf2b809dd85d60c4d226ebc3c17d9180b87339f8b`.
- EXE SHA-256: `e85d5d0097f2302694b6548d6fe2ffbbad57a0242206c7c0db6748c195ff43f6` — byte-identical to the manually tested cleanup-fix dev EXE.
- Shell DLL SHA-256: `9dc48330484bfa6389c24998d0b5244bec20a4887f5a58fd9a60f2ebf6557349`. Native source is unchanged, but the rebuilt DLL hash is distinct; no new installed Explorer runtime result is claimed for this exact DLL/package.
- Sum file: `artifacts/msix-store/out/SHA256SUMS-STORE.txt`.
- C# product/assembly/file metadata, native RC, NSIS and dev/sparse identities reviewed and deliberately unchanged. Package version is distinct from 0.9.0-beta.1 ProductVersion and 0.9.0.1 FileVersion.

## Results

| Check | Status | Evidence / scope |
|---|---|---|
| Actual Store candidate build | PASS | Publish self-contained win-x64, C++ compile, MakeAppx; `artifacts/store-1.0.2.0-build.log`. Existing nonfatal LNK4104 warnings remain. |
| Packaged official identity/version/minimum OS | PASS | Read packed manifest; exact Store name/publisher, 1.0.2.0 x64, MinVersion 19041. Embedded EXE/DLL hashes match stage. |
| Payload isolation | PASS | Required payload present; no AppxSignature.p7x or CER/PFX/P12/SNK/KEY/PEM files. No dev signing material in Store package. |
| Hardening on candidate staged EXE | PASS | 12 sections, actual Windows conversion/dimensions/DPI/naming/Unicode/batch/error/cleanup; `artifacts/store-1.0.2.0-hardening.log`. |
| Conversion/cleanup regression | PASS | 17/17, real rendering/locked/read-only cases and hidden-form state; `artifacts/store-1.0.2.0-regression.log`. Source harness links application code; not an installed Store UI test. |
| Application/test source comparison | PASS | Application/native source unchanged. Test harness byte hash differed after checkout solely because of CRLF/LF; normalized content comparison confirmed equality. |
| Syntax/whitespace/version references | PASS | PowerShell parser, XML parse, git diff --check; Store script/workflow/output filenames synchronized to 1.0.2.0. |
| Windows 10/11 dev-device smoke evidence | PASS within prior scope | Maintainer tested cleanup-fix dev package; [record](VALIDATION-2026-10-12-CLEANUP-FIX.md). Same EXE hash is useful evidence, but distinct official-identity install/upgrade is not covered. |
| Additional admitted Windows 10 versions | NOT RUN, maintainer declined | No Windows 10 2004/20H2/21H1/21H2 device evidence inferred from a 22H2 pass. |
| Official-identity installation/upgrade, WACK, Store delivery | NOT RUN | Requires approved environment/submission path and separate actions. Unsigned Store candidate is not offered for direct user installation. |
| Remaining DPI/keyboard/timer/finalization acceptance | NOT RUN / unconfirmed | Existing limits retained; not relabelled based on a successful build. |

## Decision

Local candidate packaging and automated checks passed. Preparation PR may be reviewed. Candidate is NOT uploaded/certified/published; no merge or release authorization is inferred. Review [release gates](../store-msix/RELEASE_CANDIDATE.md), confirm final SHA/hash and explicitly disposition remaining checks before submission.
