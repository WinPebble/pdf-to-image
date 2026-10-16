# Shared WinPebble brand icon

Prepared 2026-10-16 for the next product update. Candidate only, not released.

Use the shared WinPebble pebble mark rather than a separate PDF-to-Image illustration.
The maintainer supplied the source and ready-sized assets from their WinPebble brand folder.

- `WinPebble-Pebble-Mark-512.png` is the supplied 512 x 512 source mark.
- `package/Assets/Square44x44Logo.png`, `Square150x150Logo.png` and `StoreLogo.png`
  are exact copies of PDF Page Duplicator's 44 x 44, 150 x 150 and 50 x 50 assets,
  derived from the same approved 512 px mark. The initial supplied resized PNGs
  had more transparent padding and were superseded after device review.
- Full Store MSIX, full development MSIX and sparse packaging share these asset paths.
- Product names, package identities, conversion behavior and OS requirements are unchanged.
- `WinPebble.ico` is byte-identical to PDF Page Duplicator's icon, with PNG frames
  at 16/24/32/48/64/128/256 px. The executable
  embeds it as its application icon and the Progress window loads the same resource.
- The legacy NSIS installer/uninstaller ICO uses identical bytes. Both shell verbs
  return the adjacent EXE's first icon (`WinPebble.PDFToImage.exe,0`); labels,
  selection validation and conversion launch arguments are unchanged.

The existing PDF-specific source image and its dated update notes remain as historical material.
Before Store submission, choose and approve a new package version, synchronize packaging
references, build and inspect the packed assets, and verify the Store-delivered icon update.
The next Store candidate uses package version 1.0.3.0. Partner Center was checked
on 2026-10-16: Submission 3 serves 1.0.2.0 and no update draft was present.
This preparation does not publish an update.

Final 1.0.3.0 build results and hashes are recorded in
[the validation record](../tests/VALIDATION-2026-10-16-SHARED-BRANDING.md).
The subsequent device-review adjustments (matching Duplicator sizing and menu icons)
have a separate [follow-up record](../tests/VALIDATION-2026-10-16-MENU-ICON.md).

## Initial local validation, 2026-10-16

These hashes describe the initial bitmap-frame ICO build before the final PNG-frame
ICO and package version change. See the final validation record for the new artifact.

- Base: main at `8c32618`; working tree includes uncommitted branding changes.
- Store MSIX and standalone/native builds passed. Store identity and minimum OS
  requirements are unchanged. Existing native LNK4104 warnings remain.
- New MSIX SHA-256: `990688cea7d680f4f8b2feb4de4d4c89c8fc988d9e9989d127cbddc2f8250895`.
  It retains package version 1.0.2.0 for local validation only; do not submit it
  as the next Store update.
- EXE SHA-256: `d8c256c53ab86c074871199440113a31452859f82c1281ed820f19f9764852e2`.
- Development checks passed 17/17, including hidden Progress window state;
  the hardening suite passed all 12 sections against the new standalone EXE.
  Windows.Data.Pdf access was denied in the sandbox; these passing runs were
  performed outside it. An initial regression invocation omitted its root argument
  and was corrected before the passing run.
- EXE icon extraction succeeded. NSIS compiled an isolated installer/uninstaller
  icon fixture successfully outside the sandbox; the complete NSIS packaging lane
  and installation lifecycle were not run.
- `git diff --check` passed. Interactive icon display, scaling and installed
  Store upgrade behavior on Windows 10/11 have not been validated for this change.
