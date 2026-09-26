$ErrorActionPreference = "Stop"

Write-Host "WinPebble PDF to Image - Explorer integration prerequisites"
Write-Host ""

$ok = $true

# .NET SDK (core build)
if (Get-Command dotnet -ErrorAction SilentlyContinue) {
    Write-Host "PASS: .NET SDK $(dotnet --version)" -ForegroundColor Green
}
else {
    Write-Host "MISSING: .NET 8 SDK" -ForegroundColor Red
    $ok = $false
}

# Visual Studio / Build Tools C++ workload
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$vsPath = $null

if (Test-Path -LiteralPath $vswhere) {
    $vsPath = & $vswhere `
        -latest `
        -products * `
        -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
        -property installationPath
}

if ($vsPath) {
    $vcvars = Join-Path $vsPath "VC\Auxiliary\Build\vcvars64.bat"

    if (Test-Path -LiteralPath $vcvars) {
        Write-Host "PASS: MSVC C++ x64 build tools" -ForegroundColor Green
        Write-Host "      $vsPath"
    }
    else {
        Write-Host "MISSING: vcvars64.bat / MSVC x64 toolchain" -ForegroundColor Red
        $ok = $false
    }
}
else {
    Write-Host "MISSING: Visual Studio Build Tools with Desktop development with C++" -ForegroundColor Red
    $ok = $false
}

# Windows SDK package tools
$kitsBin = "${env:ProgramFiles(x86)}\Windows Kits\10\bin"
$makeAppx = $null
$signTool = $null

if (Test-Path -LiteralPath $kitsBin) {
    $sdkDirs = Get-ChildItem -LiteralPath $kitsBin -Directory |
        Sort-Object Name -Descending

    foreach ($dir in $sdkDirs) {
        $candidateMakeAppx = Join-Path $dir.FullName "x64\makeappx.exe"
        $candidateSignTool = Join-Path $dir.FullName "x64\signtool.exe"

        if ((Test-Path $candidateMakeAppx) -and (Test-Path $candidateSignTool)) {
            $makeAppx = $candidateMakeAppx
            $signTool = $candidateSignTool
            break
        }
    }
}

if ($makeAppx) {
    Write-Host "PASS: Windows SDK MakeAppx + SignTool" -ForegroundColor Green
    Write-Host "      $makeAppx"
}
else {
    Write-Host "MISSING: Windows 10/11 SDK packaging tools (MakeAppx/SignTool)" -ForegroundColor Red
    $ok = $false
}

Write-Host ""

if ($ok) {
    Write-Host "EXPLORER BUILD PREREQUISITES PASSED" -ForegroundColor Green
    return
}

Write-Host "PREREQUISITES MISSING" -ForegroundColor Red
Write-Host ""
Write-Host "Do not disable Windows security features."
throw "Explorer build prerequisites are missing."
