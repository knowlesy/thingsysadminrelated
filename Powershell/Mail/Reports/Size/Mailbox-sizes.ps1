Get-Mailbox -ResultSize unlimited | Get-MailboxStatistics | Select-Object DisplayName, IsArchiveMailbox, ItemCount, TotalItemSize | Export-CSV –Path “C:\Temp\ExchangeOnlineUsage.csv”


Get-Mailbox -ResultSize unlimited | Select-Object DisplayName, PrimarySmtpAddress  | Export-CSV –Path “C:\Temp\ExchangeOnlineUsage4.csv”



get-mailbox |select -expand userprincipalname |Get-MailboxStatistics | Select-Object DisplayName,PrimarySmtpAddress, MailboxTypeDetail,IsArchiveMailbox, ItemCount, TotalItemSize,@{name=”GB”;expression={[math]::Round((($_.TotalItemSize.Value.ToString()).Split(“(“)[1].Split(” “)[0].Replace(“,”,””)/1GB),2)}} | Export-CSV –Path “C:\Temp\ExchangeOnlineUsage3.csv” -notypeinformation

