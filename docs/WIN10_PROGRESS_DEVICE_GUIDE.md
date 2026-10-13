# Combined Windows 10 / Progress UI development device test

This is a development-only package, not a Store update. Test separately on Windows 10 22H2 x64 (19045.x) and Windows 11 x64. Local automated checks on build 26300.9457 do not replace these two device runs.

## Provenance and package

- Main baseline: `7039ff0b3eac8fae0f21da0669fbb52c3271e900` (merged PR #11).
- PR #9: `ccd1e83c838227e847f13ca1dc877b703b86110c`, dev-manifest Windows 10 experiment.
- PR #10: `15378137370be0ebf5f9d96de98db40e401c3c71`, based on PR #9, progress/Cancel experiment.
- Local branch: `codex/win10-progress-validation`, uncommitted combined changes plus pre-commit cancellation and best-effort cleanup fixes. The ZIP contains a source patch and additional new source files for traceability; it is not a release.
- Package identity: `WinPebble.PDFToImage.StoreDev`, version `1.0.0.0`, x64, minimum OS `10.0.19041.0`.
- Latest MSIX SHA-256: `2a919f4e4a94367f555ce7147630c92a694f756ebd7223c07337055a99ee90eb`. This is the cleanup-fix rebuild; prior device passes refer to the old hash, not this binary.
- Public signing CER thumbprint: `2B2764C82E2F1D9A82F4181792F346F98FB997AC`.
- ZIP: `artifacts/WinPebble-Win10-Progress-Dev-Cleanup-Fix-2026-10-12.zip` in the build workspace. It contains MSIX/CER, hashes, installation helpers, fixtures, this guide and test-record template. No private signing key is included.

## Recorded device runs

For the previous MSIX hash dc83feb149591d01cacce212caa17f44ab2da3db22d173a90a14b9a742844c02, the maintainer completed the reported functional runs on Windows 10 22H2 build 19045.7725 and Windows 11 build 26300.9457. See the separate [Windows 10](../tests/VALIDATION-2026-10-12-DEVICE-WIN10.md) and [Windows 11](../tests/VALIDATION-2026-10-12-DEVICE-WIN11.md) records for scope and remaining checks. The original ZIP and MSIX are preserved unchanged; records inside that ZIP describe the earlier build stage. Updated device records live in the source workspace.

See [the cleanup rebuild record](../tests/VALIDATION-2026-10-12-CLEANUP-FIX.md) for the new artifact. Repeat PNG/JPG success, Cancel, collision preservation and uninstall cleanup on both devices. Package version is unchanged, so explicitly remove any older full-dev package before installing the new hash-verified build. If a locked/read-only new image cannot be deleted after Cancel it may remain; cancellation should still complete, and the original existing output must be preserved.

## Prepare an isolated test machine

Use a clean VM/snapshot or dedicated test PC. Do not test alongside the production Store app or sparse NSIS beta: identities differ, but the Explorer commands use shared CLSIDs and could be ambiguous. Do not remove a production installation just to perform this test; use another environment.

Extract the ZIP to a short local writable folder, such as `C:\WPTest`. Copy conversion fixtures to a short scratch path as well: an actual 40-page conversion failed with "The file path is too long for this operation" under a deeply nested scratch folder, then passed with a short path. Multi-page staging adds a GUID and filenames to the input directory; long-path support is not established. Run all commands from the extracted root. Record the OS edition/build, display scaling and package hash in `tests/VALIDATION-RECORD-TEMPLATE.md`, one record per device.

Before installation, inspect existing packages:

```powershell
Get-AppxPackage -Name 'TrungHieuNguyen-WinPebble.WinPebblePDFtoImage'
Get-AppxPackage -Name 'WinPebble.PDFToImage.Dev'
Get-AppxPackage -Name 'WinPebble.PDFToImage.StoreDev'
Get-FileHash '.\artifacts\msix-dev\out\WinPebble-PDF-to-Image-0.9.0-beta.1-Full-Dev.msix' -Algorithm SHA256
$cer = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new((Resolve-Path '.\artifacts\msix-dev\cert\WinPebble-PDFToImage-Full-MSIX-Dev.cer').Path)
$cer.Thumbprint
```

Verify the hash and thumbprint above. If a production/NSIS package exists, stop and select an isolated environment. If an older full-dev package exists, document it: the install helper removes that dev package before installing this one.

## Install (tester action only)

Only after approving trust changes on the test machine, open Windows PowerShell as Administrator **under the same test user** and run:

```powershell
.\Install-MSIX-Dev.ps1
Get-AppxPackage -Name 'WinPebble.PDFToImage.StoreDev' | Select-Object Name,Version,PackageFullName,InstallLocation
```

The helper imports the public dev certificate into LocalMachine/TrustedPeople and installs the dev MSIX. It does not update the Store identity. Do not disable Defender, Smart App Control or machine security policy if installation fails. Capture the full error; certificate trust may need cleanup even after a failed installation.

## Acceptance checklist on each OS

1. Copy fixtures from `tests/` to a writable scratch folder; never convert inside WindowsApps. On Windows 10 inspect the classic right-click menu; on Windows 11 inspect the modern menu. Confirm both PNG and JPG commands and check that PDF double-click still opens its normal reader. If registration is delayed, sign out/in or explicitly approve an Explorer restart on the test machine.
2. Convert a small one-page PDF to PNG and JPG. If completion is under 750 ms, no progress window should flash; if it takes longer, a window is expected. Check A4 dimensions 2480 x 3508 and metadata around 300 DPI; source PDF must remain unchanged.
3. Convert `Progress-Long-40-Pages.pdf` (generated test fixture) or another long PDF. Confirm filename, page N/M and percentage. Percentage is completed pages of the **current PDF**, not elapsed time or overall batch. A complex page can leave it unchanged temporarily; 100% can precede final folder commit.
4. Select at least three PDFs, including a multi-page file. Confirm File X of Y, percentage reset per PDF, correct filenames and no partial final multi-page folder while work is in progress. On success, expect Completed and automatic close after about 1.25 seconds if the window was visible.
5. Convert the same PDF again. Existing files/folders must remain and new output must use `(2)`, `(3)`, etc. Check multi-page files have `_page_001`, `_page_002` numbering in the dedicated `Name - PNG/JPG` folder.
6. Cancel a long multi-page conversion at early and late stages. Expect Cancelling while the current native render/encode finishes; Cancel is cooperative. Then expect Cancelled with Close. Click Close to end the process. No incomplete final folder or `.winpebble.tmp` entries should remain; files completed earlier in the batch must remain intact.
7. Cancel a slow one-page conversion and repeat with an existing same-name output. The cancelled invocation's newly generated image should be removed when cancellation is observed before commit; previous output must remain. If cancellation arrives after commit, that file may already be successfully completed. Record timing and observed state rather than assuming instantaneous cancellation.
8. During conversion, use X/Alt+F4: this requests Cancel, not forced termination. Repeat Cancel clicks; UI should stay responsive. Check 100%, 150% and 200% scaling, long Unicode filenames, keyboard focus and button access.
9. Mix a corrupt/password-protected PDF with valid PDFs. Valid files should still convert; completion with errors must remain visible with Close. In a separate CLI test, remove/rename an input after specifying it to test the missing-file error.
10. After closing the window, verify no conversion process or temp output remains. Do not confuse a Cancelled window waiting for Close with a resident background service.

The ZIP includes repository fixtures and a generated 40-page A4 PDF for cancellation tests. UI appearance, delay timing, accessibility, Explorer registration and installation must be assessed manually; the automated hidden-form test covers state only.

## Uninstall and verify (tester action only)

Keep the matching CER until cleanup completes. From the same elevated test-user PowerShell:

```powershell
.\Uninstall-MSIX-Dev.ps1
Get-AppxPackage -Name 'WinPebble.PDFToImage.StoreDev'
Test-Path 'Cert:\LocalMachine\TrustedPeople\2B2764C82E2F1D9A82F4181792F346F98FB997AC'
```

The package query must return no dev package and Test-Path must return False. Confirm both Explorer verbs disappear in the clean test environment; refresh/sign out if needed. The existing uninstall helper uses best-effort cleanup and may print success despite a removal error, so these independent checks are mandatory. If cleanup fails, capture the error and stop; do not remove certificates by subject or delete another package.

The signing certificate on the build machine is in CurrentUser/My and was never imported into TrustedPeople/Root. The public CER in the ZIP is for the approved test-device trust step only.

## Reproduce automatic checks from the source workspace

```powershell
dotnet run --project .\tests\WinPebble.DevelopmentChecks\WinPebble.DevelopmentChecks.csproj -c Release -- (Get-Location).Path
pwsh -NoProfile -File .\scripts\Test-Hardening.ps1 -ExePath .\artifacts\msix-dev\package-input\WinPebble.PDFToImage.exe
pwsh -NoProfile -File .\scripts\Test-ScriptWrappers.ps1
```

The first command uses real Windows rendering with deterministic token cancellation at callbacks and a never-shown WinForms component. It does not click a packaged application's Cancel button. Installation and device acceptance remain separate gates. Submit both device records before any proposal to change production minimum OS, package version or Store support claims.

If the Codex sandbox blocks the self-contained EXE or its temporary native-library extraction, record that attempt as BLOCKED. An authorized run outside that sandbox passed on the build host without changing security policy; do not disable Windows protections to force a test to run.
