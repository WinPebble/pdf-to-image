# Isolated regression tests: substitutes target scripts, except the missing-SDK case.
# Does not build packages, trust certificates or restart Explorer.
$ErrorActionPreference = "Stop"
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$testRoot = Join-Path $repositoryRoot ("artifacts\wrapper-tests\" + [Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $testRoot -Force | Out-Null
$shellPath = (Get-Process -Id $PID).Path
$wrappers = @(
    "Build-Standalone.ps1", "Build-Explorer.ps1", "Build-Installer.ps1",
    "Check-Explorer-Prerequisites.ps1", "Check-Installer-Prerequisites.ps1"
)
$cases = @(
    @{ Name = "success-return"; Body = 'if ($args[0] -ne "argument with spaces") { throw "Arguments lost" }; Write-Output "TARGET_OK"; return'; Code = 0 },
    @{ Name = "success-exit"; Body = 'Write-Output "TARGET_OK"; exit 0'; Code = 0 },
    @{ Name = "failure-exit"; Body = 'Write-Output "EXPECTED_FAILURE"; exit 7'; Code = 7 },
    @{ Name = "failure-throw"; Body = 'throw "EXPECTED_THROW"'; Code = 1 }
)

function Invoke-Case {
    param([string]$Driver, [int]$ExpectedCode, [string]$Label, [switch]$WithoutDotnet)
    $info = New-Object System.Diagnostics.ProcessStartInfo
    $info.FileName = $shellPath
    $info.Arguments = '-NoProfile -NonInteractive -File "' + $Driver + '" "argument with spaces"'
    $info.WorkingDirectory = $testRoot
    $info.UseShellExecute = $false
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    if ($WithoutDotnet) { $info.EnvironmentVariables["PATH"] = Split-Path -Parent $Driver }
    $process = [System.Diagnostics.Process]::Start($info)
    try {
        $stdoutTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()
        if (-not $process.WaitForExit(30000)) {
            $process.Kill()
            throw "Timeout: $Label"
        }
        $stdout = $stdoutTask.GetAwaiter().GetResult()
        $stderr = $stderrTask.GetAwaiter().GetResult()
        if ($process.ExitCode -ne $ExpectedCode) {
            throw "$Label expected $ExpectedCode, got $($process.ExitCode). $stdout $stderr"
        }
        if ($WithoutDotnet -and $stdout -notmatch 'SDK was not found') {
            throw "Missing-SDK branch was not reached: $stdout $stderr"
        }
        Write-Host "PASS: $Label (exit $ExpectedCode)"
    }
    finally { $process.Dispose() }
}

foreach ($wrapper in $wrappers) {
    foreach ($case in $cases) {
        $caseRoot = Join-Path $testRoot ($wrapper + "-" + $case.Name)
        New-Item -ItemType Directory -Path (Join-Path $caseRoot "scripts") -Force | Out-Null
        Copy-Item -LiteralPath (Join-Path $repositoryRoot "scripts\$wrapper") -Destination (Join-Path $caseRoot "scripts\$wrapper")
        Set-Content -LiteralPath (Join-Path $caseRoot $wrapper) -Value $case.Body -Encoding UTF8
        $driver = Join-Path $caseRoot "driver.ps1"
        $driverText = '$global:LASTEXITCODE = 19' + "`n" + '& (Join-Path $PSScriptRoot "scripts\' + $wrapper + '") "argument with spaces"' + "`n" + 'exit $LASTEXITCODE'
        Set-Content -LiteralPath $driver -Value $driverText -Encoding UTF8
        Invoke-Case -Driver $driver -ExpectedCode $case.Code -Label "$wrapper / simulated $($case.Name)"
        Invoke-Case -Driver (Join-Path $caseRoot "scripts\$wrapper") -ExpectedCode $case.Code -Label "$wrapper / direct -File $($case.Name)"
    }
}

# Exercise the real root script's early prerequisite failure in a child with no dotnet on PATH.
$missingRoot = Join-Path $testRoot "missing-sdk"
New-Item -ItemType Directory -Path (Join-Path $missingRoot "scripts") -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $repositoryRoot "Build-Standalone.ps1") -Destination $missingRoot
Copy-Item -LiteralPath (Join-Path $repositoryRoot "scripts\Build-Standalone.ps1") -Destination (Join-Path $missingRoot "scripts")
Invoke-Case -Driver (Join-Path $missingRoot "scripts\Build-Standalone.ps1") -ExpectedCode 1 -Label "Build-Standalone.ps1 / simulated missing SDK using real prerequisite code" -WithoutDotnet
Write-Host "WRAPPER REGRESSION TESTS PASSED (41 cases). Fixtures: $testRoot"
