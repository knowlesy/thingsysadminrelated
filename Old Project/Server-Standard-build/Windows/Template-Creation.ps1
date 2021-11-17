#Taken from a variety of sources over time which arnt linked apologies for this 
$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal = new-object System.Security.Principal.WindowsPrincipal($myWindowsID)# Get the security principal for the Administrator role
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator# Check to see if we are currently running “as Administrator”
if ($myWindowsPrincipal.IsInRole($adminRole)) {
    # We are running “as Administrator” – so change the title and background colour to indicate this
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + “(Elevated)”
    $Host.UI.RawUI.BackgroundColor = “DarkBlue”
    clear-host
}
else {
    # We are not running “as Administrator” – so relaunch as administrator# Create a new process object that starts PowerShell
    $newProcess = new-object System.Diagnostics.ProcessStartInfo “PowerShell”; # Specify the current script path and name as a parameter
    $newProcess.Arguments = $myInvocation.MyCommand.Definition; # Indicate that the process should be elevated
    $newProcess.Verb = “runas”; # Start the new process
    [System.Diagnostics.Process]::Start($newProcess); # Exit from the current, unelevated, process
    exit
}

"This script is running with elevated admin privileges"
" "
"Creating Default Folders"
mkdir C:\Support
mkdir C:\Support\Build-Files\Sysinternals
mkdir C:\Support\Shortcuts
mkdir C:\Support\Scripts
mkdir c:\Logs
mkdir c:\Temp


"Get Sysinternals"

# Download the new zip file of tools
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$NewPath = "https://live.sysinternals.com/Files/SysinternalsSuite.zip"
$OldPath = "C:\Temp\SysinternalsSuite.zip"
$BaseDir = "C:\Support\Build-Files\Sysinternals"
Invoke-WebRequest -UseBasicParsing -Uri $NewPath -OutFile $OldPath -Verbose
Expand-Archive -LiteralPath $OldPath -DestinationPath $BaseDir -Force

"Create BGINFO"
#Remember to customise your bginfo file
"C:\Support\Build-Files\Sysinternals\Bginfo64.exe C:\Support\Build-Files\Sysinternals\BG-Default.bgi /timer:0 /nolicprompt /silent" | out-file C:\Support\Scripts\bgi.cmd

"Make Shortcuts"
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\Users\Public\Desktop\Logoff.lnk")
$Shortcut.TargetPath = "C:\Windows\System32\logoff.exe"
$Shortcut.Save()

$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\BG.lnk")
$Shortcut.TargetPath = "C:\Support\Scripts\bgi.cmd"
$Shortcut.Save()


"Configuring System Settings..."
# SYSTEM SETTINGS
# Disable DEP
bcdedit /set nx AlwaysOff

"Configuring System Settings..."
# SYSTEM SETTINGS

#SET IE homepage
$path = 'HKCU:\Software\Microsoft\Internet Explorer\Main\'
$name = 'start page'
$value = 'about:blank'
Set-Itemproperty -Path $path -Name $name -Value $value


# Turn off 8dot3name
fsutil.exe 8dot3name set C: 1
fsutil.exe 8dot3name set 1

# Disable NTFS Last Access Timestamps
# fsutil.exe behavior set disablelastaccess 1

# Disable Indexing on all drives
gwmi Win32_Volume -Filter "IndexingEnabled=$true" | swmi -Arguments @{IndexingEnabled = $false}

# Change DVD drive letter
gwmi Win32_Volume -Filter "DriveType = '5'" | swmi -Arguments @{DriveLetter = 'Z:'}

# Enable RDP for Admins
cscript C:\Windows\System32\Scregedit.wsf /ar 0
cscript C:\Windows\System32\Scregedit.wsf /cs 0

#Disable System Restore on C: and delete all snapshots
#disable-computerrestore -drive c:\ # not supported on 2016
vssadmin delete shadows /All /Quiet

# Disable CEIP
Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\SQMClient\Windows' CEIPEnable 0

# Set Eventlog Size to 30mb and retention to 30 days
Limit-EventLog -LogName Application -MaximumSize 30MB -OverflowAction OverwriteOlder -RetentionDays 30
Limit-EventLog -LogName System -MaximumSize 30MB -OverflowAction OverwriteOlder -RetentionDays 30
Limit-EventLog -LogName Security -MaximumSize 30MB -OverflowAction OverwriteOlder -RetentionDays 30

# Create custom Event Log
New-EventLog –LogName Application –Source “Scripts”

# Disable Computer Password Change
Set-ItemProperty -Path HKLM:SYSTEM\CurrentControlSet\Services\Netlogon\Parameters -Name DisablePasswordChange -Type DWORD -Value 1

# Disable UAC
Set-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA  -Type DWORD -Value 0

# Extend Disk Timeouts
Set-ItemProperty -Path HKLM:SYSTEM\CurrentControlSet\services\Disk -Name TimeOutValue -Value 190

# Increase Service Startup Timeouts
Set-ItemProperty -Path HKLM:SYSTEM\CurrentControlSet\Control -Name ServicesPipeTimeout -Type DWord -Value 180000

# Optimize Processor Resource Scheduling
Set-ItemProperty -Path HKLM:SYSTEM\CurrentControlSet\Control\PriorityControl -Name Win32PrioritySeparation -Value 18

# Disable TCP/IP / Large Send Offload
Set-ItemProperty -Path HKLM:SYSTEM\CurrentControlSet\Services\Tcpip\Parameters -Name EnableTCPChimney -Type DWORD -Value 0


