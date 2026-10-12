# Full MSIX / Microsoft Store path

Microsoft Store is the production distribution path. A **separate full-MSIX development gate** supports local/CI validation. The repository also retains the NSIS/sparse-package beta path.

## Why this exists

The current direct-download beta uses:

- NSIS installer
- external Win32 EXE/DLL
- sparse package identity
- development certificate trust

The Store path uses a **full MSIX** that contains the core EXE, Explorer shell
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

The product is already reserved and released. The official identity is recorded in [STORE_IDENTITY.md](STORE_IDENTITY.md). Store submissions must preserve the exact:

- Package/Identity/Name
- Package/Identity/Publisher
- PublisherDisplayName

The Store manifest must use those exact values.

## Separate package and application versions

The dev package version is `1.0.0.0`; the source Store manifest version is `1.0.1.0`. Neither value alone proves which package is currently served by the Store.

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

Use an authorized test PC; these steps affect package registration and certificate trust. Record results with [the validation template](../tests/VALIDATION-RECORD-TEMPLATE.md). Builds alone do not validate runtime compatibility.

1. Build (creates/reuses a signing certificate in CurrentUser/My):
   `.\Build-MSIX-Dev.ps1`
2. Check existing Store/dev/NSIS installations. Coordinate removal of an old NSIS/sparse beta with the tester before changing installed software; do not silently remove the production app.
3. Run PowerShell as Administrator.
4. Install:
   `.\Install-MSIX-Dev.ps1`
5. Test both Explorer commands on real PDFs.
6. Uninstall:
   `.\Uninstall-MSIX-Dev.ps1`

The self-signed certificate in this gate is development-only. The Store distribution path will
use the Store trust/signing model instead.

For Windows 10 and progress UI draft work, see [development status](../docs/DEVELOPMENT_STATUS.md) and the acceptance plans on the corresponding PR branches. Do not submit experimental PR packages to Partner Center.
