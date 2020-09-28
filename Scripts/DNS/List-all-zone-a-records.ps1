$dnszones = Get-DnsServerZone -ErrorAction SilentlyContinue | select zonename
$OutputPath = 'C:\temp\DNS-Zone-A-Record.csv'
foreach ($dnszone in $dnszones) {

    $zonename = $dnszone.zonename
    Get-DnsServerResourceRecord -ZoneName $zonename -RRType a -ErrorAction SilentlyContinue | select-object -ExpandProperty recorddata -Property Hostname,Timestamp | Export-Csv $OutputPath -NoTypeInformation -Append -NoClobber


}

