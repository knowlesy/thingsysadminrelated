
#requires -version 5
<#
.REFERENCES
https://9to5it.com/powershell-script-template-version-2/
https://gallery.technet.microsoft.com/scriptcenter/Write-Log-PowerShell-999c32d0
https://www.petri.com/useful-powershell-script-document-active-directory-environment
https://blogs.technet.microsoft.com/ashleymcglone/2017/08/31/new-improved-group-policy-link-report-with-powershell/
https://gallery.technet.microsoft.com/Additional-PowerShell-09879e8d
https://www.bvanleeuwen.nl/faq/?p=1182
.SYNOPSIS
  Deep Dive report on AD
.DESCRIPTION
  This script runs an export of all things required for an understanding on how a companies AD is configured
.INPUTS
  n/a
.OUTPUTS
  Log & CSV Files in C:\Temp\ADReport
.NOTES
  Version:        1.0
  Author:         PKnowles
  Creation Date:  2019-10-16
  Purpose/Change: Initial script development
.ToDo
#!Export to csvs or texts than just log files 
#!Resolve any highlted text in script 
#!detailed list of all machines
#!detailed list of all users 
#!Bug on write-log error needs resolving in host window 
#!Check for  groups builtinadmin/hyperv admins/rid admins
#!Exchange domain schema level
#!Exchange Organisation Name
#!Azure is it connected to AD / 365 if so then connect and pull data 
#!DNS Stale Records https://gallery.technet.microsoft.com/scriptcenter/Report-on-Stale-DNS-c6a0173b 
.EXAMPLE
Run script in host window
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

Param (
    #Script parameters go here
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Import Modules & Snap-ins

###########################################  PS Version Check  ###########################################

$PSversioncheck = $psversiontable.psversion.major
Write-Host "Installed ps version is $PSversioncheck" -ForegroundColor Yellow
if ($PSversioncheck -ge 5) {
    Write-Host "PS Version is 5 or above and will work" -ForegroundColor Green
}
else {
    Write-Host "PS Version is incorrect please install or run a PS console with 5 or above" -ForegroundColor Red
    Write-Host "Please visit https://www.microsoft.com/en-us/download/details.aspx?id=54616 or https://docs.microsoft.com/en-us/skypeforbusiness/set-up-your-computer-for-windows-powershell/download-and-install-windows-powershell-5-1" -ForegroundColor Red
    Start-Process "https://www.microsoft.com/en-us/download/details.aspx?id=54616"
    Start-Sleep -Seconds 60
    Exit
}

###########################################  RSAT Module Import  ###########################################

try {
    Write-Host "Importing Modules from RSAT" -ForegroundColor Green
    Import-Module ActiveDirectory
    Import-Module GroupPolicy
    Import-Module DHCPServer
    Write-Host "Setting Global variables, this will take some time please be patient" -ForegroundColor Green
}
catch {
    # Exception is stored in the automatic variable $_
    $ErrorMessage = $_.Exception.Message
    Write-Host $ErrorMessage 
    FailedItem = $_.Exception.ItemName
    Write-Host $FailedItem 
    Write-Host "Script failed to import AD Module script will now exit" -ForegroundColor Red -BackgroundColor Black
    Start-Sleep -Seconds 30
    Exit
}

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'
#Static Variables for  Logging Function
$date = Get-Date -Format yyyy-MM-dd-HH-mm
$logcreated = Get-Date
$Log_Location = 'C:\Temp\ADReport\'
$Outputlocation = ($Log_Location)
$outputpath = ($outputpath + $date)
$logpath = ($Log_Location + $logcreated.ToString("yyyy-MM-dd_HH-mm") + "-AD_Report.log")
$Log_Location_test = Test-Path -Path $Log_Location -ErrorAction $ErrorActionPreference
#Outputs
$Outputlocation = ($Log_Location)
#Forest
$ForestInfo = Get-ADForest
$forest = $ForestInfo.RootDomain
$allDomains = $ForestInfo.Domains
$ForestGC = $ForestInfo.GlobalCatalogs
$UPNsuffix = $ForestInfo.UPNSuffixes
$ffl = $ForestInfo.ForestMode
$FSMODomainNaming = $ForestInfo.DomainNamingMaster
$FSMOSchema = $ForestInfo.SchemaMaster
$forestDomainSID = Get-ADDomain (Get-ADForest).Name | Select-Object domainSID
$SchemaPartition = $ForestInfo.PartitionsContainer.Replace("CN=Partitions", "CN=Schema")
$SchemaVersion = Get-ADObject -Server $forest -Identity $SchemaPartition -Properties * | Select-Object objectVersion
$SchemaVersion = Get-ADObject -Server $forest -Identity $SchemaPartition -Properties * | Select-Object objectVersion
$forestDN = $ForestInfo.PartitionsContainer.Replace("CN=Partitions,CN=Configuration,", "")
$configPartition = $ForestInfo.PartitionsContainer.Replace("CN=Partitions,", "")
# Domain
$DomainInfo = Get-ADDomain
$domainSID = $DomainInfo.DomainSID
$domainDN = $DomainInfo.DistinguishedName
$domain = $DomainInfo.DNSRoot
$NetBIOS = $DomainInfo.NetBIOSName
$dfl = $DomainInfo.DomainMode
$DCListFiltered = Get-ADDomainController -Server $domain -Filter { operatingSystem -like "Windows Server 2008 R2*" -or operatingSystem -like "Windows Server 2012*" -or operatingSystem -like "Windows Server 2016*" -or operatingSystem -like "Windows Server 2019*" } | Select-Object * -ExpandProperty Name
$DCListFiltered | ForEach-Object { $DCListFilteredIndex = $DCListFilteredIndex + 1 }
# Domain FSMO roles
$FSMOPDC = $DomainInfo.PDCEmulator
$FSMORID = $DomainInfo.RIDMaster
$FSMOInfrastructure = $DomainInfo.InfrastructureMaster
$DClist = $DomainInfo.ReplicaDirectoryServers
$RODCList = $DomainInfo.ReadOnlyReplicaDirectoryServers
$cmp_location = $DomainInfo.ComputersContainer
$usr_location = $DomainInfo.UsersContainer
# Get information about built-in domain Administrator account
$BA = $domainSID.ToString() + "-500" 
$builtinAdmin = Get-ADUser -Identity $BA -Server ($DCListFiltered | Select-Object -first 1) -Properties Name, LastLogonDate, PasswordLastSet, PasswordNeverExpires, whenCreated, Enabled
# Get total number of Domain Administrator group members
$DA = $domainSID.ToString() + "-512" 
$domainAdminsNo = (Get-ADGroup -Identity $DA -Server ($DCListFiltered | Select-Object -first 1) | Get-ADGroupMember -Recursive | Measure-Object).Count
$domainAdminsNames = Get-ADGroup -Identity $DA -Server ($DCListFiltered | Select-Object -first 1) | Get-ADGroupMember #| Select-Object Name,samaccountname | Sort-Object samaccountname
$dnszones = Get-DnsServerZone -ComputerName ($DCListFiltered | Select-Object -first 1) -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Select-Object zonename -ErrorAction SilentlyContinue
$dhcpservers = Get-DhcpServerInDC -ErrorAction SilentlyContinue 
$dhcpserverSelected = ($dhcpservers | Select-Object -First 1)
#AD PAss pol
$pwdGPO = Get-ADDefaultDomainPasswordPolicy -Server ($DCListFiltered | Select-Object -first 1)
#-----------------------------------------------------------[Functions]------------------------------------------------------------

function Write-Log {
    [CmdletBinding()]

    Param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias("LogContent")]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [Alias('LogPath')]
        #[string]$Path = C:\Support\Logs\AD.log
        [string]$Path = $logpath,
        #[switch]$path2,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Error", "Warn", "Info")]
        [string]$Level = "Info",

        [Parameter(Mandatory = $false)]
        [switch]$NoClobber
    )

    Begin {
        # Set VerbosePreference to Continue so that verbose messages are displayed.
        $VerbosePreference = 'Continue'
    }
    Process {

        # If the file already exists and NoClobber was specified, do not write to the log.
        if ((Test-Path $Path) -AND $NoClobber) {
            Write-Error "Log file $Path already exists, and you specified NoClobber. Either delete the file or specify a different name."
            Return
        }

        # If attempting to write to a log file in a folder/path that doesn't exist create the file including the path.
        elseif (!(Test-Path $Path)) {
            Write-Verbose "Creating $Path."
            $NewLogFile = New-Item $Path -Force -ItemType File
            $NewLogFile 
        }

        else {
            # Nothing to see here yet.
        }

        # Format Date for our Log File
        $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

        # Write message to error, warning, or verbose pipeline and specify $LevelText
        switch ($Level) {
            'Error' {
                Write-Error $Message
                $LevelText = 'ERROR:'
            }
            'Warn' {
                Write-Warning $Message
                $LevelText = 'WARNING:'
            }
            'Info' {
                Write-Verbose $Message
                $LevelText = 'INFO:'
            }
        }

        # Write log entry to $Path
        "$FormattedDate $LevelText $Message" | Out-File -FilePath $Path -Append
    }
    End {
    }
}
Function Get-ADOrganizationalUnitOneLevel {
    param($Path)
    Get-ADOrganizationalUnit -Filter * -SearchBase $Path `
        -SearchScope OneLevel -Server $GPOServer |
        Sort-Object Name |
        ForEach-Object {
            $script:OUHash.Add($_.DistinguishedName, $script:Counter++)
            Get-ADOrganizationalUnitOneLevel -Path $_.DistinguishedName }
}
Function Get-ADOrganizationalUnitSorted {
    $DomainRoot = (Get-ADDomain -Server $GPOServer).DistinguishedName
    $script:Counter = 1
    $script:OUHash = @{$DomainRoot = 0 }
    Get-ADOrganizationalUnitOneLevel -Path $DomainRoot
    $OUHash
}

$SortedOUs = Get-ADOrganizationalUnitSorted
Function Export-DNSServerIPConfiguration {
    param($Domain)
    
    # Get the DNS configuration of each child DC
    $DNSReport = @()
    
    ForEach ($DomainEach in $Domain) {
        # Get a list of DCs without using AD Web Service
        $DCs = netdom query /domain:$DomainEach dc |
            Where-Object { $_ -notlike "*accounts*" -and $_ -notlike "*completed*" -and $_ }
    
        ForEach ($dc in $DCs) {
    
            # Forwarders
            $dnsFwd = Get-WmiObject -ComputerName $("$dc.$DomainEach") `
                -Namespace root\MicrosoftDNS -Class MicrosoftDNS_Server `
                -ErrorAction SilentlyContinue
    
            # Primary/Secondary (Self/Partner)
            # http://msdn.microsoft.com/en-us/library/windows/desktop/aa393295(v=vs.85).aspx
            $nic = Get-WmiObject -ComputerName $("$dc.$DomainEach") -Query `
                "Select * From Win32_NetworkAdapterConfiguration Where IPEnabled=TRUE" `
                -ErrorAction SilentlyContinue
    
            $DNSReport += 1 | Select-Object `
            @{name = "DC"; expression = { $dc } }, `
            @{name = "Domain"; expression = { $DomainEach } }, `
            @{name = "DNSHostName"; expression = { $nic.DNSHostName } }, `
            @{name = "IPAddress"; expression = { $nic.IPAddress } }, `
            @{name = "DNSServerAddresses"; expression = { $dnsFwd.ServerAddresses } }, `
            @{name = "DNSServerSearchOrder"; expression = { $nic.DNSServerSearchOrder } }, `
            @{name = "Forwarders"; expression = { $dnsFwd.Forwarders } }, `
            @{name = "BootMethod"; expression = { $dnsFwd.BootMethod } }, `
            @{name = "ScavengingInterval"; expression = { $dnsFwd.ScavengingInterval } }
    
        } # End ForEach
    
    }
    
    $DNSReport | Format-Table -AutoSize -Wrap
    $DNSReport | Export-Csv ($outputlocation + $date + '_DC_DNS_IP_Report.csv') -NoTypeInformation
    
}
   
