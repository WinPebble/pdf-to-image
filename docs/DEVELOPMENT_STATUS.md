# Development status

Snapshot: 2026-10-12. Recheck GitHub before using these refs.

The maintainer confirms the application is released on Microsoft Store. The source Store manifest is version 1.0.1.0; this does not independently establish the currently served binary or certification status.

## Released, experimental and unverified

| Scope | Status | Evidence / limit |
|---|---|---|
| Windows 11 x64 Explorer PDF-to-PNG/JPG, Windows-native renderer, 300 DPI, output naming and source preservation | Released baseline | Maintainer release confirmation; corresponding behavior exists on `main`. Local CLI checks are recorded in `tests/VALIDATION-2026-10-12-CORE.md`; they are not a Store-binary audit. |
| Windows 10 22H2 support | Experimental, not released | PR #9 changes only dev MSIX MinVersion; target-framework/API declarations do not prove runtime/install compatibility. |
| Progress UI and Cancel | Experimental, not released | PR #10 targets PR #9's branch. UI and cancellation code are absent from `main` and this documentation branch. |
| Windows 10 install/Explorer behavior, UI/Cancel on both OS versions | Not established by reviewed evidence | Packaging CI passes; no device-test record found in the inspected PR discussions. Tests may exist elsewhere and need to be supplied before treating these gates as passed. |
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

1. Validate PR #9's dev package on Windows 10 22H2 x64 (19045.x), including classic Explorer commands, conversion and uninstall/certificate cleanup.
2. Validate PR #10 on Windows 10 and Windows 11: fast-file delay, batch counters, output equivalence, errors, Cancel during render/encode/finalization, window close/Alt+F4, keyboard and DPI scaling.
3. Record exact artifacts and results with `tests/VALIDATION-RECORD-TEMPLATE.md`.
4. After dependency approval, review PR #10's base/diff again. Retarget/rebase/merge needs authorization.
5. Prepare a separate approved production update. Do not submit experimental PR artifacts or advertise Windows 10 support before validation.

The branch API reported `main` unprotected during inspection; repository rulesets were not audited. Check both before proposing required checks/review policies.
