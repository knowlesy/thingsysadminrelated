$domainname = 'testlab.intra'
$domainnetbiosname = 'testlab'
$sethostanme = '2012-DC'
$SafeModeAdministratorPasswordText = ‘Password12345’
$staticip = '192.168.1.2'
$subnetmaskprefix = '24'
$ipgateway = '192.168.1.1'
$dns1 = '127.0.0.1'
$dns2 = '192.168.1.2'
$pagefile = '2048'
$dhcpscope = '192.168.1.0'
$dhcpstart = '192.168.1.100'
$dhcpend = '192.168.1.200'
$dhcpsnm = '255.255.255.0'
$userpw = ConvertTo-SecureString “Password1234” -AsPlainText -Force

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

    # Create Support Folder(s)
    mkdir c:\Support
    mkdir c:\Support\Config
    mkdir c:\Support\Scripts
    mkdir c:\Support\BuildFiles

    #download sysinternals
    #https://gallery.technet.microsoft.com/scriptcenter/Collect-a-Yes-or-No-cd8d51ff
    Write-host "Would you like to download sysinternals (Default is No)" -ForegroundColor Yellow 
    $Readhost = Read-Host " ( y / n ) " 
    Switch ($ReadHost) 
     { 
         #https://gallery.technet.microsoft.com/scriptcenter/a6b10a18-c4e4-46cc-b710-4bd7fa606f95
       Y {Write-host "Yes, Downloadloading"; (New-Object Net.WebClient).DownloadFile('https://download.sysinternals.com/files/SysinternalsSuite.zip','c:\Support\BuildFiles\SysinternalsSuite.zip');(new-object -com shell.application).namespace('c:\Support\BuildFiles').CopyHere((new-object -com shell.application).namespace('c:\Support\BuildFiles\SysinternalsSuite.zip').Items(),16)} 
       N {Write-Host "Not downloading"; } 
       Default {Write-Host "Default, Skip"; } 
     } 
    

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
            Disable-ScheduledTask -TaskName "microsoft\windows\Autochk\Proxy"
            Disable-ScheduledTask -TaskName "microsoft\windows\defrag\ScheduledDefrag"
            Disable-ScheduledTask -TaskName "microsoft\windows\Customer Experience Improvement Program\Consolidator"
            Disable-ScheduledTask -TaskName "microsoft\windows\Customer Experience Improvement Program\KernelCeipTask"
            Disable-ScheduledTask -TaskName "microsoft\windows\Customer Experience Improvement Program\UsbCeip"
            Disable-ScheduledTask -TaskName "microsoft\windows\Ras\MobilityManager"
            Disable-ScheduledTask -TaskName "microsoft\windows\Registry\RegIdleBackup"
            Disable-ScheduledTask -TaskName "microsoft\windows\UPnP\UPnPHostConfig"
            Disable-ScheduledTask -TaskName "microsoft\windows\WDI\ResolutionHost"
            Disable-ScheduledTask -TaskName "microsoft\windows\Windows Filtering Platform\BfeOnServiceStartTypeChange"

            

"Enabling RSAT"
Add-windowsfeature RSAT
install-windowsfeature AD-Domain-Services
Import-Module ADDSDeployment

#Set Name
"Setting Server Name"
Rename-computer -newname $sethostanme -Force

"Configuring Network Config"
#Set network config
New-NetIPAddress –InterfaceAlias “Ethernet” –IPAddress $staticip –PrefixLength $subnetmaskprefix -DefaultGateway $ipgateway
Set-DnsClientServerAddress -InterfaceAlias “Ethernet” -ServerAddresses $dns1, $dns2
set-dnsclient -InterfaceAlias “Ethernet” -ConnectionSpecificSuffix $domainname  -RegisterThisConnectionsAddress $true
Restart-netadapter -name ethernet

#install AD
"Installing AD"
$SafeModeAdministratorPassword = ConvertTo-SecureString -AsPlainText $SafeModeAdministratorPasswordText -Force
Install-ADDSForest -CreateDNSDelegation:$False -DatabasePath “c:\Windows\NTDS” -DomainMode ‘Win2012’ -DomainName $domainname -DomainNetbiosName $domainnetbiosname -ForestMode ‘Win2012’ -InstallDNS:$true -LogPath “C:\Windows\NTDS” -NoRebootOnCompletion:$false -Sysvolpath “C:\Windows\SYSVOL” -Force:$true -SafeModeAdministratorPassword $SafeModeAdministratorPassword