Function Export-DNSServerZoneReport {
    param($Domain)
    
    # This report assumes that all DCs are running DNS.
    $Report = @()
    
    ForEach ($DomainEach in $Domain) {
        # Get a list of DCs without using AD Web Service
        # You may see RiverBed devices returned in this list.
        $DCs = netdom query /domain:$DomainEach dc |
            Where-Object { $_ -notlike "*accounts*" -and $_ -notlike "*completed*" -and $_ }
    
        ForEach ($dc in $DCs) {
    
            $DCZones = $null
            Try {
                $DCZones = Get-DnsServerZone -ComputerName $("$dc.$DomainEach") |
                    Select-Object @{Name = "Domain"; Expression = { $DomainEach } }, @{Name = "Server"; Expression = { $("$dc.$DomainEach") } }, ZoneName, ZoneType, DynamicUpdate, IsAutoCreated, IsDsIntegrated, IsReverseLookupZone, ReplicationScope, DirectoryPartitionName, MasterServers, NotifyServers, SecondaryServers
    
                ForEach ($Zone in $DCZones) {
                    If ($Zone.ZoneType -eq 'Primary') {
                        $ZoneAging = Get-DnsServerZoneAging -ComputerName $("$dc.$DomainEach") -ZoneName $Zone.ZoneName |
                            Select-Object ZoneName, AgingEnabled, NoRefreshInterval, RefreshInterval, ScavengeServers
                        Add-Member -InputObject $Zone -MemberType NoteProperty -Name AgingEnabled -Value $ZoneAging.AgingEnabled
                        Add-Member -InputObject $Zone -MemberType NoteProperty -Name NoRefreshInterval -Value $ZoneAging.NoRefreshInterval
                        Add-Member -InputObject $Zone -MemberType NoteProperty -Name RefreshInterval -Value $ZoneAging.RefreshInterval
                        Add-Member -InputObject $Zone -MemberType NoteProperty -Name ScavengeServers -Value $ZoneAging.ScavengeServers
                    }
                    Else {
                        Add-Member -InputObject $Zone -MemberType NoteProperty -Name AgingEnabled -Value $null
                        Add-Member -InputObject $Zone -MemberType NoteProperty -Name NoRefreshInterval -Value $null
                        Add-Member -InputObject $Zone -MemberType NoteProperty -Name RefreshInterval -Value $null
                        Add-Member -InputObject $Zone -MemberType NoteProperty -Name ScavengeServers -Value $null
                    }
                }
    
                $Report += $DCZones
            }
            Catch {
                Write-Warning "Error connecting to $dc.$DomainEach."
            }
    
        } # End ForEach
    
    }
    
    $Report | Export-Csv -Path ($outputlocation + $date + '_DNS_Zones.csv') -NoTypeInformation -Force -Confirm:$false
    
}
    
#-----------------------------------------------------------[Execution]------------------------------------------------------------

###########################################  Log check / creation  ###########################################

if ($Log_Location_test -eq $true) {

    Write-Log "Script Started with Script version $ScriptVersion" -Level Info
    Write-Log "Log Directory already created at $Log_Location" -Level Info
}

else {
    New-Item -Path $Log_Location -ItemType Directory 
    Write-Log "Created Log Directory at $Log_Location" -Level Info
}

#Information for End user
Write-Host "This must be ran as an admin account" -ForegroundColor Red
Start-Sleep -Seconds 10

###########################################  Checking if Import Excell is installed  ###########################################

try {
    if (Get-Module -ListAvailable -Name ImportExcel) {
        #$ReportType = 'Excel'
        Write-Log "ImportExcel module installed all exports will be to Excel "
        $ReportType = 'CSV'
    }
    else {
        $ReportType = 'CSV'
        Write-Log "ImportExcel module NOT installed all exports will be to seperate CSV files"
    }

}
catch {
    # Exception is stored in the automatic variable $_
    $ErrorMessage = $_.Exception.Message
    Write-log $ErrorMessage -level ERROR
    FailedItem = $_.Exception.ItemName
    Write-log $FailedItem -level ERROR
}

