# Development status

Snapshot: 2026-10-12. Recheck GitHub before using these refs.

Review update, 2026-10-13: after initially deferring retesting, the maintainer completed the cleanup-fix smoke procedure on Windows 11 and explicitly reported that the whole same procedure also passed on their Windows 10 PC. See the [cleanup record](../tests/VALIDATION-2026-10-12-CLEANUP-FIX.md) for new-hash evidence, screenshots versus reported results, and remaining acceptance items. PR #12 remains a development review; no merge or release approval is implied.

## Follow-up after PR #11 merge

GitHub and local `main` are now at `7039ff0` (PR #11 merged). The sections below describing the documentation PR retain its historical baseline `285ca1f`.

The local `codex/win10-progress-validation` branch starts at `7039ff0` and applies the existing combined PR #9/#10 diff without merging, rebasing, retargeting or pushing either PR branch. Both PRs remain open drafts at the recorded heads. Production Store configuration is unchanged.

Automated cancellation checks reproduced a late single-page cancellation leaving the newly encoded PNG/JPG behind, including the collision case. A small cleanup fix covers all pre-commit cancellation boundaries and preserves pre-existing output. Regression source lives in `tests/WinPebble.DevelopmentChecks/`; it links production conversion sources, uses real Windows rendering and tests a hidden form's state. It does not establish installed Explorer behavior or Windows 10 compatibility.

The maintainer has now tested the same signed development MSIX on Windows 10 Pro 22H2 x64 build 19045.7725 and Windows 11 Pro 26H2 build 26300.9457. Reported functional cases passed, including progress, Cancel, batch/errors, Unicode and manual uninstall/certificate cleanup. See the [Windows 10 record](../tests/VALIDATION-2026-10-12-DEVICE-WIN10.md) and [Windows 11 record](../tests/VALIDATION-2026-10-12-DEVICE-WIN11.md) for screenshot versus reported evidence and untested cases. DPI/keyboard, precise timer measurements and certain cancellation boundaries remain unconfirmed. Win11 menu removal after uninstall was not separately confirmed. No production-support claim is expanded. The original ZIP is preserved unchanged; its bundled records predate these device runs.

The maintainer confirms the application is released on Microsoft Store. The source Store manifest is version 1.0.1.0; this does not independently establish the currently served binary or certification status.

The [review handoff](WIN10_PROGRESS_REVIEW.md) covers 22 files. The cleanup error masking cancellation was reproduced with real locked/read-only PNG/JPG outputs and fixed with best-effort handling. The [cleanup follow-up record](../tests/VALIDATION-2026-10-12-CLEANUP-FIX.md) records 17/17 regression cases, 12 hardening sections and the new MSIX hash, now followed by passed guided smoke runs on both devices. The reproduced long-path limitation remains.

## Released, experimental and unverified

| Scope | Status | Evidence / limit |
|---|---|---|
| Windows 11 x64 Explorer PDF-to-PNG/JPG, Windows-native renderer, 300 DPI, output naming and source preservation | Released baseline | Maintainer release confirmation; corresponding behavior exists on `main`. Local CLI checks are recorded in `tests/VALIDATION-2026-10-12-CORE.md`; they are not a Store-binary audit. |
| Windows 10 22H2 support | Experimental, not released | PR #9 changes only dev MSIX MinVersion; target-framework/API declarations do not prove runtime/install compatibility. |
| Progress UI and Cancel | Experimental, not released | PR #10 targets PR #9's branch. UI and cancellation code are absent from production `main`; the local validation branch includes them for testing. |
| Windows 10 install/Explorer behavior, UI/Cancel on both OS versions | Development device cases passed, not released | Maintainer reports and screenshots recorded for builds 19045.7725 and 26300.9457. Scope and remaining cases are in the two device records; this does not certify all systems or the Store binary. |
| Currently delivered Store version and SignPath approval/signature state | Not independently verified | Source version is not proof of the live Store binary; beta documents record SignPath pending. |

## Documentation branch scope

`docs/codex-foundation` starts from `main` at `285ca1f`. It contains guidance/status/validation documents plus build-entry-point and test-path fixes preserved from the working tree. It does not change C#/C++ conversion code, manifests, application/package versions or workflow YAML. It does not implement or merge PR #9/#10.

This is a documentation and development-tooling change set, rather than Markdown-only changes: five legacy scripts delegate to canonical root scripts, the standalone script prints the correct test command, and hardening/context-menu preparation use repository-root fixture paths. Native packaging entry points have not been executed locally in this review because they can create signing certificates.

Pre-commit review found that plain delegation could mask an explicit target exit code when run with PowerShell `-File`. The wrappers now reset stale status and explicitly exit with the target code. `scripts/Test-ScriptWrappers.ps1` adds isolated regression coverage; the final change set contains 18 files (the original 17 plus this test script). This corrects development entry-point failure reporting without changing canonical packaging commands or release workflows.

## Baseline and dependent PRs

- `main`: `285ca1f`, merged PR #8 (icon refresh, Store package 1.0.1.0).
- [PR #9](https://github.com/WinPebble/pdf-to-image/pull/9): draft, base `main`, head `win10-22h2-msix-dev-validation` at `ccd1e83`. Only lowers the dev manifest minimum to 10.0.19041.0 and adds `store-msix/WINDOWS10_TEST_PLAN.md`. Production Store minimum remains 10.0.22000.0.
- [PR #10](https://github.com/WinPebble/pdf-to-image/pull/10): draft, base PR #9's branch, head `feature/progress-window-dev-validation` at `1537813`. Adds delayed WinForms progress and cooperative Cancel. Its `docs/PROGRESS_UI_TEST_PLAN.md` is on the feature branch, not this baseline.

All three build workflows succeeded for both PR heads. Dev runs: [PR #9](https://github.com/WinPebble/pdf-to-image/actions/runs/37774791878), [PR #10](https://github.com/WinPebble/pdf-to-image/actions/runs/37878896969). These are packaging results, not device evidence. No device-test record was found in the PR discussions inspected for this snapshot.

## Remaining gates

1. Review the recorded Windows 10/11 device evidence and complete unconfirmed acceptance items. Tested artifact includes the local cleanup fix beyond the original PR heads.
2. Complete precise fast-file delay/auto-close timing, keyboard/DPI, slow single-page and finalization-race checks. Reported functional progress/Cancel/batch/error cases passed on both tested builds.
3. Record exact artifacts and results with `tests/VALIDATION-RECORD-TEMPLATE.md`.
4. After dependency approval, review PR #10's base/diff again. Retarget/rebase/merge needs authorization.
5. Prepare a separate approved production update. Do not submit experimental PR artifacts or advertise Windows 10 support before validation.

The branch API reported `main` unprotected during inspection; repository rulesets were not audited. Check both before proposing required checks/review policies.
