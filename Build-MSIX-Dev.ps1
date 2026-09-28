$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$manifestSource = Join-Path $root "store-msix\AppxManifest.Dev.xml"
$artifactsRoot = Join-Path $root "artifacts\msix-dev"
$stage = Join-Path $artifactsRoot "package-input"
$outDir = Join-Path $artifactsRoot "out"
$buildDir = Join-Path $artifactsRoot "build"
$certDir = Join-Path $artifactsRoot "cert"

Write-Host "WinPebble PDF to Image - Full MSIX Dev Gate v1"
Write-Host ""

$required = @(
    "Build-Standalone.ps1",
    "Check-Explorer-Prerequisites.ps1",
    "src\WinPebble.PDFToImage\WinPebble.PDFToImage.csproj",
    "shell\ExplorerCommand.cpp",
    "shell\ExplorerCommand.def",
    "shell\WinPebble.PDFToImage.Shell.rc",
    "package\Assets\Square44x44Logo.png",
    "package\Assets\Square150x150Logo.png",
    "package\Assets\StoreLogo.png",
    "store-msix\AppxManifest.Dev.xml"
)

foreach ($relative in $required) {
    if (-not (Test-Path -LiteralPath (Join-Path $root $relative))) {
        throw "Required MSIX build input is missing: $relative"
    }
}

& (Join-Path $root "Check-Explorer-Prerequisites.ps1")

$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$vsPath = & $vswhere `
    -latest `
    -products * `
    -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
    -property installationPath

if (-not $vsPath) {
    throw "Visual Studio C++ build tools not found."
}

$vcvars = Join-Path $vsPath "VC\Auxiliary\Build\vcvars64.bat"
if (-not (Test-Path -LiteralPath $vcvars)) {
    throw "vcvars64.bat not found."
}

$kitsBin = "${env:ProgramFiles(x86)}\Windows Kits\10\bin"
$sdkDir = Get-ChildItem -LiteralPath $kitsBin -Directory |
    Sort-Object Name -Descending |
    Where-Object {
        (Test-Path (Join-Path $_.FullName "x64\makeappx.exe")) -and
        (Test-Path (Join-Path $_.FullName "x64\signtool.exe"))
    } |
    Select-Object -First 1

if (-not $sdkDir) {
    throw "Windows SDK MakeAppx/SignTool not found."
}

$makeAppx = Join-Path $sdkDir.FullName "x64\makeappx.exe"
$signTool = Join-Path $sdkDir.FullName "x64\signtool.exe"

if (Test-Path -LiteralPath $artifactsRoot) {
    Remove-Item -LiteralPath $artifactsRoot -Recurse -Force
}
foreach ($dir in @($stage, $outDir, $buildDir, $certDir)) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

Write-Host ""
Write-Host "[1/5] Building self-contained core..."
& (Join-Path $root "Build-Standalone.ps1")
if ($LASTEXITCODE -ne 0) {
    throw "Standalone core build failed."
}

$coreExe = Join-Path $root "artifacts\standalone\WinPebble.PDFToImage.exe"
if (-not (Test-Path -LiteralPath $coreExe)) {
    throw "Standalone core EXE not found."
}

Write-Host ""
Write-Host "[2/5] Building native x64 Explorer command DLL..."

$cpp = Join-Path $root "shell\ExplorerCommand.cpp"
$def = Join-Path $root "shell\ExplorerCommand.def"
$rc = Join-Path $root "shell\WinPebble.PDFToImage.Shell.rc"
$dll = Join-Path $buildDir "WinPebble.PDFToImage.Shell.dll"
$obj = Join-Path $buildDir "ExplorerCommand.obj"
$res = Join-Path $buildDir "WinPebble.PDFToImage.Shell.res"
$cmdFile = Join-Path $buildDir "_build_shell.cmd"

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

if (-not (Test-Path -LiteralPath $dll)) {
    throw "Shell DLL was not produced."
}

Write-Host ""
Write-Host "[3/5] Preparing full MSIX package input..."

Copy-Item -LiteralPath $coreExe -Destination (Join-Path $stage "WinPebble.PDFToImage.exe")
Copy-Item -LiteralPath $dll -Destination (Join-Path $stage "WinPebble.PDFToImage.Shell.dll")
Copy-Item -LiteralPath (Join-Path $root "package\Assets") `
    -Destination (Join-Path $stage "Assets") -Recurse -Force
