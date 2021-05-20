Get-DhcpServerv4Scope | Get-DhcpServerv4OptionValue -OptionId 6 | select name,type,@{Name='value';Expression={$_.value -join '; '}} | Export-Csv c:\temp\dhcp-dns.csv -Append -NoClobber -NoTypeInformation