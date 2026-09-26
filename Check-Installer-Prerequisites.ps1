$ErrorActionPreference = "Stop"

Write-Host "WinPebble PDF to Image - NSIS installer prerequisites"
Write-Host ""

$candidates = @(
    "$env:ProgramFiles\NSIS\makensis.exe",
    "${env:ProgramFiles(x86)}\NSIS\makensis.exe",
    "$env:LOCALAPPDATA\Programs\NSIS\makensis.exe"
)

$makensis = $candidates |
    Where-Object { Test-Path -LiteralPath $_ } |
    Select-Object -First 1

if (-not $makensis) {
    Write-Host "MISSING: NSIS compiler (makensis.exe)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Install NSIS with:"
    Write-Host "  winget install -e --id NSIS.NSIS"
    throw "NSIS compiler is missing."
}

Write-Host "PASS: NSIS compiler" -ForegroundColor Green
Write-Host "      $makensis"
Write-Host ""
Write-Host "INSTALLER BUILD PREREQUISITES PASSED" -ForegroundColor Green
