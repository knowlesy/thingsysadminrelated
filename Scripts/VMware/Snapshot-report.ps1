#REF 
# https://www.theaccessgroup.com/hosting/resources/our-blog/getting-a-list-of-snapshots-in-vsphere-using-powercli/
# http://www.checkyourlogs.net/?p=34783

###Variables###

#Vcenter Server
$vcsbox = 'servername'
#CSV export of location
$exportlocation = 'D:\test.csv'
#Sets SMTP Server
$smtpServer = "<smtp-server>"
#Sets from email
$smtpFrom = "<scripts-server>-noemail@<domain>"
#Sets Date
$emailDate = Get-Date -Format "dd/MM/yyyy"
#Sets to whom
$toRecipients = "<user-email>" 
#Sets subject
$messageSubject = "VM Snapshot Report - $emailDate"



#Imports powercli
Get-Module -ListAvailable VMware.VimAutomation.* | Import-Module -ErrorAction SilentlyContinue

#connects to VC server 
Connect-VIServer -Server $vcsbox

#Exports to csv
#get-vm | get-snapshot | Select-Object vm, name, description, created, sizegb | Export-Csv $exportlocation

#Email report
 $vmsnapshots = get-vm | get-snapshot | ConvertTo-Html -Title "List of snapshots" -Fragment -Property vm, name, description, created, sizegb

#foreach ($snap in $vmsnapshots )

#{
 #   $now = Get-Date -format "yyyy-MM-dd-HH:mm"  


#}


$message = New-Object System.Net.Mail.MailMessage 
$message.From = $smtpFrom
foreach ($toRecipient in $toRecipients) {
    $message.To.Add($toRecipient)
}
$smtp = New-Object Net.Mail.SmtpClient($smtpServer)
$att = New-Object Net.Mail.Attachment("$Directory\BackupHost.Log")
$message.Subject = $messageSubject
$message.IsBodyHTML = $true
#Using the previous variables / arrays it builds a report 
$message.Body = "
<html>
    <head>
        <style type=text/css>
            body 
            { 
                font-family:Helvetica,Verdana 
            }`r`n
            td 
            { 
                font-size:10pt; 
            }
        </style>
    </head>
<body>
<center>
 $vmsnapshots
</body></html>"
$message.Attachments.Add($att)
$smtp.Send($message)
Remove-Variable message 
$att.Dispose()