###########################################  AD Forrest  ###########################################
write-log "###########################################  AD Forrest  ###########################################"
try {

    #Forrest name
    Write-Log "Forrest Name: $forest"
    #Forrest SID
    Write-Log "Forrest Domain SID: $forestDomainSID"
    #Forrest Distinguished Namne
    write-log "Forrest Distinguished Name: $forestDN"
    #Forrest Functional Version
    switch ($ffl) {
        #https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/active-directory-functional-levels
        Windows2000Forest { write-log "Forest Functional Level is Windows 2000" }
        Windows2003Forest { write-log "Forest Functional Level is Windows Server 2003" }
        Windows2008Forest { write-log "Forest Functional Level is Windows Server 2008" }
        Windows2008R2Forest { write-log "Forest Functional Level is Windows Server 2008 R2" }
        Windows2012Forest { write-log "Forest Functional Level is Windows Server 2012" }
        Windows2012R2Forest { write-log "Forest Functional Level is Windows Server 2012 R2" }
        Windows2016Forest { write-log "Forest Functional Level is Windows Server 2016" }
        default { write-log "Unknown Forest Functional Level: $ffl" }
   
    }
    #AD Schema Version
    switch ($SchemaVersion.objectVersion) {
        #!# add vairable for output 
        13 { Write-Log ('AD Schema is ' + $SchemaVersion.objectVersion + ' - Windows 2000 Server' ) }
        30 { Write-Log ('AD Schema is ' + $SchemaVersion.objectVersion + ' - Windows Server 2003'  ) }
        31 { Write-Log ('AD Schema is ' + $SchemaVersion.objectVersion + ' - Windows Server 2003 R2' ) }
        44 { Write-Log ('AD Schema is ' + $SchemaVersion.objectVersion + ' - Windows Server 2008' ) }
        47 { Write-Log ('AD Schema is ' + $SchemaVersion.objectVersion + ' - Windows Server 2008 R2' ) }
        56 { Write-Log ('AD Schema is ' + $SchemaVersion.objectVersion + ' - Windows Server 2012' ) }
        69 { Write-Log ('AD Schema is ' + $SchemaVersion.objectVersion + ' - Windows Server 2012 R2' ) }
        87 { Write-Log ('AD Schema is ' + $SchemaVersion.objectVersion + ' - Windows Server 2016' ) }
        88 { Write-Log ('AD Schema is ' + $SchemaVersion.objectVersion + ' - Windows Server 2019' ) }
        default { Write-Log ('unknown - AD Schema is ' + $SchemaVersion ) }
    }
    #list all domains in forrest
    Write-Log "All Domains in this forrest $allDomains"
    #list default upn suffix
    Write-Log "UPN Suffix $UPNsuffix"
    #default naming master
    Write-Log "Domain Naming Master $FSMODomainNaming"
    #schema master
    Write-Log "Schema Master $FSMOSchema"
    GB or Global catalog servers
    Write-Log "All Global Catalogue Servers $ForestGC" 
    #List of trusts
    $ADTrusts = Get-ADObject -Server $forest -Filter { objectClass -eq "trustedDomain" } -Properties CanonicalName, trustDirection

    if ($ADTrusts.Count -gt 0) {
        
        foreach ($Trust in $ADTrusts) {

            switch ($Trust.trustDirection) {
                        
                3 { $trustInfo = ($Trust.CanonicalName).Replace("/System/", "  <===>  ") }
                2 { $trustInfo = ($Trust.CanonicalName).Replace("/System/", "  <----  ") }
                1 { $trustInfo = ($Trust.CanonicalName).Replace("/System/", "  ---->  ") }
                        
            }

            Write-log $trustInfo

        }

    }

    else {
        
        Write-Log "(none)"
        
    }
    #Additional UPN suffixes
    Write-Log "Additional UPN Suffix(s)"
    if ( $UPNSuffix.Count -ne 0 ) {
        
        $UPNsuffix | Sort-Object | ForEach-Object { Write-log $_ }
        
    }
        
    else {
        
        Write-Log "(none)"
        
    }

    #Schema Admins #! missed off eq 2 is it needed# 
    $schemaGroupID = ((Get-ADDomain(Get-ADForest).name).domainSID).value + "-518"
    $schemaAdminsNo = Get-ADGroup -Server $forest -Identity $schemaGroupID | Get-ADGroupMember -Recursive
    Write-log ('Total number of Schema Administrators: ' + ($schemaAdminsNo | Measure-Object).Count)
    Write-Log ('Schema Admins are as follows : ' + ($schemaAdminsNo | Select-Object *))
       
    # Enterprise Admins #! missed off eq 1 is it needed# 
    $entGroupID = ((Get-ADDomain(Get-ADForest).name).domainSID).value + "-519"
    $enterpriseAdminsNo = Get-ADGroup -Server $forest -Identity $entGroupID | Get-ADGroupMember -Recursive #!# do a for each
    Write-Log ('Total number of Enterprise Administrators : ' + ($enterpriseAdminsNo | Measure-Object).Count)
    Write-Log ('Ent Admins are as follows : ' + ($enterpriseAdminsNo | Select-Object *))

    if ($ReportType -eq 'Excel') {
        Write-Log 'Exporting information to Excel Sheet'

    }
    else {
        Write-Log 'Exporting information to CSV or Other'

    }
}
catch {
    # Exception is stored in the automatic variable $_
    $ErrorMessage = $_.Exception.Message
    Write-log $ErrorMessage -level ERROR
    FailedItem = $_.Exception.ItemName
    Write-log $FailedItem -level ERROR
}

###########################################  Partitions  ###########################################
write-log "###########################################  Partitions  ###########################################"
# List of all partitions in a forest
$partitions = Get-ADObject -Server $forest -Filter * -SearchBase $ForestInfo.PartitionsContainer -SearchScope OneLevel -Properties name, nCName, msDS-NC-Replica-Locations | Select-Object name, nCName, msDS-NC-Replica-Locations | Sort-Object name
    
Write-Log "List of all partitions"
foreach ($part in $partitions) {
         
    Write-log ('Partition: ' + $part.name)
    write-log $part.nCName
         
    $DNSServers = $part."msDS-NC-Replica-Locations" | Sort-Object
         
    # If any DNS server holds partition
    if ($DNSServers -ne $nul) {
                 
        Write-log "DNS servers"
                 
        # Get DNS Servers for selected partition
        foreach ($DNSServer in $DNSServers) {
                     
            Write-log ( ($DNSServer -Split ",")[1] -Replace "CN=", "")
                         
        }
                     
        # End of DNS servers list for selected partition
                     
    }
    # End IF section for DNS servers
          
}

###########################################  AD Domain  ###########################################
write-log "###########################################  AD Domain  ###########################################"
#DNS Distingushed name
Write-Log ('Distinguished name is: ' + $domainDN)
#Domain SID
Write-Log ('Domain SID is: ' + $domainSID)
#DNS Domain Name
Write-Log ('DNS Domain Name is: ' + $domain)
#Netbios
write-log ('Netbios is: ' + $NetBIOS)
#PDC Emulator master
write-log ('PDC Emulator Master is: ' + $FSMOPDC)
#RID Master
write-log ('Master is: ' + $FSMORID)
#Infrastructuree master
write-log ('Master is: ' + $FSMOInfrastructure)
#Domain Functional Level
write-log ('Domain Functional Level is: ' + $dfl)
#DNS Servers

#Domain Controllers
write-log ('Domain Controllers: ' + $DClist )
#RO Domain Controllers #!# put a catch in in there is none
Write-Log ('RO Domain Controllers: ' + $RODCList )
#Domain admins amount and who
write-log "Current count of Domain Admins is: $domainAdminsNo"
write-log "$domainAdminsNames" #!# put a for each in this to break it up 
#Built-in Domain Administrator account details > last logon etc 
Write-Log ('Builtin Admin Name: ' + $builtinAdmin.Name)
Write-Log ('Builtin Admin Enabled: ' + $builtinAdmin.Enabled)
Write-Log ('Builtin Admin Last Logged on: ' + $builtinAdmin.LastLogonDate)
Write-Log ('Builtin Admin Last Password set on: ' + $builtinAdmin.PasswordLastSet)
Write-Log ('Builtin Admin Password Never Expires: ' + $builtinAdmin.PasswordNeverExpires)

