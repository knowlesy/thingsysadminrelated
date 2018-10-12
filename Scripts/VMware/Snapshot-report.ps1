#REF
# https://www.theaccessgroup.com/hosting/resources/our-blog/getting-a-list-of-snapshots-in-vsphere-using-powercli/
# http://www.checkyourlogs.net/?p=34783
# https://pastebin.com/WJRpcbnj

$vcserver = 'server'
$toAddr = "too@who.com"
$fromAddr = "from@who.com"
$smtpsrv = "server"
$date = Get-Date
$attachmentPref = $true
#$expired = get-date -date $(get-date).adddays(-7) 



#Imports powercli
Get-Module -ListAvailable VMware.VimAutomation.* | Import-Module -ErrorAction SilentlyContinue

#connects to server 
Connect-VIServer -Server $vcserver 
$VMsWithSnaps = @(Get-VM | Get-Snapshot | Select-Object VM, Name, Created, Description)
# Make sure the body isn't empty. If it is, skip this part and exit the script.
if ($VMsWithSnaps -ne $null) {
    $body = @("
        <center><table border=1 width=50 % cellspacing=0 cellpadding=8 bgcolor=Black cols=3>
        <tr bgcolor=White><td>Virtual Machine</td><td>Snapshot</td><td>Description</td><td>Creation Time</td></tr>")


    $i = 0
    do {
        
        
        if ($i % 2) {$body += "<tr bgcolor=#D2CFCF><td>$($VMsWithSnaps[$i].VM)</td><td>$($VMsWithSnaps[$i].Name)</td><td>$($VMsWithSnaps[$i].Description)</td><td>$($VMsWithSnaps[$i].Created)</td></tr>"; $i++}
        else {$body += "<tr bgcolor=#EFEFEF><td>$($VMsWithSnaps[$i].VM)</td><td>$($VMsWithSnaps[$i].Name)</td><td>$($VMsWithSnaps[$i].Description)</td><td>$($VMsWithSnaps[$i].Created)</td></tr>"; $i++}
    }
    while ($VMsWithSnaps[$i] -ne $null)

    $body += "</table></center>"
    # Send email alerting recipients about snapshots.
    if ($attachmentPref) {
        $VMsWithSnaps | Export-CSV "$vcserver SnapshotReport $($date.month)-$($date.day)-$($date.year).csv"
        Send-MailMessage -To "$toAddr" -From "$fromAddr" -Subject "$vcserver Automated Daily Snapshot Report $($date.month)-$($date.day)-$($date.year)" -Body "$body" -Attachments "$vcserver SnapshotReport $($date.month)-$($date.day)-$($date.year).csv" -SmtpServer "$smtpsrv" -BodyAsHtml
        Remove-Item "$vcserver SnapshotReport $($date.month)-$($date.day)-$($date.year).csv"
    }
    Else {
        Send-MailMessage -To "$toAddr" -From "$fromAddr" -Subject "$vcserver Automated Daily Snapshot Report $($date.month)-$($date.day)-$($date.year)" -Body "$body" -SmtpServer "$smtpsrv" -BodyAsHtml
    }
}
else {
    Send-MailMessage -To "$toAddr" -From "$fromAddr" -Subject "$vcserver Automated Daily Snapshot Report $($date.month)-$($date.day)-$($date.year) (No Snapshots Detected)" -Body "No Snapshots" -SmtpServer "$smtpsrv"
}

Disconnect-VIServer -server $vcserver  -Confirm:$false 
exit