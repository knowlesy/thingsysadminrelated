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
  Log of script running and majority of all outputs contained with in a single file
 
  AD Forrest
  #DCDIAG
  #REPLSUM
  ##Forest Name
  ##Forest SID
  ##Forest Distinguished SID
  ##Forest Functional Version
  ##Domaions in forest
  ##Default naming master
  ##global catalogue servers
  ##llist of all trusts
  ##additional upn suffixes
  ##schema admins
  ##enterprise admins
  
  Partitions
  ##Partitions in a forrest
  ##DNS servers that hold partitions
  
  AD Domain
  ##DNS Distinguished names
  #Domain SID's
  #MSOL USer
  ##DNS DOMAIN NAME
  ##netbios
  ##pdc emulator master
  ##RID master
  ##infra master
  ##domain functional level
  ##domain controllers
  ##ro domain controllers
  ##domain admins amount and who
  ##builtin admin details

  OU
  ##default comp obj location
  ##default user obj location
  ##orphanned objects
  ##replication conflicts
  ##AD recycle bin on or off
  ##tombstone liftetime
  ##ou objects number

  GPO
  ##confirmation default domain policy exists
  ##confirmation default domain controller policy exists
  ##default domain password details
  ##password complexity
  ##reversable encryption enabled
  ##last gpo modiified (x10)
  ##GPO report
  ##backs up the gpo's

  Sites and subnets
  ##lists all sites and subnets
  ###DC's in sites / ip / os /sysvol / subnets

  Exchange
  ##Forrest Schema version

  Skype
  ##Forrest Skype Version

  DNS
  ##DNS Stats
  ##DNS Static A records

  DHCP
  ##dhcp v4 options 
  ##Scope ranges

  Users and computers
  ##Computer objects and type (count)
  ###desktops / servers / unknown
  ##Computers not logged in in over 60 days
  ##User objects and type 
  ##users not logged in in over 60 days
  ##group objects and type
  ##Group lists 
  ##members of groups
  ###active / inactive
  ##detailed list of all machines
  ##detailed list of all users
  #no pass expire users

  #DFS
  ##dfs root

  #Print Servers
  ##List Print Servers 

  #WSUS Servers
  ##Lists servers
  ##classifications
  ##products

.NOTES
  Version:        1.0
  Purpose/Change: Initial script development
.ToDo

.EXAMPLE
Run script in host window
#>

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
    Add-Type -assembly 'system.io.compression.filesystem'
    Write-Host "Setting Global variables, this will take some time please be patient" -ForegroundColor Magenta      
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
$rootdir = 'C:\Temp\'
$Log_Location = ('C:\Temp\' + $date + '-ADReport\')
$Outputlocation = ($Log_Location)
$outputpath = ($Outputlocation + $date)
$logpath = ($Log_Location + $logcreated.ToString("yyyy-MM-dd_HH-mm") + "-AD_Script_Report.log")
$Log_Location_test = Test-Path -Path $Log_Location -ErrorAction $ErrorActionPreference

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
$dnszones = Get-DnsServerZone -ComputerName ($DCListFiltered | Select-Object -first 1) -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Select-Object zonename 
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
    $DNSReport | Export-Csv ($outputpath + '_DC_DNS_IP_Report.csv') -NoTypeInformation
    
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
    
    $Report | Export-Csv -Path ($outputpath + '_DNS_Zones.csv') -NoTypeInformation -Force -Confirm:$false
    
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
Write-Host "This must be ran as an admin account" -ForegroundColor Magenta      
Start-Sleep -Seconds 10

###########################################  Checking if Import Excell is installed  ###########################################
#Ignored for now
<#try {
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
}#>

