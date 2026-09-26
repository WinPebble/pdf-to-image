param(
    [string]$ExePath
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path

if ([string]::IsNullOrWhiteSpace($ExePath)) {
    $exe = Join-Path $root "artifacts\core\WinPebble.PDFToImage.exe"
}
else {
    $exe = [System.IO.Path]::GetFullPath($ExePath)
}
$tests = Join-Path $root "tests"
$work = Join-Path $root "artifacts\hardening-test"

function Assert-True {
    param(
        [bool]$Condition,
        [string]$Message
    )

    if (-not $Condition) {
        throw "ASSERT FAILED: $Message"
    }

    Write-Host "PASS: $Message" -ForegroundColor Green
}

function Assert-Exists {
    param([string]$Path, [string]$Message)
    Assert-True (Test-Path -LiteralPath $Path) $Message
}

function Assert-NotExists {
    param([string]$Path, [string]$Message)
    Assert-True (-not (Test-Path -LiteralPath $Path)) $Message
}

function Get-HashString {
    param([string]$Path)
    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash
}

function Invoke-ExpectedSuccess {
    param([string[]]$Arguments)

    & $exe @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Expected success, got exit code $LASTEXITCODE. Args: $($Arguments -join ' ')"
    }
}

function Invoke-ExpectedFailure {
    param([string[]]$Arguments)

    & $exe @Arguments
    if ($LASTEXITCODE -eq 0) {
        throw "Expected failure, but command succeeded. Args: $($Arguments -join ' ')"
    }
}

function Get-ImageInfo {
    param([string]$Path)

    Add-Type -AssemblyName System.Drawing
    $image = [System.Drawing.Image]::FromFile($Path)

    try {
        return [PSCustomObject]@{
            Width  = $image.Width
            Height = $image.Height
            DpiX   = [double]$image.HorizontalResolution
            DpiY   = [double]$image.VerticalResolution
        }
    }
    finally {
        $image.Dispose()
    }
}

function Assert-Image {
    param(
        [string]$Path,
        [int]$Width,
        [int]$Height,
        [string]$Label
    )

    Assert-Exists $Path "$Label exists"

    $info = Get-ImageInfo $Path

    Assert-True ($info.Width -eq $Width) "$Label width = $Width px"
    Assert-True ($info.Height -eq $Height) "$Label height = $Height px"
    Assert-True ([Math]::Abs($info.DpiX - 300.0) -lt 1.0) "$Label horizontal metadata ≈ 300 DPI"
    Assert-True ([Math]::Abs($info.DpiY - 300.0) -lt 1.0) "$Label vertical metadata ≈ 300 DPI"
}

function Assert-NoTempArtifacts {
    $tempArtifacts = @(
        Get-ChildItem -LiteralPath $work -Force -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -like "*.winpebble.tmp*" }
    )

    Assert-True ($tempArtifacts.Count -eq 0) "No WinPebble temporary artifacts remain"
}

if (-not (Test-Path -LiteralPath $exe)) {
    Write-Host "ERROR: Core executable not found." -ForegroundColor Red
    Write-Host "Run .\Build-Dev.ps1 first."
    exit 1
}

if (Test-Path -LiteralPath $work) {
    Remove-Item -LiteralPath $work -Recurse -Force
}

New-Item -ItemType Directory -Path $work | Out-Null

Write-Host ""
Write-Host "======================================"
Write-Host " WinPebble PDF to Image - Hardening v2"
Write-Host "======================================"

# ------------------------------------------------------------
# 1. A4 PNG + source preservation
# ------------------------------------------------------------
Write-Host ""
Write-Host "=== 1. A4 PNG + source preservation ==="

$a4PngPdf = Join-Path $work "A4 PNG.pdf"
Copy-Item (Join-Path $tests "Hardening-A4.pdf") $a4PngPdf

$before = Get-HashString $a4PngPdf
Invoke-ExpectedSuccess @("--png", $a4PngPdf)
$after = Get-HashString $a4PngPdf

Assert-True ($before -eq $after) "Original PDF SHA-256 is unchanged after PNG conversion"
Assert-Image (Join-Path $work "A4 PNG.png") 2480 3508 "A4 PNG"

# Collision
Invoke-ExpectedSuccess @("--png", $a4PngPdf)
Assert-Image (Join-Path $work "A4 PNG (2).png") 2480 3508 "A4 PNG collision output"

# ------------------------------------------------------------
# 2. A4 JPG + source preservation
# ------------------------------------------------------------
Write-Host ""
Write-Host "=== 2. A4 JPG + source preservation ==="

$a4JpgPdf = Join-Path $work "A4 JPG.pdf"
Copy-Item (Join-Path $tests "Hardening-A4.pdf") $a4JpgPdf

$before = Get-HashString $a4JpgPdf
Invoke-ExpectedSuccess @("--jpg", $a4JpgPdf)
$after = Get-HashString $a4JpgPdf

Assert-True ($before -eq $after) "Original PDF SHA-256 is unchanged after JPG conversion"
Assert-Image (Join-Path $work "A4 JPG.jpg") 2480 3508 "A4 JPG"

Invoke-ExpectedSuccess @("--jpg", $a4JpgPdf)
Assert-Image (Join-Path $work "A4 JPG (2).jpg") 2480 3508 "A4 JPG collision output"

# ------------------------------------------------------------
# 3. Landscape
# ------------------------------------------------------------
Write-Host ""
Write-Host "=== 3. A4 landscape ==="

$landscapePdf = Join-Path $work "Landscape.pdf"
Copy-Item (Join-Path $tests "Hardening-A4-Landscape.pdf") $landscapePdf

