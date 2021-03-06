# Configure Remote Settings
Net LocalGroup "Remote Management Users" /Add Adminz
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force
Get-NetFirewallRule *WINRM* | Set-NetFirewallRule -Profile Any -RemoteAddress Any
Get-NetFirewallRule *RemoteDesktop* | Set-NetFirewallRule -Profile Any -RemoteAddress Any
# Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private
Enable-PSRemoting -SkipNetworkProfileCheck -Force
Set-WSManQuickConfig -Force

# Configure Lab Environment
New-Item -Path c:\labfiles.55264a -Type Directory -Force
New-Item -Path C:\Temp -Type Directory -Force
New-Item -Path C:\ConfigAZVM -Type Directory -Force
$SetupFile = "c:\labfiles.55264a\55264A-ENU_SetupFiles.zip"
$LabfilesFolder = "c:\labfiles.55264a\"
[Environment]::SetEnvironmentVariable("LABFILESFOLDER", $LabfilesFolder, "Machine")
[Environment]::SetEnvironmentVariable("WORKFOLDER", $LabfilesFolder, "Machine")
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Expand-Archive -LiteralPath $SetupFile -DestinationPath $LabfilesFolder -Force
Get-ChildItem -Recurse $LabfilesFolder | Unblock-File
$SQLServerConfig = $LabfilesFolder + "SQLServerConfig.sql"
(Get-Content $SQLServerConfig) -Replace "vm55264srv",$env:COMPUTERNAME | Out-File -FilePath $SQLServerConfig
$RunCMD = $LabfilesFolder + "run.cmd"
(Get-Content $RunCMD) -Replace "vm55264srv",$env:COMPUTERNAME | Out-File -FilePath $RunCMD -Encoding ASCII
Enable-NetFirewallRule -DisplayName "File and Printer Sharing*"
#   Get-DNSClient -InterfaceAlias Ethernet* | Set-DNSClient -ConnectionSpecificSuffix "contoso.com"
#   Get-DNSClient -InterfaceAlias Ethernet* | Set-DNSClientServerAddress -ServerAddresses ("192.168.10.100","192.168.20.100")
reg import c:\labfiles.55264a\LocalLogonAdminz.reg
REG ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce /d c:\labfiles.55264a\run.cmd /f
shutdown /r /t 15