###########################################  OU  ###########################################
write-log "###########################################  OU  ###########################################"
#Default domain computer objects location #!# no checks on redirect as it needs a better method
write-log ('Defailt Computer OU: ' + $cmp_location)
#Default domain user objects location #!# no checks on redirect as it needs a better method
write-log ('Defailt Computer OU: ' + $usr_location )
#orphaned objects 
$orphanedCount = (Get-ADObject -Filter * -SearchBase "cn=LostAndFound,$($domainDN)" -SearchScope OneLevel | Measure-Object).Count
$Orphaned = Get-ADObject -Filter * -SearchBase "cn=LostAndFound,$($domainDN)" -SearchScope OneLevel 
Write-Log ('Orphaned Objects Found: ' + $orphanedCount)
Write-Log ('Orphaned Objects Names: ' + $orphaned.Name) #!# For each required and if there is any objects
#lingering or replication conflict objects 
$lingConfReplCount = (Get-ADObject -LDAPFilter "(cn=*\0ACNF:*)" -SearchBase $domainDN -SearchScope SubTree | Measure-Object).Count
$lingConfRepl = Get-ADObject -LDAPFilter "(cn=*\0ACNF:*)" -SearchBase $domainDN -SearchScope SubTree
Write-Log ('Lingering or replication conflict objects found: ' + $lingConfReplCount)
Write-Log ('Lingering or replication conflict objects: ' + $lingConfRepl.Name) #!# For each required and if there is any objects
#Active Directory Recycle Bin
$ADRecBinSupport = "feature not supported"

if ( $ffl -like "Windows2008R2Forest" -or $ffl -like "Windows2012Forest" -or $ffl -like "Windows2012R2Forest" -or $ffl -like "Windows2016Forest" ) {
    
    $ADRecBin = (Get-ADOptionalFeature -Server $forest -Identity 766ddcd8-acd0-445e-f3b9-a7f9b6744f2a).EnabledScopes | Measure-Object

    if ( $ADRecBin.Count -ne 0 ) {
            
        $ADRecBinSupport = "Enabled"
            
    }
            
    else {
            
        $ADRecBinSupport = "Disabled"
            
    }

}
write-log ('AD Recycle bin is: ' + $ADRecBinSupport)
#Tombstone lifetime
$tombstoneLifetime = (Get-ADObject -Server $forest -Identity "cn=Directory Service,cn=Windows NT,cn=Services,$configPartition" -Properties tombstoneLifetime).tombstoneLifetime
write-log ('Tombstone Lifetime is (Days): ' + $tombstoneLifetime)
#ou objects
$ou_objectsNo = (Get-ADOrganizationalUnit -Server $domain -Filter * | Measure-Object).Count
write-log ('OU Objects Totals: ' + $ou_objectsNo)

###########################################  GPO  ###########################################
Write-Log "###########################################  GPO  ###########################################"

#Default Domain policy
$gpoDefaultDomain = Get-ADObject -Server $domain -LDAPFilter "(&(objectClass=groupPolicyContainer)(cn={31B2F340-016D-11D2-945F-00C04FB984F9}))"             
if ($gpoDefaultDomain -ne $nul) {

    write-log "Default Domain Policy Exists"

}

else {

    write-log "Default Domain Policy DOES NOT EXIST" -Level Err

}

#Default Domain Controllers policy 
$gpoDefaultDomainController = Get-ADObject -Server $domain -LDAPFilter "(&(objectClass=groupPolicyContainer)(cn={6AC1786C-016F-11D2-945F-00C04fB984F9}))"

if ($gpoDefaultDomainController -ne $nul) {

    Write-Log "Default Domain Controllers policy Exists"

}

else {

    Write-Log "Default Domain Controllers policy DOES NOT Exist" 

}

#Default Domain Password Policy details
Write-log "Default Domain Password Policy details:"
Write-Log ('Minimum password age: ' + $pwdGPO.MinPasswordAge.days + 'day(s)')
Write-Log ('Maximum password age: ' + $pwdGPO.MaxPasswordAge.days + 'day(s)')
Write-Log ('Minimum password length: ' + $pwdGpo.MinPasswordLength + 'character(s)')
Write-Log ('Password history count: ' + $pwdGPO.PasswordHistoryCount + 'unique password(s)')
        
if ( $pwdGPO.ComplexityEnabled ) {
            
    Write-Log "Password Complexity Enaled: Yes "
            
}
            
else {
            
    Write-Log "Password Complexity Enaled: No "
            
}

if ( $pwdGPO.ReversibleEncryptionEnabled ) {
            
    Write-Log "Password uses reversible encryption: Yes "
            
}
            
else {
            
    Write-Log "Password uses reversible encryption: No "
            
}

#Last 10 GPO Modified
write-log "Last 10 GPO's Modified"
$GPOsModifiedlist = Get-GPO -all | Sort-Object ModificationTime -Descending | Select-Object -First 10 | Select-Object DisplayName, ModificationTime
foreach ($gpomodifiedlist in $gposmodifiedlist) {
    write-log ('GPO Name: ' + $gpomodifiedlist.DisplayName + ' On the ' + $gpomodifiedlist.ModificationTime)
}

