# Full MSIX / Microsoft Store path

This branch introduces a **parallel full-MSIX development gate**. It does not replace the
existing NSIS/sparse-package beta yet.

## Why this exists

The current direct-download beta uses:

- NSIS installer
- external Win32 EXE/DLL
- sparse package identity
- development certificate trust

The Store path should instead use a **full MSIX** that contains the core EXE, Explorer shell
DLL, assets and manifest in one package.

Microsoft Store can re-sign submitted MSIX/AppX packages after certification, which removes
the need for WinPebble to purchase a CA-trusted certificate for Store distribution.

## Important identity rule

`AppxManifest.Dev.xml` uses a DEVELOPMENT identity:

```text
Name      = WinPebble.PDFToImage.StoreDev
Publisher = CN=WinPebble Development
Version   = 1.0.0.0
```

This is only for local/CI packaging validation.

Before Store submission, reserve/create the product in Partner Center and obtain the exact:

- Package/Identity/Name
- Package/Identity/Publisher
- PublisherDisplayName

The Store manifest must use those exact values.

## Why package version is 1.0.0.0

Microsoft Store package versioning uses four numeric parts. For Windows 10/11 packages,
the first part cannot be zero and the fourth part is reserved for Store use and should be 0.

This package identity version is separate from the current application marketing/product version:

```text
ProductVersion = 0.9.0-beta.1
FileVersion    = 0.9.0.1
```

## Compatibility gate

The full MSIX dev manifest currently targets:

```text
Windows.Desktop
MinVersion = 10.0.22000.0
Architecture = x64
```

This intentionally matches the currently verified support statement: Windows 11 x64.

Windows 10 must not be advertised as supported until validation is complete.

## Local test sequence

1. Build:
   `.\Build-MSIX-Dev.ps1`
2. Uninstall the old NSIS/sparse beta if installed.
3. Run PowerShell as Administrator.
4. Install:
   `.\Install-MSIX-Dev.ps1`
5. Test both Explorer commands on real PDFs.
6. Uninstall:
   `.\Uninstall-MSIX-Dev.ps1`

The self-signed certificate in this gate is development-only. The Store distribution path will
use the Store trust/signing model instead.
