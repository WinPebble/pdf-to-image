# Core validation — 2026-10-12

## Provenance

- Date/timezone: 2026-10-12, Asia/Bangkok.
- Tester: Codex, local automated CLI execution.
- Baseline: `main`, `285ca1fefb573b8b3be89138b670833ee1674cdb`.
- Working tree: dirty documentation/script changes for repository guidance and path fixes. C# conversion sources unchanged. Tracked diff captured locally at `artifacts/validation-2026-10-12.diff`; new guidance/status/template/record documents are untracked pending maintainer review.
- Workflow: none; local build, not a PR artifact.
- SDK: .NET 8.0.425. Native C++/Windows SDK toolchains were not exercised.
- OS: version 10.0.26300.0, build 26300.9457, registry DisplayVersion 26H2. Registry ProductName reports Windows 10 Pro; this label is recorded verbatim and does not establish Windows 10 22H2 compatibility.
- Architecture: standalone target win-x64.
- EXE: `artifacts/standalone/WinPebble.PDFToImage.exe`, 41,406,894 bytes.
- EXE SHA-256: `06f7d33524fbe7d9e2b21dcb9c00b20572cc970fe133e470186a5f869b8345b2`.
- No package installation/removal, certificate operation or Explorer restart performed.

## Results

| Check | Result | Evidence |
|---|---|---|
| `scripts/Build-Standalone.ps1` compatibility entry point | PASS | Delegated to root script; self-contained publish completed, exit 0 |
| `scripts/Test-Hardening.ps1` with default EXE path | PASS | All 12 sections completed, exit 0, terminal reports HARDENING TEST SUITE PASSED |
| A4 PNG/JPG | PASS | 2480 × 3508, metadata within 1 DPI of 300; original PDF hashes unchanged |
| Landscape / A3 | PASS | 3508 × 2480 / 3508 × 4961; 300-DPI metadata checks |
| Naming and paths | PASS | Single-page collision, Unicode, nested paths and batch |
| Multi-page output | PASS | Three final PNG pages and repeated output folder `(2)` |
| Corrupt/password-protected/non-PDF inputs | PASS | Expected failures, no final PNG |
| Cleanup | PASS | No `.winpebble.tmp` artifacts or conversion processes after suite |
| PowerShell syntax and local documentation links | PASS | Parser/link checks completed |
| MSIX, Explorer, Windows 10 22H2 and progress/Cancel | NOT RUN | No installation/UI tests; PR #9/#10 sources not checked out |

Generated fixture outputs remain in ignored `artifacts/hardening-test/`. Results cover the suite's assertions, not visual image quality or concurrent/interactive cancellation behavior. The initial sandboxed build was blocked from reading user NuGet.Config; the authorized retry completed.

## Decision

Core build and corrected test paths passed locally. This is not approval to merge PR #9/#10, claim additional OS support or submit a Store release. Release decision: PENDING.

## Documentation-branch review — 2026-10-12

- Created `docs/codex-foundation` from `main` at the same baseline SHA. All 17 modified/untracked files were verified byte-for-byte unchanged across the branch switch.
- Rechecked live GitHub: `main` and both PR heads match this snapshot; PR #9/#10 remain open drafts with their original dependency. All three workflows still report success for each head; inspected discussions still contain no device-test record.
- Clarified released versus experimental versus unverified behavior, including absent Progress UI/code 3 on this baseline and unverified current SignPath approval/Store binary version.
- Rechecked all PowerShell syntax, local Markdown links, new-file whitespace, `git diff --check`, and absence of changes in application sources/manifests/workflows: PASS.
- Verified the five replaced duplicate script bodies matched the original canonical root scripts. No additional script behavior changes were made during this review.
- The previously tested EXE still matches the SHA-256 above. Build/hardening were not rerun for documentation-only review edits; the earlier 12-section run remains the runtime evidence.
- Native packaging wrappers, MSIX installation and interactive feature tests remain NOT RUN locally. No commit, push, PR merge or Store action performed.

The ignored local diff/outputs referenced above are supplementary workspace evidence and will not accompany a normal Git commit. The portable record is this result summary; retain/export detailed logs and artifacts when a release validation requires independent reproduction.

## Exit-code correction and pre-commit validation — 2026-10-12

The maintainer authorized correction of wrapper failure reporting, followed by commit/push and a Draft PR if checks pass. This does not authorize merging or production release.

Cause: invoking a target script with `&` updates LASTEXITCODE for an explicit target `exit`, but a wrapper run via PowerShell `-File` that reaches its end normally can still return process exit 0. The previous wrapper reproduced direct=7 versus wrapper=0. A local LASTEXITCODE variable also shadows the updated automatic status, so the correction resets the global automatic status before delegation and explicitly exits with the resulting code. Resetting prevents a caller's stale native failure from contaminating a target that returns normally without running native tools. Terminating errors remain failures.

| Check | Type | Result |
|---|---|---|
| `scripts/Test-ScriptWrappers.ps1`, 41 cases | Isolated simulation | PASS: all five wrappers forward spaced arguments, return 0 for normal/explicit success, preserve explicit 7 and fail on throw, both with `-File` and a calling script carrying stale status |
| Missing .NET SDK | Isolated simulation with real prerequisite code | PASS: child PATH excludes dotnet; real root standalone script reports missing SDK and wrapper process exits 1. Installed SDK was not removed. |
| `scripts/Build-Standalone.ps1` | Actual local build | PASS: SDK 8.0.425, one self-contained win-x64 EXE, same size/hash as above, process exit 0 |
| `pwsh -NoProfile -NonInteractive -File scripts/Test-Hardening.ps1` | Actual local CLI conversions | PASS: all 12 sections; process exit 0. Local log: ignored `artifacts/hardening-2026-10-12-final.log`. |
| Parser, documentation links, new-file whitespace, `git diff --check`, selected-file secret-pattern checks | Static | PASS |
| Native packaging / install lifecycle / Explorer / UI / Windows 10 22H2 | Not run | No claims of target-device or interactive compatibility |

When initially checking hardening in-process, LASTEXITCODE retained 1 from the expected negative-input cases despite the suite reaching its success marker. Validation was rerun as a separate `-File` process and checked its process exit 0; the hardening implementation was not changed for this harness issue.

Final scope is 18 files: nine documents, the original eight support scripts and one regression-test script. Canonical build/pack/sign commands, C#/C++, manifests, versions and CI YAML are unchanged. No generated artifacts, certificates or logs are intended for the commit. Wrapper fixtures and the PR-body file are under ignored `artifacts/`.