#GPO Report 
$GPOReport = ($Outputlocation)
$GPOdate = Get-Date -Format yyyy-MM-dd-HH-mm
$GPOServer = Get-ADDomainController -Discover | Select-Object -ExpandProperty HostName
Write-Log ('Creating Report of GPO(s) in ' + $GPOReport )
try {
    # Grab a list of all GPOs
    $GPOs = Get-GPO -All -Server $GPOServer | Select-Object ID, Path, DisplayName, GPOStatus, WMIFilter, CreationTime, ModificationTime, User, Computer

    # Create a hash table for fast GPO lookups later in the report.
    # Hash table key is the policy path which will match the gPLink attribute later.
    # Hash table value is the GPO object with properties for reporting.
    $GPOsHash = @{ }
    ForEach ($GPO in $GPOs) {
        $GPOsHash.Add($GPO.Path, $GPO)
    }

    # Empty array to hold all possible GPO link SOMs
    $gPLinks = @()

    # GPOs linked to the root of the domain
    #  !!! Get-ADDomain does not return the gPLink attribute
    $gPLinks += `
        Get-ADObject -Server $GPOServer -Identity (Get-ADDomain).distinguishedName -Properties name, distinguishedName, gPLink, gPOptions |
        Select-Object name, distinguishedName, gPLink, gPOptions, @{name = 'Depth'; expression = { 0 } }

    # GPOs linked to OUs
    #  !!! Get-GPO does not return the gPLink attribute
    # Calculate OU depth for graphical representation in final report
    $gPLinks += `
        Get-ADOrganizationalUnit -Server $GPOServer -Filter * -Properties name, distinguishedName, gPLink, gPOptions |
        Select-Object name, distinguishedName, gPLink, gPOptions, @{name = 'Depth'; expression = { ($_.distinguishedName -split 'OU=').count - 1 } }

    # GPOs linked to sites
    $gPLinks += `
        Get-ADObject -Server $GPOServer -LDAPFilter '(objectClass=site)' -SearchBase "CN=Sites,$((Get-ADRootDSE).configurationNamingContext)" -SearchScope OneLevel -Properties name, distinguishedName, gPLink, gPOptions |
        Select-Object name, distinguishedName, gPLink, gPOptions, @{name = 'Depth'; expression = { 0 } }

    # Empty report array
    $report = @()

    # Loop through all possible GPO link SOMs collected
    ForEach ($SOM in $gPLinks) {
        # Filter out policy SOMs that have a policy linked
        If ($SOM.gPLink) {

            # Retrieve the replication metadata for gPLink
            $gPLinkMetadata = Get-ADReplicationAttributeMetadata -Server $GPOServer -Object $SOM.distinguishedName -Properties gPLink
            <#
         AttributeName                                    : gPLink
         AttributeValue                                   : [LDAP://cn={4152322F-D1AD-4A46-8A48-CCBB585DDEDB},cn=policies,cn=system,DC=cohovineyard,DC=com;0]
         FirstOriginatingCreateTime                       :
         IsLinkValue                                      : False
        *LastOriginatingChangeDirectoryServerIdentity     : CN=NTDS Settings,CN=CVDCR2,CN=Servers,CN=Ohio,CN=Sites,CN=Configuration,DC=CohoVineyard,DC=com
        *LastOriginatingChangeDirectoryServerInvocationId : 4eab0674-680c-4036-851a-1ba76275ca01
        *LastOriginatingChangeTime                        : 11/20/2014 12:39:58 PM
         LastOriginatingChangeUsn                         : 533407
         LastOriginatingDeleteTime                        :
         LocalChangeUsn                                   : 533407
         Object                                           : OU=Legal,DC=CohoVineyard,DC=com
         Server                                           : CVDCR2.CohoVineyard.com
        *Version                                          : 23
        #>

            # If an OU has 'Block Inheritance' set (gPOptions=1) and no GPOs linked,
            # then the gPLink attribute is no longer null but a single space.
            # There will be no gPLinks to parse, but we need to list it with BlockInheritance.
            If ($SOM.gPLink.length -gt 1) {
                # Use @() for force an array in case only one object is returned (limitation in PS v2)
                # Example gPLink value:
                #   [LDAP://cn={7BE35F55-E3DF-4D1C-8C3A-38F81F451D86},cn=policies,cn=system,DC=wingtiptoys,DC=local;2][LDAP://cn={046584E4-F1CD-457E-8366-F48B7492FBA2},cn=policies,cn=system,DC=wingtiptoys,DC=local;0][LDAP://cn={12845926-AE1B-49C4-A33A-756FF72DCC6B},cn=policies,cn=system,DC=wingtiptoys,DC=local;1]
                # Split out the links enclosed in square brackets, then filter out
                # the null result between the closing and opening brackets ][
                $links = @($SOM.gPLink -split { $_ -eq '[' -or $_ -eq ']' } | Where-Object { $_ })
                # Use a for loop with a counter so that we can calculate the precedence value
                For ( $i = $links.count - 1 ; $i -ge 0 ; $i-- ) {
                    # Example gPLink individual value (note the end of the string):
                    #   LDAP://cn={7BE35F55-E3DF-4D1C-8C3A-38F81F451D86},cn=policies,cn=system,DC=wingtiptoys,DC=local;2
                    # Splitting on '/' and ';' gives us an array every time like this:
                    #   0: LDAP:
                    #   1: (null value between the two //)
                    #   2: distinguishedName of policy
                    #   3: numeric value representing gPLinkOptions (LinkEnabled and Enforced)
                    $GPOData = $links[$i] -split { $_ -eq '/' -or $_ -eq ';' }
                    # Add a new report row for each GPO link
                    $report += New-Object -TypeName PSCustomObject -Property @{
                        Depth                             = $SOM.Depth;
                        Name                              = $SOM.Name;
                        DistinguishedName                 = $SOM.distinguishedName;
                        PolicyDN                          = $GPOData[2];
                        Precedence                        = $links.count - $i
                        GUID                              = "{$($GPOsHash[$($GPOData[2])].ID)}";
                        DisplayName                       = $GPOsHash[$GPOData[2]].DisplayName;
                        GPOStatus                         = $GPOsHash[$GPOData[2]].GPOStatus;
                        WMIFilter                         = $GPOsHash[$GPOData[2]].WMIFilter.Name;
                        GPOCreated                        = $GPOsHash[$GPOData[2]].CreationTime;
                        GPOModified                       = $GPOsHash[$GPOData[2]].ModificationTime;
                        UserVersionDS                     = $GPOsHash[$GPOData[2]].User.DSVersion;
                        UserVersionSysvol                 = $GPOsHash[$GPOData[2]].User.SysvolVersion;
                        ComputerVersionDS                 = $GPOsHash[$GPOData[2]].Computer.DSVersion;
                        ComputerVersionSysvol             = $GPOsHash[$GPOData[2]].Computer.SysvolVersion;
                        Config                            = $GPOData[3];
                        LinkEnabled                       = [bool](!([int]$GPOData[3] -band 1));
                        Enforced                          = [bool]([int]$GPOData[3] -band 2);
                        BlockInheritance                  = [bool]($SOM.gPOptions -band 1)
                        gPLinkVersion                     = $gPLinkMetadata.Version
                        gPLinkLastOrigChgTime             = $gPLinkMetadata.LastOriginatingChangeTime
                        gPLinkLastOrigChgDirServerId      = $gPLinkMetadata.LastOriginatingChangeDirectoryServerIdentity
                        gPLinkLastOrigChgDirServerInvocId = $gPLinkMetadata.LastOriginatingChangeDirectoryServerInvocationId
                    } # End Property hash table
                } # End For
            }
            Else {
                # BlockInheritance but no gPLink
                $report += New-Object -TypeName PSCustomObject -Property @{
                    Depth                             = $SOM.Depth;
                    Name                              = $SOM.Name;
                    DistinguishedName                 = $SOM.distinguishedName;
                    BlockInheritance                  = [bool]($SOM.gPOptions -band 1)
                    gPLinkVersion                     = $gPLinkMetadata.Version
                    gPLinkLastOrigChgTime             = $gPLinkMetadata.LastOriginatingChangeTime
                    gPLinkLastOrigChgDirServerId      = $gPLinkMetadata.LastOriginatingChangeDirectoryServerIdentity
                    gPLinkLastOrigChgDirServerInvocId = $gPLinkMetadata.LastOriginatingChangeDirectoryServerInvocationId
                }
            } # End If
        }
        Else {
            # No gPLink at this SOM
            $report += New-Object -TypeName PSCustomObject -Property @{
                Depth             = $SOM.Depth;
                Name              = $SOM.Name;
                DistinguishedName = $SOM.distinguishedName;
                BlockInheritance  = [bool]($SOM.gPOptions -band 1)
            }
        } # End If
    } # End ForEach

    # Output the results to CSV file for viewing in Excel
    $report |
        Select-Object @{name = 'OUSort'; expression = { $SortedOUs[$_.DistinguishedName] } }, `
        @{name = 'SOM'; expression = { $_.name.PadLeft($_.name.length + ($_.depth * 5), '_') } }, `
            DistinguishedName, BlockInheritance, LinkEnabled, Enforced, Precedence, `
            DisplayName, GPOStatus, WMIFilter, GUID, GPOCreated, GPOModified, `
            UserVersionDS, UserVersionSysvol, ComputerVersionDS, ComputerVersionSysvol, PolicyDN, `
            gPLinkVersion, gPLinkLastOrigChgTime, gPLinkLastOrigChgDirServerId, gPLinkLastOrigChgDirServerInvocId |
        Sort-Object OUSort, Precedence, SOM |
        Export-Csv ($GPOReport + $gpodate + "-gPLink_Report_Sorted_Metadata.csv") -NoTypeInformation

}
catch {
    # Exception is stored in the automatic variable $_
    $ErrorMessage = $_.Exception.Message
    Write-log $ErrorMessage -level ERROR
    FailedItem = $_.Exception.ItemName
    Write-log $FailedItem -level ERROR
}

#Backup GPO's
$GPUBackupLocation = ($Outputlocation + 'GPOBackup')
Write-Log ('Backing up GPO to ' + $GPUBackupLocation)

try {
    New-Item -Path $GPUBackupLocation -ItemType Directory >> $logpath
    Backup-GPO -All -Path $GPUBackupLocation -Comment 'Backup' >> $logpath
}
catch {
    # Exception is stored in the automatic variable $_
    $ErrorMessage = $_.Exception.Message
    Write-log $ErrorMessage -level ERROR
    FailedItem = $_.Exception.ItemName
    Write-log $FailedItem -level ERROR
}

###########################################  Sites and Subnets information  ###########################################
write-log "###########################################  Sites and Subnets information  ###########################################"
#sites
$ConfigurationPart = ($ForestInfo.PartitionsContainer -Replace "CN=Partitions,", "")
$AllSites = Get-ADObject -Server $forest -Filter { objectClass -eq "site" } -SearchBase $ConfigurationPart -Properties *
Write-Log "Sites Enumeration:...."

