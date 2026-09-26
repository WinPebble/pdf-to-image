Unicode true
ManifestDPIAware true
RequestExecutionLevel admin

!include "LogicLib.nsh"

!ifndef StageDir
  !error "StageDir must be supplied by Build-Installer.ps1"
!endif

!ifndef OutputDir
  !error "OutputDir must be supplied by Build-Installer.ps1"
!endif

!define APP_NAME "WinPebble PDF to Image"
!define APP_VERSION "0.9.0-beta"
!define APP_VERSION_NUM "0.9.0.0"
!define APP_PUBLISHER "WinPebble"
!define APP_URL "https://winpebble.com"
!define APP_DIR "$PROGRAMFILES64\WinPebble\PDF to Image"
!define UNINSTALL_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\WinPebble PDF to Image"

Name "${APP_NAME} ${APP_VERSION}"
Caption "${APP_NAME} ${APP_VERSION}"
OutFile "${OutputDir}\WinPebble-PDF-to-Image-Setup-Beta-Dev.exe"
InstallDir "${APP_DIR}"
InstallDirRegKey HKLM "${UNINSTALL_KEY}" "InstallLocation"
Icon "${StageDir}\WinPebble-Setup-Dev.ico"
UninstallIcon "${StageDir}\WinPebble-Setup-Dev.ico"

; Use only NSIS's zlib compressor for a straightforward OSI-approved
; installer-runtime license story for the SignPath Foundation path.
SetCompressor /SOLID zlib
SetDatablockOptimize on
CRCCheck on
AutoCloseWindow false
ShowInstDetails show
ShowUninstDetails show

VIProductVersion "${APP_VERSION_NUM}"
VIAddVersionKey /LANG=1033 "ProductName" "${APP_NAME}"
VIAddVersionKey /LANG=1033 "ProductVersion" "${APP_VERSION}"
VIAddVersionKey /LANG=1033 "CompanyName" "${APP_PUBLISHER}"
VIAddVersionKey /LANG=1033 "FileDescription" "WinPebble PDF to Image installer"
VIAddVersionKey /LANG=1033 "FileVersion" "${APP_VERSION_NUM}"
VIAddVersionKey /LANG=1033 "LegalCopyright" "Copyright (c) 2026 WinPebble"

Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

Section "Install"
  SetRegView 64
  SetShellVarContext all

  SetOutPath "$INSTDIR"
  File "${StageDir}\WinPebble.PDFToImage.exe"
  File "${StageDir}\WinPebble.PDFToImage.Shell.dll"
  File "${StageDir}\WinPebble.PDFToImage.Dev.identity.msix"
  File "${StageDir}\WinPebble-PDFToImage-Dev.cer"
  File "${StageDir}\Register-Installed-Package.ps1"
  File "${StageDir}\Unregister-Installed-Package.ps1"
  File "${StageDir}\WinPebble-Setup-Dev.ico"

  SetOutPath "$INSTDIR\Assets"
  File /r "${StageDir}\Assets\*.*"

  ; Development only: register the sparse identity package and trust the exact
  ; local development certificate. Public release will use production signing.
  DetailPrint "Registering WinPebble PDF to Image with Windows Explorer..."
  ExecWait '"$SYSDIR\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "$INSTDIR\Register-Installed-Package.ps1"' $0
  ${If} $0 != 0
    MessageBox MB_ICONSTOP|MB_OK "Windows Explorer registration failed (exit code $0). Installation will stop."
    Abort
  ${EndIf}

  WriteUninstaller "$INSTDIR\Uninstall.exe"

  WriteRegStr HKLM "${UNINSTALL_KEY}" "DisplayName" "${APP_NAME}"
  WriteRegStr HKLM "${UNINSTALL_KEY}" "DisplayVersion" "${APP_VERSION}"
  WriteRegStr HKLM "${UNINSTALL_KEY}" "Publisher" "${APP_PUBLISHER}"
  WriteRegStr HKLM "${UNINSTALL_KEY}" "URLInfoAbout" "${APP_URL}"
  WriteRegStr HKLM "${UNINSTALL_KEY}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKLM "${UNINSTALL_KEY}" "DisplayIcon" "$INSTDIR\WinPebble.PDFToImage.exe"
  WriteRegStr HKLM "${UNINSTALL_KEY}" "UninstallString" '"$INSTDIR\Uninstall.exe"'
  WriteRegStr HKLM "${UNINSTALL_KEY}" "QuietUninstallString" '"$INSTDIR\Uninstall.exe" /S'
  WriteRegDWORD HKLM "${UNINSTALL_KEY}" "NoModify" 1
  WriteRegDWORD HKLM "${UNINSTALL_KEY}" "NoRepair" 1
SectionEnd

Section "Uninstall"
  SetRegView 64
  SetShellVarContext all

  DetailPrint "Removing WinPebble PDF to Image Explorer integration..."
  ExecWait '"$SYSDIR\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "$INSTDIR\Unregister-Installed-Package.ps1"' $0

  DeleteRegKey HKLM "${UNINSTALL_KEY}"

  Delete "$INSTDIR\WinPebble.PDFToImage.exe"
  Delete "$INSTDIR\WinPebble.PDFToImage.Shell.dll"
  Delete "$INSTDIR\WinPebble.PDFToImage.Dev.identity.msix"
  Delete "$INSTDIR\WinPebble-PDFToImage-Dev.cer"
  Delete "$INSTDIR\Register-Installed-Package.ps1"
  Delete "$INSTDIR\Unregister-Installed-Package.ps1"
  Delete "$INSTDIR\WinPebble-Setup-Dev.ico"

  RMDir /r "$INSTDIR\Assets"

  ; NSIS runs uninstall logic from a temporary copy, so the original
  ; uninstaller in the install directory can be deleted explicitly.
  Delete "$INSTDIR\Uninstall.exe"

  RMDir "$INSTDIR"
  RMDir "$PROGRAMFILES64\WinPebble"
SectionEnd
