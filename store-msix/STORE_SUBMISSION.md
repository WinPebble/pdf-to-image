# Store submission path

The Microsoft Store product is already released. Partner Center confirmed Submission 3 / version 1.0.2.0 published on 2026-10-15. Version 1.0.3.0 prepares the [shared WinPebble logo update](../branding/SHARED_BRAND_ICON.md); it has not been submitted or published. The [1.0.2.0 preparation record](RELEASE_CANDIDATE.md) is historical.

Official Partner Center identity:

```text
Product name: WinPebble PDF to Image
Store ID: 9NRZMPGMQPS4

Package/Identity/Name:
TrungHieuNguyen-WinPebble.WinPebblePDFtoImage

Package/Identity/Publisher:
CN=6BD09250-A4F3-4F78-9DA7-2D9751735950

Package/Properties/PublisherDisplayName:
Trung Hieu Nguyen - WinPebble
```

The Store-ready manifest is:

```text
store-msix/AppxManifest.Store.xml
```

The Store build is:

```powershell
.\Build-MSIX-Store.ps1
```

Output:

```text
artifacts/msix-store/out/WinPebble-PDF-to-Image-0.9.0-beta.1-Store-v1.0.3.0.msix
```

This Store artifact is intentionally **unsigned**. Microsoft Store accepts MSIX/AppX packages
without a CA-trusted developer signature and re-signs packages with a Microsoft certificate
after certification. Do not distribute the unsigned Store artifact directly to end users.

The local full-MSIX development gate remains separate and continues to use
`AppxManifest.Dev.xml` plus a development-only self-signed certificate.
