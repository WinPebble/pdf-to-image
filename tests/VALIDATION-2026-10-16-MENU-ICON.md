# Duplicator-aligned branding and Explorer menu icons

## Provenance and device feedback

- Date: 2026-10-16, Asia/Bangkok; local Windows x64 build 26300.9457.
- Base: PR #15 commit `e6bcdabd2a8aca628c1d4fa5de89b3929b3b0711` on
  `codex/shared-winpebble-branding`. This follow-up is uncommitted; no CI run covers it yet.
- The maintainer installed the earlier PR artifact (dev 1.0.0.0, SHA-256
  `1f12984e1d2b3aa30edfba7b0a46e4791d5410d16579cf7d06e4146f5ebabb51`).
  Their screenshot confirms the shared logo appears in Installed apps, but it looks
  smaller than PDF Page Duplicator. The prior package had no menu icons by design.
- Source mark SHA-256 is identical in both repositories:
  `482baafeac1a7c9814c5556c8a18b6c9c3aa204531261f319b6efa2902ba63a3`.
- At alpha > 32, the old 150 px asset's visible horizontal bounds were 14..134
  (121 px), versus Duplicator's 10..139 (130 px). The resized derivatives differed.
- Copy Duplicator's existing PNGs and ICO exactly; do not change the other repository.
  The ICO has 16/24/32/48/64/128/256 px PNG frames.
- Both IExplorerCommand verbs now return the adjacent `WinPebble.PDFToImage.exe,0`
  icon location, with E_POINTER/E_OUTOFMEMORY handling. Conversion and launch behavior
  are unchanged. Package identities, versions and minimum OS remain unchanged.

## Artifact hashes (local dirty-tree builds)

| Artifact | SHA-256 |
|---|---|
| Store candidate 1.0.3.0, unsigned | `867e6c0e11a3a2876711774f43fd1bda515e482cd5d8ef0b9b87b46b4b91e448` |
| Development MSIX 1.0.0.0, signed | `2bcb2c66bf5e7bc47b2c9b7eae61a063b39bc40cc0e1346459151e402f26ffe0` |
| EXE, both packages | `bcaf78d05c3feeb82946b700b477be074ae66f9a7e297c19c6ac6ecb577f7110` |
| Store DLL | `a97e7eb63c75604ce1500f0e0988d7d0e14d9e76bc6cd48e6a3cd6eb6896b2ff` |
| Development DLL | `ae84bddb2722ba8cdd046330130170314851d1a07d7e5b1ee9834d5a64c854b5` |
| Shared ICO | `9364eaa131046d4867f50ce742c31203b3ffb8c6a472e029ecfe97b720f3523c` |

The development certificate thumbprint is `2B2764C82E2F1D9A82F4181792F346F98FB997AC`,
different from the earlier CI artifact's signer. Build reused a local development
signing certificate; no TrustedPeople change, install/uninstall or Explorer restart
was performed. Test installation must explicitly use the new artifact and public CER.

## Results

| Check | Result | Evidence / scope |
|---|---|---|
| PNG/ICO parity with Duplicator | PASS | SHA-256 equality for all three PNGs and ICO. |
| Store and development packaging | PASS | Canonical builds, .NET SDK 8.0.425, VS 2022 Build Tools, SDK 10.0.26100.0. Existing LNK4104 warnings remain. |
| Native EXE icon | PASS | Extracted icon bitmap matches shared ICO pixels. |
| Signed dev MSIX | PASS | Packed PNGs match; CMS cryptographic signature validates and signer matches public CER. This is not machine trust or installed acceptance. |
| PNG/JPG shell commands | PASS | Test both built DLLs with `scripts/Test-ShellCommands.ps1`: icon location/null pointer, exact labels, invalid selections, single/batch Unicode argv and progress/format flags. |
| Conversion regression | PASS | 17/17 after clean rebuild with new icon. |
| Core hardening | PASS | All 12 sections on new EXE. |
| NSIS icon compilation | PASS | Isolated installer/uninstaller icon fixture; full NSIS lifecycle NOT RUN. |
| Script syntax / whitespace | PASS | PowerShell parser and `git diff --check`. |
| Windows 11 installed logo and both Explorer menu icons | PASS | Maintainer screenshots show matching visible logo size with Duplicator and icons on both PNG/JPG verbs in the classic menu. |
| Guided PNG/JPG, Progress and Cancel checks | PASS (maintainer report) | Maintainer replied that everything matched their intent after the requested smoke procedure. No separate Progress screenshot or timing/scaling measurements were supplied. |
| Windows 10 / other scaling levels / modern Windows 11 menu | NOT RUN | The supplied screenshots do not establish these cases. |
| Follow-up uninstall / certificate cleanup | PASS | Maintainer PowerShell screenshot: dev package query returns nothing, exact test certificate returns False, no converter process returned. |
| Explorer menu removal and source/output preservation after uninstall | PASS (maintainer report) | Maintainer explicitly confirmed both menus disappeared and source PDFs/output images remained after uninstall. |

The shell test uses a test-only child recorder and empty PDF placeholders; it validates
actual process argv without launching the converter or registering COM. Core tests use
real Windows.Data.Pdf rendering separately. No full installed Explorer PASS is claimed.

An initial incremental build retained the previous EXE because copied assets had older
timestamps. A clean build was performed; only the clean-build hashes above are final.
Test harness build/invocation setup errors were corrected before the passing runs.

The follow-up kit hash and signer were verified by the maintainer before installation.
Their installation screenshot shows dev version 1.0.0.0 / Status Ok and
`Certificate already trusted: False` for thumbprint
`2B2764C82E2F1D9A82F4181792F346F98FB997AC`; that trust entry was added for this test.
Screenshots supplied in chat on 2026-10-16: `codex-clipboard-b7e526cb-5987-45b1-a9cd-1ee482a1b3b5.png`
(Installed apps) and `codex-clipboard-b5bcf24a-e334-4baa-8266-8daa2897ae5e.png`
(classic Explorer menu). These temporary chat attachment names identify evidence,
not repository files or permanent public links.

Cleanup evidence: `codex-clipboard-02930a54-61e8-4139-a5f6-c1c0d826ff99.png` supplied
in chat on 2026-10-16. No package/process appears in the final queries; the exact
TrustedPeople certificate query returns False. Explorer menu removal and retained
PDF/output files are not visible in that screenshot.

The maintainer subsequently confirmed those Explorer/filesystem observations and
authorized commit/push of the follow-up into PR #15. This approval does not authorize
merge or Store submission/publication.

Next: review CI for the committed follow-up, retain the untested-case limits above,
and obtain separate approval for merge and Store submission. The Store 1.0.2.0
release is unchanged.
