$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$external = Join-Path $root "artifacts\external"
$packageInput = Join-Path $root "artifacts\package-input"
$packageOut = Join-Path $root "artifacts\package"
$certDir = Join-Path $root "artifacts\dev-cert"

Write-Host "WinPebble PDF to Image - Explorer Integration Dev v1"
Write-Host ""

& (Join-Path $root "Check-Explorer-Prerequisites.ps1")
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

# Locate Visual Studio C++ environment.
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$vsPath = & $vswhere `
    -latest `
    -products * `
    -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
    -property installationPath

$vcvars = Join-Path $vsPath "VC\Auxiliary\Build\vcvars64.bat"

# Locate newest SDK MakeAppx/SignTool.
$kitsBin = "${env:ProgramFiles(x86)}\Windows Kits\10\bin"
$sdkDir = Get-ChildItem -LiteralPath $kitsBin -Directory |
    Sort-Object Name -Descending |
    Where-Object {
        (Test-Path (Join-Path $_.FullName "x64\makeappx.exe")) -and
        (Test-Path (Join-Path $_.FullName "x64\signtool.exe"))
    } |
    Select-Object -First 1

if (-not $sdkDir) {
    throw "Windows SDK packaging tools were not found."
}

$makeAppx = Join-Path $sdkDir.FullName "x64\makeappx.exe"
$signTool = Join-Path $sdkDir.FullName "x64\signtool.exe"

# Clean output.
foreach ($dir in @($external, $packageInput, $packageOut)) {
    if (Test-Path -LiteralPath $dir) {
        Remove-Item -LiteralPath $dir -Recurse -Force
    }
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

New-Item -ItemType Directory -Force -Path $certDir | Out-Null

# 1) Build the self-contained WinPebble core.
Write-Host ""
Write-Host "[1/5] Building standalone core..."
& (Join-Path $root "Build-Standalone.ps1")
if ($LASTEXITCODE -ne 0) {
    throw "Standalone core build failed."
}

$coreExe = Join-Path $root "artifacts\standalone\WinPebble.PDFToImage.exe"
Copy-Item -LiteralPath $coreExe -Destination (Join-Path $external "WinPebble.PDFToImage.exe")

# 2) Build native IExplorerCommand shell DLL.
Write-Host ""
Write-Host "[2/5] Building native x64 IExplorerCommand DLL..."

$cpp = Join-Path $root "shell\ExplorerCommand.cpp"
$def = Join-Path $root "shell\ExplorerCommand.def"
$rc = Join-Path $root "shell\WinPebble.PDFToImage.Shell.rc"
$dll = Join-Path $external "WinPebble.PDFToImage.Shell.dll"
$obj = Join-Path $external "ExplorerCommand.obj"
$res = Join-Path $external "WinPebble.PDFToImage.Shell.res"
$cmdFile = Join-Path $external "_build_shell.cmd"

$cmdContent = @"
@echo off
call "$vcvars" >nul
if errorlevel 1 exit /b %errorlevel%
rc.exe /nologo /fo "$res" "$rc"
if errorlevel 1 exit /b %errorlevel%
cl.exe /nologo /std:c++17 /EHsc /O2 /MT /LD /DUNICODE /D_UNICODE /Fo:"$obj" "$cpp" "$res" /Fe:"$dll" /link /NOLOGO /DEF:"$def" shell32.lib shlwapi.lib ole32.lib
exit /b %errorlevel%
"@

Set-Content -LiteralPath $cmdFile -Value $cmdContent -Encoding ASCII

& cmd.exe /d /c "`"$cmdFile`""
if ($LASTEXITCODE -ne 0) {
    throw "Native shell DLL build failed."
}

Remove-Item -LiteralPath $cmdFile -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $obj -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $res -Force -ErrorAction SilentlyContinue

if (-not (Test-Path -LiteralPath $dll)) {
    throw "Shell DLL was not created."
}

# 3) Prepare external assets and sparse package input.
Write-Host ""
Write-Host "[3/5] Preparing sparse identity package..."

Copy-Item -LiteralPath (Join-Path $root "package\Assets") `
    -Destination (Join-Path $external "Assets") -Recurse -Force

Copy-Item -LiteralPath (Join-Path $root "package\AppxManifest.xml") `
    -Destination (Join-Path $packageInput "AppxManifest.xml")

$msix = Join-Path $packageOut "WinPebble.PDFToImage.Dev.identity.msix"

# Sparse/external-location package:
# EXE/DLL/Assets are intentionally external and not included in the identity MSIX.
# /nv disables full-package semantic validation that would otherwise require
# manifest-referenced external files to be present inside the package.
& $makeAppx pack /d $packageInput /p $msix /o /nv
if ($LASTEXITCODE -ne 0) {
    throw "MakeAppx failed."
}

# 4) Create/reuse development signing certificate.
Write-Host ""
Write-Host "[4/5] Preparing development signing certificate..."

$pfx = Join-Path $certDir "WinPebble-PDFToImage-Dev.pfx"
$cer = Join-Path $certDir "WinPebble-PDFToImage-Dev.cer"
$passwordText = "WinPebble-Dev-Cert-Only-2026!"
$password = ConvertTo-SecureString -String $passwordText -Force -AsPlainText

if (-not (Test-Path -LiteralPath $pfx)) {
    $cert = New-SelfSignedCertificate `
        -Type Custom `
        -KeyUsage DigitalSignature `
        -Subject "CN=WinPebble Development" `
        -CertStoreLocation "Cert:\CurrentUser\My" `
        -TextExtension @(
            "2.5.29.37={text}1.3.6.1.5.5.7.3.3",
            "2.5.29.19={text}"
        ) `
        -FriendlyName "WinPebble PDF to Image Development"

    Export-PfxCertificate `
        -Cert $cert `
        -FilePath $pfx `
        -Password $password | Out-Null

    Export-Certificate `
        -Cert $cert `
        -FilePath $cer | Out-Null
}

# 5) Sign identity package.
Write-Host ""
Write-Host "[5/5] Signing development identity package..."

& $signTool sign `
    /fd SHA256 `
    /f $pfx `
    /p $passwordText `
    $msix

if ($LASTEXITCODE -ne 0) {
    throw "SignTool failed."
}

$exeHash = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $external "WinPebble.PDFToImage.exe")).Hash.ToLowerInvariant()
$dllHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $dll).Hash.ToLowerInvariant()
$msixHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $msix).Hash.ToLowerInvariant()

Write-Host ""
Write-Host "EXPLORER DEV BUILD SUCCESS" -ForegroundColor Green
Write-Host ""
Write-Host "External payload:"
Write-Host "  $external"
Write-Host ""
Write-Host "Identity package:"
Write-Host "  $msix"
Write-Host ""
Write-Host "Development certificate (not trusted yet):"
Write-Host "  $cer"
Write-Host ""
Write-Host "SHA-256"
Write-Host "  EXE : $exeHash"
Write-Host "  DLL : $dllHash"
Write-Host "  MSIX: $msixHash"
Write-Host ""
Write-Host "Next:"
Write-Host "  1. Open PowerShell AS ADMINISTRATOR"
Write-Host "  2. Run .\Trust-Dev-Certificate.ps1"
Write-Host "  3. Return to normal PowerShell and run .\Register-Explorer-Dev.ps1"
