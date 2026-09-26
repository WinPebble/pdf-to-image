$ErrorActionPreference = "Stop"

$appDir = Join-Path $env:ProgramFiles "WinPebble\PDF to Image"
$packageName = "WinPebble.PDFToImage.Dev"

Write-Host "WinPebble PDF to Image - Uninstalled-state check"
Write-Host ""

$failed = $false

if (Test-Path -LiteralPath $appDir) {
    Write-Host "FAIL: install directory still exists: $appDir" -ForegroundColor Red
    $failed = $true
}
else {
    Write-Host "PASS: install directory removed" -ForegroundColor Green
}

$package = Get-AppxPackage -Name $packageName -ErrorAction SilentlyContinue
if ($package) {
    Write-Host "FAIL: Explorer package registration remains" -ForegroundColor Red
    $failed = $true
}
else {
    Write-Host "PASS: Explorer package registration removed" -ForegroundColor Green
}

if ($failed) {
    Write-Host ""
    Write-Host "UNINSTALLED-STATE CHECK FAILED" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "UNINSTALLED-STATE CHECK PASSED" -ForegroundColor Green
Write-Host ""
Write-Host "Right-click a PDF and confirm WinPebble commands are gone."
