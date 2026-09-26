# Changelog

## 0.9.0-beta.1 — development certificate disclosure

- Added an explicit installer warning before the unsigned development preview adds the local `WinPebble Development` certificate to `Local Computer > Trusted People`.
- Requires explicit user confirmation before continuing installation.
- Documents that the development certificate is removed during uninstall.
- Clarifies that production releases will not require the development/self-signed certificate.
- Keeps the Windows-native renderer, Explorer commands, install/uninstall behavior, output rules, and privacy behavior unchanged.

## 0.9.0-beta — pre-release preparation

- Replaced Poppler with the Windows-native `Windows.Data.Pdf` renderer.
- Added 300 DPI PNG/JPG rendering with explicit 300 × 300 DPI metadata.
- Added maximum-quality JPEG encoding.
- Added atomic multi-page output and collision-safe naming.
- Added native x64 Windows 11 `IExplorerCommand` integration.
- Added self-contained Windows x64 executable packaging.
- Added NSIS Setup EXE install/uninstall workflow.
- Added clean uninstall of Explorer package registration and install directory.
- Aligned EXE, DLL, sparse-package and installer metadata to `0.9.0-beta` / `0.9.0.0`.
- Added hardening tests for Unicode, page sizes/orientation, invalid PDFs, cleanup, and batch operation.
- Added GitHub-hosted release-form build workflow for SignPath readiness.
