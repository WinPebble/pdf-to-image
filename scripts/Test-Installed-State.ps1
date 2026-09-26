$ErrorActionPreference = "Stop"

$appDir = Join-Path $env:ProgramFiles "WinPebble\PDF to Image"
$packageName = "WinPebble.PDFToImage.Dev"

Write-Host "WinPebble PDF to Image - Installed-state check"
Write-Host ""

$required = @(
    "WinPebble.PDFToImage.exe",
    "WinPebble.PDFToImage.Shell.dll",
    "WinPebble.PDFToImage.Dev.identity.msix",
    "Assets\Square44x44Logo.png"
)

$failed = $false

foreach ($relative in $required) {
    $path = Join-Path $appDir $relative
    if (Test-Path -LiteralPath $path) {
        Write-Host "PASS: $relative" -ForegroundColor Green
    }
    else {
        Write-Host "FAIL: missing $relative" -ForegroundColor Red
        $failed = $true
    }
}

$package = Get-AppxPackage -Name $packageName -ErrorAction SilentlyContinue
if ($package) {
    Write-Host "PASS: Explorer identity package registered" -ForegroundColor Green
    Write-Host "      $($package.PackageFullName)"
}
else {
    Write-Host "FAIL: Explorer identity package not registered" -ForegroundColor Red
    $failed = $true
}

$uninstallKey = Get-ChildItem `
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" `
    -ErrorAction SilentlyContinue |
    Get-ItemProperty -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -eq "WinPebble PDF to Image" } |
    Select-Object -First 1

if ($uninstallKey) {
    Write-Host "PASS: Settings > Apps uninstall entry exists" -ForegroundColor Green
}
else {
    Write-Host "FAIL: uninstall entry not found" -ForegroundColor Red
    $failed = $true
}

if ($failed) {
    Write-Host ""
    Write-Host "INSTALLED-STATE CHECK FAILED" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "INSTALLED-STATE CHECK PASSED" -ForegroundColor Green
Write-Host ""
Write-Host "Next manual test:"
Write-Host "  1. Right-click a PDF"
Write-Host "  2. Convert PDF to PNG"
Write-Host "  3. Convert PDF to JPG"
Write-Host "  4. Settings > Apps > Installed apps > WinPebble PDF to Image > Uninstall"
