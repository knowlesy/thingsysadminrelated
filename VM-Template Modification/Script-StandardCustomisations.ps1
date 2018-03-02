$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator# Check to see if we are currently running “as Administrator”
if ($myWindowsPrincipal.IsInRole($adminRole))
{
# We are running “as Administrator” – so change the title and background colour to indicate this
$Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + “(Elevated)”
$Host.UI.RawUI.BackgroundColor = “DarkBlue”
clear-host
}
else
{
# We are not running “as Administrator” – so relaunch as administrator# Create a new process object that starts PowerShell
$newProcess = new-object System.Diagnostics.ProcessStartInfo “PowerShell”;# Specify the current script path and name as a parameter
$newProcess.Arguments = $myInvocation.MyCommand.Definition;# Indicate that the process should be elevated
$newProcess.Verb = “runas”;# Start the new process
[System.Diagnostics.Process]::Start($newProcess);# Exit from the current, unelevated, process
exit
}

"This script is running with elevated admin privileges"
" "
"Configuring System Settings..."	
# SYSTEM SETTINGS
	# Disable DEP
	bcdedit /set nx AlwaysOff

"Configuring System Settings..."	
# SYSTEM SETTINGS
	
	# Turn off 8dot3name
	fsutil.exe 8dot3name set C: 1
	fsutil.exe 8dot3name set 1
	
	# Disable NTFS Last Access Timestamps 
	# fsutil.exe behavior set disablelastaccess 1
	
	# Disable Indexing on all drives
	gwmi Win32_Volume -Filter "IndexingEnabled=$true" | swmi -Arguments @{IndexingEnabled=$false} | out-file c:\Technip\CustomizeReport.txt -append
	
	# Change DVD drive letter
	# gwmi Win32_Volume -Filter "DriveType = '5'" | swmi -Arguments @{DriveLetter = 'Z:'} 
	
	# Enable RDP for Admins
	cscript C:\Windows\System32\Scregedit.wsf /ar 0
	cscript C:\Windows\System32\Scregedit.wsf /cs 0
	
	#Disable System Restore on C: and delete all snapshots
	# disable-computerrestore -drive c:\
	# vssadmin delete shadows /All /Quiet
	
	# Disable CEIP
	Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\SQMClient\Windows' CEIPEnable 0
	
	# Set Eventlog Size to 20mb and retention to 30 days
	Limit-EventLog -LogName Application -MaximumSize 20MB -OverflowAction OverwriteOlder -RetentionDays 30
	Limit-EventLog -LogName System -MaximumSize 20MB -OverflowAction OverwriteOlder -RetentionDays 30
	Limit-EventLog -LogName Security -MaximumSize 20MB -OverflowAction OverwriteOlder -RetentionDays 30
	
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

"Configuring Pagefile..."
# PAGEFILE CONFIGURATION - retired, cmd file now handles this

	# Turn off Auto Manage Pagefile Size
	#gwmi Win32_ComputerSystem -EnableAllPrivileges | swmi -Arguments @{AutomaticManagedPagefile=$false}
	
	# Get current paging file on drive C
	#$CurrentPageFile = gwmi -Query "select * from Win32_PageFileSetting where name='c:\\pagefile.sys'" -EnableAllPrivileges
	
	# Delete current paging file on drive C
	#If($CurrentPageFile){$CurrentPageFile.Delete()}
	
	# Create paging file on SWAP drive
	gwmi Win32_PageFileSetting -Arguments @{Name='C:\pagefile.sys'; InitialSize=4096; MaximumSize=4096}
    wmic pagefileset where name="C:\\pagefile.sys" set InitialSize=4096,MaximumSize=4096

"Configuring System Failure Settings..."
# FAILURE SETTINGS
	# Enable Small Memory Dump
	gwmi Win32_OSRecoveryConfiguration -EnableAllPrivileges | swmi -Arguments @{DebugInfoType=1}
	
	# No System Failure Auto-Restart
	gwmi Win32_OSRecoveryConfiguration -EnableAllPrivileges | swmi -Arguments @{AutoReboot=$false}
	
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
	