Invoke-ExpectedSuccess @("--png", $landscapePdf)
Assert-Image (Join-Path $work "Landscape.png") 3508 2480 "A4 landscape PNG"

# ------------------------------------------------------------
# 4. A3
# ------------------------------------------------------------
Write-Host ""
Write-Host "=== 4. A3 portrait ==="

$a3Pdf = Join-Path $work "A3.pdf"
Copy-Item (Join-Path $tests "Hardening-A3.pdf") $a3Pdf

Invoke-ExpectedSuccess @("--png", $a3Pdf)
Assert-Image (Join-Path $work "A3.png") 3508 4961 "A3 PNG"

# ------------------------------------------------------------
# 5. Unicode filename
# ------------------------------------------------------------
Write-Host ""
Write-Host "=== 5. Unicode / Vietnamese filename ==="

$unicodeName = "Tài liệu thử nghiệm – Việt Nam.pdf"
$unicodePdf = Join-Path $work $unicodeName
Copy-Item (Join-Path $tests $unicodeName) $unicodePdf

Invoke-ExpectedSuccess @("--png", $unicodePdf)
Assert-Exists (Join-Path $work "Tài liệu thử nghiệm – Việt Nam.png") "Unicode output filename is preserved"

# ------------------------------------------------------------
# 6. Multi-page + atomic folder + collision
# ------------------------------------------------------------
Write-Host ""
Write-Host "=== 6. Multi-page output ==="

$multiPdf = Join-Path $work "Multi Document.pdf"
Copy-Item (Join-Path $tests "Hardening-MultiPage.pdf") $multiPdf

Invoke-ExpectedSuccess @("--png", $multiPdf)

$multiFolder = Join-Path $work "Multi Document - PNG"
Assert-Exists $multiFolder "Multi-page PNG final folder exists"

1..3 | ForEach-Object {
    $page = $_.ToString("D3")
    Assert-Image (Join-Path $multiFolder "Multi Document_page_$page.png") 2480 3508 "Multi-page PNG page $page"
}

Invoke-ExpectedSuccess @("--png", $multiPdf)
$multiFolder2 = Join-Path $work "Multi Document - PNG (2)"
Assert-Exists $multiFolder2 "Repeated multi-page conversion creates folder (2)"

# ------------------------------------------------------------
# 7. Multiple PDFs in one invocation
# ------------------------------------------------------------
Write-Host ""
Write-Host "=== 7. Multiple PDFs in one command ==="

$batchA = Join-Path $work "Batch A.pdf"
$batchB = Join-Path $work "Batch B.pdf"
Copy-Item (Join-Path $tests "Hardening-A4.pdf") $batchA
Copy-Item (Join-Path $tests "Hardening-A4.pdf") $batchB

Invoke-ExpectedSuccess @("--jpg", $batchA, $batchB)
Assert-Exists (Join-Path $work "Batch A.jpg") "Batch A output exists"
Assert-Exists (Join-Path $work "Batch B.jpg") "Batch B output exists"

# ------------------------------------------------------------
# 8. Nested path
# ------------------------------------------------------------
Write-Host ""
Write-Host "=== 8. Nested path ==="

$nested = Join-Path $work "Nested Folder 01\Nested Folder 02\Nested Folder 03"
New-Item -ItemType Directory -Force -Path $nested | Out-Null
$nestedPdf = Join-Path $nested "Nested Path Test.pdf"
Copy-Item (Join-Path $tests "Hardening-A4.pdf") $nestedPdf

Invoke-ExpectedSuccess @("--png", $nestedPdf)
Assert-Exists (Join-Path $nested "Nested Path Test.png") "Nested-path conversion succeeds"

# ------------------------------------------------------------
# 9. Corrupt PDF must fail cleanly
# ------------------------------------------------------------
Write-Host ""
Write-Host "=== 9. Corrupt PDF failure ==="

$corrupt = Join-Path $work "Corrupt.pdf"
Copy-Item (Join-Path $tests "Hardening-Corrupt.pdf") $corrupt

Invoke-ExpectedFailure @("--png", $corrupt)
Assert-NotExists (Join-Path $work "Corrupt.png") "Corrupt PDF leaves no final PNG"

# ------------------------------------------------------------
# 10. Password-protected PDF must fail cleanly (v1 behavior)
# ------------------------------------------------------------
Write-Host ""
Write-Host "=== 10. Password-protected PDF failure ==="

$protected = Join-Path $work "Password Protected.pdf"
Copy-Item (Join-Path $tests "Hardening-Password-Protected.pdf") $protected

Invoke-ExpectedFailure @("--png", $protected)
Assert-NotExists (Join-Path $work "Password Protected.png") "Password-protected PDF leaves no final PNG"

# ------------------------------------------------------------
# 11. Non-PDF extension must fail
# ------------------------------------------------------------
Write-Host ""
Write-Host "=== 11. Non-PDF input ==="

$txt = Join-Path $work "Not A PDF.txt"
"WinPebble hardening test" | Set-Content -LiteralPath $txt -Encoding UTF8

Invoke-ExpectedFailure @("--png", $txt)
Assert-NotExists (Join-Path $work "Not A PDF.png") "Non-PDF input creates no output"

# ------------------------------------------------------------
# 12. Cleanup / no background process
# ------------------------------------------------------------
Write-Host ""
Write-Host "=== 12. Cleanup ==="

Assert-NoTempArtifacts

Start-Sleep -Milliseconds 250
$leftoverProcesses = @(Get-Process -Name "WinPebble.PDFToImage" -ErrorAction SilentlyContinue)
Assert-True ($leftoverProcesses.Count -eq 0) "No WinPebble.PDFToImage process remains running"

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host " HARDENING TEST SUITE PASSED" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "Outputs:"
Write-Host "  $work"
