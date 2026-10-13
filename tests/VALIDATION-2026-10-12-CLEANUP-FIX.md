# Best-effort cancellation cleanup regression and rebuild

## Provenance

- Date: 2026-10-12, Asia/Bangkok. Tester: Codex, actual automated Windows checks on build host Windows 11 Pro 26H2 build 26300.9457.
- Branch `codex/win10-progress-validation`, baseline `7039ff0b3eac8fae0f21da0669fbb52c3271e900`; dirty/uncommitted. No commit, push, branch switch, merge, retarget/rebase or release.
- Source includes PR #9 head `ccd1e83c838227e847f13ca1dc877b703b86110c`, PR #10 head `15378137370be0ebf5f9d96de98db40e401c3c71` and the previously tested pre-commit cancellation fix. This follow-up changes only the cleanup exception handling, regression harness and affected records/guidance.
- Local build, no new Actions run. .NET SDK 8.0.425, VS 2022 BuildTools, Windows SDK packaging tools 10.0.26100.0.
- Canonical Build-MSIX-Dev.ps1 built self-contained win-x64 app and C++ shell DLL, packed and signed with existing CurrentUser/My dev signer. No package installation or trusted certificate changes performed.

## Reproduction and fix

At PageCompleted for a single-page PDF, the fixture either holds the newly encoded output open without FileShare.Delete, or sets that output read-only, then requests cancellation. Each fixture first attempts File.Delete and verifies the real expected Windows exception. It creates a pre-existing sentinel output so the conversion uses a collision name.

Before the fix, cleanup threw IOException (sharing violation) or UnauthorizedAccessException (read-only), replacing OperationCanceledException. Four new PNG/JPG cases failed; original 13 cases passed. The fix catches only IOException/UnauthorizedAccessException during this best-effort deletion, then rethrows the cancellation. It does not change ACLs, clear read-only attributes, retry indefinitely or delete existing user output. A completed new image can remain when Windows prevents its deletion. The test releases its lock/restores its own read-only fixture attribute in Dispose; production code does not.

## Checks

| Check | Result | Evidence / scope |
|---|---|---|
| Before-fix reproduction | FAIL, expected | 13/17 passed; four real locked/read-only PNG/JPG cases failed. `artifacts/cleanup-before-fix.log` |
| After-fix regression | PASS | 17/17; real Windows PDF rendering and deletion errors, cancellation propagated, no FileCompleted, source hash and pre-existing sentinel preserved, blocked new-image hash unchanged; normal cleanup and multi-page cases still pass. `artifacts/cleanup-after-fix.log` |
| MSIX development build | PASS | Actual standalone publish, C++ compile, MakeAppx, signing. `artifacts/msix-dev-cleanup-build.log` |
| New packaged EXE hardening | PASS | 12 sections, actual CLI rendering/metadata/naming/Unicode/batch/error/cleanup. `artifacts/cleanup-hardening.log` |
| Package audit | PASS | Dev identity 1.0.0.0 x64, minimum OS 10.0.19041.0; embedded EXE/DLL hashes match stage; no CER/private-key files in MSIX; CMS cryptographic signature valid and matches public CER. Not a trust-chain/install test. |
| New artifact installation/interactive UI on Win10 and Win11 | NOT RUN | Prior device records cover the previous MSIX hash only. Repeat success/Cancel/collision/cleanup smoke tests on both devices. |
| UI process cancellation exit code 3 | NOT RUN on new binary | Regression asserts converter cancellation; it does not click a packaged UI or independently measure its final process exit code. |

Existing nonfatal LNK4104 export warnings remain. Deep-path limitation, remaining DPI/keyboard/timer acceptance and uninstall-helper behavior are unchanged. Wrapper code is unchanged; its previous 41-case evidence is retained, not counted as a new run.

## New artifact

- MSIX: `artifacts/msix-dev/out/WinPebble-PDF-to-Image-0.9.0-beta.1-Full-Dev.msix`.
- MSIX SHA-256: `2a919f4e4a94367f555ce7147630c92a694f756ebd7223c07337055a99ee90eb`.
- EXE SHA-256: `e85d5d0097f2302694b6548d6fe2ffbbad57a0242206c7c0db6748c195ff43f6`.
- DLL SHA-256: `5c22ee9666099cf5fce1af6303151dd0cba3b266f93f65619e4c0242f604b6cc`.
- Public CER thumbprint unchanged: `2B2764C82E2F1D9A82F4181792F346F98FB997AC`.
- New kit: `artifacts/WinPebble-Win10-Progress-Dev-Cleanup-Fix-2026-10-12.zip`; external hash file `artifacts/SHA256SUMS-CLEANUP-FIX-KIT.txt`.
- Previous package preserved under `artifacts/msix-dev-before-cleanup-fix/`; original ZIP and original kit unchanged. Old device records still refer to MSIX hash `dc83feb149591d01cacce212caa17f44ab2da3db22d173a90a14b9a742844c02`.
- Package/product versions and Store manifest/workflows remain unchanged. Identify these development rebuilds by SHA-256, not version alone.

## Maintainer decision — 2026-10-13

The maintainer agreed in this conversation to defer repeating device smoke tests on both machines and proceed with review preparation. This is an explicit exception for the current review stage to AGENTS.md's UI/Cancel device-validation requirement. The new binary's device tests remain NOT RUN, not PASS or permanently waived. Earlier device results apply only to the old MSIX hash. Revisit the pending device gate before any merge/release decision; this deferral does not authorize commit/push, modification of PR #9/#10, or Store submission.

Status: DEVELOPMENT ONLY; review preparation may proceed with the documented deferral. New device acceptance pending. No production-support claim or release approval.
