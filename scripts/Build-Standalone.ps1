$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$project = Join-Path $root "src\WinPebble.PDFToImage\WinPebble.PDFToImage.csproj"
$outDir = Join-Path $root "artifacts\standalone"

Write-Host "WinPebble PDF to Image - standalone packaging gate"
Write-Host ""

if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: .NET SDK was not found." -ForegroundColor Red
    exit 1
}

Write-Host ".NET SDK: $(dotnet --version)"
Write-Host ""

if (Test-Path -LiteralPath $outDir) {
    Remove-Item -LiteralPath $outDir -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

Write-Host "Publishing self-contained single-file win-x64..."
Write-Host "Trimming is intentionally OFF for this gate because WinRT is used."
Write-Host ""

dotnet publish $project `
    -c Release `
    -r win-x64 `
    --self-contained true `
    -p:PublishSingleFile=true `
    -p:EnableCompressionInSingleFile=true `
    -p:IncludeNativeLibrariesForSelfExtract=true `
    -p:PublishTrimmed=false `
    -p:DebugType=None `
    -p:DebugSymbols=false `
    -o $outDir

if ($LASTEXITCODE -ne 0) {
    throw "Standalone dotnet publish failed."
}

$exe = Join-Path $outDir "WinPebble.PDFToImage.exe"

if (-not (Test-Path -LiteralPath $exe)) {
    throw "Standalone executable was not created."
}

$files = @(Get-ChildItem -LiteralPath $outDir -File)
$size = (Get-Item -LiteralPath $exe).Length
$hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $exe).Hash.ToLowerInvariant()

Write-Host ""
Write-Host "STANDALONE BUILD SUCCESS" -ForegroundColor Green
Write-Host ""
Write-Host "Payload files: $($files.Count)"
$files | ForEach-Object {
    Write-Host ("  {0}  ({1:N0} bytes)" -f $_.Name, $_.Length)
}
Write-Host ""
Write-Host ("EXE size : {0:N0} bytes ({1:N2} MiB)" -f $size, ($size / 1MB))
Write-Host "SHA-256 : $hash"
Write-Host ""
Write-Host "Next:"
Write-Host "  .\Test-Standalone.ps1"
