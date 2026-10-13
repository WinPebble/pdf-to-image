# Combined Windows 10 / Progress UI validation — 2026-10-12

## Provenance

- Tester: Codex, automated checks on the local build host, Asia/Bangkok.
- Main synchronized by fast-forward: `7039ff0b3eac8fae0f21da0669fbb52c3271e900`, PR #11 merged.
- Initial working tree was clean. Local branch: `codex/win10-progress-validation`; changes remain uncommitted and unpushed.
- Feature source: existing combined PR #9/#10 diff, from `285ca1f` to `15378137370be0ebf5f9d96de98db40e401c3c71`; PR #9 head is `ccd1e83c838227e847f13ca1dc877b703b86110c`. Neither PR was merged, rebased, retargeted or modified.
- Additional application fix: clean only the successfully encoded single-page output on cancellation at any pre-commit boundary. This fixes the intended cancellation contract rather than introducing a new feature.
- OS: 10.0.26300.9457, DisplayVersion 26H2; registry ProductName says Windows 10 Pro. This label is not evidence of Windows 10 22H2 compatibility.
- .NET SDK: 8.0.425; Visual Studio 2022 BuildTools; Windows SDK packaging tools: 10.0.26100.0.
- Local build, no new GitHub Actions run dispatched. Store manifest/build/workflow YAML unchanged; no Store submission or release.

This record describes the first device-tested binary. A later [cleanup-fix rebuild](VALIDATION-2026-10-12-CLEANUP-FIX.md) has separate evidence and a new hash; do not transfer these device results to it.

## Artifact identity

- Dev MSIX: `artifacts/msix-dev-before-cleanup-fix/out/WinPebble-PDF-to-Image-0.9.0-beta.1-Full-Dev.msix` (72,344,507 bytes), preserved before the rebuild.
- Identity `WinPebble.PDFToImage.StoreDev`, version 1.0.0.0, x64, MinVersion 10.0.19041.0.
- MSIX SHA-256: `dc83feb149591d01cacce212caa17f44ab2da3db22d173a90a14b9a742844c02`.
- Embedded EXE SHA-256: `13fc5a14e44f2f26367e0dd423e2df2f067ddee0281fe359170b3cfedd8ec4fd`.
- Embedded shell DLL SHA-256: `438d71454a68f32039baa59f64cdb99774a293902f68e9066d649f7995703801`.
- Public CER thumbprint: `2B2764C82E2F1D9A82F4181792F346F98FB997AC`.
- The build created/reused a development signing certificate in CurrentUser/My. At the initial automated-build stage the signer was absent from TrustedPeople/Root and Codex did not install/remove any package. The maintainer subsequently imported the exact dev CER, installed/tested/removed the package and deleted that trusted CER on both devices; see separate device records below. CurrentUser/My build signing material is distinct from installed-device trust.

## Checks performed

| Check | Status | Scope / evidence |
|---|---|---|
| Existing feature code review | PASS | Progress delay 750 ms, per-PDF percentage, batch counters, cooperative token boundaries; production configuration preserved |
| Before-fix cancellation regression | FAIL, reproduced | 9/13 passed; PNG/JPG cancellation after final PageCompleted left new single-page output, including collision cases |
| After-fix cancellation/component regression | PASS | 13/13; real Windows rendering, pre-cancel, cancellation after load, after one-page encode, collision preservation, multi-page first/last-page cleanup, source hashes; hidden-form percentage/reset/batch/Close state |
| Build-MSIX-Dev.ps1 | PASS | Actual self-contained publish, native C++ compilation, MakeAppx packing and dev signing; log `artifacts/msix-dev-build.log` |
| MSIX content/signature checks | PASS | Embedded EXE/DLL hashes match tested staged files; dev identity/minimum OS verified; no certificate/key payload files; CMS cryptographic signature valid and signer matches CER. Trust-chain acceptance not tested. |
| Self-contained EXE in sandbox | BLOCKED | Application Control/process creation and bundle extraction restrictions observed; no security policy changes made |
| Same packaged EXE hardening outside sandbox | PASS | 12 sections using real CLI conversion; `artifacts/hardening-win10-progress-elevated-host.log`, process exit 0 |
| Additional packaged CLI checks | PASS | Help and invalid arguments return 2; mixed corrupt/valid batch returns 1 and still creates the valid image |
| Generated 40-page PDF, short scratch path | PASS | Actual packaged EXE, 40 PNG outputs, exit 0; `artifacts/long-fixture-short-path.log` |
| Generated 40-page PDF, deeply nested scratch path | FAIL, limitation | Renderer reported "The file path is too long for this operation" after loading 40 pages; retry at short path passed. Long-path behavior remains an unresolved limitation, not a Windows 10 compatibility result. |
| Script wrapper regression | PASS | 41 cases including simulated targets, explicit failure/throw, and real missing-SDK prerequisite code under isolated PATH; not 41 actual builds. Log `artifacts/wrappers-win10-progress.log` |
| Windows 10 22H2 install/runtime/Explorer | PASS for reported cases | Maintainer device run on 19045.7725; see [Windows 10 record](VALIDATION-2026-10-12-DEVICE-WIN10.md) for evidence and untested cases |
| Windows 11 installed Explorer and interactive UI | PASS for reported cases | Maintainer device run on 26300.9457; see [Windows 11 record](VALIDATION-2026-10-12-DEVICE-WIN11.md); precise timings, keyboard/DPI acceptance remain unconfirmed |
| Uninstall / trusted-certificate cleanup | PASS for manual commands | Both devices: screenshots show no package/process and exact trusted CER absent. Helper scripts were not validated end to end; Win11 Explorer removal observation remains unconfirmed separately. |

Development callback tests link the current conversion source; they do not exercise a packaged UI process. Detailed logs, generated outputs and test-kit archive remain ignored local artifacts. Native linking emitted existing nonfatal LNK4104 warnings for DllCanUnloadNow/DllGetClassObject exports lacking PRIVATE; no export behavior was changed.

## Remaining gates and decision

Device functional runs have now been reported on both OS builds, with separate records linked above. Complete remaining acceptance items using `docs/WIN10_PROGRESS_DEVICE_GUIDE.md` and record separate results with `tests/VALIDATION-RECORD-TEMPLATE.md`. Evaluate late Cancel at commit, error/cancel combinations, UI responsiveness, 750-ms display delay, automatic success close, DPI/keyboard, install/uninstall and classic/modern Explorer commands. Do not infer Windows 10 support from MinVersion, compiler success or this host's registry name.

Status: DEVELOPMENT ARTIFACT ONLY. Merge/release approval: NOT REQUESTED; production support claims unchanged.
