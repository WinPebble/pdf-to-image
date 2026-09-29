# Store submission path

The Microsoft Store product has now been reserved.

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
artifacts/msix-store/out/WinPebble-PDF-to-Image-0.9.0-beta.1-Store.msix
```

This Store artifact is intentionally **unsigned**. Microsoft Store accepts MSIX/AppX packages
without a CA-trusted developer signature and re-signs packages with a Microsoft certificate
after certification. Do not distribute the unsigned Store artifact directly to end users.

The local full-MSIX development gate remains separate and continues to use
`AppxManifest.Dev.xml` plus a development-only self-signed certificate.
