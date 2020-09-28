#everyone
get-mailbox |select -expand userprincipalname |Get-MailboxStatistics | Select-Object DisplayName, IsArchiveMailbox, ItemCount, @{name=”TotalItemSize (GB)”;expression={[math]::Round((($_.TotalItemSize.Value.ToString()).Split(“(“)[1].Split(” “)[0].Replace(“,”,””)/1GB),2)}} |  Export-CSV –Path “C:\Temp\GBExchangeOnlineUsage.csv” -notypeinformation


#specific emails
$list = Get-Content "C:\temp\list.txt"
foreach ($item in $list) {
    get-mailbox $item |select -expand userprincipalname |Get-MailboxStatistics | Select-Object DisplayName, IsArchiveMailbox, ItemCount, @{name=”TotalItemSize (GB)”;expression={[math]::Round((($_.TotalItemSize.Value.ToString()).Split(“(“)[1].Split(” “)[0].Replace(“,”,””)/1GB),2)}} |  Export-CSV –Path “C:\Temp\GBExchangeOnlineUsage.csv” -notypeinformation -Append
    
}