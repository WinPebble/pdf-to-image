# Working in this repository

## Product and architecture

- WinPebble PDF to Image is released on Microsoft Store. Windows 11 x64 is the production baseline; Windows 10 requires device validation and a separate approved production update.
- Read `README.md`, `BUILDING.md`, `docs/DEVELOPMENT_STATUS.md` and the relevant test plan. Recheck live PR state; dated documents are snapshots.
- C# in `src/WinPebble.PDFToImage` owns CLI/conversion. Native C++17 in `shell/` implements COM IExplorerCommand and starts a separate conversion process. Keep conversion out of the shell DLL.
- Full MSIX manifests live in `store-msix/`. `package/AppxManifest.xml` belongs to NSIS/sparse packaging. Root build scripts are canonical; equivalent scripts in `scripts/` are compatibility entry points.

## Preserve behavior

- Preserve source PDFs, offline operation, Unicode paths and batch conversion. Do not introduce telemetry, services or resident processes without a product request.
- Keep Windows.Data.Pdf, white background, 300 DPI dimensions/metadata and JPEG quality 1.0. Do not change the renderer or add a PDF runtime incidentally.
- Preserve output names, collision handling and staged multi-page output. Cleanup is best effort; never delete pre-existing user output.
- Released-baseline CLI codes: 0 success, 1 conversion failure, 2 invalid arguments. The production baseline on main does not implement Progress UI, cancellation or exit code 3; experimental validation branches may include them.

## Experimental feature work

- PR #9 tests Windows 10 using the dev manifest only. PR #10 prototypes Progress UI and adds cancellation exit code 3. Neither is a released feature; recheck live status before relying on these draft details.
- When working on Progress UI, keep conversion off the UI thread, marshal callbacks safely and cancel at safe boundaries. Preserve completed files' output. Document delayed display, per-PDF percentage and window-close behavior; preserve ordinary console behavior.

## Scope and Git

- Inspect status, branch, instructions, PR base/head and diff before editing. Preserve unrelated changes and follow nearby coding style; avoid incidental formatting/dependencies.
- Work within the request. Do not switch branches, commit, push, retarget/rebase PRs, merge, tag or publish without user authorization. Implementation permission does not imply release permission.
- Review dependent PRs against their actual base. Recheck ancestry and scope after a dependency merges. Use `codex/` for authorized new branches unless instructed otherwise.

## Build and validation

- Follow `BUILDING.md` from the root. Preserve self-contained win-x64 packaging and keep trimming disabled for WinRT unless separately validated.
- Core changes: build standalone and run `scripts/Test-Hardening.ps1`. Shell changes: also compile the DLL and verify selection, Unicode and both Explorer verbs.
- UI/Cancel changes: also run the feature acceptance plan on Windows 10 22H2 x64 and Windows 11 x64. Packaging changes: check relevant artifacts and installation lifecycle on an approved test machine.
- Use `tests/VALIDATION-RECORD-TEMPLATE.md` to record SHA, dirty state, OS build, workflow run, artifact hash and results. Distinguish pass/fail/blocked/not run. Packaging CI success does not establish runtime compatibility.
- Package installation/removal, certificate trust changes and restarting Explorer need authorization for the intended environment unless already granted. Never disable Windows security protections as a workaround.

## Packaging and release

- Keep Store, full-MSIX dev and NSIS/sparse identities separate. Preserve exact values in `store-msix/STORE_IDENTITY.md`; synchronize shell CLSIDs with all manifests.
- Never commit private keys or dev certificates or include certificate material in Store packages. Publishing the dev workflow's public CER is intentional and for test installation only.
- Package/Product/File versions are distinct. For approved version changes, check C# metadata, native RC, NSIS, manifests, script assertions/output names and workflow artifact names together.
- PR artifacts are validation artifacts. Production submission needs maintainer approval, runtime evidence, version review and the appropriate Store/signing process.
- Update affected docs with behavior changes. Report actual checks and remaining limits in Vietnamese unless requested otherwise. Keep repository docs in English, matching existing files.
