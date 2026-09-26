$ErrorActionPreference = "Stop"

Write-Host "Restarting Windows Explorer..."
Write-Host "Open File Explorer windows will close and reopen."

Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Milliseconds 800
Start-Process explorer.exe

Write-Host "Explorer restarted." -ForegroundColor Green
