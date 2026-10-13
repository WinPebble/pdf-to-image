# Windows 11 development device validation

## Provenance

- Recorded: 2026-10-12, Asia/Bangkok, from the maintainer's guided testing in this conversation. This is human device testing, not Codex-operated UI automation.
- OS: Windows 11 Pro 26H2, build 26300.9457; x64 package installed successfully. OS evidence: attached winver screenshot `codex-clipboard-2ba6c149-5a52-4d9c-a101-416405e581b8.png`.
- Main baseline: `7039ff0b3eac8fae0f21da0669fbb52c3271e900`; local branch `codex/win10-progress-validation`, dirty/uncommitted build.
- PR #9 head: `ccd1e83c838227e847f13ca1dc877b703b86110c`; PR #10 head: `15378137370be0ebf5f9d96de98db40e401c3c71`; additional single-page cancellation cleanup fix included. Source patch and hashes are preserved in the original test ZIP.
- Local build; no new GitHub Actions run. Build tool versions and embedded EXE/DLL hashes: [build record](VALIDATION-2026-10-12-WIN10-PROGRESS.md).
- Artifact: `WinPebble-PDF-to-Image-0.9.0-beta.1-Full-Dev.msix`; identity `WinPebble.PDFToImage.StoreDev`, version 1.0.0.0, x64.
- MSIX SHA-256: `dc83feb149591d01cacce212caa17f44ab2da3db22d173a90a14b9a742844c02`.
- Original ZIP SHA-256: `1050e440b88457c45c24f5b361164c824d6f81c815395ca60359026e156c2fdd`.
- Dev CER thumbprint: `2B2764C82E2F1D9A82F4181792F346F98FB997AC`.
- Maintainer chose to remove the Store app and explicitly performed dev trust/install/removal. Pre-install queries showed no Store/dev/sparse package.
- Display scaling, monitors and accessibility setup: not recorded. Exact test times were not recorded independently.

## Results

PASS (reported) means confirmed by the maintainer; screenshots directly establish only the visible results. Screenshot names identify conversation attachments, not committed repository assets. They are not copied into Git because they include personal desktop/account information.

| Case | Result | Evidence and scope |
|---|---|---|
| Artifact integrity and install | PASS | Hash screenshot `codex-clipboard-76efb827-cfd8-4d01-b0f3-3ccd032fc26b.png`; install screenshot `codex-clipboard-fe72172b-1b7e-4a9a-a722-eb86c381575b.png` shows matching signer and package 1.0.0.0 |
| Installation method | PASS, manual commands | Initial .ps1 execution was BLOCKED by Execution Policy; maintainer used interactive Import-Certificate/Add-AppxPackage. No Execution Policy change was requested. This does not validate the install helper end to end. |
| Explorer PNG/JPG commands; one-page conversion | PASS (reported) | Maintainer confirmed the guided cases; PDF source preservation included |
| 40-page PNG/JPG | PASS | `Screenshot (681).png` and `Screenshot (680).png` each show 40 outputs, numbered through 040 |
| Progress window, page/percentage updates, success auto-close | PASS (reported) | Explicit maintainer observation; no precise timer measurement |
| Cancel PNG/JPG, X and Alt+F4, output preservation, temp cleanup | PASS (reported) | Maintainer confirmed guided cases including old outputs retained and incomplete output discarded; cancellation timing was not instrumented |
| Batch counters/reset and preserving completed batch output | PASS (reported) | Maintainer confirmed guided batch cases |
| Corrupt/valid batch, error window/Close, Unicode filename | PASS (reported) | Maintainer confirmed guided cases |
| Uninstall, exact trusted CER removal, process cleanup | PASS | `codex-clipboard-8ba8f1b0-2a8c-4444-acf7-c86337b871b5.png`: no package/process output and cert Test-Path False; manual commands used |
| Explorer menu removal and source/output preservation after uninstall | NOT SEPARATELY CONFIRMED | Requested after cleanup screenshot; subsequent general confirmation concerned the Windows 10 run. Do not infer this Windows 11 observation from package removal alone. |
| 150%/200% DPI, keyboard focus/accessibility | NOT RUN / not confirmed | No separate evidence or configuration supplied |
| Exact 750-ms delay / 1250-ms close interval; late-commit race; slow single-page Cancel | NOT RUN / not confirmed | General success/Cancel observations do not establish these precise boundaries; deterministic source-level cancellation checks are separate |
| Image dimensions/DPI metadata and source SHA on this installed device | NOT RUN / not independently recorded | Automated build-host hardening covers these separately |

## Decision

The tested development artifact passed the reported Windows 11 functional cases on this device. This is not certification for all Windows 11 builds, complete UI acceptance, or the Store-delivered binary. Remaining cases above remain open. Merge/production release approval: PENDING.
