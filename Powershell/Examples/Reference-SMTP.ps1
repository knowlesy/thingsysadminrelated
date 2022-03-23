$smtpServer = "<server>"
$smtpFrom = "noemail@company.com"
$emailDate = Get-Date -Format "dd/MM/yyyy"


$toRecipients = "noemail@company.com", "noemail1@company.com"
$messageSubject = "$cluster <subject message>- $emailDate"
$message = New-Object System.Net.Mail.MailMessage 
$message.From = $smtpFrom
foreach ($toRecipient in $toRecipients) {
    $message.To.Add($toRecipient)
}
$smtp = New-Object Net.Mail.SmtpClient($smtpServer)
$message.Subject = $messageSubject
$message.IsBodyHTML = $true
$message.Body = "<html><head><style type=text/css>body { font-family:Helvetica,Verdana }`r`ntd { font-size:10pt; }</style></head><body>$emailBodyMissing`r`n$emailBodyNotRun`r`n$emailBodyIgnored`r`n$emailBodySuccessful</body></html>"

$smtp.Send($message)
Remove-Variable message 