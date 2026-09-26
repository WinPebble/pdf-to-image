$ErrorActionPreference = "Continue"

$appDir = $PSScriptRoot
$packageName = "WinPebble.PDFToImage.Dev"
$cer = Join-Path $appDir "WinPebble-PDFToImage-Dev.cer"

# Remove package identity/context-menu registration for the current user.
$existingPackage = Get-AppxPackage -Name $packageName -ErrorAction SilentlyContinue
if ($existingPackage) {
    $existingPackage | Remove-AppxPackage -ErrorAction SilentlyContinue
}

# Development only: remove only the exact certificate included with this installer.
if (Test-Path -LiteralPath $cer) {
    try {
        $certObject = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($cer)
        $thumbprint = $certObject.Thumbprint

        $store = New-Object System.Security.Cryptography.X509Certificates.X509Store(
            "TrustedPeople",
            [System.Security.Cryptography.X509Certificates.StoreLocation]::LocalMachine
        )

        $store.Open(
            [System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite
        )

        try {
            $matches = $store.Certificates |
                Where-Object { $_.Thumbprint -eq $thumbprint }

            foreach ($cert in $matches) {
                $store.Remove($cert)
            }
        }
        finally {
            $store.Close()
        }
    }
    catch {
        # Do not block uninstall if certificate cleanup fails.
        Write-Output "Certificate cleanup warning: $($_.Exception.Message)"
    }
}

exit 0
