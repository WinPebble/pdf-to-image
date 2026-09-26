$ErrorActionPreference = "Stop"

$appDir = $PSScriptRoot
$packageName = "WinPebble.PDFToImage.Dev"
$msix = Join-Path $appDir "WinPebble.PDFToImage.Dev.identity.msix"
$cer = Join-Path $appDir "WinPebble-PDFToImage-Dev.cer"
$core = Join-Path $appDir "WinPebble.PDFToImage.exe"
$shell = Join-Path $appDir "WinPebble.PDFToImage.Shell.dll"

foreach ($required in @($msix, $cer, $core, $shell)) {
    if (-not (Test-Path -LiteralPath $required)) {
        throw "Required WinPebble install file is missing: $required"
    }
}

# Development only: trust the exact certificate shipped by this dev installer.
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
    $existingCert = $store.Certificates |
        Where-Object { $_.Thumbprint -eq $thumbprint } |
        Select-Object -First 1

    if (-not $existingCert) {
        $store.Add($certObject)
    }
}
finally {
    $store.Close()
}

# Remove an older development registration for the current user before re-registering.
$existingPackage = Get-AppxPackage -Name $packageName -ErrorAction SilentlyContinue
if ($existingPackage) {
    $existingPackage | Remove-AppxPackage -ErrorAction Stop
}

Add-AppxPackage `
    -Path $msix `
    -ExternalLocation $appDir `
    -ErrorAction Stop

$registered = Get-AppxPackage -Name $packageName -ErrorAction Stop

Write-Output "Registered: $($registered.PackageFullName)"
Write-Output "ExternalLocation: $appDir"