"Configuring Power Settings..."
# POWER SETTINGS

# Set Power plan to High performance
powercfg.exe /SETACTIVE 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

# Disable the hibernate feature
powercfg.exe /HIBERNATE off

# Disable Monitor Timeout
powercfg.exe -change -monitor-timeout-ac 0


#"Configuring System Failure Settings..."
# FAILURE SETTINGS
# Enable Small Memory Dump
#gwmi Win32_OSRecoveryConfiguration -EnableAllPrivileges | swmi -Arguments @{DebugInfoType=1}

# No System Failure Auto-Restart
#gwmi Win32_OSRecoveryConfiguration -EnableAllPrivileges | swmi -Arguments @{AutoReboot=$false}

# System Failure Auto-Restart
gwmi Win32_OSRecoveryConfiguration -EnableAllPrivileges | swmi -Arguments @{AutoReboot=$true}

# Move Memory Dump File
#Set-ItemProperty -Path HKLM:SYSTEM\CurrentControlSet\Control\CrashControl -Name 'DedicatedDumpFile' -Value 'X:\MEMORY.DMP'
#gwmi Win32_OSRecoveryConfiguration -EnableAllPrivileges | swmi -Arguments @{DebugFilePath='X:\MEMORY.DMP'}

"Configuring Windows Firewall..."
# FIREWALL CONFIGURATION

# Set Firewall ALL profiles off
netsh advfirewall set allprofiles state off

# Allow MMC Remote (in case profiles get re-enabled)
Enable-NetFirewallRule -DisplayGroup 'Windows Remote Management'

# Allow ICMP Traffic
netsh firewall set icmpsetting 8

"Disabling Scheduled Tasks..."
# DISABLE SCHEDULED TASKS
Disable-ScheduledTask -TaskName "microsoft\windows\Application Experience\ProgramDataUpdater"
Disable-ScheduledTask -TaskName "microsoft\windows\UPnP\UPnPHostConfig"
Disable-ScheduledTask -TaskName "microsoft\windows\WDI\ResolutionHost"
Disable-ScheduledTask -TaskName "microsoft\windows\Windows Filtering Platform\BfeOnServiceStartTypeChange"
Disable-ScheduledTask -TaskName "microsoft\windows\Ras\MobilityManager"
Disable-ScheduledTask -TaskName "microsoft\windows\Registry\RegIdleBackup"
Disable-ScheduledTask -TaskName "microsoft\windows\Autochk\Proxy"
Disable-ScheduledTask -TaskName "microsoft\windows\defrag\ScheduledDefrag"
Disable-ScheduledTask -TaskName "microsoft\windows\Customer Experience Improvement Program\Consolidator"
Disable-ScheduledTask -TaskName "microsoft\windows\Customer Experience Improvement Program\KernelCeipTask"
Disable-ScheduledTask -TaskName "microsoft\windows\Customer Experience Improvement Program\UsbCeip"
Disable-ScheduledTask -TaskName "microsoft\windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticResolver"
# Disable-ScheduledTask -TaskName "microsoft\windows\Customer Experience Improvement Program\BthSQM"
# Disable-ScheduledTask -TaskName "microsoft\windows\Customer Experience Improvement Program\Uploader"
# Disable-ScheduledTask -TaskName "microsoft\windows\Diagnosis\Scheduled"
# Disable-ScheduledTask -TaskName "microsoft\windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
# Disable-ScheduledTask -TaskName "microsoft\windows\Maintenance\WinSAT"
# Disable-ScheduledTask -TaskName "microsoft\windows\MobilePC\HotStart"
# Disable-ScheduledTask -TaskName "microsoft\windows\Power Efficiency Diagnostic\AnalyzeSystem"
# Disable-ScheduledTask -TaskName "microsoft\windows\RAC\RacTask"
# Disable-ScheduledTask -TaskName "microsoft\windows\Application Experience\StartupAppTask"
# Disable-ScheduledTask -TaskName "microsoft\windows\Shell\FamilySafetyMonitor"
# Disable-ScheduledTask -TaskName "microsoft\windows\Shell\FamilySafetyRefresh"
# Disable-ScheduledTask -TaskName "microsoft\windows\SideShow\AutoWake"
# Disable-ScheduledTask -TaskName "microsoft\windows\SideShow\GadgetManager"
# Disable-ScheduledTask -TaskName "microsoft\windows\SideShow\SessionAgent"
# Disable-ScheduledTask -TaskName "microsoft\windows\SideShow\SystemDataProviders"
# Disable-ScheduledTask -TaskName "microsoft\windows\Windows Media Sharing\UpdateLibrary"
# Disable-ScheduledTask -TaskName "microsoft\windows\WindowsBackup\ConfigNotification"
# Disable-ScheduledTask -TaskName "WinSAT"

"dotNet Optimisation"
%windir%\microsoft.net\framework\v4.0.30319\ngen.exe update /force /queue
%windir%\microsoft.net\framework64\v4.0.30319\ngen.exe update /force /queue

"Clean event logs"
Clear-eventlog -log application, system, security

"Empty Recycle Bin"
Clear-RecycleBin -Confirm:$false #ps 5.1 and above only 

"Running Disk Cleanup"
CLEANMGR /lowdisk

"Performing Defrag"
defrag /c /o

"Zero'ing Disk"
C:\Support\Build-Files\Sysinternals\sdelete64.exe -z c:
