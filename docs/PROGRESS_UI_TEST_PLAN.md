# WinPebble PDF to Image - Progress UI development test

**Experimental; do not merge into main or publish a Store MSIX until Windows 10 and Windows 11 tests pass.**

## Intent and scope

- Keep the existing Windows.Data.Pdf converter, 300 DPI encoder, PNG/JPG quality, output naming and shell CLSIDs.
- Keep ordinary CLI mode compatible. Shell invocation opts in with `--progress-ui`.
- Show a WinForms progress window only when processing takes >= 750 ms; no flicker for fast files.
- Percentage is based on **completed pages in the current PDF**, not elapsed time or estimated batch completion. A very complex page can keep the bar unchanged for a while.
- Show current filename, page N/M and file X/Y when a selection includes several PDFs.
- Cancellation is cooperative: let the current Windows native render/encode step finish, then cancel. For multi-page PDFs the hidden staging folder is discarded and no partial final output folder is exposed. Prior successfully converted files remain.
- Show errors with a Close button, and show a short success state before auto-closing.
- No background service, account, network dependency, tracking or telemetry.

## Branching policy

This PR targets `win10-22h2-msix-dev-validation` (PR #9), NOT `main`, so that the signed development artifact can be tested on Windows 10. The Windows 10 compatibility PR remains unchanged. The *production* Store manifest/version and production build workflow remain unchanged.

After PR #9 is validated, cleanly merged and a progress UI test passes, retarget/rebase this feature onto main, review the diff and submit a separate Store package update. Do not merge this draft PR directly or submit PR build artifacts to Microsoft Partner Center.

## Acceptance tests on both Windows 10 22H2 x64 and Windows 11 x64

- [ ] GitHub Actions dev MSIX build and Store CI build compile successfully (build success != runtime test success).
- [ ] SHA-256 matches the release artifact text.
- [ ] Install dev MSIX; restart Explorer if the context menu verbs do not appear immediately.
- [ ] Right-click a small 1-page PDF to PNG/JPG; conversion completes and the window does not flash on screen if under 750 ms.
- [ ] Use a long/multi-page PDF; window shows correct filename, current page, and percentage of **current PDF**.
- [ ] Convert 3+ PDFs selected together; confirm File 1 of N, File 2 of N and no false batch percentage.
- [ ] After processing, window briefly says Completed and closes itself; image dimensions, color, 300-DPI metadata and quality are unchanged.
- [ ] During the conversion of a long multi-page PDF press Cancel; application eventually exits and no incomplete *final* output folder remains; prior completed PDFs remain.
- [ ] Cancel while one-page PDF is rendering/encoding; no partially encoded image is left behind.
- [ ] Corrupt/missing/passworded PDF reports a visible error, offers Close, and other selected PDFs continue.
- [ ] Double-click a PDF on Explorer is not intercepted by the progress UI.
- [ ] Direct CLI `WinPebble.PDFToImage.exe --png file.pdf` still emits console output and original exit codes.
- [ ] Confirm no extra resident processes after close and no change to existing PDFs.
- [ ] Uninstall MSIX and remove the exact trusted test certificate; verify Explorer menu verbs disappear.

## Security and release

- Development `.cer` is trusted **only on testing PCs**, not distributed to end users.
- Never disable Defender, Smart App Control or lower Windows security settings for users.
- Microsoft Store package identity and `Version=1.0.1.0` are unchanged by this experimental PR.
