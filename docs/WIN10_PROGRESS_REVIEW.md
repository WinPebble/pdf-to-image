# Windows 10 / Progress UI review package

Post-review update, 2026-10-13: PR #12 merged at `cf9f7ad0180c26cc987f4d22251979d1f717e6d5`; all three post-merge packaging workflows passed. PR #9/#10 were closed as superseded without deleting source branches. No release or Store update occurred. The preparation history below retains its original review/build provenance.

Prepared 2026-10-12. Local branch: `codex/win10-progress-validation`; baseline `7039ff0b3eac8fae0f21da0669fbb52c3271e900`. Changes are uncommitted/unpushed. This is a review handoff, not release approval or a new GitHub PR.

## Cleanup follow-up

The authorized cleanup follow-up reproduced and fixed finding 2 below. See [new regression/build record](../tests/VALIDATION-2026-10-12-CLEANUP-FIX.md): 17/17 regression and 12 hardening sections passed. On 2026-10-13 the new hash subsequently passed guided smoke cases on the Windows 11 laptop (screenshots and report) and Windows 10 PC (explicit maintainer report). Earlier original device records remain tied to the old hash. The current review scope is 22 files.

## Problem and resulting behavior

Explorer conversion can display the existing PR #10 progress window and cooperatively cancel work; the dev MSIX can be installed on Windows 10 using PR #9's minimum OS declaration. Ordinary console conversion remains available. A local regression fix removes newly encoded single-page output if cancellation arrives after the final progress callback but before commit; pre-existing output is preserved.

PR #9 remains an open draft targeting main at head `ccd1e83c838227e847f13ca1dc877b703b86110c`. PR #10 remains an open draft targeting PR #9's branch at head `15378137370be0ebf5f9d96de98db40e401c3c71`. GitHub state was rechecked during preparation. Neither PR was changed. The combined tested artifact includes a local fix beyond those heads; its evidence must not be presented as proof that the original PR #10 binary contains that fix.

## Files in the review scope

| Group | Files relative to repository root |
|---|---|
| Existing feature implementation | `shell/ExplorerCommand.cpp`; `src/WinPebble.PDFToImage/Program.cs`; `ExitCodes.cs`; `WinPebble.PDFToImage.csproj`; `Conversion/ProgressReporter.cs`; `Conversion/PdfConverter.cs`; `UI/ConversionApplicationContext.cs`; `UI/ProgressWindow.cs` (C# paths after the first are relative to the same application directory) |
| Windows 10 dev gate | `store-msix/AppxManifest.Dev.xml`; `store-msix/WINDOWS10_TEST_PLAN.md` |
| Regression harness | `tests/WinPebble.DevelopmentChecks/Program.cs`; `tests/WinPebble.DevelopmentChecks/WinPebble.DevelopmentChecks.csproj` |
| Guidance and records | `AGENTS.md`; `README.md`; `docs/DEVELOPMENT_STATUS.md`; `docs/PROGRESS_UI_TEST_PLAN.md`; `docs/WIN10_PROGRESS_DEVICE_GUIDE.md`; this review; `tests/VALIDATION-2026-10-12-WIN10-PROGRESS.md`; `tests/VALIDATION-2026-10-12-DEVICE-WIN10.md`; `tests/VALIDATION-2026-10-12-DEVICE-WIN11.md` |

Store identity/version/manifest, release scripts, workflow YAML, renderer, image encoder, output naming and OutputPlan are unchanged. The shell only adds the UI opt-in flag. No additional production code edits were made while recording device results. Source hashes for application/native/dev-manifest/regression files match the original tested kit.

## Validation evidence

- Actual local signed dev-MSIX build, native DLL compilation and package content/signature checks passed.
- Earlier source-level regression: 13/13, including real Windows rendering; earlier actual packaged-EXE hardening: 12 sections passed. Wrapper harness: 41 simulated cases passed; these are not 41 builds.
- Maintainer manual functional cases passed on Windows 10 Pro 22H2 x64 build 19045.7725 and Windows 11 Pro 26H2 build 26300.9457. See [Win10](../tests/VALIDATION-2026-10-12-DEVICE-WIN10.md), [Win11](../tests/VALIDATION-2026-10-12-DEVICE-WIN11.md) and [automated build record](../tests/VALIDATION-2026-10-12-WIN10-PROGRESS.md).
- Both devices show package removal, no conversion process and exact trusted CER removal. Manual installation/removal commands were used; no end-to-end helper-script pass is claimed.
- Original test ZIP/MSIX are retained unchanged. Their bundled records predate the device runs; updated records are in this source checkout. Do not rebuild/replace the tested binary merely to refresh documentation.
- During this documentation follow-up, rerunning conversion/build tests was unnecessary: executable source hashes are unchanged. Whitespace, Markdown links, scope, source hashes and artifact integrity were rechecked.

## Findings and remaining checks

1. **Known reproduced limitation:** deeply nested paths can fail multi-page conversion with a path-length error. Short paths passed. Long-path work is not included in this change.
2. **Resolved in cleanup follow-up (historical finding):** single-page cancellation cleanup called `File.Delete` without a best-effort guard. A sharing/access exception could replace the cancellation exception and be reported as conversion failure. Real locked/read-only cases reproduced it; guarded cleanup now preserves cancellation. New-artifact guided smoke runs have since passed on both devices, with the evidence limits recorded above.
3. DPI at 150%/200%, keyboard/accessibility, precise delayed-show/auto-close timing, slow single-page manual Cancel and finalization races remain unconfirmed. Win11 Explorer-menu removal was not separately confirmed for the old artifact; it was explicitly confirmed during the new-build smoke run. Device-specific dimensions/DPI/source hashes were not recorded separately from host hardening.
4. Existing native LNK4104 export warnings are nonfatal and unchanged. The uninstall helper remains best effort and can print success despite cleanup errors; device tests used explicit commands and independent checks.
5. PR plan documents retain historical assumptions about Actions artifacts and future retarget/rebase. They do not authorize Git changes or submission. The tested artifact was built locally, not by a newly dispatched workflow.

## Review and release boundaries

On 2026-10-13 the maintainer approved deferring the new build's two-device smoke retest while preparing review. See the [recorded exception](../tests/VALIDATION-2026-10-12-CLEANUP-FIX.md). New device results remain NOT RUN. This is a review-stage deferral, not a merge/release approval or a transfer of the previous binary's PASS results.

That historical deferral was subsequently superseded for the guided smoke cases by actual maintainer testing on both machines, recorded separately for the new hash. Other unconfirmed acceptance items remain open; this does not authorize merge/release.

Subsequently on 2026-10-13, the maintainer authorized committing/pushing this combined branch and opening a Draft PR into main as a consolidated review vehicle. Earlier references to uncommitted state describe build/test provenance. This publication authorization does not permit changing PR #9/#10, merging, or releasing.

Review the recorded scope and resolve or explicitly disposition findings before requesting merge. Decide separately how the local cancellation fix should be delivered relative to the dependent PRs. Do not merge, rebase/retarget, commit/push, tag or release without authorization. A production update still needs separate Store/version/signing review and approval; Windows 10 and Progress UI are not released Store features.
