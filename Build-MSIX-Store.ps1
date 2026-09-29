$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$manifestSource = Join-Path $root "store-msix\AppxManifest.Store.xml"
$artifactsRoot = Join-Path $root "artifacts\msix-store"
$stage = Join-Path $artifactsRoot "package-input"
$outDir = Join-Path $artifactsRoot "out"
$buildDir = Join-Path $artifactsRoot "build"

$expectedName = "TrungHieuNguyen-WinPebble.WinPebblePDFtoImage"
$expectedPublisher = "CN=6BD09250-A4F3-4F78-9DA7-2D9751735950"
$expectedPublisherDisplayName = "Trung Hieu Nguyen - WinPebble"
$expectedVersion = "1.0.0.0"

Write-Host "WinPebble PDF to Image - Microsoft Store MSIX Gate v1"
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
    "store-msix\AppxManifest.Store.xml",
    "store-msix\STORE_IDENTITY.md"
)

foreach ($relative in $required) {
    if (-not (Test-Path -LiteralPath (Join-Path $root $relative))) {
        throw "Required Store build input is missing: $relative"
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
        Test-Path (Join-Path $_.FullName "x64\makeappx.exe")
    } |
    Select-Object -First 1

if (-not $sdkDir) {
    throw "Windows SDK MakeAppx not found."
}

$makeAppx = Join-Path $sdkDir.FullName "x64\makeappx.exe"

if (Test-Path -LiteralPath $artifactsRoot) {
    Remove-Item -LiteralPath $artifactsRoot -Recurse -Force
}
foreach ($dir in @($stage, $outDir, $buildDir)) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

Write-Host "[1/6] Validating official Store identity..."

[xml]$sourceManifest = Get-Content -LiteralPath $manifestSource
$ns = New-Object System.Xml.XmlNamespaceManager($sourceManifest.NameTable)
$ns.AddNamespace("f", "http://schemas.microsoft.com/appx/manifest/foundation/windows10")

$identity = $sourceManifest.SelectSingleNode("/f:Package/f:Identity", $ns)
$properties = $sourceManifest.SelectSingleNode("/f:Package/f:Properties", $ns)

if (-not $identity) { throw "Store manifest Identity node missing." }
if (-not $properties) { throw "Store manifest Properties node missing." }

if ($identity.Name -cne $expectedName) {
    throw "Store Identity Name mismatch. Expected '$expectedName', got '$($identity.Name)'."
}
if ($identity.Publisher -cne $expectedPublisher) {
    throw "Store Publisher mismatch. Expected '$expectedPublisher', got '$($identity.Publisher)'."
}
if ($identity.Version -cne $expectedVersion) {
    throw "Store package version mismatch. Expected '$expectedVersion', got '$($identity.Version)'."
}
if ($identity.ProcessorArchitecture -cne "x64") {
    throw "Unexpected Store MSIX architecture: $($identity.ProcessorArchitecture)"
}
if ($properties.PublisherDisplayName -cne $expectedPublisherDisplayName) {
    throw "PublisherDisplayName mismatch. Expected '$expectedPublisherDisplayName', got '$($properties.PublisherDisplayName)'."
}

Write-Host "PASS: Partner Center identity matches exactly" -ForegroundColor Green

Write-Host ""
Write-Host "[2/6] Building self-contained core..."
& (Join-Path $root "Build-Standalone.ps1")
if ($LASTEXITCODE -ne 0) {
    throw "Standalone core build failed."
}

$coreExe = Join-Path $root "artifacts\standalone\WinPebble.PDFToImage.exe"
if (-not (Test-Path -LiteralPath $coreExe)) {
    throw "Standalone core EXE not found."
}

Write-Host ""
Write-Host "[3/6] Building native x64 Explorer command DLL..."

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
Write-Host "[4/6] Preparing Store package input..."

Copy-Item -LiteralPath $coreExe -Destination (Join-Path $stage "WinPebble.PDFToImage.exe")
Copy-Item -LiteralPath $dll -Destination (Join-Path $stage "WinPebble.PDFToImage.Shell.dll")
Copy-Item -LiteralPath (Join-Path $root "package\Assets") `
    -Destination (Join-Path $stage "Assets") -Recurse -Force
Copy-Item -LiteralPath $manifestSource `
    -Destination (Join-Path $stage "AppxManifest.xml") -Force

$forbidden = Get-ChildItem -LiteralPath $stage -Recurse -File |
    Where-Object { $_.Extension -in @(".cer",".pfx",".p12") }

if ($forbidden) {
    throw "Store package input contains certificate material: $($forbidden.FullName -join ', ')"
}

$msix = Join-Path $outDir "WinPebble-PDF-to-Image-0.9.0-beta.1-Store.msix"

Write-Host ""
Write-Host "[5/6] Packing Store-ready MSIX (unsigned for Partner Center)..."
& $makeAppx pack /d $stage /p $msix /o
if ($LASTEXITCODE -ne 0) {
    throw "MakeAppx Store MSIX packaging failed."
}

Write-Host ""
Write-Host "[6/6] Verifying Store artifact..."

Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead($msix)
try {
    $entries = @($zip.Entries | ForEach-Object { $_.FullName })
    if ($entries -contains "AppxSignature.p7x") {
        throw "Store artifact unexpectedly contains a package signature."
    }
    if ($entries -contains "WinPebble-PDFToImage-Full-MSIX-Dev.cer") {
        throw "Development certificate leaked into Store artifact."
    }

    foreach ($requiredEntry in @(
        "AppxManifest.xml",
        "WinPebble.PDFToImage.exe",
        "WinPebble.PDFToImage.Shell.dll",
        "Assets/Square44x44Logo.png",
        "Assets/Square150x150Logo.png",
        "Assets/StoreLogo.png"
    )) {
        if ($entries -notcontains $requiredEntry) {
            throw "Store MSIX missing required entry: $requiredEntry"
        }
    }
}
finally {
    $zip.Dispose()
}

$msixHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $msix).Hash.ToLowerInvariant()
$coreHash = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $stage "WinPebble.PDFToImage.exe")).Hash.ToLowerInvariant()
$dllHash = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $stage "WinPebble.PDFToImage.Shell.dll")).Hash.ToLowerInvariant()

$sumFile = Join-Path $outDir "SHA256SUMS-STORE.txt"
@"
SHA256 (WinPebble-PDF-to-Image-0.9.0-beta.1-Store.msix) = $msixHash
SHA256 (WinPebble.PDFToImage.exe) = $coreHash
SHA256 (WinPebble.PDFToImage.Shell.dll) = $dllHash
"@ | Set-Content -LiteralPath $sumFile -Encoding ASCII

Copy-Item -LiteralPath $manifestSource `
    -Destination (Join-Path $outDir "AppxManifest.Store.xml") -Force

Write-Host ""
Write-Host "STORE MSIX BUILD SUCCESS" -ForegroundColor Green
Write-Host ""
Write-Host "Store ID:"
Write-Host "  9NRZMPGMQPS4"
Write-Host "Identity Name:"
Write-Host "  $expectedName"
Write-Host "Publisher:"
Write-Host "  $expectedPublisher"
Write-Host "PublisherDisplayName:"
Write-Host "  $expectedPublisherDisplayName"
Write-Host "Package version:"
Write-Host "  $expectedVersion"
Write-Host ""
Write-Host "MSIX:"
Write-Host "  $msix"
Write-Host "SHA-256:"
Write-Host "  $msixHash"
Write-Host ""
Write-Host "This artifact is intentionally unsigned for Microsoft Store submission."
Write-Host "Do not use this unsigned Store artifact for direct/sideload distribution."
