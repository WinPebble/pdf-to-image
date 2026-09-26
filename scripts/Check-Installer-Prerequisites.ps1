$ErrorActionPreference = "Stop"

Write-Host "WinPebble PDF to Image - Installer prerequisites"
Write-Host ""

$candidates = @(
    "$env:LOCALAPPDATA\Programs\Inno Setup 7\ISCC.exe",
    "$env:ProgramFiles\Inno Setup 7\ISCC.exe",
    "${env:ProgramFiles(x86)}\Inno Setup 7\ISCC.exe",
    "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe",
    "$env:ProgramFiles\Inno Setup 6\ISCC.exe",
    "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe"
)

$iscc = $candidates |
    Where-Object { Test-Path -LiteralPath $_ } |
    Select-Object -First 1

if (-not $iscc) {
    Write-Host "MISSING: Inno Setup compiler (ISCC.exe)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Install Inno Setup 7 with:"
    Write-Host "  winget install --id JRSoftware.InnoSetup.7 -e -s winget -i"
    throw "Inno Setup compiler is missing."
}

Write-Host "PASS: Inno Setup compiler" -ForegroundColor Green
Write-Host "      $iscc"
Write-Host ""
Write-Host "INSTALLER BUILD PREREQUISITES PASSED" -ForegroundColor Green

# Intentionally no 'exit 0' here:
# this script is also invoked from Build-Installer.ps1 and must return to its caller.