# Loop for Sites and Subnets
foreach ( $Site in $AllSites ) {
     
    write-log ('Site: ' + $Site.Name)
    write-log "Server(s) in site:"
    $ServersInSite = Get-ADObject -Server $forest -Filter { objectClass -eq "server" } -SearchBase $Site.distinguishedName -SearchScope Subtree -Properties Name | Select-Object Name | Sort-Object Name
    # Loop for Domain Controller details
    foreach ($SiteServer in $ServersInSite) {

        # If any DC is in Site
        if ( $SiteServer -ne $nul ) {
                         
            $dcDetails = Get-ADDomainController $SiteServer.Name -ErrorAction SilentlyContinue
            if (Test-Connection $server -Quiet) {
                Write-Log ('Can sucsessfully connect to DC: ' + $dcDetail)
        
            } 
            else {
                Write-Log ('Can NOT connect to DC: ' + $dcDetail) -Level Error
            }

            $dcDN = $dcDetails.ComputerObjectDN -Replace $dcDetails.Name, ""
            $dcDN = $dcDN -Replace "CN=,", ""

            $dcFRS = "CN=Domain System Volume (SYSVOL share),CN=NTFRS Subscriptions,$($dcdetails.computerobjectdn)"
            $dcDFSR = "CN=SYSVOL Subscription,CN=Domain System Volume,CN=DFSR-LocalSettings,$($dcdetails.computerobjectdn)"

            $dcFRSinfo = Get-ADObject -Filter { distinguishedName -eq $dcFRS } -Properties fRSRootPath
            $dcDFSRinfo = Get-ADObject -Filter { distinguishedName -eq $dcDFSR } -Properties msDFSR-RootPath, msDFSR-RootSizeInMb

            # Display Domain Controller details
            write-log ($SiteServer.Name + '(' + $dcDN + ')')
            write-log ('IP address (v4): ' + $dcDetails.ipv4address)

            # IPv6 address
            if ($dcDetails.ipv6address -ne $nul) {
                             
                write-log ('IP address (v6): ' + $dcDetails.ipv6address)
                             
            }
                             
            else {
                             
                write-log "IP address (v6):  (none)"
                           
            }
                                
            # Operating system type and its service pack level
            write-log ('OS type: ' + $dcDetails.operatingSystem)

            if ($dcDetails.operatingSystemServicePack -ne $nul) {
                             
                write-log ('Service Pack: ' + $dcDetails.operatingSystemServicePack)
                             
            }
            # End of operating system and service pack level section
                         
            # SYSVOL replication method on DC
            # SYSVOL FRS section
            if ($dcFRSinfo -ne $nul) {
                             
                write-log "SYSVOL replication :  FRS"
                write-log ('SYSVOL location: ' + $dcFRSinfo.fRSRootPath)
                            
            }
            # End of SYSVOL FRS section

            # SYSVOL DFS-R section
            if ($dcDFSRinfo -ne $nul) {
                             
                write-log  "SYSVOL replication:  DFS-R"
                write-log  ('SYSVOL location: ' + $dcDFSRinfo."msDFSR-RootPath")

                # SYSVOL size
                if ($dcDFSRinfo."msDFSR-RootSizeInMb" -ne $nul) {
                                     
                    write-log ('SYSVOL quota: ' + $dcDFSRinfo."msDFSR-RootSizeInMb")
                                     
                }
                                     
                else {
                                     
                    write-log "SYSVOL quota:  4GB (default setting)"
                                     
                }
                # End of SYSVOL size
                                 
            }
            # End of SYSVOL DFS-R section

        }
        # End of section where DC is in Site    
                 
        # If no DC in Site
        else {
                 
            Write-Log "(none)"
                 
        }
        # End of section where no DC in Site

    } # End of sub foreach for Domain Controllers details
             
    # List Subnets for selected Site
    $subnets = $Site.siteObjectBL

    Write-log "Subnets:"

    # If any Subnet assigned
    if ( $subnets -ne $nul ) {
         
        # List all Subnets for selected Site
        foreach ($subnet in $subnets) {
                             
            $SubnetSplit = $Subnet.Split(",")
            Write-log ($SubnetSplit[0].Replace("CN=", ""))
                             
        }
        # End of listing Subnets

    }
    # End of existing Subnets section
     
    # If no Subnets in Site
    else {
                     
        Write-log "(none)"
                     
    }
    # End of no Subnets section
         
    # End of listing Subnets
 
} # End of main foreach for Sites and Subnets
     
# End of Sites section

###########################################  Exchange  ###########################################
Write-Log "###########################################  Exchange  ###########################################"
#Microsoft Exchange version
$ExchangeSystemObjects = Get-ADObject -Server $forest -LDAPFilter "(&(objectClass=container)(name=Microsoft Exchange System Objects))" -SearchBase $forestDN -Properties objectVersion
$ExchangeSchemaVersion = Get-ADObject -Server $forest -LDAPFilter "(&(objectClass=attributeSchema)(name=ms-Exch-Schema-Version-Pt))" -SearchBase $SchemaPartition -Properties rangeUpper

$ExchangeSchema = $ExchangeSystemObjects.objectVersion + $ExchangeSchemaVersion.rangeUpper

if ($ExchangeSchemaVersion -ne $nul) {
        
    switch ($ExchangeSchema) {
        4397 { write-log "Exchange 2000 RTM" }
        4397 { write-log "Exchange 2000 SP1" }
        4406 { write-log "Exchange 2000 SP2" }
        4406 { write-log "Exchange 2000 SP3" }
        6870 { write-log "Exchange 2003 RTM" }
        6870 { write-log "Exchange 2003 SP1" }
        6870 { write-log "Exchange 2003 SP2" }
        10637 { write-log "Exchange 2007 RTM" }
        11116 { write-log "Exchange 2007 SP1" }
        14622 { write-log "Exchange 2007 SP2" }
        14625 { write-log "Exchange 2007 SP3" }
        14622 { write-log "Exchange 2010 RTM" }
        14726 { write-log "Exchange 2010 SP1" }
        14732 { write-log "Exchange 2010 SP2" }
        14734 { write-log "Exchange 2010 SP3" }
        15137 { write-log "Exchange 2013 RTM" }
        15254 { write-log "Exchange 2013 CU1" }
        15281 { write-log "Exchange 2013 CU2" }
        15283 { write-log "Exchange 2013 CU3" }
        15292 { write-log "Exchange 2013 SP1 (CU4)" }
        15300 { write-log "Exchange 2013 CU5" }
        15303 { write-log "Exchange 2013 CU6" }
        15312 { write-log "Exchange 2013 CU7" }
        15312 { write-log "Exchange 2013 CU8" }
        15312 { write-log "Exchange 2013 CU9" }
        15312 { write-log "Exchange 2013 CU10" }
        15312 { write-log "Exchange 2013 CU11" }
        15312 { write-log "Exchange 2013 CU12" }
        15312 { write-log "Exchange 2013 CU13" }
        15312 { write-log "Exchange 2013 CU14" }
        15312 { write-log "Exchange 2013 CU15" }
        15312 { write-log "Exchange 2013 CU16" }
        15312 { write-log "Exchange 2013 CU17" }
        15312 { write-log "Exchange 2013 CU18" }
        15312 { write-log "Exchange 2013 CU19" }
        15312 { write-log "Exchange 2013 CU20" }
        15312 { write-log "Exchange 2013 CU21" }
        15317 { write-log "Exchange 2016 RTM" }
        15323 { write-log "Exchange 2016 CU1" }
        15325 { write-log "Exchange 2016 CU2" }
        15326 { write-log "Exchange 2016 CU3" }
        15326 { write-log "Exchange 2016 CU4" }
        15326 { write-log "Exchange 2016 CU5" }
        15330 { write-log "Exchange 2016 CU6" }
        15332 { write-log "Exchange 2016 CU7" }
        15332 { write-log "Exchange 2016 CU8" }
        15332 { write-log "Exchange 2016 CU9" }
        15332 { write-log "Exchange 2016 CU10" }
        15332 { write-log "Exchange 2016 CU11" }
        17000 { write-log "Exchange 2019 RTM" }
        default { Write-Host -ForegroundColor red "unknown - "$ExchangeSchemaVersion.rangeUpper }
                    
    }
    <#
            #Ignored due to unable to test
            $ExchOrganization = (Get-ADObject -Server $forest -Identity "cn=Microsoft Exchange,cn=Services,$configPartition" -Properties templateRoots).templateRoots
            $ExchOrgName = (Get-ADObject -Server $forest -Identity $($ExchOrganization -Replace "cn=Addressing," , "") -Properties name).name

            Write-Host ""
            
            Write-Host "Microsoft Exchange Organization name"
            Write-Host -ForegroundColor Green $ExchOrgName
            #>

} #end if
        
else {
        
    Write-Log "Exchange Schema not present"
        
}

###########################################  Skype  ###########################################
write-log "###########################################  Skype  ###########################################"
#Microsoft Lync/Skype Schema version
write-log "Skype Schema Version:...."
$LyncSchemaVersion = Get-ADObject -Server $forest -LDAPFilter "(&(objectClass=attributeSchema)(name=ms-RTC-SIP-SchemaVersion))" -SearchBase $SchemaPartition -Properties rangeUpper

