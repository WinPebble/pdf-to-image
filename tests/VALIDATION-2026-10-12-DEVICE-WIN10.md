# Windows 10 development device validation

## Provenance

- Recorded: 2026-10-12, Asia/Bangkok, from the maintainer's guided testing in this conversation. The Windows 10 screenshots show a different device-clock date (10/10/2026); that discrepancy was not independently reconciled. Do not treat the record date as a measured execution timestamp.
- Tester: maintainer, manual device testing; Codex reviewed screenshots and recorded reports.
- OS: Windows 10 Pro 22H2, build 19045.7725, 64-bit OS/x64 processor; `Screenshot (138).png`.
- Main baseline: `7039ff0b3eac8fae0f21da0669fbb52c3271e900`; branch `codex/win10-progress-validation`, dirty/uncommitted build.
- PR #9 head: `ccd1e83c838227e847f13ca1dc877b703b86110c`; PR #10 head: `15378137370be0ebf5f9d96de98db40e401c3c71`; additional single-page cancellation cleanup fix included. Original ZIP contains source patch/hashes.
- Local build, no new Actions run; tools and embedded EXE/DLL hashes: [build record](VALIDATION-2026-10-12-WIN10-PROGRESS.md).
- Artifact: `WinPebble-PDF-to-Image-0.9.0-beta.1-Full-Dev.msix`; `WinPebble.PDFToImage.StoreDev`, version 1.0.0.0, x64.
- MSIX SHA-256: `dc83feb149591d01cacce212caa17f44ab2da3db22d173a90a14b9a742844c02`.
- Original ZIP SHA-256: `1050e440b88457c45c24f5b361164c824d6f81c815395ca60359026e156c2fdd`.
- CER thumbprint: `2B2764C82E2F1D9A82F4181792F346F98FB997AC`.
- A full-dev package was already installed. Maintainer removed it, verified CER and reinstalled the hash-verified MSIX using interactive commands. No Store/sparse package was returned; legacy NSIS directory check was False. Actions were explicitly performed by the maintainer on their test machine.
- Display scaling, keyboard/accessibility configuration: not recorded.

## Results

PASS (reported) means maintainer confirmation, not independently automated observation. Screenshot names refer to conversation attachments; raw desktop screenshots are not copied into Git.

| Case | Result | Evidence and scope |
|---|---|---|
| Artifact integrity, prerequisites, reinstall | PASS | `Screenshot (145).png` shows correct MSIX hash and no legacy directory; `Screenshot (146).png` shows matching CER and package 1.0.0.0, Status Ok |
| Classic Explorer PNG/JPG commands, one-page conversion, PDF association | PASS (reported) | Maintainer confirmed all guided cases |
| 40-page PNG/JPG, progress/page/percentage, automatic close | PASS (reported) | Maintainer confirmed all cases; no output/progress screenshot provided for this device |
| Cancel PNG/JPG, X/Alt+F4, preserve previous output, no partial final folder | PASS (reported) | Maintainer confirmed all guided cases; exact native render/encode timing not instrumented |
| Temporary output cleanup | PASS | `Screenshot (147).png` shows temp-entry query without results; maintainer confirmed cases |
| Batch counters/reset, valid file after corrupt input, error Close | PASS (reported) | Explicit final confirmation of the remaining guided cases |
| Unicode filenames/output | PASS (reported) | Explicit final confirmation |
| Uninstall, exact trusted CER removal, no process | PASS | `Screenshot (147).png`: package/process queries return nothing and cert Test-Path False; manual commands, not uninstall helper |
| Explorer commands removed; original PDFs/generated images retained | PASS (reported) | Explicit final confirmation of the three outstanding points |
| DPI 150%/200%, keyboard focus/accessibility | NOT RUN / not confirmed | No separate device evidence supplied |
| Exact delay/auto-close timings, slow single-page Cancel, late-commit race | NOT RUN / not confirmed | Functional observation is not precision timing/race coverage |
| Dimensions/DPI metadata and source SHA on this installed device | NOT RUN / not independently recorded | Covered separately by build-host automated checks, not claimed here |

## Decision

The tested development package passed the reported functional/install/uninstall cases on Windows 10 22H2 x64 build 19045.7725. This establishes device-specific development evidence, not a production Windows 10 support commitment or coverage for every device/build. Remaining cases above remain open. Merge/Store update/release approval: PENDING.
