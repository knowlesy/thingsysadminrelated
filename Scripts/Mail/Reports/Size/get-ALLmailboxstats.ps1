get-mailbox |select -expand userprincipalname |Get-MailboxStatistics | Select-Object * | Export-CSV –Path “C:\Temp\AllExchangeOnlineUsage.csv” -notypeinformation
