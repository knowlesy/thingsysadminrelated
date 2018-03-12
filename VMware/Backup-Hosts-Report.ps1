
#Set Directory Location
$Directory = "C:\VMWARE\$((Get-Date).ToString('yyyy-MM-dd'))"
#Create Directory
New-Item -ItemType Directory -Path $Directory
$StartTime=Get-Date -format "yyyy-MM-dd-HH:mm" 
Write-Output "$StartTime Backup of Hosts started" | Out-File $Directory\BackupHost.Log -Append
#Ignore Cert if needed
#Set-PowerCLIConfiguration -InvalidCertificateAction ignore -confirm:$false
#Connect to VSphere
Connect-VIServer -Server <vcenter-server> -User <username> -Password <password>
#Testing a single Host
#$Hosts = Get-VMHost -Name "<host-for-testing>"
#All Hosts
$Hosts = Get-VMHost 
#Sets Variable to Null
$connectedhostsbackedup=$connectedhostsbutfailed=$disconnectedhosts=$notrespondinghosts=$maintenancehosts=""
#Finds Hosst
 ForEach ($vmhost in $Hosts)
        {
        #Gets Time
        $now=Get-Date -format "yyyy-MM-dd-HH:mm"
        #Checks connectivity if connected do....
         if($vmhost.ConnectionState -eq "Connected")
            {
             #Backs up Host
             Write-Output "$now $($vmhost.Name) Connected" | Out-File $Directory\BackupHost.Log -Append
             Get-VMHostFirmware -VMHost $vmhost.Name -BackupConfiguration -DestinationPath $Directory
             #Sets directory for file to confirm backup
             $ConfigFileTest="$Directory\configBundle-$($vmhost.Name).tgz"
             #Looks for file
             If (Test-Path $ConfigFileTest)
                {
                # // Backup File exists
                Write-Output "$now $($vmhost.Name) successfully backed up configuration" | Out-File $Directory\BackupHost.Log -Append
                #Sets variable that backup exists for this host
                $connectedhostsbackedup += "$($vmhost.Name)<br />"
                } 
             #Backup didnt exist ?
             Else
                {
                # // File does not exist
                Write-Output "$now $($vmhost.Name) failed to back up configuration - ERROR"  | Out-File $Directory\BackupHost.Log -Append
                 #Sets variable that backup doesnt exist for this host
                $connectedhostsbutfailed += "$($vmhost.Name)<br />"
                }
             
            }
         #If hosts has Disconnected status it pipes that to the variable for the report
         elseif($vmhost.ConnectionState -eq "Disconnected")
            {
             Write-Output "$now $($vmhost.Name) Disconnected - ERROR" | Out-File $Directory\BackupHost.Log -Append
             $disconnectedhosts += "$($vmhost.Name)<br />"
            }
         #If hosts has NotResponding status it pipes that to the variable for the report
         elseif($vmhost.ConnectionState -eq "NotResponding")
            {
             Write-Output "$now $($vmhost.Name) Not Responding - ERROR" | Out-File $Directory\BackupHost.Log -Append
             $notrespondinghosts += "$($vmhost.Name)<br />"
            }
         #If hosts has Maintenance status it pipes that to the variable for the report
         elseif($vmhost.ConnectionState -eq "Maintenance")
            {
             Write-Output "$now $($vmhost.Name) In Maintenance - ERROR" | Out-File $Directory\BackupHost.Log -Append
             $maintenancehosts += "$($vmhost.Name)<br />"
            }
        }


$CompleteTime=Get-Date -format "yyyy-MM-dd-HH:mm" 
Write-Output "$CompleteTime Backup of Hosts Completed" | Out-File $Directory\BackupHost.Log -Append
Write-Output "$CompleteTime Sending Email" | Out-File $Directory\BackupHost.Log -Append
#Email
#Sets SMTP Server
$smtpServer = "<smtp-server>"
#Sets from email
$smtpFrom = "<scripts-server>-noemail@<domain>"
#Sets Date
$emailDate=Get-Date -Format "dd/MM/yyyy"

#Sets to whom
$toRecipients ="<user-email>" 
#Sets subject
$messageSubject = "ESXI Host Backup Config - $emailDate"
#Sets the message
$message = New-Object System.Net.Mail.MailMessage 
$message.From = $smtpFrom
foreach($toRecipient in $toRecipients) {
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
<table width=95%>
<tr>
<th>Connected-Backed-Up</th><th>Connected-Backup-Failed</th><th>Disconnected</th><th>NotResponding</th><th>Maintenance</th>
</tr>
<tr>
<td bgcolor='Green' valign='top'>$connectedhostsbackedup</td><td bgcolor='Orange' valign='top'>$connectedhostsbutfailed</td><td bgcolor='Red' valign='top'>$disconnectedhosts</td><td bgcolor='Red' valign='top'>$notrespondinghosts</td><td bgcolor='Red' valign='top'>$maintenancehosts</td>
</tr>
</table>
</body></html>"
$message.Attachments.Add($att)
$smtp.Send($message)
Remove-Variable message 
$att.Dispose()
$JobCompleteTime=Get-Date -format "yyyy-MM-dd-HH:mm" 
Write-Output "$JobCompleteTime Job completed" | Out-File $Directory\BackupHost.Log -Append
Write-Output "Start Time: $StartTime  Complete time $JobCompleteTime Job completed" | Out-File $Directory\BackupHost.Log -Append
