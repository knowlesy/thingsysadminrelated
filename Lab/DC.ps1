$domainname = 'testlab.intra'
$domainnetbiosname = 'testlab'
$sethostanme = '2012-DC'
$SafeModeAdministratorPasswordText = ‘Password12345’
$staticip = '192.168.1.2'
$subnetmaskprefix = '24'
$ipgateway = '192.168.1.1'
$dns = '127.0.0.1, 192.168.1.2'
$pagefile = '2048'

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

    # Disable Server manager at startup
    New-ItemProperty -Path HKCU:\Software\Microsoft\ServerManager -Name DoNotOpenServerManagerAtLogon -PropertyType DWORD -Value "0x1" –Force
    # Disable DEP
        bcdedit /set nx AlwaysOff
    # Disable Indexing on all drives
        gwmi Win32_Volume -Filter "IndexingEnabled=$true" | swmi -Arguments @{IndexingEnabled=$false} | out-file c:\Technip\CustomizeReport.txt -append
    # Enable RDP for Admins
	    cscript C:\Windows\System32\Scregedit.wsf /ar 0
        cscript C:\Windows\System32\Scregedit.wsf /cs 0
    # Disable CEIP
	    Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\SQMClient\Windows' CEIPEnable 0
    # Set Eventlog Size to 20mb and retention to 30 days
	    Limit-EventLog -LogName Application -MaximumSize 20MB -OverflowAction OverwriteOlder -RetentionDays 30
	    Limit-EventLog -LogName System -MaximumSize 20MB -OverflowAction OverwriteOlder -RetentionDays 30
	    Limit-EventLog -LogName Security -MaximumSize 20MB -OverflowAction OverwriteOlder -RetentionDays 30
    # Disable UAC
        Set-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA  -Type DWORD -Value 0
	
    # Extend Disk Timeouts
        Set-ItemProperty -Path HKLM:SYSTEM\CurrentControlSet\services\Disk -Name TimeOutValue -Value 190

    # Increase Service Startup Timeouts 
        Set-ItemProperty -Path HKLM:SYSTEM\CurrentControlSet\Control -Name ServicesPipeTimeout -Type DWord -Value 180000

    # Optimize Processor Resource Scheduling 
        Set-ItemProperty -Path HKLM:SYSTEM\CurrentControlSet\Control\PriorityControl -Name Win32PrioritySeparation -Value 18

    # Disable TCP/IP / Large Send Offload 
     Set-ItemProperty -Path HKLM:SYSTEM\CurrentC

"Configuring Power Settings..."
    # POWER SETTINGS
    
        # Set Power plan to High performance
        powercfg.exe /SETACTIVE 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    
        # Disable the hibernate feature
        powercfg.exe /HIBERNATE off
        
        # Disable Monitor Timeout
        powercfg.exe -change -monitor-timeout-ac 0

"Configuring Pagefile..."
    #Config Page file
    #gwmi Win32_PageFileSetting -Arguments @{Name='C:\pagefile.sys'; InitialSize=$pagefile; MaximumSize=$pagefile}
    wmic pagefileset where name="C:\\pagefile.sys" set InitialSize=$pagefile,MaximumSize=$pagefile

"Configuring System Failure Settings..."
    # FAILURE SETTINGS
        # Enable Small Memory Dump
        gwmi Win32_OSRecoveryConfiguration -EnableAllPrivileges | swmi -Arguments @{DebugInfoType=1}
        
        # No System Failure Auto-Restart
        gwmi Win32_OSRecoveryConfiguration -EnableAllPrivileges | swmi -Arguments @{AutoReboot=$false}

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
            # Disable-ScheduledTask -TaskName "microsoft\windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticResolver"
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
            

"Enabling RSAT"
Add-windowsfeature RSAT
install-windowsfeature AD-Domain-Services
Import-Module ADDSDeployment

#Set Name
"Setting Server Name"
Rename-computer -newname $sethostanme -Force

"Configuring Network Config"
#Set network config
New-NetIPAddress –InterfaceAlias “Ethernet” –IPAddress “192.168.1.2” –PrefixLength 24 -DefaultGateway 192.168.1.1
Set-DnsClientServerAddress -InterfaceAlias “Ethernet” -ServerAddresses 127.0.0.1, 192.168.1.2
set-dnsclient -InterfaceAlias “Ethernet” -ConnectionSpecificSuffix $domainname  -RegisterThisConnectionsAddress $true
Restart-netadapter -name ethernet

#install AD
"Installing AD"
$SafeModeAdministratorPassword = ConvertTo-SecureString -AsPlainText $SafeModeAdministratorPasswordText -Force
Install-ADDSForest -CreateDNSDelegation:$False -DatabasePath “c:\Windows\NTDS” -DomainMode ‘Win2012’ -DomainName $domainname -DomainNetbiosName $domainnetbiosname -ForestMode ‘Win2012’ -InstallDNS:$true -LogPath “C:\Windows\NTDS” -NoRebootOnCompletion:$false -Sysvolpath “C:\Windows\SYSVOL” -Force:$true -SafeModeAdministratorPassword $SafeModeAdministratorPassword