Copy-Item -LiteralPath $manifestSource `
    -Destination (Join-Path $stage "AppxManifest.xml") -Force

[xml]$manifest = Get-Content -LiteralPath (Join-Path $stage "AppxManifest.xml")
$ns = New-Object System.Xml.XmlNamespaceManager($manifest.NameTable)
$ns.AddNamespace("f", "http://schemas.microsoft.com/appx/manifest/foundation/windows10")
$identity = $manifest.SelectSingleNode("/f:Package/f:Identity", $ns)

if (-not $identity) { throw "MSIX manifest Identity node missing." }
if ($identity.Version -ne "1.0.0.0") {
    throw "Unexpected dev MSIX package version: $($identity.Version)"
}
if ($identity.ProcessorArchitecture -ne "x64") {
    throw "Unexpected MSIX architecture: $($identity.ProcessorArchitecture)"
}

$msix = Join-Path $outDir "WinPebble-PDF-to-Image-0.9.0-beta.1-Full-Dev.msix"

Write-Host ""
Write-Host "[4/5] Packing full MSIX..."
& $makeAppx pack /d $stage /p $msix /o
if ($LASTEXITCODE -ne 0) {
    throw "MakeAppx full MSIX packaging failed."
}

Write-Host ""
Write-Host "[5/5] Creating/reusing dev signing certificate and signing MSIX..."

$subject = "CN=WinPebble Development"
$friendly = "WinPebble PDF to Image Full MSIX Development"

$cert = Get-ChildItem Cert:\CurrentUser\My |
    Where-Object {
        $_.Subject -eq $subject -and
        $_.HasPrivateKey -and
        $_.FriendlyName -eq $friendly
    } |
    Sort-Object NotAfter -Descending |
    Select-Object -First 1

if (-not $cert) {
    $cert = New-SelfSignedCertificate `
        -Type Custom `
        -KeyUsage DigitalSignature `
        -Subject $subject `
        -CertStoreLocation "Cert:\CurrentUser\My" `
        -TextExtension @(
            "2.5.29.37={text}1.3.6.1.5.5.7.3.3",
            "2.5.29.19={text}"
        ) `
        -FriendlyName $friendly
}

$cer = Join-Path $certDir "WinPebble-PDFToImage-Full-MSIX-Dev.cer"
Export-Certificate -Cert $cert -FilePath $cer -Force | Out-Null

& $signTool sign `
    /fd SHA256 `
    /sha1 $cert.Thumbprint `
    /s My `
    $msix

if ($LASTEXITCODE -ne 0) {
    throw "SignTool failed for full MSIX."
}

$msixHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $msix).Hash.ToLowerInvariant()
$coreHash = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $stage "WinPebble.PDFToImage.exe")).Hash.ToLowerInvariant()
$dllHash = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $stage "WinPebble.PDFToImage.Shell.dll")).Hash.ToLowerInvariant()

$sumFile = Join-Path $outDir "SHA256SUMS-MSIX-DEV.txt"
@"
SHA256 (WinPebble-PDF-to-Image-0.9.0-beta.1-Full-Dev.msix) = $msixHash
SHA256 (WinPebble.PDFToImage.exe) = $coreHash
SHA256 (WinPebble.PDFToImage.Shell.dll) = $dllHash
"@ | Set-Content -LiteralPath $sumFile -Encoding ASCII

Write-Host ""
Write-Host "FULL MSIX DEV BUILD SUCCESS" -ForegroundColor Green
Write-Host ""
Write-Host "MSIX:"
Write-Host "  $msix"
Write-Host "Certificate:"
Write-Host "  $cer"
Write-Host "SHA-256:"
Write-Host "  $msixHash"
Write-Host ""
Write-Host "Package identity version: 1.0.0.0"
Write-Host "App product version remains: 0.9.0-beta.1 / 0.9.0.1"
Write-Host ""
Write-Host "Next: run Install-MSIX-Dev.ps1 AS ADMINISTRATOR."