if ($LyncSchemaVersion -ne $nul) {
    
    switch ($LyncSchemaVersion.rangeUpper) {
            
        1006 { Write-Log "Live Communications Server 2005" }
        1007 { Write-Log "Office Communications Server 2007 Release 1" }
        1008 { Write-Log "Office Communications Server 2007 Release 2" }
        1100 { Write-Log "Lync Server 2010" }
        1150 { Write-Log "Lync Server 2013 / Skype 2015+" }
        default { write-log ('unknown - ' + $LyncSchemaVersion.rangeUpper ) }
            
    }

}# end if
    
else {
    
    Write-Log "(not present)"
    
}
###########################################  DNS  ###########################################
write-log "###########################################  DNS  ###########################################"
#DNS Zone Information

Write-log ('Exporting reports on DNS')
foreach ($dnszone in $dnszones) {
    Write-Log ('Exporting information on zone: ' + $dnszone.zonename)
    Export-DNSServerZoneReport -Domain $dnszone.zonename >> $logpath
    Export-DNSServerIPConfiguration -Domain $dnszone.zonename >> $logpath
}

#DNS Stats
$DNSstats = ($Outputlocation + $date + 'DNS_Stats.txt')
Write-Log ('Exporting DNS Statistics to: ' + $DNSStats)
Get-DnsServerZone | Select-Object zonename | Get-DnsServerStatistics >> $DNSstats

#DNS Static A Records
Write-Log "Exporting Static A records"

foreach ($StaticARecord in $dnszones) {
    $DNS_A_SRecord = ($Outputlocation + $date + '-DNS-Stating-A-Recordlocation.csv')
    Get-DnsServerResourceRecord -ZoneName $zone.zonename -RRType A | Where-Object { -not $_.TimeStamp } | Select-Object * | Export-Csv $DNS_A_SRecord -Append

}
###########################################  DHCP  ###########################################
Write-Log "###########################################  DHCP  ###########################################"
write-log "Listing DHCP Servers in AD..."
foreach ($dhcpserver in $dhcpservers ) {
    $testDHCPServerActive = Test-Connection -ComputerName $dhcpserver -Quiet
    write-log ('DHCP Server Name: ' + $dhcpserver.DNSName + ' on the IP: ' + $dhcpserver.IPAddress + ' Is Active: ' + $testDHCPServerActive)
}
#DHCP V4 Options
Write-Log "Exporting DHCP v4 Options"
$DHCPv4OptionsReport = ($Outputlocation + $date + 'DHCPv4OptionsOutput.csv')
Get-DhcpServerv4Scope -ComputerName $dhcpserverSelected | Get-DhcpServerv4OptionValue >> $logpath
Get-DhcpServerv4Scope -ComputerName $dhcpserverSelected | Get-DhcpServerv4OptionValue | Export-Csv $DHCPv4OptionsReport -Append

