# Compatibility entry point. The repository-root script is canonical.
$ErrorActionPreference = "Stop"
$repositoryRoot = Split-Path -Parent $PSScriptRoot
# Reset stale native status when the target succeeds without invoking a native tool.
$global:LASTEXITCODE = 0
& (Join-Path $repositoryRoot "Check-Explorer-Prerequisites.ps1") @args
exit $LASTEXITCODE