###########################################  AD Forrest  ###########################################
write-log "###########################################  AD Forrest  ###########################################"
try {
    $SectionLog = ($outputpath + '-AD-Forrest_Report.txt')
    write-log ('Dedicated Log output to: ' + $SectionLog)
    #DCDIAG
    $dcdiagout = ($outputpath + '-DCDIAG.txt')
    Write-Log ('Performing DC Diag to ' + $dcdiagout)
    Write-Output ('Performing DC Diag to ' + $dcdiagout) >> $SectionLog
    $dcdiagdc = $DClist | Select-Object -First 1
    dcdiag /s:$dcdiagdc >> $dcdiagout
    dcdiag /s:$dcdiagdc

    #REPLYSum
    $repoutput = ($outputpath + '-REPLSUM.txt')
    Write-Log ('Performing rep admin ' + $repoutput )
    Write-Output ('Performing DC Diag to ' + $repoutput) >> $SectionLog
    repadmin /replsummary >> $repoutput
    repadmin /replsummary
        
    #Forrest name
    Write-Log "Forrest Name: $forest"
    Write-Output "Forrest Name: $forest" >> $SectionLog
    #Forrest SID
    Write-Log ('Forrest Domain SID: ' + $forestDomainSID.domainSID)
    Write-Output ('Forrest Domain SID: ' + $forestDomainSID.domainSID) >> $SectionLog
    #Forrest Distinguished Namne
    write-log "Forrest Distinguished Name: $forestDN"
    Write-Output "Forrest Distinguished Name: $forestDN" >> $SectionLog
    #Forrest Functional Version
    switch ($ffl) {
        #https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/active-directory-functional-levels
        Windows2000Forest { write-log "Forest Functional Level is: Windows 2000"; $FFVOut = "Forest Functional Level is: Windows 2000" }
        Windows2003Forest { write-log "Forest Functional Level is: Windows Server 2003"; $FFVOut = "Forest Functional Level is: Windows Server 2003" }
        Windows2008Forest { write-log "Forest Functional Level is: Windows Server 2008"; $FFVOut = "Forest Functional Level is: Windows Server 2008" }
        Windows2008R2Forest { write-log "Forest Functional Level is: Windows Server 2008 R2"; $FFVOut = "Forest Functional Level is: Windows Server 2008 R2" }
        Windows2012Forest { write-log "Forest Functional Level is: Windows Server 2012"; $FFVOut = "Forest Functional Level is: Windows Server 2012" }
        Windows2012R2Forest { write-log "Forest Functional Level is: Windows Server 2012 R2"; $FFVOut = "Forest Functional Level is: Windows Server 2012 R2" }
        Windows2016Forest { write-log "Forest Functional Level is: Windows Server 2016"; $FFVOut = "Forest Functional Level is: Windows Server 2016" }
        default { write-log "Unknown Forest Functional Level: $ffl"; $FFVOut = "Unknown Forest Functional Level: $ffl" }
   
    }
    Write-Output $FFVOut >> $SectionLog
    #AD Schema Version
    switch ($SchemaVersion.objectVersion) {
    
        13 { Write-Log ('AD Schema is: ' + $SchemaVersion.objectVersion + ' - Windows 2000 Server' ); $ADSVOut = ('AD Schema is: ' + $SchemaVersion.objectVersion + ' - Windows 2000 Server' ) }
        30 { Write-Log ('AD Schema is: ' + $SchemaVersion.objectVersion + ' - Windows Server 2003'  ); $ADSVOut = ('AD Schema is: ' + $SchemaVersion.objectVersion + ' - Windows Server 2003'  ) }
        31 { Write-Log ('AD Schema is: ' + $SchemaVersion.objectVersion + ' - Windows Server 2003 R2' ); $ADSVOut = ('AD Schema is: ' + $SchemaVersion.objectVersion + ' - Windows Server 2003 R2' ) }
        44 { Write-Log ('AD Schema is: ' + $SchemaVersion.objectVersion + ' - Windows Server 2008' ); $ADSVOut = ('AD Schema is: ' + $SchemaVersion.objectVersion + ' - Windows Server 2008' ) }
        47 { Write-Log ('AD Schema is: ' + $SchemaVersion.objectVersion + ' - Windows Server 2008 R2' ); $ADSVOut = ('AD Schema is: ' + $SchemaVersion.objectVersion + ' - Windows Server 2008 R2' ) }
        56 { Write-Log ('AD Schema is: ' + $SchemaVersion.objectVersion + ' - Windows Server 2012' ); $ADSVOut = ('AD Schema is: ' + $SchemaVersion.objectVersion + ' - Windows Server 2012' ) }
        69 { Write-Log ('AD Schema is: ' + $SchemaVersion.objectVersion + ' - Windows Server 2012 R2' ); $ADSVOut = ('AD Schema is: ' + $SchemaVersion.objectVersion + ' - Windows Server 2012 R2' ) }
        87 { Write-Log ('AD Schema is: ' + $SchemaVersion.objectVersion + ' - Windows Server 2016' ); $ADSVOut = ('AD Schema is: ' + $SchemaVersion.objectVersion + ' - Windows Server 2016' ) }
        88 { Write-Log ('AD Schema is: ' + $SchemaVersion.objectVersion + ' - Windows Server 2019' ); $ADSVOut = ('AD Schema is: ' + $SchemaVersion.objectVersion + ' - Windows Server 2019' ) }
        default { Write-Log ('unknown - AD Schema is: ' + $SchemaVersion ); $ADSVOut = ('unknown - AD Schema is: ' + $SchemaVersion ) }
    }
    Write-Output $ADSVOut >> $SectionLog
    #list all domains in forrest 
    write-log "Domains in Forrest:..."
    Write-Output "Domains in Forrest:..." >> $SectionLog
    $allDomains | Sort-Object | ForEach-Object { $_ } >> $SectionLog
    $allDomains | ForEach-Object { Write-Log " Domains in this forrest $_" }
    #list default upn suffix
    if (($UPNsuffix | Measure-Object).Count -eq 0) {
        Write-Log "UPN Suffix: NONE SET"
        Write-Output "UPN Suffix: NONE SET" >> $SectionLog
    }
    else {
        Write-Log "UPN Suffix: $UPNsuffix"
        Write-Output "UPN Suffix: $UPNsuffix" >> $SectionLog
    }
    Write-Log "FSMO Roles"
    Write-Output "FSMO Roles"
    #default naming master
    Write-Log "Domain Naming Master: $FSMODomainNaming"
    Write-Output "Domain Naming Master: $FSMODomainNaming" >> $SectionLog
    #schema master
    Write-Log "Schema Master: $FSMOSchema"
    Write-Output "Schema Master: $FSMOSchema" >> $SectionLog
    #GB or Global catalog servers
    Write-Log "All Global Catalogue Servers $ForestGC" 
    Write-Output "All Global Catalogue Servers:... "  >> $SectionLog
    $ForestGC | Sort-Object | ForEach-Object { $_ } >> $SectionLog
    #List of trusts
    $ADTrusts = Get-ADObject -Server $forest -Filter { objectClass -eq "trustedDomain" } -Properties CanonicalName, trustDirection
    Write-Output "AD Trusts:..." >> $SectionLog
    write-log "AD Trusts:..."
    if (($ADTrusts | Measure-Object).Count -gt 0) {
        
        foreach ($Trust in $ADTrusts) {

            switch ($Trust.trustDirection) {
                        
                3 { $trustInfo = ($Trust.CanonicalName).Replace("/System/", "  <===>  ") }
                2 { $trustInfo = ($Trust.CanonicalName).Replace("/System/", "  <----  ") }
                1 { $trustInfo = ($Trust.CanonicalName).Replace("/System/", "  ---->  ") }
                        
            }

            Write-log $trustInfo
            
            Write-Output $trustInfo >> $SectionLog
        }

    }

    else {
        
        Write-Log "NO AD Trusts Found"
        Write-Output "NO AD Trusts Found" >> $SectionLog
    }
    #Additional UPN suffixes
    Write-Log "Additional UPN Suffix(s)"
    write-output "Additional UPN Suffix(s)" >> $SectionLog
    if ( $UPNSuffix.Count -ne 0 ) {
        
        $UPNsuffix | Sort-Object | ForEach-Object { Write-log $_ }
        $UPNsuffix | Sort-Object | ForEach-Object { $_ } >> $SectionLog
    }
        
    else {
        
        Write-Log "No additional UPN Suffix's"
        Write-Output "No additional UPN Suffix's" >> $SectionLog
    }

    #Schema Admins #! missed off eq 2 is it needed# 
    $schemaGroupID = ((Get-ADDomain(Get-ADForest).name).domainSID).value + "-518"
    $schemaAdminsNo = Get-ADGroup -Server $forest -Identity $schemaGroupID | Get-ADGroupMember -Recursive
    Write-log ('Total number of Schema Administrators: ' + ($schemaAdminsNo | Measure-Object).Count)
    Write-Output ('Total number of Schema Administrators: ' + ($schemaAdminsNo | Measure-Object).Count) >> $SectionLog
    Write-Log ('Schema Admins are as follows : ' + ($schemaAdminsNo.samaccountname))
    Write-Output ('Schema Admins are as follows : ' + ($schemaAdminsNo.samaccountname)) >> $SectionLog
    $schemaAdminsNo | ForEach-Object { Get-object $_ | Select-Object * } | Export-Csv ($outputpath + '-Schema-Admins.csv') -Append -NoClobber -NoTypeInformation
       
    # Enterprise Admins #! missed off eq 1 is it needed# 
    $entGroupID = ((Get-ADDomain(Get-ADForest).name).domainSID).value + "-519"
    $enterpriseAdminsNo = Get-ADGroup -Server $forest -Identity $entGroupID | Get-ADGroupMember -Recursive 
    Write-Log ('Total number of Enterprise Administrators : ' + ($enterpriseAdminsNo | Measure-Object).Count)
    Write-Output ('Total number of Enterprise Administrators : ' + ($enterpriseAdminsNo | Measure-Object).Count) >> $SectionLog
    $enterpriseAdminsNo | ForEach-Object { write-log ('Enterprise Sam Account Name: ' + $_.samaccountname) } 
    $enterpriseAdminsNo | ForEach-Object { ('Enterprise Sam Account Name: ' + $_.samaccountname) >> $SectionLog } 
    $enterpriseAdminsNo | ForEach-Object { Get-adobject $_ | Select-Object * } | Export-Csv ($outputpath + '-Enterprise-Admins.csv') -Append -NoClobber -NoTypeInformation

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
$SectionLog = ($outputpath + '-Partitions_Report.txt')
write-log ('Dedicated Log output to: ' + $SectionLog)

# List of all partitions in a forest
$partitions = Get-ADObject -Server $forest -Filter * -SearchBase $ForestInfo.PartitionsContainer -SearchScope OneLevel -Properties name, nCName, msDS-NC-Replica-Locations | Select-Object name, nCName, msDS-NC-Replica-Locations | Sort-Object name
  
Write-Log "List of all partitions"
Write-Output "List of all partitions" >> $SectionLog
foreach ($part in $partitions) {
         
    Write-log ('Partition: ' + $part.name)
    Write-Output ('Partition: ' + $part.name) >> $SectionLog
    write-log $part.nCName
    Write-Output $part.nCName >> $SectionLog    
    $DNSServers = $part."msDS-NC-Replica-Locations" | Sort-Object
         
    # If any DNS server holds partition
    if ($DNSServers -ne $nul) {
                 
        Write-log "DNS servers"
        Write-Output "DNS servers" >> $SectionLog        
        # Get DNS Servers for selected partition
        foreach ($DNSServer in $DNSServers) {
                     
            Write-log ( ($DNSServer -Split ",")[1] -Replace "CN=", "")
            Write-Output ( ($DNSServer -Split ",")[1] -Replace "CN=", "") >> $SectionLog             
        }
                     
        # End of DNS servers list for selected partition
                     
    }
    # End IF section for DNS servers
          
}

###########################################  AD Domain  ###########################################
write-log "###########################################  AD Domain  ###########################################"
$SectionLog = ($outputpath + '-AD-Domain_Report.txt')
write-log ('Dedicated Log output to: ' + $SectionLog)
#DNS Distingushed name
Write-Log ('Distinguished name is: ' + $domainDN)
Write-Output ('Distinguished name is: ' + $domainDN) >> $SectionLog
#Domain SID
Write-Log ('Domain SID is: ' + $domainSID)
Write-Output ('Domain SID is: ' + $domainSID) >> $SectionLog
#DNS Domain Name
Write-Log ('DNS Domain Name is: ' + $domain)
Write-Output ('DNS Domain Name is: ' + $domain) >> $SectionLog
#Netbios
write-log ('Netbios is: ' + $NetBIOS)
Write-Output ('Netbios is: ' + $NetBIOS) >> $SectionLog
Write-Log "FSMO Roles"
Write-Output "FSMO Roles"
#PDC Emulator master
write-log ('PDC Emulator Master is: ' + $FSMOPDC)
Write-Output ('PDC Emulator Master is: ' + $FSMOPDC) >> $SectionLog
#RID Master
write-log ('RID Master is: ' + $FSMORID)
Write-Output ('RID Master is: ' + $FSMORID) >> $SectionLog
#Infrastructuree master
write-log ('Infratsucture Master is: ' + $FSMOInfrastructure)
Write-Output ('Master is: ' + $FSMOInfrastructure) >> $SectionLog
#Domain Functional Level
write-log ('Domain Functional Level is: ' + $dfl)
Write-Output ('Domain Functional Level is: ' + $dfl) >> $SectionLog
#Domain Controllers
write-log ('Domain Controllers:... ')
Write-Output "Domain Controllers:..." >> $SectionLog
$DClist | ForEach-Object { Write-Log $_ }
$DClist | ForEach-Object { $_ } >> $SectionLog
#RO Domain Controllers 
if (($RODCList | Measure-Object).Count -gt 0) {
    Write-Log ('RO Domain Controllers:... ')
    Write-Output ('RO Domain Controllers:...') >> $SectionLog
    $RODCList | ForEach-Object { Write-Log $_ }
    $RODCList | ForEach-Object { $_ } >> $SectionLog
}
else {
    Write-Log "No Read Only Domain Controllers"
    Write-Output "No Read Only Domain Controllers" >> $SectionLog
}
#Azure
$msoluser = get-aduser -Filter * | Where-Object { $_.Name -match "msol" }
if ($msoluser.count -gt 0) {
    Write-Log "MSOL user found"
    Write-Output "MSOL user found" >> $SectionLog
    get-aduser -Filter * -Properties * | Where-Object { $_.Name -match "msol" } | Select-Object * >> $SectionLog

}
else {
    Write-Log "No MSOL user found"
    Write-Output "No MSOL user found" >> $SectionLog
}

#Domain admins amount and who
write-log "Current count of Domain Admins is: $domainAdminsNo"
Write-Output "Current count of Domain Admins is: $domainAdminsNo" >> $SectionLog
write-log "Domain Admins are:..."
Write-Output "Domain Admins are:..." >> $SectionLog
$domainAdminsNames | ForEach-Object { write-log $_.samaccountname }
$domainAdminsNames | ForEach-Object { $_.samaccountname } >> $SectionLog
$domainAdminsNames | ForEach-Object { Get-ADobject $_  -Properties * | Select-Object *} | Export-Csv ($outputpath + '-AD-Domain-Admins.csv') -Append
write-log ('File created at: ' + ($outputpath + '-AD-Domain-Admins.csv'))
Write-Output ('Detailed log of Admin users created at: ' + ($outputpath + '-AD-Domain-Admins.csv')) >> $SectionLog
#Built-in Domain Administrator account details > last logon etc 
Write-Log ('Builtin Admin Name: ' + $builtinAdmin.Name)
Write-Output ('Builtin Admin Name: ' + $builtinAdmin.Name) >> $SectionLog
Write-Log ('Builtin Admin Enabled: ' + $builtinAdmin.Enabled)
Write-Output ('Builtin Admin Enabled: ' + $builtinAdmin.Enabled) >> $SectionLog
Write-Log ('Builtin Admin Last Logged on: ' + $builtinAdmin.LastLogonDate)
Write-Output ('Builtin Admin Last Logged on: ' + $builtinAdmin.LastLogonDate) >> $SectionLog
Write-Log ('Builtin Admin Last Password set on: ' + $builtinAdmin.PasswordLastSet)
Write-Output ('Builtin Admin Last Password set on: ' + $builtinAdmin.PasswordLastSet)>> $SectionLog
Write-Log ('Builtin Admin Password Never Expires: ' + $builtinAdmin.PasswordNeverExpires)
Write-Output ('Builtin Admin Password Never Expires: ' + $builtinAdmin.PasswordNeverExpires) >> $SectionLog

###########################################  OU  ###########################################
write-log "###########################################  OU  ###########################################"
$SectionLog = ($outputpath + '-OU_Report.txt')
write-log ('Dedicated Log output to: ' + $SectionLog)
#Default domain computer objects location #!# no checks on redirect as it needs a better method
write-log ('Defailt Computer OU: ' + $cmp_location)
Write-Output ('Defailt Computer OU: ' + $cmp_location) >> $SectionLog
#Default domain user objects location #!# no checks on redirect as it needs a better method
write-log ('Defailt Computer OU: ' + $usr_location )
Write-Output ('Defailt Computer OU: ' + $usr_location ) >> $SectionLog
#orphaned objects 
$orphanedCount = (Get-ADObject -Filter * -SearchBase "cn=LostAndFound,$($domainDN)" -SearchScope OneLevel | Measure-Object).Count
$Orphaned = Get-ADObject -Filter * -SearchBase "cn=LostAndFound,$($domainDN)" -SearchScope OneLevel 
Write-Log ('Orphaned Objects Found: ' + $orphanedCount)
Write-Output ('Orphaned Objects Found: ' + $orphanedCount) >> $SectionLog
Write-Log ('Orphaned Objects Names:.. ') 
Write-Output ('Orphaned Objects Names:.. ') >> $SectionLog
$orphaned.Name | ForEach-Object { $_ } >> $SectionLog
$orphaned.Name | ForEach-Object { write-log $_ }
#lingering or replication conflict objects 
$lingConfReplCount = (Get-ADObject -LDAPFilter "(cn=*\0ACNF:*)" -SearchBase $domainDN -SearchScope SubTree | Measure-Object).Count
$lingConfRepl = Get-ADObject -LDAPFilter "(cn=*\0ACNF:*)" -SearchBase $domainDN -SearchScope SubTree
Write-Log ('Lingering or replication conflict objects found: ' + $lingConfReplCount)
Write-Output ('Lingering or replication conflict objects found: ' + $lingConfReplCount) >> $SectionLog
Write-Log ('Lingering or replication conflict objects:... ') 
Write-Output ('Lingering or replication conflict objects:... ') >> $SectionLog
$lingConfRepl.Name | ForEach-Object { $_ } >> $SectionLog
$lingConfRepl.Name | ForEach-Object { Write-Log $_ } 
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
Write-Output ('AD Recycle bin is: ' + $ADRecBinSupport) >> $SectionLog
#Tombstone lifetime
$tombstoneLifetime = (Get-ADObject -Server $forest -Identity "cn=Directory Service,cn=Windows NT,cn=Services,$configPartition" -Properties tombstoneLifetime).tombstoneLifetime
write-log ('Tombstone Lifetime is (Days): ' + $tombstoneLifetime)
Write-Output ('Tombstone Lifetime is (Days): ' + $tombstoneLifetime) >> $SectionLog
#ou objects
$ou_objectsNo = (Get-ADOrganizationalUnit -Server $domain -Filter * | Measure-Object).Count
$ouobjectsDN = Get-ADOrganizationalUnit -Server $domain -Filter * | Select-Object Name, DistinguishedName, ObjectGUID
$OUReportConfig = ($outputpath + '-OU_Config.csv')
write-log ('OU Objects Totals: ' + $ou_objectsNo)
Write-Output ('OU Objects Totals: ' + $ou_objectsNo) >> $SectionLog
$ouobjectsDN | Export-Csv $OUReportConfig -Append
write-log ('File created: ' + $OUReportConfig)
Write-Output ('File created: ' + $OUReportConfig) >> $SectionLog
###########################################  GPO  ###########################################
Write-Log "###########################################  GPO  ###########################################"
$SectionLog = ($outputpath + '-GPO_Report.txt')
write-log ('Dedicated Log output to: ' + $SectionLog)

#Default Domain policy
$gpoDefaultDomain = Get-ADObject -Server $domain -LDAPFilter "(&(objectClass=groupPolicyContainer)(cn={31B2F340-016D-11D2-945F-00C04FB984F9}))"             
if ($gpoDefaultDomain -ne $nul) {

    write-log "Default Domain Policy Exists"
    Write-Output "Default Domain Policy Exists" >> $SectionLog
}

else {

    write-log "Default Domain Policy DOES NOT EXIST" -Level Err
    Write-Output "Default Domain Policy DOES NOT EXIST" >> $SectionLog

}

#Default Domain Controllers policy 
$gpoDefaultDomainController = Get-ADObject -Server $domain -LDAPFilter "(&(objectClass=groupPolicyContainer)(cn={6AC1786C-016F-11D2-945F-00C04fB984F9}))"

if ($gpoDefaultDomainController -ne $nul) {

    Write-Log "Default Domain Controllers policy Exists"
    Write-Output "Default Domain Controllers policy Exists" >> $SectionLog

}

else {

    Write-Log "Default Domain Controllers policy DOES NOT Exist" 
    Write-Output "Default Domain Controllers policy DOES NOT Exist"  >> $SectionLog

}

#Default Domain Password Policy details
Write-log "Default Domain Password Policy details:"
Write-Output "Default Domain Password Policy details:" >> $SectionLog
Write-Log ('Minimum password age: ' + $pwdGPO.MinPasswordAge.days + ' day(s)')
Write-Output ('Minimum password age: ' + $pwdGPO.MinPasswordAge.days + ' day(s)') >> $SectionLog
Write-Log ('Maximum password age: ' + $pwdGPO.MaxPasswordAge.days + ' day(s)')
Write-Output ('Maximum password age: ' + $pwdGPO.MaxPasswordAge.days + ' day(s)') >> $SectionLog
Write-Log ('Minimum password length: ' + $pwdGpo.MinPasswordLength + ' character(s)')
Write-Output ('Minimum password length: ' + $pwdGpo.MinPasswordLength + ' character(s)') >> $SectionLog
Write-Log ('Password history count: ' + $pwdGPO.PasswordHistoryCount + ' unique password(s)')
Write-Output ('Password history count: ' + $pwdGPO.PasswordHistoryCount + ' unique password(s)') >> $SectionLog
#password complexity        
if ( $pwdGPO.ComplexityEnabled ) {
            
    Write-Log "Password Complexity Enaled: Yes "
    Write-Output "Password Complexity Enaled: Yes " >> $SectionLog
            
}
            
else {
            
    Write-Log "Password Complexity Enaled: No "
    Write-Output "Password Complexity Enaled: No " >> $SectionLog
            
}
#reversable encryption
if ( $pwdGPO.ReversibleEncryptionEnabled ) {
            
    Write-Log "Password uses reversible encryption: Yes "
    Write-Output "Password uses reversible encryption: Yes " >> $SectionLog
            
}
            
else {
            
    Write-Log "Password uses reversible encryption: No "
    Write-Output "Password uses reversible encryption: No " >> $SectionLog
            
}

#Last 10 GPO Modified
write-log "Last 10 GPO's Modified"
Write-Output "Last 10 GPO's Modified" >> $SectionLog
$GPOsModifiedlist = Get-GPO -all | Sort-Object ModificationTime -Descending | Select-Object -First 10 | Select-Object DisplayName, ModificationTime
foreach ($gpomodifiedlist in $gposmodifiedlist) {
    write-log ('GPO Name: ' + $gpomodifiedlist.DisplayName + ' On the ' + $gpomodifiedlist.ModificationTime)
    Write-Output ('GPO Name: ' + $gpomodifiedlist.DisplayName + ' On the ' + $gpomodifiedlist.ModificationTime) >> $SectionLog
}
write-log "All GPO's"
Write-Output "all GPO's" >> $SectionLog
get-gpo -All >> $SectionLog
get-gpo -All | select-object displayname
get-gpo -All | Select-Object * | Export-Csv ($outputpath + '_GPO_names.csv') -NoTypeInformation

#GPO HTML
write-log "All GPO's HTML"
Write-Output "all GPO's HTML" >> $SectionLog
$gponames = get-gpo -All | select-object displayname
New-Item -Path ($Outputlocation + "\GPO_HTML") -ItemType Directory -ErrorAction SilentlyContinue
foreach ($gponame in $gponames) {
    $gponameTostring = $gponame.DisplayName

    $gpohtmlname = $gponameTostring -replace (' ', '')

    $gpohtmlname1 = $gpohtmlname -replace ('"', "")
    $gpohtmlname2 = $gpohtmlname1 -replace ("!", "")
    $gpohtmlnamelast = $gpohtmlname2 -replace ("/", "")
    write-log ('name changed from ' + $gpohtmlname + ' to ' + $gpohtmlnamelast )
    Write-Output ('name changed from ' + $gpohtmlname + ' to ' + $gpohtmlnamelast )>> $SectionLog
    Get-GPOReport $gponame.displayname -ReportType Html -Path ($Outputlocation + "\GPO_HTML\" + $gpohtmlnamelast + '.html') -ErrorAction SilentlyContinue
} 

#GPO Report 
$GPOServer = Get-ADDomainController -Discover | Select-Object -ExpandProperty HostName
Write-Log ('Creating Report of GPO(s) in ' + $outputpath )
Write-Output ('Creating Report of GPO(s) in ' + $outputpath ) >> $SectionLog
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

            # If an OU has 'Block Inheritance' set (gPOptions=1) and no GPOs linked,
            # then the gPLink attribute is no longer null but a single space.
            # There will be no gPLinks to parse, but we need to list it with BlockInheritance.
            If ($SOM.gPLink.length -gt 1) {
                $links = @($SOM.gPLink -split { $_ -eq '[' -or $_ -eq ']' } | Where-Object { $_ })
                # Use a for loop with a counter so that we can calculate the precedence value
                For ( $i = $links.count - 1 ; $i -ge 0 ; $i-- ) {
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
    Export-Csv ($outputpath + "-gPLink_Report_Sorted_Metadata.csv") -NoTypeInformation

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
Write-Output "" >> $SectionLog

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
$SectionLog = ($outputpath + '-Sites_and_Subnets_Report.txt')
write-log ('Dedicated Log output to: ' + $SectionLog)
#sites
$ConfigurationPart = ($ForestInfo.PartitionsContainer -Replace "CN=Partitions,", "")
$AllSites = Get-ADObject -Server $forest -Filter { objectClass -eq "site" } -SearchBase $ConfigurationPart -Properties *
Write-Log "Sites Enumeration:...."
Write-Output "Sites Enumeration:...." >> $SectionLog

# Loop for Sites and Subnets
foreach ( $Site in $AllSites ) {
     
    write-log ('Site: ' + $Site.Name)
    Write-Output ('Site: ' + $Site.Name) >> $SectionLog
    write-log "Server(s) in site:"
    Write-Output "Server(s) in site:" >> $SectionLog
    $ServersInSite = Get-ADObject -Server $forest -Filter { objectClass -eq "server" } -SearchBase $Site.distinguishedName -SearchScope Subtree -Properties Name | Select-Object Name | Sort-Object Name
    # Loop for Domain Controller details
    foreach ($SiteServer in $ServersInSite) {

        # If any DC is in Site
        if ( $SiteServer -ne $nul ) {
                         
            $dcDetails = Get-ADDomainController $SiteServer.Name -ErrorAction SilentlyContinue
            if (Test-Connection $server -Quiet) {
                Write-Log ('Can sucsessfully connect to DC: ' + $dcDetail)
                Write-Output ('Can sucsessfully connect to DC: ' + $dcDetail) >> $SectionLog
        
            } 
            else {
                Write-Log ('Can NOT connect to DC: ' + $dcDetail) -Level Error
                Write-Output ('Can NOT connect to DC: ' + $dcDetail) >> $SectionLog
            }

            $dcDN = $dcDetails.ComputerObjectDN -Replace $dcDetails.Name, ""
            $dcDN = $dcDN -Replace "CN=,", ""

            $dcFRS = "CN=Domain System Volume (SYSVOL share),CN=NTFRS Subscriptions,$($dcdetails.computerobjectdn)"
            $dcDFSR = "CN=SYSVOL Subscription,CN=Domain System Volume,CN=DFSR-LocalSettings,$($dcdetails.computerobjectdn)"

            $dcFRSinfo = Get-ADObject -Filter { distinguishedName -eq $dcFRS } -Properties fRSRootPath
            $dcDFSRinfo = Get-ADObject -Filter { distinguishedName -eq $dcDFSR } -Properties msDFSR-RootPath, msDFSR-RootSizeInMb

            # Display Domain Controller details
            write-log ($SiteServer.Name + '(' + $dcDN + ')')
            Write-Output ($SiteServer.Name + '(' + $dcDN + ')') >> $SectionLog
            write-log ('IP address (v4): ' + $dcDetails.ipv4address)
            Write-Output ('IP address (v4): ' + $dcDetails.ipv4address) >> $SectionLog

            # IPv6 address
            if ($dcDetails.ipv6address -ne $nul) {
                             
                write-log ('IP address (v6): ' + $dcDetails.ipv6address)
                Write-Output ('IP address (v6): ' + $dcDetails.ipv6address) >> $SectionLog
                             
            }
                             
            else {
                             
                write-log "IP address (v6):  (none)"
                Write-Output "IP address (v6):  (none)" >> $SectionLog
                           
            }
                                
            # Operating system type and its service pack level
            write-log ('OS type: ' + $dcDetails.operatingSystem)
            Write-Output ('OS type: ' + $dcDetails.operatingSystem) >> $SectionLog

            if ($dcDetails.operatingSystemServicePack -ne $nul) {
                             
                write-log ('Service Pack: ' + $dcDetails.operatingSystemServicePack)
                Write-Output ('Service Pack: ' + $dcDetails.operatingSystemServicePack) >> $SectionLog
                             
            }
            # End of operating system and service pack level section
                         
            # SYSVOL replication method on DC
            # SYSVOL FRS section
            if ($dcFRSinfo -ne $nul) {
                             
                write-log "SYSVOL replication :  FRS"
                Write-Output "SYSVOL replication :  FRS" >> $SectionLog
                write-log ('SYSVOL location: ' + $dcFRSinfo.fRSRootPath)
                Write-Output ('SYSVOL location: ' + $dcFRSinfo.fRSRootPath) >> $SectionLog
                            
            }
            # End of SYSVOL FRS section

            # SYSVOL DFS-R section
            if ($dcDFSRinfo -ne $nul) {
                             
                write-log  "SYSVOL replication:  DFS-R"
                Write-Output "SYSVOL replication:  DFS-R" >> $SectionLog
                write-log  ('SYSVOL location: ' + $dcDFSRinfo."msDFSR-RootPath")
                Write-Output ('SYSVOL location: ' + $dcDFSRinfo."msDFSR-RootPath") >> $SectionLog

                # SYSVOL size
                if ($dcDFSRinfo."msDFSR-RootSizeInMb" -ne $nul) {
                                     
                    write-log ('SYSVOL quota: ' + $dcDFSRinfo."msDFSR-RootSizeInMb")
                    Write-Output ('SYSVOL quota: ' + $dcDFSRinfo."msDFSR-RootSizeInMb") >> $SectionLog
                                     
                }
                                     
                else {
                                     
                    write-log "SYSVOL quota:  4GB (default setting)"
                    Write-Output "SYSVOL quota:  4GB (default setting)" >> $SectionLog
                                     
                }
                # End of SYSVOL size
                                 
            }
            # End of SYSVOL DFS-R section

        }
        # End of section where DC is in Site    
                 
        # If no DC in Site
        else {
                 
            Write-Log "(none)"
            Write-Output "(none)" >> $SectionLog
                 
        }
        # End of section where no DC in Site

    } # End of sub foreach for Domain Controllers details
             
    # List Subnets for selected Site
    $subnets = $Site.siteObjectBL

    Write-log "Subnets:"
    Write-Output "Subnets:" >> $SectionLog

    # If any Subnet assigned
    if ( $subnets -ne $nul ) {
         
        # List all Subnets for selected Site
        foreach ($subnet in $subnets) {
                             
            $SubnetSplit = $Subnet.Split(",")
            Write-log ($SubnetSplit[0].Replace("CN=", ""))
            Write-Output ($SubnetSplit[0].Replace("CN=", "")) >> $SectionLog
                             
        }
        # End of listing Subnets

    }
    # End of existing Subnets section
     
    # If no Subnets in Site
    else {
                     
        Write-log "(none)"
        Write-Output "(none)" >> $SectionLog
                     
    }
    # End of no Subnets section
         
    # End of listing Subnets
 
} # End of main foreach for Sites and Subnets
     
# End of Sites section

###########################################  Exchange  ###########################################
Write-Log "###########################################  Exchange  ###########################################"
$SectionLog = ($outputpath + '-Exchange_Report.txt')
write-log ('Dedicated Log output to: ' + $SectionLog)
#Microsoft Exchange version
$ExchangeSystemObjects = Get-ADObject -Server $forest -LDAPFilter "(&(objectClass=container)(name=Microsoft Exchange System Objects))" -SearchBase $forestDN -Properties objectVersion
$ExchangeSchemaVersion = Get-ADObject -Server $forest -LDAPFilter "(&(objectClass=attributeSchema)(name=ms-Exch-Schema-Version-Pt))" -SearchBase $SchemaPartition -Properties rangeUpper

$ExchangeSchema = $ExchangeSystemObjects.objectVersion + $ExchangeSchemaVersion.rangeUpper
Write-Log "Finding Exchange Schema Version"
Write-Output "Finding Exchange Schema Version" >> $SectionLog
if ($ExchangeSchemaVersion -ne $nul) {
        
    switch ($ExchangeSchema) {
        4397 { write-log "Exchange 2000 RTM"; $ESV = "Exchange 2000 RTM" }
        4397 { write-log "Exchange 2000 SP1"; $ESV = "Exchange 2000 SP1" }
        4406 { write-log "Exchange 2000 SP2/SP3"; $ESV = "Exchange 2000 SP2/SP3" }
        6870 { write-log "Exchange 2003 RTM / SP1 / SP2"; $ESV = "Exchange 2003 RTM / SP1 / SP2" }
        10637 { write-log "Exchange 2007 RTM"; $ESV = "Exchange 2007 RTM" }
        11116 { write-log "Exchange 2007 SP1"; $ESV = "Exchange 2007 SP1" }
        14622 { write-log "Exchange 2007 SP2"; $ESV = "Exchange 2007 SP2" }
        14625 { write-log "Exchange 2007 SP3"; $ESV = "Exchange 2007 SP3" }
        14622 { write-log "Exchange 2010 RTM"; $ESV = "Exchange 2010 RTM" }
        14726 { write-log "Exchange 2010 SP1"; $ESV = "Exchange 2010 SP1" }
        14732 { write-log "Exchange 2010 SP2"; $ESV = "Exchange 2010 SP2" }
        14734 { write-log "Exchange 2010 SP3"; $ESV = "Exchange 2010 SP3" }
        15137 { write-log "Exchange 2013 RTM"; $ESV = "Exchange 2013 RTM" }
        15254 { write-log "Exchange 2013 CU1"; $ESV = "Exchange 2013 CU1" }
        15281 { write-log "Exchange 2013 CU2"; $ESV = "Exchange 2013 CU2" }
        15283 { write-log "Exchange 2013 CU3"; $ESV = "Exchange 2013 CU3" }
        15292 { write-log "Exchange 2013 SP1 (CU4)"; $ESV = "Exchange 2013 SP1 (CU4)" }
        15300 { write-log "Exchange 2013 CU5"; $ESV = "Exchange 2013 CU5" }
        15303 { write-log "Exchange 2013 CU6"; $ESV = "Exchange 2013 CU6" }
        15312 { write-log "Exchange 2013 CU7 - 21"; $ESV = "Exchange 2013 CU7 - 21" }
        15317 { write-log "Exchange 2016 RTM"; $ESV = "Exchange 2016 RTM" }
        15323 { write-log "Exchange 2016 CU1"; $ESV = "Exchange 2016 CU1" }
        15325 { write-log "Exchange 2016 CU2"; $ESV = "Exchange 2016 CU2" }
        15326 { write-log "Exchange 2016 CU3 - 5"; $ESV = "Exchange 2016 CU3 - 5" }
        15330 { write-log "Exchange 2016 CU6"; $ESV = "Exchange 2016 CU6" }
        15332 { write-log "Exchange 2016 CU7 - 11"; $ESV = "Exchange 2016 CU7 - 11" }
        17000 { write-log "Exchange 2019 RTM"; $ESV = "Exchange 2019 RTM" }
        
        default { write-log ('unknown - ' + $ExchangeSchemaVersion.rangeUpper); $ESV = ('unknown - ' + $ExchangeSchemaVersion.rangeUpper) }
                    
    }
    Write-Output ('Exchange Schema version is:' + $ESV) >> $SectionLog
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
    Write-Output "Exchange Schema not present" >> $SectionLog
        
}

###########################################  Skype  ###########################################
write-log "###########################################  Skype  ###########################################"
$SectionLog = ($outputpath + '-Skype_Report.txt')
write-log ('Dedicated Log output to: ' + $SectionLog)
#Microsoft Lync/Skype Schema version
write-log "Skype Schema Version:...."
Write-Output "Skype Schema Version:...." >> $SectionLog
$LyncSchemaVersion = Get-ADObject -Server $forest -LDAPFilter "(&(objectClass=attributeSchema)(name=ms-RTC-SIP-SchemaVersion))" -SearchBase $SchemaPartition -Properties rangeUpper

if ($LyncSchemaVersion -ne $nul) {
    
    switch ($LyncSchemaVersion.rangeUpper) {
            
        1006 { Write-Log "Live Communications Server 2005" ; $SSV = "Live Communications Server 2005" }
        1007 { Write-Log "Office Communications Server 2007 Release 1" ; $SSV = "Office Communications Server 2007 Release 1" }
        1008 { Write-Log "Office Communications Server 2007 Release 2" ; $SSV = "Office Communications Server 2007 Release 2" }
        1100 { Write-Log "Lync Server 2010" ; $SSV = "Lync Server 2010" }
        1150 { Write-Log "Lync Server 2013 / Skype 2015+" ; $SSV = "Lync Server 2013 / Skype 2015+" }
        default { write-log ('unknown - ' + $LyncSchemaVersion.rangeUpper ) ; $SSV = ('unknown - ' + $LyncSchemaVersion.rangeUpper ) }
            
    }
    Write-Output $SSV >> $SectionLog
}# end if
    
else {
    
    Write-Log "(not present)"
    Write-Output "(not present)" >> $SectionLog
    
}
###########################################  DNS  ###########################################
write-log "###########################################  DNS  ###########################################"
$SectionLog = ($outputpath + '-DNS_Report.txt')
write-log ('Dedicated Log output to: ' + $SectionLog)
#DNS Zone Information

<# Code needs reviewing #!
Write-log ('Exporting reports on DNS')
Write-Output ('Exporting reports on DNS') >> $SectionLog
foreach ($dnszone in $dnszones) {
    Write-Log ('Collecting information on zone: ' + $dnszone.zonename)
    Write-Output ('Collecting information on zone: ' + $dnszone.zonename) >> $SectionLog
    Export-DNSServerZoneReport -Domain $dnszone.zonename >> $logpath
    Export-DNSServerIPConfiguration -Domain $dnszone.zonename >> $logpath
    Export-DNSServerZoneReport -Domain $dnszone.zonename >> $SectionLog
    Export-DNSServerIPConfiguration -Domain $dnszone.zonename >> $SectionLog
}#>

#DNS Stats
$DNSstats = ($outputpath + '-DNS_Stats.txt')
$dnsdc = $DClist | Select-Object -First 1
Write-Log ('Exporting DNS server info to: ' + $DNSStats)
Write-Output ('Exporting DNS Server info to: ' + $DNSStats) >> $SectionLog
Get-DnsServerResourceRecord -ComputerName $dnsdc -ZoneName $domain -RRType "NS" | format-table -AutoSize
Get-DnsServerResourceRecord -ComputerName $dnsdc -ZoneName $domain -RRType "NS" | format-table -AutoSize >> $DNSstats
Get-DnsServer -ComputerName $dnsdc
Get-DnsServer -ComputerName $dnsdc >> $DNSstats
Write-Log ('Exporting DNS Statistics to: ' + $DNSStats)
Write-Output ('Exporting DNS Statistics to: ' + $DNSStats) >> $SectionLog
Get-DnsServerZone | Select-Object zonename | Get-DnsServerStatistics >> $DNSstats

#DNS Static A Records
Write-Log "Exporting Static A records"
Write-Output "Exporting Static A records" >> $SectionLog

foreach ($StaticARecord in $dnszones) {
    $DNS_A_SRecord = ($outputpath + '-DNS-Stating-A-Recordlocation.csv')
    Get-DnsServerResourceRecord -ZoneName $zone.zonename -RRType A | Where-Object { -not $_.TimeStamp } | Select-Object * | Export-Csv $DNS_A_SRecord -Append

}
Write-Log ('File Created at: ' + $DNS_A_SRecord )
Write-Output ('File Created at: ' + $DNS_A_SRecord ) >> $SectionLog

###########################################  DHCP  ###########################################
Write-Log "###########################################  DHCP  ###########################################"
$SectionLog = ($outputpath + '-DHCP_Report.txt')
write-log ('Dedicated Log output to: ' + $SectionLog)
write-log "Listing DHCP Servers in AD..."
Write-Output "Listing DHCP Servers in AD..." >> $SectionLog
$dhcpservers = Get-DhcpServerInDC
$dhcpservers = Get-DhcpServerInDC
if ($dhcpservers.count -eq 0) {
    write-log "NO DHCP Servers found in AD..."
    Write-Output "NO DHCP Servers found in AD..." >> $SectionLog
}
else {
    write-log "DHCP Servers in AD..."
    Write-Output " DHCP Servers in AD..." >> $SectionLog
    foreach ($dhcpserver in $dhcpservers ) {
        $testDHCPServerActive = Test-Connection -ComputerName $dhcpserver -Quiet
        if ($testDHCPServerActive -eq $true) {
            $DHCPSERVERRESPONSE = ('DHCP Server Responded to ping: ' + $dhcpserver)
            write-log $DHCPSERVERRESPONSE 
            write-output $DHCPSERVERRESPONSE  >> $SectionLog
            write-log ('DHCP Server Name: ' + $dhcpserver.DNSName + ' on the IP: ' + $dhcpserver.IPAddress + ' Is Active: ' + $testDHCPServerActive)
            Write-Output ('DHCP Server Name: ' + $dhcpserver.DNSName + ' on the IP: ' + $dhcpserver.IPAddress + ' Is Active: ' + $testDHCPServerActive) >> $SectionLog

        }
        else {
            $DHCPSERVERRESPONSE = ('DHCP Server DID NOT RESPOND to ping: ' + $dhcpserver)
            write-log ('DHCP Server Name: ' + $dhcpserver.DNSName + ' on the IP: ' + $dhcpserver.IPAddress + ' Is Active: ' + $testDHCPServerActive)
            Write-Output ('DHCP Server Name: ' + $dhcpserver.DNSName + ' on the IP: ' + $dhcpserver.IPAddress + ' Is Active: ' + $testDHCPServerActive) >> $SectionLog
            write-log $DHCPSERVERRESPONSE 
            write-output $DHCPSERVERRESPONSE  >> $SectionLog
        }

        #DHCP V4 Options
        Write-Log "Exporting DHCP v4 Options"
        Write-Output "Exporting DHCP v4 Options" >> $SectionLog
        $DHCPv4OptionsReport = ($outputpath + '-DHCPv4OptionsOutput.csv')
        write-log "Getting Information from $dhcpserverSelected"
        write-output "Getting Information from $dhcpserverSelected" >> $sectionlog
        Get-DhcpServerv4Scope -ComputerName $dhcpserverSelected.IPAddress | Get-DhcpServerv4OptionValue >> $logpath
        Get-DhcpServerv4Scope -ComputerName $dhcpserverSelected.IPAddress | Get-DhcpServerv4OptionValue >> $SectionLog
        Get-DhcpServerv4Scope -ComputerName $dhcpserverSelected.IPAddress | Get-DhcpServerv4OptionValue | Export-Csv $DHCPv4OptionsReport -Append
        Write-Log ('File created at: ' + $DHCPv4OptionsReport)
        Write-Output ('File created at: ' + $DHCPv4OptionsReport) >> $SectionLog

        #Scope Ranges
        $DHCPv4ScopeReport = ($outputpath + 'DHCPv4ScopeReport.csv')
        write-log "Exporting DHCP Scope"
        Write-Output "Exporting DHCP Scope" >> $SectionLog
        $DHCPReport = @()
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
                        $DHCPReport += $row }
                }
                Else {
                    Write-Host -foregroundcolor Yellow """$($dhcpscope.DNSName)"" is either running Windows 2003, or is somehow not responding to querries. Adding to report as blank"
                    $row = "" | Select-Object Hostname, ScopeID, SubnetMask, Name, State, StartRange, EndRange, LeaseDuration, Description, DNS1, DNS2, DNS3, GDNS1, GDNS2, GDNS3, Router
                    $row.Hostname = $dhcpscope.DNSName
                    $DHCPReport += $row
                }
            }
            Else {
                write-log "Could not connect to DHCP Server"
                Write-Output "" >> $SectionLog
                $row = "" | Select-Object Hostname, ScopeID, SubnetMask, Name, State, StartRange, EndRange, LeaseDuration, Description, DNS1, DNS2, DNS3, GDNS1, GDNS2, GDNS3, Router
                $row.Hostname = $dhcpscope.DNSName
                $DHCPReport += $row
            }
            write-log ('Completed processing: ' + $dhcpscope.DNSName)
            Write-Output "" >> $SectionLog
        }

        $DHCPv4ScopeReport | Export-Csv -NoTypeInformation -UseCulture $DHCPv4ScopeReport
        write-log ('File Created at ' + $DHCPv4ScopeReport)
        Write-Output ('File Created at ' + $DHCPv4ScopeReport) >> $SectionLog
    }
}
###########################################  users & Computers  ###########################################
Write-Log "###########################################  Users & Computers  ###########################################"
$SectionLog = ($outputpath + '-Users_and_Computers_Report.txt')
write-log ('Dedicated Log output to: ' + $SectionLog)

#computer objects and type
Write-Log "Computer Objects in Domain"
Write-Output "Computer Objects in Domain" >> $SectionLog
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
Write-Output ('Total Computer Objects: ' + $cmp_objectsNo) >> $SectionLog
Write-Output ('Windows 2000: ' + $cmp_os_2000) >> $SectionLog
Write-Output ('Windows XP: ' + $cmp_os_xp) >> $SectionLog
Write-Output ('Windows 7: ' + $cmp_os_7) >> $SectionLog
Write-Output ('Windows 8: ' + $cmp_os_8) >> $SectionLog
Write-Output ('Windows 8.1: ' + $cmp_os_81) >> $SectionLog
Write-Output ('Windows 10: ' + $cmp_os_10) >> $SectionLog
Write-Output ('Windows Server 2000: ' + $cmp_srvos_2000) >> $SectionLog
Write-Output ('Windows Server 2003: ' + $cmp_srvos_2003) >> $SectionLog
Write-Output ('Windows Server 2008: ' + $cmp_srvos_2008) >> $SectionLog
Write-Output ('Windows Server 2008R2: ' + $cmp_srvos_2008r2) >> $SectionLog
Write-Output ('Windows Server 2012: ' + $cmp_srvos_2012) >> $SectionLog
Write-Output ('Windows Server 2012R2: ' + $cmp_srvos_2012r2) >> $SectionLog
Write-Output ('Windows Server 2016: ' + $cmp_srvos_2016) >> $SectionLog
Write-Output ('Windows Server 2019: ' + $cmp_srvos_2019) >> $SectionLog
Write-Output ('OS(s) Not Filtered for: ' + $cmp_os_unkwn) >> $SectionLog
#Computers
write-log "Exporting report on AD Computers"
Write-Output "Exporting report on AD Computers" >> $SectionLog
$comps= Get-ADComputer  -Properties * -Filter * | Select-Object *
$compsLOG = ($outputpath + '-Comp_details.csv')
$comps| Export-Csv $compsLOG -Append -notypeinformation -noclobber
#Computers not logged in, in over 60 days
write-log "Machines which have not logged in, in over 60 Days..."
Write-Output "Machines which have not logged in, in over 60 Days...(see Log)" >> $SectionLog
$compsnotloggedin = Get-ADComputer  -Properties * -Filter * | Where-Object { $_.lastlogondate -lt (Get-Date).AddDays(-60) } | Select-Object Name, lastlogondate, CanonicalName, OperatingSystem, Enabled 
foreach ($compnotloggedin in $compsnotloggedin) {
    Write-Log ('The follwoing Machine ' + $compnotloggedin.Name + ' Has not logged in since ' + $compnotloggedin.lastlogondate + ' Its OS is ' + $compnotloggedin.OperatingSystem + ' Its status is ' + $compnotloggedin.Enabled)
    
}
$compsnotloggedinLOG = ($outputpath + '-Comp60days.csv')
$compsnotloggedin | Export-Csv $compsnotloggedinLOG -Append
Write-Log ('New File Created: ' + $compsnotloggedinLOG)
Write-Output ('New File Created: ' + $compsnotloggedinLOG) >> $SectionLog
#user objects and type
Write-Log "User Objects in Domain"
Write-Output "User Objects in Domain" >> $SectionLog
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
Write-Output ('Users Object Count: ' + $usr_objectsNo) >> $SectionLog
Write-Output ('Users Active: ' + $usr_active_objectsNo) >> $SectionLog
Write-Output ('Users Inactive: ' + $usr_inactive_objectsNo) >> $SectionLog
Write-Output ('Users Locked Out: ' + $usr_locked_objectsNo) >> $SectionLog
Write-Output ('Users Password Not Required: ' + $usr_pwdnotreq_objectsNo) >> $SectionLog
Write-Output ('Users Passwords That Never Expire: ' + $usr_pwdnotexp_objectsNo) >> $SectionLog
#users not logged in for over 60 days
write-log "Users which have not logged in, in over 60 Days..."
Write-Output "Users which have not logged in, in over 60 Days...(see log)" >> $SectionLog
$usersnotloggedin = Get-ADUser  -Properties * -Filter * | Where-Object { $_.lastlogondate -lt (Get-Date).AddDays(-60) } | Select-Object Name, LastLogonDate, Enabled, samaccountname  
foreach ($usernotloggedin in $usersnotloggedin) {
    Write-Log ('The user ' + $usernotloggedin.Name + ' with username ' + $usernotloggedin.samaccountname + ' has not logged in since ' + $usernotloggedin.LastLogonDate + ' their status is ' + $usernotloggedin.Enabled)
    
}
$usersnotloggedinLOG = ($outputpath + '-User60days.csv')
$usersnotloggedin | Export-Csv $usersnotloggedinLOG -Append
Write-Log ('New File Created: ' + $usersnotloggedinLOG)
Write-Output ('New File Created: ' + $usersnotloggedinLOG) >> $SectionLog
#group objects and type
Write-Log "Group Objects in Domain"
Write-Output "Group Objects in Domain" >> $SectionLog
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
Write-Output ('Group Object Count: ' + $grp_objectsNo)  >> $SectionLog
Write-Output ('Group Domain Local Count: ' + $grp_objects_localNo)  >> $SectionLog
Write-Output ('Group Universal Count: ' + $grp_objects_universalNo)  >> $SectionLog
Write-Output ('Group Global Count: ' + $grp_objects_globalNo)  >> $SectionLog
#Group lists 
Write-Log "AD Group Names..."
Write-Output "AD Group Names..." >> $SectionLog
$ADGroups = Get-ADGroup -Filter * | Select-Object Name
foreach ($ADGroup in $ADGroups) {
    write-log ('Group Name: ' + $ADGroup.Name)
    Write-Output ('Group Name: ' + $ADGroup.Name) >> $SectionLog
}
#members of groups
Write-Log "Getting members of AD Groups:.."
Write-Output "Getting members of AD Groups:..." >> $SectionLog

$MemberGroupAll = ($outputpath + '-All_members_of_Group.csv')
#gets all AD Groups
$getADGroups = Get-ADGroup -Filter * -SearchScope Subtree
#for each group in the list 
foreach ($getADGroup in $getADGroups) {
    Write-Log ('Processing Group: ' + $group + '...')
    #get there members
    $getADGroupMembers = Get-ADGroupMember -Identity $getADGroup
    #checks hoiw many members are in the group if its equal to 0 then...
    if (($getADGroupMembers | Measure-Object).count -eq 0) {

        #output group has 0 users
        Write-Log ('The Group: ' + $getADGroup.Name + ' Contains No Users') 
        #state the pre defined param for csv output 
        $memberscsvoutput = @(
            [pscustomobject]@{
                GroupName  = $getADGroup.Name

                UsersName  = ("No USERS")

                SamAccount = ("No USERS")

                UserEmail  = ("No USERS")
        
                UserActive = ("No USERS")

                Type       = ("N/A")
       
            })
        #export to CSV
        $memberscsvoutput | Export-Csv $MemberGroupAll -Append -Force -NoClobber -NoTypeInformation
    }
    #if the group has mopre than 0 members then...
    else {
        #output group has users
        #Write-Host ('The Group: ' + $getADGroup.Name + ' Contains Users')
     
        #for each member of the group do....
        foreach ($getADGroupMember in $getADGroupMembers) {
            if ($getADGroupMember.objectClass -eq "group") {
                $memberscsvoutput = @(
                    [pscustomobject]@{
                        GroupName  = $getADGroup.Name

                        UsersName  = $getADGroupMember.Name

                        SamAccount = $getADGroupMember.SamAccountName

                        UserEmail  = ("n/a")
        
                        UserActive = ("n/a")

                        Type       = ("GROUP")
       
                    })
                #export to CSV
                $memberscsvoutput | Export-Csv $MemberGroupAll -Append -Force -NoTypeInformation -NoClobber
            }
            else {
                #get their AD information
                $getADGroupMemberDetail = Get-ADUser $getADGroupMember -Properties *
                if ($getADGroupMemberDetail.enabled -eq $true) {
                    # write-host ('User ' + $getADGroupMemberDetail.samaccountname + ' is active')
                    $OutputofifuserisActive = "Enabled"
                }
        
                else {
                    $OutputofifuserisActive = "Disabled"
                    #write-host ('User ' + $getADGroupMemberDetail.samaccountname + ' is NOT active') -ForegroundColor DarkYellow
                    $memberscsvoutput = @(
                        [pscustomobject]@{
                            GroupName  = $getADGroup.Name

                            UsersName  = $getADGroupMember.Name

                            SamAccount = $getADGroupMember.SamAccountName

                            UserEmail  = $getADGroupMember.mail
        
                            UserActive = $OutputofifuserisActive

                            Type       = ("User")
       
                        })
                    #export to CSV
                    $memberscsvoutput | Export-Csv $MemberGroupAll -Append -Force -NoClobber -NoTypeInformation
                }
            }
        }
    }
}

Write-Log ('File created at: ' + $MemberGroupAll)
Write-Output ('File containing all members of groups located at: ' + $MemberGroupAll) >> $SectionLog
#detailed list of all machines
$DetailedlistofComp = ($outputpath + '-Cutdown_List_of_Computers.csv')
Write-Log "Getting cutdown list of AD Computers"
Write-Output "Getting cutdown list of AD Computers" >> $SectionLog
$listofadcomp = Get-ADComputer -Properties * -Filter * | Select-Object Name, OperatingSystem, OperatingSystemHotfix, OperatingSystemServicePack, OperatingSystemVersion, Enabled, LockedOut, Location, whenCreated, IPv4Address, BadLogonCount, CN, CanonicalName, DistinguishedName, LastLogonDate, logonCount
$listofadcomp | Export-Csv $DetailedlistofComp -Append -NoTypeInformation -NoClobber
Write-Log ('File Created at ' + $DetailedlistofComp)
Write-Output  ('File Created at ' + $DetailedlistofComp) >> $SectionLog

#list of all machines
$DetailedlistofComp = ($outputpath + '-All_info_list_of_Computers.csv')
Write-Log "Getting list of AD Computers"
Write-Output "Getting list of AD Computers" >> $SectionLog
$listofadcomp = Get-ADComputer -Properties * -Filter * | Select-Object *
$listofadcomp | Export-Csv $DetailedlistofComp -Append -NoTypeInformation -NoClobber
Write-Log ('File Created at ' + $DetailedlistofComp)
Write-Output  ('File Created at ' + $DetailedlistofComp) >> $SectionLog

#detailed list of all users 
$Detailedlistofusers = ($outputpath + '-Detailed_List_of_Users.csv')
Write-Log "Getting cutdown list of AD Users"
Write-Output "Getting cutdown list of AD Users" >> $SectionLog
$listofadusers = Get-ADUser -Filter * -Properties * | Select-Object Name, department, sAMAccountName, givenName, surname, DisplayName, title, PasswordNeverExpires, PasswordLastSet, LastLogonDate, whenCreated, Description, Mail, ScriptPath, homeDirectory, homeDrive, Company, CN, distinguishedName, LockedOut, Enabled, LastBadPasswordAttempt, Country, Created, badPwdCount, CanonicalName, Manager, scriptpath
$listofadusers | Export-Csv $Detailedlistofusers -Append -NoTypeInformation -NoClobber
Write-Log ('File Created at ' + $Detailedlistofusers)
Write-Output  ('File Created at ' + $Detailedlistofusers) >> $SectionLog

#list of all users 
$Detailedlistofusers = ($outputpath + '-All_info_List_of_Users.csv')
Write-Log "Getting list of AD Users"
Write-Output "Getting list of AD Users" >> $SectionLog
$listofadusers = Get-ADUser -Filter * -Properties * | Select-Object *
$listofadusers | Export-Csv $Detailedlistofusers -Append -NoTypeInformation -NoClobber
Write-Log ('File Created at ' + $Detailedlistofusers)
Write-Output  ('File Created at ' + $Detailedlistofusers) >> $SectionLog

#Users no Pass expired 
Write-Log "Getting list of AD Users with no expired pass"
Write-Output "Getting list of AD Users with no expired pass" >> $SectionLog
$usersnopassexiredreport = ($outputpath + '-Users_No_Pass_Expired.csv')
Get-ADUser -Filter * -Properties * | Where-Object { $_.PasswordNeverExpires -eq 'True' -and $_.Enabled -eq "True" } | Select-Object SamAccountName, PasswordNeverExpires, PasswordLastSet, @{N = 'LastLogon'; E = { [DateTime]::FromFileTime($_.LastLogon) } }, CanonicalName, Description, msExchRecipientTypeDetails | Export-Csv -Append -Path $usersnopassexiredreport -NoClobber -NoTypeInformation
#msExchRecipientTypeDetails is exchange shared mailbox or not

#add the following to filter 
##-and $_.msExchRecipientTypeDetails -ne "4"
#User Mailbox 1
#Linked Mailbox 2
#Shared Mailbox 4
#Legacy Mailbox 8
#Room Mailbox 16
#Equipment Mailbox 32
#Mail Contact 64
#Mail User 128
#http://techgenix.com/msexchangerecipienttypedetails-active-directory-values/

#Possible service accounts
Write-Log "Getting list of possible service accounts in AD"
Write-Output "Getting list of possible service accounts in AD" >> $SectionLog
$serviceaccountsreport = ($outputpath + '-Possible_Service_Accounts.csv')
[array] $serviceAN = "svc", "service", "Services", "lansweeper", "build", "veeam", "vmware", "sql", "app", "application", "task", "backup", "monitor", "display", "ldap", "build", "support", "symantec", "sophos", "microsoft", "exchange"
foreach ($serviceaccounttext in $serviceAN) {
    Get-ADUser -Filter * -Properties * | Where-Object { $_.SamAccountName -match $serviceaccounttext -or $_.Description -match $serviceaccounttext -or $_.givenname -match $serviceaccounttext -or $_.surname -match $serviceaccounttext -or $_.DisplayName -match $serviceaccounttext } | Select-Object * | Export-Csv -Append -Path $serviceaccountsreport -NoClobber -NoTypeInformation
}

###########################################  DFS  ###########################################
Write-Log "###########################################  DFS  ###########################################"
$SectionLog = ($outputpath + '-DFS_root.txt')
write-log ('Dedicated Log output to: ' + $SectionLog)
$dfsroot = (Get-DfsnRoot -Domain $forest).Where( { $_.State -eq 'Online' } ) | Select-Object -ExpandProperty Path 
if ($dfsroot.count -eq 0) {
    write-log "No DFS Root found"
    Write-Output "No DFS Root found" >> $SectionLog
}
else {
    write-log "DFS Root found"
    Write-Output "DFS Root found" >> $SectionLog
    $dfsroot
    $dfsroot >> $SectionLog
}

###########################################  Print Servers  ###########################################
Write-Log "###########################################  Print Servers  ###########################################"
$SectionLog = ($outputpath + '-Print_Servers.txt')
write-log ('Dedicated Log output to: ' + $SectionLog)
Write-Log "Getting list of possible Print Servers"
Write-Output "Getting list of possible Print Servers" >> $SectionLog
$printservernames = Get-ADObject -Filter 'objectClass -eq "printQueue"' -Properties ServerName | sort ServerName -Unique | select ServerName
$printservernames >> $sectionlog



###########################################  WSUS  ###########################################
Write-Log "###########################################  WSUS  ###########################################"
$SectionLog = ($outputpath + '-WSUS.txt')
write-log ('Dedicated Log output to: ' + $SectionLog)
Write-Log "Getting list of possible WSUS Servers"
Write-Output "Getting list of possible WSUS Servers" >> $SectionLog
$wsusserver = Get-WsusComputer | Select-Object -First

if ($wsusserver -ge 1) {
    $wsusservers = Get-WsusServer -all
    $wsusservers >> $SectionLog
    $wsusservers
$wsusclassifcation = Get-WsusServer | Get-WsusClassification
$wsusclassifcation >> $SectionLog
$wsusclassifcation 

#list products and classifcations
$wsusServer = Get-WsusServer | select -first
$wsusSubscription = $wsusServer.GetSubscription()
$selectedProducts = $wsusSubscription.GetUpdateCategories() | Select Title
$selectedClassification = $wsusSubscription.GetUpdateClassifications() | Select Title
$selectedProducts
$selectedProducts >> $SectionLog
$selectedClassification 
$selectedClassification >> $SectionLog
    
}
else {
    Write-Log "No WSUS Servers found"
Write-Output "No WSUS Servers found" >> $SectionLog
}


###########################################  END  ###########################################

Write-Host ('Zipping folder.... ') -ForegroundColor Magenta      
#Zip Folder
[io.compression.zipfile]::CreateFromDirectory($Outputlocation, ($rootdir + $date + '-AD-Report.zip')) >> $zipcatch
Write-Host $zipcatch -ForegroundColor Red
Write-Host ('Zip file created of reports at:... ' + $rootdir + $date + '-AD-Report.zip') -ForegroundColor Magenta      
Write-Log "End of Script"