"Enabling Administration Features..."
#Configures the Admin features
Install-WindowsFeature –ConfigurationFilePath c:\Support\Scripts\Generic\DeploymentConfigTemplate.xml

#Alternative Method for feature install
#$ServerFeatures = Import-Clixml c:\Support\Scripts\Generic\DeploymentConfigTemplate.xml
#foreach ($feature in $ServerFeatures) {Install-WindowsFeature -Name $feature.name}

"Disabling Scheduled Tasks..."	
# DISABLE SCHEDULED TASKS

Disable-ScheduledTask -TaskName "microsoft\windows\Application Experience\AitAgent"
Disable-ScheduledTask -TaskName "microsoft\windows\Application Experience\ProgramDataUpdater"
# Disable-ScheduledTask -TaskName "microsoft\windows\Application Experience\StartupAppTask"
Disable-ScheduledTask -TaskName "microsoft\windows\Autochk\Proxy"
Disable-ScheduledTask -TaskName "microsoft\windows\defrag\ScheduledDefrag"
# Disable-ScheduledTask -TaskName "microsoft\windows\Customer Experience Improvement Program\BthSQM"
Disable-ScheduledTask -TaskName "microsoft\windows\Customer Experience Improvement Program\Consolidator"
Disable-ScheduledTask -TaskName "microsoft\windows\Customer Experience Improvement Program\KernelCeipTask"
# Disable-ScheduledTask -TaskName "microsoft\windows\Customer Experience Improvement Program\Uploader"
Disable-ScheduledTask -TaskName "microsoft\windows\Customer Experience Improvement Program\UsbCeip"
# Disable-ScheduledTask -TaskName "microsoft\windows\Diagnosis\Scheduled"
# Disable-ScheduledTask -TaskName "microsoft\windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
Disable-ScheduledTask -TaskName "microsoft\windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticResolver"
# Disable-ScheduledTask -TaskName "microsoft\windows\Maintenance\WinSAT"
# Disable-ScheduledTask -TaskName "microsoft\windows\MobilePC\HotStart"
# Disable-ScheduledTask -TaskName "microsoft\windows\Power Efficiency Diagnostic\AnalyzeSystem"
# Disable-ScheduledTask -TaskName "microsoft\windows\RAC\RacTask"
Disable-ScheduledTask -TaskName "microsoft\windows\Ras\MobilityManager"
Disable-ScheduledTask -TaskName "microsoft\windows\Registry\RegIdleBackup"
# Disable-ScheduledTask -TaskName "microsoft\windows\Shell\FamilySafetyMonitor"
# Disable-ScheduledTask -TaskName "microsoft\windows\Shell\FamilySafetyRefresh"
# Disable-ScheduledTask -TaskName "microsoft\windows\SideShow\AutoWake"
# Disable-ScheduledTask -TaskName "microsoft\windows\SideShow\GadgetManager"
# Disable-ScheduledTask -TaskName "microsoft\windows\SideShow\SessionAgent"
# Disable-ScheduledTask -TaskName "microsoft\windows\SideShow\SystemDataProviders"
Disable-ScheduledTask -TaskName "microsoft\windows\UPnP\UPnPHostConfig"
Disable-ScheduledTask -TaskName "microsoft\windows\WDI\ResolutionHost"
Disable-ScheduledTask -TaskName "microsoft\windows\Windows Filtering Platform\BfeOnServiceStartTypeChange"
# Disable-ScheduledTask -TaskName "microsoft\windows\Windows Media Sharing\UpdateLibrary"
# Disable-ScheduledTask -TaskName "microsoft\windows\WindowsBackup\ConfigNotification"
# Disable-ScheduledTask -TaskName "WinSAT"
	