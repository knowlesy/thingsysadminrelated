<##############################################################################
Ashley McGlone
Microsoft Premier Field Engineer
http://aka.ms/GoateePFE

January 2015

This script creates a report of all group policy links, their locations, and
their configurations in the current domain, and their replication metadata
for auditing and forensics.  Output is a CSV file.

For more information on gPLink, gPOptions, and gPLinkOptions see:
 [MS-GPOL]: Group Policy: Core Protocol
  http://msdn.microsoft.com/en-us/library/cc232478.aspx
 2.2.2 Domain SOM Search
  http://msdn.microsoft.com/en-us/library/cc232505.aspx
 2.3 Directory Service Schema Elements
  http://msdn.microsoft.com/en-us/library/cc422909.aspx
 3.2.5.1.5 GPO Search
  http://msdn.microsoft.com/en-us/library/cc232537.aspx

SOM is an acronym for Scope of Management, referring to any location where
a group policy could be linked: domain, OU, site.

NOTE: This GPO report does not list GPO filtering by permissions.

Requires:
-PowerShell v3 or above
-RSAT 2012 or above
-AD PowerShell module
-Group Policy module
-Appropriate permissions

LEGAL DISCLAIMER
This Sample Code is provided for the purpose of illustration only and is not
intended to be used in a production environment.  THIS SAMPLE CODE AND ANY
RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  We grant You a
nonexclusive, royalty-free right to use and modify the Sample Code and to
reproduce and distribute the object code form of the Sample Code, provided
that You agree: (i) to not use Our name, logo, or trademarks to market Your
software product in which the Sample Code is embedded; (ii) to include a valid
copyright notice on Your software product in which the Sample Code is embedded;
and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and
against any claims or lawsuits, including attorneys’ fees, that arise or result
from the use or distribution of the Sample Code.

This posting is provided "AS IS" with no warranties, and confers no rights. Use
of included script samples are subject to the terms specified
at http://www.microsoft.com/info/cpyright.htm.
##############################################################################>

###############

$date = Get-Date -Format yyyy-MM-dd-%H-mm
$GPOrootDir = 'C:\Temp\'
$GPOReport = ($GPOrootDir + 'GPO_Report\')

###############


# Import the module goodness
# Requires RSAT installed and features enabled
Import-Module GroupPolicy
Import-Module ActiveDirectory

# Pick a DC to target
$Server = Get-ADDomainController -Discover | Select-Object -ExpandProperty HostName

##############################################################################

Function Get-ADOrganizationalUnitOneLevel {
    param($Path)
    Get-ADOrganizationalUnit -Filter * -SearchBase $Path `
        -SearchScope OneLevel -Server $Server |
    Sort-Object Name |
    ForEach-Object {
        $script:OUHash.Add($_.DistinguishedName, $script:Counter++)
        Get-ADOrganizationalUnitOneLevel -Path $_.DistinguishedName }
}

Function Get-ADOrganizationalUnitSorted {
    $DomainRoot = (Get-ADDomain -Server $Server).DistinguishedName
    $script:Counter = 1
    $script:OUHash = @{$DomainRoot = 0 }
    Get-ADOrganizationalUnitOneLevel -Path $DomainRoot
    $OUHash
}

$SortedOUs = Get-ADOrganizationalUnitSorted

##############################################################################

# Grab a list of all GPOs
$GPOs = Get-GPO -All -Server $Server | Select-Object ID, Path, DisplayName, GPOStatus, WMIFilter, CreationTime, ModificationTime, User, Computer

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
    Get-ADObject -Server $Server -Identity (Get-ADDomain).distinguishedName -Properties name, distinguishedName, gPLink, gPOptions |
Select-Object name, distinguishedName, gPLink, gPOptions, @{name = 'Depth'; expression = { 0 } }

# GPOs linked to OUs
#  !!! Get-GPO does not return the gPLink attribute
# Calculate OU depth for graphical representation in final report
$gPLinks += `
    Get-ADOrganizationalUnit -Server $Server -Filter * -Properties name, distinguishedName, gPLink, gPOptions |
Select-Object name, distinguishedName, gPLink, gPOptions, @{name = 'Depth'; expression = { ($_.distinguishedName -split 'OU=').count - 1 } }

# GPOs linked to sites
$gPLinks += `
    Get-ADObject -Server $Server -LDAPFilter '(objectClass=site)' -SearchBase "CN=Sites,$((Get-ADRootDSE).configurationNamingContext)" -SearchScope OneLevel -Properties name, distinguishedName, gPLink, gPOptions |
Select-Object name, distinguishedName, gPLink, gPOptions, @{name = 'Depth'; expression = { 0 } }

# Empty report array
$report = @()

# Loop through all possible GPO link SOMs collected
ForEach ($SOM in $gPLinks) {
    # Filter out policy SOMs that have a policy linked
    If ($SOM.gPLink) {

        # Retrieve the replication metadata for gPLink
        $gPLinkMetadata = Get-ADReplicationAttributeMetadata -Server $Server -Object $SOM.distinguishedName -Properties gPLink
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
Export-CSV ($GPOReport + $date + "-gPLink_Report_Sorted_Metadata.csv") -NoTypeInformation

<#########################################################################sdg#>