#Scope Ranges
$DHCPv4ScopeReport = ($Outputlocation + $date + 'DHCPv4ScopeReport.csv')
write-log "Exporting DHCP Scope"
$Report = @()
$k = $null
Write-Host -foregroundcolor Green "`n`n`n`n`n`n`n`n`n"
foreach ($dhcpscope in $dhcpservers) {
    $k++
    Write-Progress -activity "Getting DHCP scopes:" -status "Percent Done: " `
        -PercentComplete (($k / $dhcpservers.Count) * 100) -CurrentOperation "Now processing $($dhcpscope.DNSName)"
    if (Test-Connection $dhcpscope -Quiet) {
        $scopes = $null
        $scopes = (Get-DhcpServerv4Scope -ComputerName $dhcpscope.DNSName -ErrorAction:SilentlyContinue)
        If ($null -ne $scopes) {
            #getting global DNS settings, in case scopes are configured to inherit these settings
            $GlobalDNSList = $null
            $GlobalDNSList = (Get-DhcpServerv4OptionValue -OptionId 6 -ComputerName $dhcpscope.DNSName -ErrorAction:SilentlyContinue).Value
            $scopes | ForEach-Object {
                $row = "" | Select-Object Hostname, ScopeID, SubnetMask, Name, State, StartRange, EndRange, LeaseDuration, Description, DNS1, DNS2, DNS3, GDNS1, GDNS2, GDNS3, Router
                $row.Hostname = $dhcpscope.DNSName
                $row.ScopeID = $_.ScopeID
                $row.SubnetMask = $_.SubnetMask
                $row.Name = $_.Name
                $row.State = $_.State
                $row.StartRange = $_.StartRange
                $row.EndRange = $_.EndRange
                $row.LeaseDuration = $_.LeaseDuration
                $row.Description = $_.Description
                $ScopeDNSList = $null
                $ScopeDNSList = (Get-DhcpServerv4OptionValue -OptionId 6 -ScopeID $_.ScopeId -ComputerName $dhcpscope.DNSName -ErrorAction:SilentlyContinue).Value
            
                If (($ScopeDNSList -eq $null) -and ($GlobalDNSList -ne $null)) {
                    $row.GDNS1 = $GlobalDNSList[0]
                    $row.GDNS2 = $GlobalDNSList[1]
                    $row.GDNS3 = $GlobalDNSList[2]
                    $row.DNS1 = $GlobalDNSList[0]
                    $row.DNS2 = $GlobalDNSList[1]
                    $row.DNS3 = $GlobalDNSList[2]
                }
                Else {
                    $row.DNS1 = $ScopeDNSList[0]
                    $row.DNS2 = $ScopeDNSList[1]
                    $row.DNS3 = $ScopeDNSList[2]
                }
                $router = (Get-DhcpServerv4OptionValue -ComputerName $dhcpscope.DNSName -OptionId 3 -ScopeID $_.ScopeId).Value
                $row.Router = $router[0]
                $Report += $row }
        }
        Else {
            Write-Host -foregroundcolor Yellow """$($dhcpscope.DNSName)"" is either running Windows 2003, or is somehow not responding to querries. Adding to report as blank"
            $row = "" | Select-Object Hostname, ScopeID, SubnetMask, Name, State, StartRange, EndRange, LeaseDuration, Description, DNS1, DNS2, DNS3, GDNS1, GDNS2, GDNS3, Router
            $row.Hostname = $dhcpscope.DNSName
            $Report += $row
        }
    }
    Else {
        write-log "Could not connect to DHCP Server"
        $row = "" | Select-Object Hostname, ScopeID, SubnetMask, Name, State, StartRange, EndRange, LeaseDuration, Description, DNS1, DNS2, DNS3, GDNS1, GDNS2, GDNS3, Router
        $row.Hostname = $dhcpscope.DNSName
        $Report += $row
    }
    write-log ('Completed processing: ' + $dhcpscope.DNSName)
}

$Report | Export-Csv -NoTypeInformation -UseCulture $DHCPv4ScopeReport
###########################################  users & Computers  ###########################################
Write-Log "###########################################  Users & Computers  ###########################################"

#computer objects and type
Write-Log "Computer Objects in Domain"
$cmp_os_2000 = 0
$cmp_os_xp = 0
$cmp_os_7 = 0
$cmp_os_8 = 0
$cmp_os_81 = 0
$cmp_os_10
$cmp_srvos_2000 = 0
$cmp_srvos_2003 = 0
$cmp_srvos_2008 = 0
$cmp_srvos_2008r2 = 0
$cmp_srvos_2012 = 0
$cmp_srvos_2012r2 = 0
$cmp_srvos_2016 = 0
$cmp_srvos_2019 = 0
$cmp_os_unkwn = 0
$cmp_objects = Get-ADComputer -Server $domain -Filter * -Properties operatingSystem
$cmp_objectsNo = ($cmp_objects | Measure-Object).Count
#Desktops
$cmp_objects | ForEach-Object { if ($_.operatingSystem -like "Windows 2000 Professional*") { $cmp_os_2000 = $cmp_os_2000 + 1 } }
$cmp_objects | ForEach-Object { if ($_.operatingSystem -like "Windows XP*") { $cmp_os_xp = $cmp_os_xp + 1 } }
$cmp_objects | ForEach-Object { if ($_.operatingSystem -like "Windows 7*") { $cmp_os_7 = $cmp_os_7 + 1 } }
$cmp_objects | ForEach-Object { if ($_.operatingSystem -like "Windows 8 *") { $cmp_os_8 = $cmp_os_8 + 1 } }
$cmp_objects | ForEach-Object { if ($_.operatingSystem -like "Windows 8.1*") { $cmp_os_81 = $cmp_os_81 + 1 } }
$cmp_objects | ForEach-Object { if ($_.operatingSystem -like "Windows 10*") { $cmp_os_10 = $cmp_os_10 + 1 } }
#Servers
$cmp_objects | ForEach-Object { if ($_.operatingSystem -like "Windows 2000 Server*") { $cmp_srvos_2000 = $cmp_srvos_2000 + 1 } }
$cmp_objects | ForEach-Object { if ($_.operatingSystem -like "Windows Server 2003*") { $cmp_srvos_2003 = $cmp_srvos_2003 + 1 } }
$cmp_objects | ForEach-Object { if ( ($_.operatingSystem -like "Windows Server 2008*") -and ($_.operatingSystem -notlike "Windows Server 2008 R2*") ) { $cmp_srvos_2008 = $cmp_srvos_2008 + 1 } }
$cmp_objects | ForEach-Object { if ($_.operatingSystem -like "Windows Server 2008 R2*") { $cmp_srvos_2008r2 = $cmp_srvos_2008r2 + 1 } }
$cmp_objects | ForEach-Object { if ( ($_.operatingSystem -like "Windows Server 2012 *") -and ($_.operatingSystem -notlike "Windows Server 2012 R2*") ) { $cmp_srvos_2012 = $cmp_srvos_2012 + 1 } }
$cmp_objects | ForEach-Object { if ($_.operatingSystem -like "Windows Server 2012 R2*") { $cmp_srvos_2012r2 = $cmp_srvos_2012r2 + 1 } }
$cmp_objects | ForEach-Object { if ($_.operatingSystem -like "Windows Server 2016*") { $cmp_srvos_2016 = $cmp_srvos_2016 + 1 } }
$cmp_objects | ForEach-Object { if ($_.operatingSystem -like "Windows Server 2019*") { $cmp_srvos_2019 = $cmp_srvos_2019 + 1 } }
#Unknown
$cmp_objects | ForEach-Object { if ($_.operatingSystem -notmatch "Windows*") { $cmp_os_unkwn = $cmp_os_unkwn + 1 } }
#Output
write-log ('Total Computer Objects: ' + $cmp_objectsNo)
write-log ('Windows 2000: ' + $cmp_os_2000)
write-log ('Windows XP: ' + $cmp_os_xp)
write-log ('Windows 7: ' + $cmp_os_7)
write-log ('Windows 8: ' + $cmp_os_8)
write-log ('Windows 8.1: ' + $cmp_os_81)
write-log ('Windows 10: ' + $cmp_os_10)
write-log ('Windows Server 2000: ' + $cmp_srvos_2000)
write-log ('Windows Server 2003: ' + $cmp_srvos_2003)
write-log ('Windows Server 2008: ' + $cmp_srvos_2008)
write-log ('Windows Server 2008R2: ' + $cmp_srvos_2008r2)
write-log ('Windows Server 2012: ' + $cmp_srvos_2012)
write-log ('Windows Server 2012R2: ' + $cmp_srvos_2012r2)
write-log ('Windows Server 2016: ' + $cmp_srvos_2016)
write-log ('Windows Server 2019: ' + $cmp_srvos_2019)
write-log ('OS(s) Not Filtered for: ' + $cmp_os_unkwn)
#Computers not logged in, in over 60 days
write-log "Machines which have not logged in, in over 60 Days..."
$compsnotloggedin = Get-ADComputer  -Properties * -Filter * | Where-Object { $_.lastlogondate -lt (Get-Date).AddDays(-60) } | Select-Object Name, lastlogondate, CanonicalName, OperatingSystem, Enabled 
foreach ($compnotloggedin in $compsnotloggedin) {
    Write-Log ('The follwoing Machine ' + $compnotloggedin.Name + ' Has not logged in since ' + $compnotloggedin.lastlogondate + ' Its OS is ' + $compnotloggedin.OperatingSystem + ' Its status is ' + $compnotloggedin.Enabled)

}
#user objects and type
$usr_objectsNo = 0
$usr_active_objectsNo = 0
$usr_inactive_objectsNo = 0
$usr_locked_objectsNo = 0
$usr_pwdnotreq_objectsNo = 0
$usr_pwdnotexp_objectsNo = 0
$usr_objects = Get-ADUser -Server $domain -Filter * -Properties Enabled, LockedOut, PasswordNeverExpires, PasswordNotRequired
$usr_objectsNo = $usr_objects.Count
$usr_objects | ForEach-Object { if ($_.Enabled -eq $True) { $usr_active_objectsNo = $usr_active_objectsNo + 1 } }
$usr_objects | ForEach-Object { if ($_.Enabled -eq $False) { $usr_inactive_objectsNo = $usr_inactive_objectsNo + 1 } }
$usr_objects | ForEach-Object { if ($_.LockedOut -eq $True) { $usr_locked_objectsNo = $usr_locked_objectsNo + 1 } }
$usr_objects | ForEach-Object { if ($_.PasswordNotRequired -eq $True) { $usr_pwdnotreq_objectsNo = $usr_pwdnotreq_objectsNo + 1 } }
$usr_objects | ForEach-Object { if ($_.PasswordNeverExpires -eq $True) { $usr_pwdnotexp_objectsNo = $usr_pwdnotexp_objectsNo + 1 } }
#Log Output
write-log ('Users Object Count: ' + $usr_objectsNo)
write-log ('Users Active: ' + $usr_active_objectsNo)
write-log ('Users Inactive: ' + $usr_inactive_objectsNo)
write-log ('Users Locked Out: ' + $usr_locked_objectsNo)
write-log ('Users Password Not Required: ' + $usr_pwdnotreq_objectsNo)
write-log ('Users Passwords That Never Expire: ' + $usr_pwdnotexp_objectsNo)
#users not logged in for over 60 days
write-log "Users which have not logged in, in over 60 Days..."
$usersnotloggedin = Get-ADUser  -Properties * -Filter * | Where-Object { $_.lastlogondate -lt (Get-Date).AddDays(-60) } | Select-Object Name, LastLogonDate, Enabled, samaccountname  
foreach ($usernotloggedin in $usersnotloggedin) {
    Write-Log ('The user ' + $usernotloggedin.Name + ' with username ' + $usernotloggedin.samaccountname + ' has not logged in since ' + $usernotloggedin.LastLogonDate + ' their status is ' + $usernotloggedin.Enabled)
}
#group objects and type
$grp_objectsNo = 0
$grp_objects_localNo = 0
$grp_objects_universalNo = 0
$grp_objects_globalNo = 0
$grp_objects = Get-ADGroup -Server $domain -Filter * -Properties GroupScope
$grp_objectsNo = $grp_objects.Count
$grp_objects | ForEach-Object { if ($_.GroupScope -eq "DomainLocal") { $grp_objects_localNo = $grp_objects_localNo + 1 } }
$grp_objects | ForEach-Object { if ($_.GroupScope -eq "Universal") { $grp_objects_universalNo = $grp_objects_universalNo + 1 } }
$grp_objects | ForEach-Object { if ($_.GroupScope -eq "Global") { $grp_objects_globalNo = $grp_objects_globalNo + 1 } }
#Log Output
write-log ('Group Object Count: ' + $grp_objectsNo)
write-log ('Group Domain Local Count: ' + $grp_objects_localNo)
write-log ('Group Universal Count: ' + $grp_objects_universalNo)
write-log ('Group Global Count: ' + $grp_objects_globalNo)
#Group lists 
Write-Log "AD Group Names..."
$ADGroups = Get-ADGroup -Filter * | Select-Object Name
foreach ($ADGroup in $ADGroups) {
    write-log ('Group Name: ' + $ADGroup)
}
#members of groups
Write-Log "Getting members of AD Groups"
$ADGroups = Get-ADGroup -Filter * | Select-Object Name

foreach ($group in $ADgroups.name) {
    Write-Log ('Processing Group: ' + $group + '...')

    #gets list of users in ad group
    $membersofthegroup = Get-ADGroupMember -Identity $group | Select-Object samaccountname, name

    #goes through each member in the list to see if their enabled
    foreach ($member in $membersofthegroup) {
        #looks up user in ad
        $IsUserEnabled = Get-ADUser $member.samaccountname -Properties * | Select-Object Name, Enabled
        #if based on there enabled 
        if ($IsUserEnabled.enabled -eq $true) {
            #Output to filtered members for ernabled only 
            
        }
        else {
            #Output to all members list
        }

    }
    Write-Log ('Processing Group: ' + $group + ' - Complete')
}

#detailed list of all machines
#detailed list of all users 
