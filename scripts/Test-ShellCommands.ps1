param(
    [string]$DllPath
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if (-not $DllPath) {
    $DllPath = Join-Path $root 'artifacts\msix-store\package-input\WinPebble.PDFToImage.Shell.dll'
}
$dll = (Resolve-Path -LiteralPath $DllPath).Path
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$vsPath = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if (-not $vsPath) { throw 'MSVC x64 build tools not found.' }
$vcvars = Join-Path $vsPath 'VC\Auxiliary\Build\vcvars64.bat'

# A unique directory avoids deleting previous results. Include Unicode/spaces to
# verify that icon locations and child arguments preserve filesystem paths.
$work = Join-Path $root ('artifacts\shell-command-checks\' + [guid]::NewGuid().ToString('N'))
$fixture = Join-Path $work 'WinPebble Việt Nam'
New-Item -ItemType Directory -Path $work -Force | Out-Null
New-Item -ItemType Directory -Path $fixture -Force | Out-Null
Copy-Item -LiteralPath $dll -Destination (Join-Path $fixture 'WinPebble.PDFToImage.Shell.dll')
$runner = Join-Path $work 'ShellCommandChecks.exe'
$recorder = Join-Path $work 'WinPebble.PDFToImage.exe'
$runnerSource = Join-Path $root 'tests\ShellCommandChecks.cpp'
$recorderSource = Join-Path $root 'tests\ShellArgumentRecorder.cpp'
$buildFile = Join-Path $work 'build-tests.cmd'
$buildCommands = @"
@echo off
call "$vcvars" >nul
if errorlevel 1 exit /b %errorlevel%
cl.exe /nologo /utf-8 /std:c++17 /EHsc /O2 /MT /DUNICODE /D_UNICODE /Fo:"$work\runner.obj" "$runnerSource" /Fe:"$runner" /link /NOLOGO shell32.lib ole32.lib
if errorlevel 1 exit /b %errorlevel%
cl.exe /nologo /utf-8 /std:c++17 /EHsc /O2 /MT /DUNICODE /D_UNICODE /Fo:"$work\recorder.obj" "$recorderSource" /Fe:"$recorder" /link /NOLOGO
exit /b %errorlevel%
"@
[IO.File]::WriteAllText($buildFile, $buildCommands.Replace("`r`n", "`n").Replace("`n", "`r`n"), [Text.Encoding]::ASCII)
& cmd.exe /d /c "`"$buildFile`""
if ($LASTEXITCODE -ne 0) { throw 'Shell test compilation failed.' }
Copy-Item -LiteralPath $recorder -Destination (Join-Path $fixture 'WinPebble.PDFToImage.exe')
& $runner (Join-Path $fixture 'WinPebble.PDFToImage.Shell.dll')
if ($LASTEXITCODE -ne 0) { throw 'Shell command checks failed.' }
Write-Host "PASS: native shell checks. Fixtures retained at $work"
Write-Host 'The child is an argv recorder, not the converter. This does not validate installed Explorer rendering.'
