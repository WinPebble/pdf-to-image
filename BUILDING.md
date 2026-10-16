# Building WinPebble PDF to Image

Run commands from the repository root. Root build scripts are canonical; matching entry points under `scripts/` forward to them.

Compatibility wrappers reset stale native status and explicitly propagate the target's exit code. To test forwarding and failure handling without invoking packaging tools:

```powershell
.\scripts\Test-ScriptWrappers.ps1
```

This runs 41 isolated cases with substituted target scripts, including argument forwarding, normal return, exit 0, exit 7 and terminating exceptions via both `-File` and a PowerShell caller with stale status. The missing-SDK case runs the real standalone prerequisite code with an isolated child PATH; it does not uninstall the installed SDK. Fixtures remain under ignored `artifacts/wrapper-tests/`. These simulations do not validate native packaging or Windows compatibility.

## Environment

- Windows x64 and .NET 8 SDK.
- Visual Studio 2022 Build Tools with Desktop development with C++.
- Windows 10/11 SDK with `MakeAppx.exe`, `SignTool.exe` and `rc.exe`.
- NSIS only for the optional Setup EXE path (`winget install -e --id NSIS.NSIS`).

CI uses `windows-2025` and .NET `8.0.x`. Local scripts select installed VS/SDK tooling; versions are not fully pinned. Record tool versions when validating releases. Builds create/replace output directories in `artifacts/`; they are not read-only checks.

## Core executable and hardening

```powershell
.\Build-Standalone.ps1
.\scripts\Test-Hardening.ps1
```

The EXE is `artifacts/standalone/WinPebble.PDFToImage.exe`: self-contained, single-file, win-x64. Trimming is disabled for WinRT. To test another executable:

```powershell
.\scripts\Test-Hardening.ps1 -ExePath 'C:\path\to\WinPebble.PDFToImage.exe'
```

The suite copies fixtures from `tests/`, replaces `artifacts/hardening-test/`, and checks dimensions/DPI, source hashes, collisions, Unicode, batch conversion, invalid PDFs and cleanup. It performs real conversion without installing packages or changing certificate trust. Run without other conversions active: it checks for leftover processes by name.

After compiling the native DLL (for example with the Store build), run:

```powershell
.\scripts\Test-ShellCommands.ps1
```

This loads a copy of the DLL in an isolated directory with Unicode/spaces, checks
both PNG/JPG icon locations and menu labels, rejects invalid selections, and records
actual child argv for single/batch PDF selections. Its child executable is a test
recorder, not the converter. It does not register COM or validate installed Explorer
display. Fixtures are retained under ignored `artifacts/shell-command-checks/`.

## Full MSIX development package

```powershell
.\Check-Explorer-Prerequisites.ps1
.\Build-MSIX-Dev.ps1
```

Output: `artifacts/msix-dev/out/WinPebble-PDF-to-Image-0.9.0-beta.1-Full-Dev.msix`, SHA-256 sums and a public CER under `artifacts/msix-dev/cert/`. The build creates/reuses a self-signed certificate in `CurrentUser/My` and signs the dev package; it does not install it.

On an authorized test PC, use elevated PowerShell for `Install-MSIX-Dev.ps1` and `Uninstall-MSIX-Dev.ps1`. Installation changes certificate trust and package registration. Follow [the MSIX guide](store-msix/README.md), preserve existing installations and record results with [the validation template](tests/VALIDATION-RECORD-TEMPLATE.md).

## Microsoft Store package

```powershell
.\Build-MSIX-Store.ps1
```

Output: `artifacts/msix-store/out/WinPebble-PDF-to-Image-0.9.0-beta.1-Store-v1.0.3.0.msix`, `SHA256SUMS-STORE.txt` and a manifest copy. This validates official identity, compiles the core/native DLL and checks package contents. It does not create a dev certificate or install the package.

The artifact is intentionally unsigned for Store submission. Do not distribute it directly or submit a PR artifact without release approval. See [Store identity](store-msix/STORE_IDENTITY.md) and [submission](store-msix/STORE_SUBMISSION.md).

Package 1.0.2.0 was published on 2026-10-15. Package 1.0.3.0 prepares the shared WinPebble logo update; its Windows 10 minimum remains 10.0.19041.0. See [branding scope](branding/SHARED_BRAND_ICON.md) and the historical [1.0.2.0 candidate gates](store-msix/RELEASE_CANDIDATE.md).

## Optional NSIS / sparse-package beta

```powershell
.\Check-Installer-Prerequisites.ps1
.\Build-Installer.ps1
```

Output: `artifacts/installer/WinPebble-PDF-to-Image-Setup-Beta1-Dev.exe`. `Build-Explorer.ps1` separately builds the sparse-package Explorer gate. These development paths use local signing certificates; the installer discloses trust changes.

After authorized NSIS installation/removal, use `scripts/Test-Installed-State.ps1` and `scripts/Test-Uninstalled-State.ps1`. These target NSIS/sparse identity, not full MSIX or Store installs. `scripts/Prepare-ContextMenu-Test.ps1` prepares a fixture and opens Explorer. `scripts/Restart-Explorer.ps1` closes Explorer windows and requires authorization.

## GitHub Actions and release gates

| Workflow | Validation and outputs |
|---|---|
| `build-windows.yml` | NSIS build, product/file-version checks, Setup EXE and SHA-256 |
| `build-msix-dev.yml` | Full dev MSIX build/signing, output existence, MSIX/CER/SHA-256 |
| `build-msix-store.yml` | Store identity/content checks, unsigned MSIX/manifest/SHA-256 |

All run for pull requests and manual dispatch. Push triggers include `main`; see YAML for additional branch filters. Workflows upload artifacts without automatic Store submission/release publishing. They currently do not run the hardening suite or interactive/device tests.

Before claiming compatibility, run core checks and applicable Explorer/UI/install/uninstall plans on the target OS. See [development status](docs/DEVELOPMENT_STATUS.md) for the dependent Windows 10/progress drafts. Record actual results; packaging success alone is insufficient.

For approved version changes, review C# metadata, native RC, NSIS metadata, manifests, script assertions/output names and workflow artifact names together. Store candidate package version (currently 1.0.3.0), ProductVersion (0.9.0-beta.1) and FileVersion (0.9.0.1) are distinct. See [code signing policy](CODE_SIGNING_POLICY.md).
