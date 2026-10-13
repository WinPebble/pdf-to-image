# Windows 10 22H2 x64 - development validation gate

**Status: experimental. Do not merge into `main` or claim Windows 10 support before a real-device pass.**

## Scope

- Test target: Windows 10 Pro 22H2 (OS build 19045.x), x64.
- Change: only the development MSIX `TargetDeviceFamily MinVersion` from `10.0.22000.0` to `10.0.19041.0`.
- Store production manifest, Store identity, Store package version and converter source are unchanged.
- Development package identity is `WinPebble.PDFToImage.StoreDev`; the developer certificate is self-signed and must be removed after testing.

## Build and install

1. Open this PR's successful **Build Full MSIX Dev Gate** GitHub Actions run.
2. Download artifact `winpebble-pdf-to-image-full-msix-dev-gate-v1`.
3. Unzip the MSIX and CER files. Verify the SHA256SUMS-MSIX-DEV.txt file.
4. To reuse repository scripts, place the MSIX in `artifacts/msix-dev/out/` and the CER in `artifacts/msix-dev/cert/`. Keep the original filenames.
5. On the *test PC only*, use an elevated Windows PowerShell to run `Install-MSIX-Dev.ps1` from the checkout directory.
6. If the Windows 10 package installation reports errors, stop and capture the full PowerShell message. Do not disable Defender or change system-wide security policies to work around it.
7. Uninstall by running `Uninstall-MSIX-Dev.ps1` in elevated Windows PowerShell from the checkout directory. Verify the app and both context menu commands disappear, and the exact development certificate is removed from LocalMachine/TrustedPeople.

## Required acceptance tests

- [ ] MSIX installs on Windows 10 22H2 x64 without unsupported OS/API errors.
- [ ] Both `Convert PDF to PNG` and `Convert PDF to JPG` appear on the classic PDF right-click context menu.
- [ ] Both commands work on one-page and multi-page PDFs.
- [ ] Multi-select PDFs work; original source PDFs are preserved.
- [ ] Existing image/folder names are not overwritten.
- [ ] 300 DPI output dimensions are checked with a known-size PDF.
- [ ] Output location and folder naming match the current production behavior.
- [ ] Uninstall removes app, context menu verbs, and dev certificate.

## Go / no-go

Even with all CI builds green, do not treat Windows 10 as supported until these Windows 10 device tests pass. After validation, prepare a separate Store-package version bump and update submission. Do not retroactively modify the current certification submission.