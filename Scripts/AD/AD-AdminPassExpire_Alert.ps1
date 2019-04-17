#REFS
#https://4sysops.com/archives/a-password-expiration-reminder-script-in-powershell/


#imports the AD module
Import-Module ActiveDirectory

#email server
$smtpServer = "server"
$smtpFrom = "noreply-server@domain.com"

#Date variables
$date = Get-Date -Format yyyy-MM-dd-%H-mm
$Daysback = '-30'
$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddDays($Daysback)
$dateformated = Get-Date $30days -Format "yyyy-MM-dd HH:mm:ss"
$30days = (Get-Date).AddDays(-10)

#logging
$adadmin = "C:\Support\Logs\"
$Logsize = "{0:N2}" -f ((Get-ChildItem $adadmin -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)
$servicelog = ($adadmin +  $date + '-AD_Admin_PassExpireAlert.log')

#Days to count down
$10day = (Get-Date).adddays(10).ToLongDateString()
$9day = (Get-Date).adddays(9).ToLongDateString()
$8day = (Get-Date).adddays(8).ToLongDateString()
$7day = (Get-Date).adddays(7).ToLongDateString()
$6day = (Get-Date).adddays(6).ToLongDateString()
$5day = (Get-Date).adddays(5).ToLongDateString()
$4day = (Get-Date).adddays(4).ToLongDateString()
$3day = (Get-Date).adddays(3).ToLongDateString()
$2day = (Get-Date).adddays(2).ToLongDateString()
$1day = (Get-Date).adddays(1).ToLongDateString()
$0day = (Get-Date).adddays(0).ToLongDateString()

#Filters for admin users
$users = Get-ADUser -filter { Enabled -eq $True -and PasswordNeverExpires -eq $False -and PasswordLastSet -gt 0 } -Properties "samaccountname", "msDS-UserPasswordExpiryTimeComputed" | Where-Object { $_.Enabled -eq "True" -and $_.samaccountname.StartsWith('!') } | Select-Object -Property "samaccountname", @{Name = "PasswordExpiry"; Expression = { [datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed").tolongdatestring() } }


#goes through each user
foreach ($user in $users) {

    #states a variable if there over 30 days it will change
    $userisover10days = "no"
    #filtering to just ad account name
    $IDnoneuseradmin = $user.samaccountname

    #filters ad account to normal ad account
    $noneuseradmin = $IDnoneuseradmin -replace '[!]', ""

    #gets email address of normal ad account
    $emailofnoneadmin = Get-ADUser -Identity $noneuseradmin -Properties * | foreach { $_.mail }

    #enables email to be populated
    $message = New-Object System.Net.Mail.MailMessage

    #for normal users ignored for now
    ################################################
    #identofying an attrib to pass to command get-mailbox
    #$IDuserMail = Get-ADUser -Identity $user -Properties * | Select-Object -ExpandProperty mail
    #lookup user to see if it has a mailbox
    #$mailboxCheck = get-mailbox $IDuserMail | Select-Object -expandproperty RecipientTypeDetails
    #finds if the user has a mailbox and is specifically a usermailbox then if the users password last set is greater than todays date -30 days
    #if ($mailboxCheck -eq 'UserMailbox') {
    ##################################################

    #checks if password is 10 days
    if ($user.PasswordExpiry -eq $10day) {
        #writes a log if the user is 10 days
        Write-Output ($user.samaccountname + " 9 days") >> $servicelog
        #populates the body for being 9 days + time now
        $message.Body = "<html><head><style type=text/css>body { font-family:Helvetica,Verdana }`r`ntd { font-size:10pt; }</style></head><body> Your Admin password is going to expire in 9 days</body></html>"
        #used for populating subject
        $days = '9'

    }
    elseif ($user.PasswordExpiry -eq $9day) {
        Write-Output ($user.samaccountname + " 8 days") >> $servicelog
        $message.Body = "<html><head><style type=text/css>body { font-family:Helvetica,Verdana }`r`ntd { font-size:10pt; }</style></head><body> Your Admin password is going to expire in 8 days</body></html>"
        $days = '8'
    }
    elseif ($user.PasswordExpiry -eq $8day) {
        Write-Output ($user.samaccountname + " 7 days") >> $servicelog
        $message.Body = "<html><head><style type=text/css>body { font-family:Helvetica,Verdana }`r`ntd { font-size:10pt; }</style></head><body> Your Admin password is going to expire in 7 days</body></html>"
        $days = '7'
    }
    elseif ($user.PasswordExpiry -eq $7day) {
        Write-Output ($user.samaccountname + " 6 days") >> $servicelog
        $message.Body = "<html><head><style type=text/css>body { font-family:Helvetica,Verdana }`r`ntd { font-size:10pt; }</style></head><body> Your Admin password is going to expire in 6 days</body></html>"
        $days = '6'
    }
    elseif ($user.PasswordExpiry -eq $6day) {
        Write-Output ($user.samaccountname + " 5 days") >> $servicelog
        $message.Body = "<html><head><style type=text/css>body { font-family:Helvetica,Verdana }`r`ntd { font-size:10pt; }</style></head><body> Your Admin password is going to expire in 5 days</body></html>"
        $days = '5'
    }
    elseif ($user.PasswordExpiry -eq $5day) {
        Write-Output ($user.samaccountname + " 4 days") >> $servicelog
        $message.Body = "<html><head><style type=text/css>body { font-family:Helvetica,Verdana }`r`ntd { font-size:10pt; }</style></head><body> Your Admin password is going to expire in 4 days</body></html>"
        $days = '4'
    }
    elseif ($user.PasswordExpiry -eq $4day) {
        write-Output ($user.samaccountname + " 3 days") >> $servicelog
        $message.Body = "<html><head><style type=text/css>body { font-family:Helvetica,Verdana }`r`ntd { font-size:10pt; }</style></head><body> Your Admin password is going to expire in 3 days</body></html>"
        $days = '3'
    }
    elseif ($user.PasswordExpiry -eq $3day) {
        write-Output ($user.samaccountname + " 3 days") >> $servicelog
        $message.Body = "<html><head><style type=text/css>body { font-family:Helvetica,Verdana }`r`ntd { font-size:10pt; }</style></head><body> Your Admin password is going to expire in 2 days</body></html>"
        $days = '2'
    }
    elseif ($user.PasswordExpiry -eq $2day) {
        write-Output ($user.samaccountname + " 1 days") >> $servicelog
        $message.Body = "<html><head><style type=text/css>body { font-family:Helvetica,Verdana }`r`ntd { font-size:10pt; }</style></head><body> Your Admin password is going to expire in 1 days</body></html>"
        $days = '1'
    }
    elseif ($user.PasswordExpiry -eq $1day) {
        write-Output ($user.samaccountname + " 0 day") >> $servicelog
        $message.Body = "<html><head><style type=text/css>body { font-family:Helvetica,Verdana }`r`ntd { font-size:10pt; }</style></head><body> Your Admin password is going to expire within 24 Hours !!!!!</body></html>"
        $days = '0'
    }
    elseif ($user.PasswordExpiry -eq $0day) {
        write-Output ($user.samaccountname + " 0 days") >> $servicelog
        $message.Body = "<html><head><style type=text/css>body { font-family:Helvetica,Verdana }`r`ntd { font-size:10pt; }</style></head><body> Your Admin password is going to expire today !!!!!!!</body></html>"
        $days = '0'
    }

    else {
        #exits the loop if their older than 10 days
        $userisover10days = "yes"
        #sets subject to null
        $days = $null
        #logs user is older than 10 days
        write-Output ("user is older than 10 days" + $user.samaccountname + "expires " + $user.PasswordExpiry ) >> $servicelog

    }

    #checks if user is over 10 days
    if ($userisover10days -eq "yes") {

        #updates log
        write-Output ($user.samaccountname + " userisover10days is checked " ) >> $servicelog
        #clears variables
        Remove-Variable emailofnoneadmin
        Remove-Variable noneuseradmin
        Remove-Variable IDnoneuseradmin
        Remove-Variable userisover10days

    }
    #user is within the countdown
    else {
        #sends email
        $toRecipients = $emailofnoneadmin
        $messageSubject = ("Your Admin Password will expire in " + $days + " Days")

        $message.From = $smtpFrom
        foreach ($toRecipient in $toRecipients) {
            $message.To.Add($toRecipient)
        }
        $smtp = New-Object Net.Mail.SmtpClient($smtpServer)
        $message.Subject = $messageSubject
        $message.IsBodyHTML = $true

        $smtp.Send($message)
        Remove-Variable message
        Remove-Variable days
        Remove-Variable emailofnoneadmin
        Remove-Variable noneuseradmin
        Remove-Variable IDnoneuseradmin
        Remove-Variable userisover10days
    }
}
#Log Cleanup
if ($Logsize -gt 10.0) {
    Get-ChildItem $adadmin -Recurse -Force -File -PipelineVariable File | % {
        try {
            Remove-Item -Path $File.fullname -Force -Confirm:$false -ErrorAction Stop | Where-Object { $_.LastWriteTime -lt $DatetoDelete }
            "Deleted file: $($File.fullname)" | Out-File $servicelog -Append
        }
        catch {
            "Failed to delete file: $($File.fullname)" | Out-File $servicelog -Append
        }
    }
}
else {
    Write-Output ($date + " Log is below 10MB") >> $servicelog

}
# else {
#    Write-Host "No Mailbox attached to " $user
#}


# }


