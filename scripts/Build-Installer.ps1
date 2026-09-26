$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$stage = Join-Path $root "artifacts\installer-stage"
$dist = Join-Path $root "artifacts\installer"
$external = Join-Path $root "artifacts\external"
$package = Join-Path $root "artifacts\package"
$certDir = Join-Path $root "artifacts\dev-cert"
$installerSource = Join-Path $root "installer"

Write-Host "WinPebble PDF to Image - Installer Dev v1"
Write-Host ""

& (Join-Path $root "Check-Installer-Prerequisites.ps1")

# Locate ISCC.
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

# Build the already-validated core/shell/sparse-package chain fresh.
Write-Host ""
Write-Host "[1/4] Building Explorer payload..."
& (Join-Path $root "Build-Explorer.ps1")
if ($LASTEXITCODE -ne 0) {
    throw "Explorer payload build failed."
}

# Prepare installer stage.
Write-Host ""
Write-Host "[2/4] Preparing installer payload..."

foreach ($dir in @($stage, $dist)) {
    if (Test-Path -LiteralPath $dir) {
        Remove-Item -LiteralPath $dir -Recurse -Force
    }
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

Copy-Item -LiteralPath (Join-Path $external "WinPebble.PDFToImage.exe") -Destination $stage
Copy-Item -LiteralPath (Join-Path $external "WinPebble.PDFToImage.Shell.dll") -Destination $stage
Copy-Item -LiteralPath (Join-Path $external "Assets") -Destination (Join-Path $stage "Assets") -Recurse
Copy-Item -LiteralPath (Join-Path $package "WinPebble.PDFToImage.Dev.identity.msix") -Destination $stage
Copy-Item -LiteralPath (Join-Path $certDir "WinPebble-PDFToImage-Dev.cer") -Destination $stage
Copy-Item -LiteralPath (Join-Path $installerSource "Register-Installed-Package.ps1") -Destination $stage
Copy-Item -LiteralPath (Join-Path $installerSource "Unregister-Installed-Package.ps1") -Destination $stage
Copy-Item -LiteralPath (Join-Path $installerSource "WinPebble-Setup-Dev.ico") -Destination $stage

# Compile Setup.exe.
Write-Host ""
Write-Host "[3/4] Compiling Inno Setup installer..."

$iss = Join-Path $installerSource "WinPebble-PDF-to-Image.iss"

& $iscc `
    "/DStageDir=$stage" `
    "/DOutputDir=$dist" `
    $iss

if ($LASTEXITCODE -ne 0) {
    throw "Inno Setup compilation failed."
}

$setup = Join-Path $dist "WinPebble-PDF-to-Image-Setup-Dev.exe"

if (-not (Test-Path -LiteralPath $setup)) {
    throw "Installer compilation completed but Setup.exe was not found."
}

# Metadata.
Write-Host ""
Write-Host "[4/4] Finalizing installer metadata..."

$info = Get-Item -LiteralPath $setup
$hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $setup).Hash.ToLowerInvariant()

Write-Host ""
Write-Host "INSTALLER DEV BUILD SUCCESS" -ForegroundColor Green
Write-Host ""
Write-Host "Installer:"
Write-Host "  $setup"
Write-Host ""
Write-Host ("Size    : {0:N0} bytes ({1:N2} MiB)" -f $info.Length, ($info.Length / 1MB))
Write-Host "SHA-256 : $hash"
Write-Host ""
Write-Host "Next:"
Write-Host "  Run WinPebble-PDF-to-Image-Setup-Dev.exe"
Write-Host "  Then run .\Test-Installed-State.ps1"
