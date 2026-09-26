#ifndef StageDir
  #error StageDir must be supplied by Build-Installer.ps1
#endif

#ifndef OutputDir
  #error OutputDir must be supplied by Build-Installer.ps1
#endif

#define AppName "WinPebble PDF to Image"
#define AppVersion "0.9.0-dev"
#define AppPublisher "WinPebble"
#define AppURL "https://winpebble.com"
#define AppId "{{8C47BB15-16F7-4F5B-9B36-14B32762C4CB}"

[Setup]
AppId={#AppId}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}
AppUpdatesURL={#AppURL}
VersionInfoCompany={#AppPublisher}
VersionInfoDescription=WinPebble PDF to Image development installer
VersionInfoProductName={#AppName}
VersionInfoProductVersion=0.9.0.0
DefaultDirName={autopf}\WinPebble\PDF to Image
DisableProgramGroupPage=yes
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0.19041
WizardStyle=modern
Compression=lzma2/max
SolidCompression=yes
OutputDir={#OutputDir}
OutputBaseFilename=WinPebble-PDF-to-Image-Setup-Dev
SetupIconFile={#StageDir}\WinPebble-Setup-Dev.ico
UninstallDisplayIcon={app}\WinPebble.PDFToImage.exe
UninstallDisplayName={#AppName}
CreateUninstallRegKey=yes
CloseApplications=yes
RestartApplications=no
ChangesEnvironment=no
SetupMutex=WinPebblePDFToImageSetupMutex
Uninstallable=yes

[Files]
Source: "{#StageDir}\WinPebble.PDFToImage.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#StageDir}\WinPebble.PDFToImage.Shell.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#StageDir}\WinPebble.PDFToImage.Dev.identity.msix"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#StageDir}\WinPebble-PDFToImage-Dev.cer"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#StageDir}\Register-Installed-Package.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#StageDir}\Unregister-Installed-Package.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#StageDir}\Assets\*"; DestDir: "{app}\Assets"; Flags: ignoreversion recursesubdirs createallsubdirs

[Run]
Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; \
    Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\Register-Installed-Package.ps1"""; \
    StatusMsg: "Registering WinPebble with Windows Explorer..."; \
    Flags: runhidden waituntilterminated

[UninstallRun]
Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; \
    Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\Unregister-Installed-Package.ps1"""; \
    Flags: runhidden waituntilterminated; RunOnceId: "WinPebblePDFToImageUnregister"

[Code]
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    Log('WinPebble PDF to Image installation completed.');
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
  begin
    Log('WinPebble PDF to Image uninstall started.');
  end;
end;
