
Import-Module ActiveDirectory
$date = Get-Date -Format yyyy-MM-dd-%H-mm
$path = ("C:\temp\" + $date + "-computers.csv")
$DaysInactive = 60
$time = (Get-Date).Adddays( - ($DaysInactive))
$filteredcomp = Get-Content -Path "C:\Support\Scripts\computers-toignore.txt"

Get-ADComputer -Filter { LastLogonTimeStamp -lt $time } -Properties LastLogonTimeStamp | Where-Object { $filteredcomp -notcontains $_.Name } | Select-Object Name, @{Name = "Last Logon"; Expression = { [DateTime]::FromFileTime($_.lastLogonTimestamp) } } | Sort-Object -Property Name -Descending | Export-Csv -Append -Path $path


$smtpServer = "smtpserver"
$smtpFrom = "sendingserver-noreply@domain.com"
$emailDate = Get-Date -Format "dd/MM/yyyy"


$toRecipients = "email@domain.com"
$messageSubject = "Computers not logged in over 60 days - $emailDate"
$message = New-Object System.Net.Mail.MailMessage
$message.From = $smtpFrom
foreach ($toRecipient in $toRecipients) {
    $message.To.Add($toRecipient)
}
$smtp = New-Object Net.Mail.SmtpClient($smtpServer)
$message.Subject = $messageSubject
$message.IsBodyHTML = $true
$message.Body = "<html><head><style type=text/css>body { font-family:Helvetica,Verdana }`r`ntd { font-size:10pt; }</style></head><body>List of machines that have not logged in 6 0 days to add machine to ignore list go to <location>  </ body></html>"
$message.Attachments.Add($path)
$smtp.Send($message)
Remove-Variable message