#Create AD Users
New-ADUser -Name S.Butler -SamAccountName S.Butler -DisplayName 'S.Butler' -AccountPassword $userpw -Enabled $true
New-ADUser -Name S.Butler -SamAccountName S.Butler -DisplayName 'S.Butler' -AccountPassword $userpw -Enabled $true
New-ADUser -Name J.Archer -SamAccountName J.Archer -DisplayName 'J.Archer' -AccountPassword $userpw -Enabled $true
New-ADUser -Name F.Holland -SamAccountName F.Holland -DisplayName 'F.Holland' -AccountPassword $userpw -Enabled $true
New-ADUser -Name H.Morrison -SamAccountName H.Morrison -DisplayName 'H.Morrison' -AccountPassword $userpw -Enabled $true
New-ADUser -Name A.Hope -SamAccountName A.Hope -DisplayName 'A.Hope' -AccountPassword $userpw -Enabled $true
New-ADUser -Name H.Naylor -SamAccountName H.Naylor -DisplayName 'H.Naylor' -AccountPassword $userpw -Enabled $true
New-ADUser -Name H.Burton -SamAccountName H.Burton -DisplayName 'H.Burton' -AccountPassword $userpw -Enabled $true
New-ADUser -Name M.Walters -SamAccountName M.Walters -DisplayName 'M.Walters' -AccountPassword $userpw -Enabled $true
New-ADUser -Name R.McDonald -SamAccountName R.McDonald -DisplayName 'R.McDonald' -AccountPassword $userpw -Enabled $true
New-ADUser -Name R.Gregory -SamAccountName R.Gregory -DisplayName 'R.Gregory' -AccountPassword $userpw -Enabled $true
New-ADUser -Name A.Gilbert -SamAccountName A.Gilbert -DisplayName 'A.Gilbert' -AccountPassword $userpw -Enabled $true
New-ADUser -Name M.Hancock -SamAccountName M.Hancock -DisplayName 'M.Hancock' -AccountPassword $userpw -Enabled $true
New-ADUser -Name Z.Buckley -SamAccountName Z.Buckley -DisplayName 'Z.Buckley' -AccountPassword $userpw -Enabled $true
New-ADUser -Name J.Rose -SamAccountName J.Rose -DisplayName 'J.Rose' -AccountPassword $userpw -Enabled $true
New-ADUser -Name M.Gordon -SamAccountName M.Gordon -DisplayName 'M.Gordon' -AccountPassword $userpw -Enabled $true
New-ADUser -Name E.Connolly -SamAccountName E.Connolly -DisplayName 'E.Connolly' -AccountPassword $userpw -Enabled $true
New-ADUser -Name T.Smith -SamAccountName T.Smith -DisplayName 'T.Smith' -AccountPassword $userpw -Enabled $true
New-ADUser -Name H.Kennedy -SamAccountName H.Kennedy -DisplayName 'H.Kennedy' -AccountPassword $userpw -Enabled $true
New-ADUser -Name K.Edwards -SamAccountName K.Edwards -DisplayName 'K.Edwards' -AccountPassword $userpw -Enabled $true
New-ADUser -Name W.Horton -SamAccountName W.Horton -DisplayName 'W.Horton' -AccountPassword $userpw -Enabled $true
New-ADUser -Name C.Lawrence -SamAccountName C.Lawrence -DisplayName 'C.Lawrence' -AccountPassword $userpw -Enabled $true
New-ADUser -Name M.Bartlett -SamAccountName M.Bartlett -DisplayName 'M.Bartlett' -AccountPassword $userpw -Enabled $true
New-ADUser -Name M.Holden -SamAccountName M.Holden -DisplayName 'M.Holden' -AccountPassword $userpw -Enabled $true
New-ADUser -Name S.Summers -SamAccountName S.Summers -DisplayName 'S.Summers' -AccountPassword $userpw -Enabled $true
New-ADUser -Name C.Bradshaw -SamAccountName C.Bradshaw -DisplayName 'C.Bradshaw' -AccountPassword $userpw -Enabled $true
New-ADUser -Name B.Gough -SamAccountName B.Gough -DisplayName 'B.Gough' -AccountPassword $userpw -Enabled $true
New-ADUser -Name D.Hughes -SamAccountName D.Hughes -DisplayName 'D.Hughes' -AccountPassword $userpw -Enabled $true
New-ADUser -Name V.Bond -SamAccountName V.Bond -DisplayName 'V.Bond' -AccountPassword $userpw -Enabled $true
New-ADUser -Name A.Hunter -SamAccountName A.Hunter -DisplayName 'A.Hunter' -AccountPassword $userpw -Enabled $true
New-ADUser -Name C.Ryan -SamAccountName C.Ryan -DisplayName 'C.Ryan' -AccountPassword $userpw -Enabled $true
New-ADUser -Name F.Bond -SamAccountName F.Bond -DisplayName 'F.Bond' -AccountPassword $userpw -Enabled $true
New-ADUser -Name S.Ferguson -SamAccountName S.Ferguson -DisplayName 'S.Ferguson' -AccountPassword $userpw -Enabled $true
New-ADUser -Name M.Dixon -SamAccountName M.Dixon -DisplayName 'M.Dixon' -AccountPassword $userpw -Enabled $true
New-ADUser -Name L.Thompson -SamAccountName L.Thompson -DisplayName 'L.Thompson' -AccountPassword $userpw -Enabled $true
New-ADUser -Name E.Jackson -SamAccountName E.Jackson -DisplayName 'E.Jackson' -AccountPassword $userpw -Enabled $true
New-ADUser -Name M.Kerr -SamAccountName M.Kerr -DisplayName 'M.Kerr' -AccountPassword $userpw -Enabled $true
New-ADUser -Name A.Freeman -SamAccountName A.Freeman -DisplayName 'A.Freeman' -AccountPassword $userpw -Enabled $true
New-ADUser -Name C.Potts -SamAccountName C.Potts -DisplayName 'C.Potts' -AccountPassword $userpw -Enabled $true
New-ADUser -Name I.Kirk -SamAccountName I.Kirk -DisplayName 'I.Kirk' -AccountPassword $userpw -Enabled $true
New-ADUser -Name M.Payne -SamAccountName M.Payne -DisplayName 'M.Payne' -AccountPassword $userpw -Enabled $true
New-ADUser -Name J.Stevenson -SamAccountName J.Stevenson -DisplayName 'J.Stevenson' -AccountPassword $userpw -Enabled $true
New-ADUser -Name L.Porter -SamAccountName L.Porter -DisplayName 'L.Porter' -AccountPassword $userpw -Enabled $true
New-ADUser -Name C.Barnett -SamAccountName C.Barnett -DisplayName 'C.Barnett' -AccountPassword $userpw -Enabled $true
New-ADUser -Name M.Atkinson -SamAccountName M.Atkinson -DisplayName 'M.Atkinson' -AccountPassword $userpw -Enabled $true
New-ADUser -Name A.Chapman -SamAccountName A.Chapman -DisplayName 'A.Chapman' -AccountPassword $userpw -Enabled $true
New-ADUser -Name A.Pugh -SamAccountName A.Pugh -DisplayName 'A.Pugh' -AccountPassword $userpw -Enabled $true
New-ADUser -Name G.Day -SamAccountName G.Day -DisplayName 'G.Day' -AccountPassword $userpw -Enabled $true
New-ADUser -Name L.Fuller -SamAccountName L.Fuller -DisplayName 'L.Fuller' -AccountPassword $userpw -Enabled $true
New-ADUser -Name J.Johnston -SamAccountName J.Johnston -DisplayName 'J.Johnston' -AccountPassword $userpw -Enabled $true

#Install DHCP
"Installing DHCP"
Add-WindowsFeature  -IncludeManagementTools dhcp 
netsh dhcp add securitygroups
Restart-service dhcpserver
Add-DhcpServerInDC  $sethostanme  $staticip
registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager\Roles\12 –Name ConfigurationState –Value 2
#Configure Scope
"Configuring DHCP Scope"
Add-DHCPServerv4Scope -EndRange $dhcpend -Name LAN1 -StartRange $dhcpstart -SubnetMask $dhcpsnm -State Active
Set-DHCPServerv4OptionValue -ComputerName $sethostanme -ScopeId $dhcpscope -DnsServer $dns2 -DnsDomain $domainname -Router $ipgateway
