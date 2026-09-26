$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$stage = Join-Path $root "artifacts\installer-stage"
$dist = Join-Path $root "artifacts\installer"
$external = Join-Path $root "artifacts\external"
$package = Join-Path $root "artifacts\package"
$certDir = Join-Path $root "artifacts\dev-cert"
$installerSource = Join-Path $root "installer"

Write-Host "WinPebble PDF to Image - NSIS Installer Dev v1"
Write-Host "Version: 0.9.0-beta"
Write-Host ""

& (Join-Path $root "Check-Installer-Prerequisites.ps1")

$candidates = @(
    "$env:ProgramFiles\NSIS\makensis.exe",
    "${env:ProgramFiles(x86)}\NSIS\makensis.exe",
    "$env:LOCALAPPDATA\Programs\NSIS\makensis.exe"
)

$makensis = $candidates |
    Where-Object { Test-Path -LiteralPath $_ } |
    Select-Object -First 1

Write-Host ""
Write-Host "[1/4] Building Explorer payload..."
& (Join-Path $root "Build-Explorer.ps1")
if ($LASTEXITCODE -ne 0) {
    throw "Explorer payload build failed."
}

Write-Host ""
Write-Host "[2/4] Preparing NSIS installer payload..."

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

Write-Host ""
Write-Host "[3/4] Compiling NSIS installer..."

$nsi = Join-Path $installerSource "WinPebble-PDF-to-Image.nsi"

& $makensis `
    "/DStageDir=$stage" `
    "/DOutputDir=$dist" `
    $nsi

if ($LASTEXITCODE -ne 0) {
    throw "NSIS compilation failed."
}

$setup = Join-Path $dist "WinPebble-PDF-to-Image-Setup-Beta-Dev.exe"
if (-not (Test-Path -LiteralPath $setup)) {
    throw "NSIS completed but Setup.exe was not found."
}

Write-Host ""
Write-Host "[4/4] Validating version metadata and hashes..."

$exe = Join-Path $external "WinPebble.PDFToImage.exe"
$dll = Join-Path $external "WinPebble.PDFToImage.Shell.dll"

$expectedFileVersion = "0.9.0.0"

foreach ($file in @($exe, $dll, $setup)) {
    $vi = (Get-Item -LiteralPath $file).VersionInfo
    Write-Host ""
    Write-Host "Metadata: $([IO.Path]::GetFileName($file))"
    Write-Host "  ProductName    : $($vi.ProductName)"
    Write-Host "  ProductVersion : $($vi.ProductVersion)"
    Write-Host "  FileVersion    : $($vi.FileVersion)"

    if ($vi.FileVersion -ne $expectedFileVersion) {
        throw "Unexpected FileVersion for $file. Expected $expectedFileVersion."
    }
}

$info = Get-Item -LiteralPath $setup
$hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $setup).Hash.ToLowerInvariant()

Write-Host ""
Write-Host "NSIS INSTALLER DEV BUILD SUCCESS" -ForegroundColor Green
Write-Host ""
Write-Host "Installer:"
Write-Host "  $setup"
Write-Host ""
Write-Host ("Size    : {0:N0} bytes ({1:N2} MiB)" -f $info.Length, ($info.Length / 1MB))
Write-Host "SHA-256 : $hash"
Write-Host ""
Write-Host "Next:"
Write-Host "  1. Run WinPebble-PDF-to-Image-Setup-Beta-Dev.exe"
Write-Host "  2. Run .\Test-Installed-State.ps1"
Write-Host "  3. Test Convert PDF to PNG/JPG"
Write-Host "  4. Uninstall from Settings > Apps"
Write-Host "  5. Run .\Test-Uninstalled-State.ps1"
