(Get-ADDomain -Current LocalComputer).ChildDomains

(Get-ADDomain -Current LocalComputer).NetBIOSName
((Get-ADForest).Domains | %{ Get-ADDomainController -Filter * -Server $_ }).hostname
(Get-ADForest).SchemaMaster
(Get-ADForest).DomainNamingMaster
(Get-ADDomain -Current LocalComputer).RIDMaster
(Get-ADDomain -Current LocalComputer).PDCEmulator
(Get-ADDomain -Current LocalComputer).InfrastructureMaster
(Get-ADDomain -Current LocalComputer).DomainMode
$ForestInfo = Get-ADForest
$ForestInfo.GlobalCatalogs
Get-DnsServerResourceRecord -ComputerName $dnsdc -ZoneName $domain -RRType "NS" | FT -AutoSize
Get-DhcpServerInDC
