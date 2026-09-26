$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$source = Join-Path $root "tests\Hardening-A4.pdf"
$testDir = Join-Path $root "artifacts\context-menu-test"

if (Test-Path -LiteralPath $testDir) {
    Remove-Item -LiteralPath $testDir -Recurse -Force
}

New-Item -ItemType Directory -Path $testDir | Out-Null

$pdf = Join-Path $testDir "WinPebble Context Menu Test.pdf"
Copy-Item -LiteralPath $source -Destination $pdf

Write-Host "Context-menu test PDF prepared:" -ForegroundColor Green
Write-Host "  $pdf"
Write-Host ""
Write-Host "Open this folder:"
Start-Process explorer.exe -ArgumentList "`"$testDir`""
Write-Host ""
Write-Host "Right-click the PDF in the MODERN Windows 11 context menu."
Write-Host "Expected commands:"
Write-Host "  Convert PDF to PNG"
Write-Host "  Convert PDF to JPG"
Write-Host ""
Write-Host "Run one command at a time and verify the image appears beside the PDF."
