$ErrorActionPreference = "Continue"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$cer = Join-Path $root "artifacts\msix-dev\cert\WinPebble-PDFToImage-Full-MSIX-Dev.cer"

Write-Host "WinPebble PDF to Image - Full MSIX Dev Uninstall"
Write-Host ""

$principal = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "Run this script from PowerShell AS ADMINISTRATOR."
}

$existing = Get-AppxPackage -Name "WinPebble.PDFToImage.StoreDev" -ErrorAction SilentlyContinue
if ($existing) {
    $existing | Remove-AppxPackage -ErrorAction SilentlyContinue
    Write-Host "PASS: Full MSIX dev package removed" -ForegroundColor Green
} else {
    Write-Host "INFO: Full MSIX dev package was not installed"
}

if (Test-Path -LiteralPath $cer) {
    try {
        $certObject = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($cer)
        $thumbprint = $certObject.Thumbprint
        $store = New-Object System.Security.Cryptography.X509Certificates.X509Store(
            "TrustedPeople",
            [System.Security.Cryptography.X509Certificates.StoreLocation]::LocalMachine
        )
        $store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
        try {
            $matches = $store.Certificates | Where-Object { $_.Thumbprint -eq $thumbprint }
            foreach ($cert in $matches) { $store.Remove($cert) }
        }
        finally {
            $store.Close()
        }
        Write-Host "PASS: Full MSIX dev certificate removed" -ForegroundColor Green
    }
    catch {
        Write-Host "Certificate cleanup warning: $($_.Exception.Message)"
    }
}

Write-Host ""
Write-Host "FULL MSIX DEV UNINSTALL COMPLETE" -ForegroundColor Green
