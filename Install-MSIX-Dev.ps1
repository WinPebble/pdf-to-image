$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$msix = Join-Path $root "artifacts\msix-dev\out\WinPebble-PDF-to-Image-0.9.0-beta.1-Full-Dev.msix"
$cer = Join-Path $root "artifacts\msix-dev\cert\WinPebble-PDFToImage-Full-MSIX-Dev.cer"

Write-Host "WinPebble PDF to Image - Full MSIX Dev Install"
Write-Host ""

$principal = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "Run this script from PowerShell AS ADMINISTRATOR."
}

foreach ($required in @($msix, $cer)) {
    if (-not (Test-Path -LiteralPath $required)) {
        throw "Required dev MSIX artifact is missing: $required"
    }
}

$oldSparse = Get-AppxPackage -Name "WinPebble.PDFToImage.Dev" -ErrorAction SilentlyContinue
if ($oldSparse) {
    throw "Old sparse beta package WinPebble.PDFToImage.Dev is still registered. Uninstall the NSIS beta before testing the full MSIX to avoid duplicate Explorer registrations."
}

$oldProgramFiles = "C:\Program Files\WinPebble\PDF to Image"
if (Test-Path -LiteralPath $oldProgramFiles) {
    throw "Old NSIS beta install directory still exists: $oldProgramFiles. Uninstall/clean it before full MSIX testing."
}

Write-Host "[1/3] Trusting the dev package certificate..."
$imported = Import-Certificate `
    -FilePath $cer `
    -CertStoreLocation Cert:\LocalMachine\TrustedPeople

if (-not $imported) {
    throw "Development certificate import failed."
}

Write-Host "[2/3] Removing an older full-MSIX dev package if present..."
$existing = Get-AppxPackage -Name "WinPebble.PDFToImage.StoreDev" -ErrorAction SilentlyContinue
if ($existing) {
    $existing | Remove-AppxPackage -ErrorAction Stop
}

Write-Host "[3/3] Installing full MSIX..."
Add-AppxPackage -Path $msix -ForceApplicationShutdown -ErrorAction Stop

$registered = Get-AppxPackage -Name "WinPebble.PDFToImage.StoreDev" -ErrorAction Stop

Write-Host ""
Write-Host "FULL MSIX DEV INSTALL SUCCESS" -ForegroundColor Green
Write-Host ""
Write-Host "Registered:"
Write-Host "  $($registered.PackageFullName)"
Write-Host ""
Write-Host "Test:"
Write-Host "  Right-click a PDF in Windows 11 File Explorer."
Write-Host "  Confirm Convert PDF to PNG and Convert PDF to JPG."
Write-Host ""
Write-Host "If commands do not appear immediately, restart File Explorer or sign out/in."
