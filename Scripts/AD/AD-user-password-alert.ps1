#REFS
#https://4sysops.com/archives/a-password-expiration-reminder-script-in-powershell/

    $testlog = 'C:\temp\testuser.txt'


    #imports the AD module
    Import-Module ActiveDirectory
    #$filteredusers = Get-Content -Path "D:\Dump\test\filtered.txt"

    #sets a variable for 30 days previous
    $30days = (Get-Date).AddDays(-30)
    #formats todays date
    $dateformated = get-date $30days -Format "yyyy-MM-dd HH:mm:ss"

    $10day = (get-date).adddays(10).ToLongDateString()
    $9day = (get-date).adddays(9).ToLongDateString()
    $8day = (get-date).adddays(8).ToLongDateString()
    $7day = (get-date).adddays(7).ToLongDateString()
    $6day = (get-date).adddays(6).ToLongDateString()
    $5day = (get-date).adddays(5).ToLongDateString()
    $4day = (get-date).adddays(4).ToLongDateString()
    $3day = (get-date).adddays(3).ToLongDateString()
    $2day = (get-date).adddays(2).ToLongDateString()
    $1day = (get-date).adddays(1).ToLongDateString()
    $0day = (get-date).adddays(0).ToLongDateString()


    $MailSender = " Password AutoBot <EMAILADDRESS@SOMECOMPANY.com>"
    $Subject = 'FYI - Your account password will expire soon'
    $SMTPServer = 'smtp.somecompany.com'

    #sets scope of users and filters to enabled users only
    $users = Get-ADUser -SearchBase "DC=DOMAIN,DC=LOCAL" -Filter * -Properties * | Where-Object {$_.Enabled -eq "True" }

    foreach ($user in $users) {

        @{Name = "PasswordExpiry"; Expression = {[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed").tolongdatestring() }}
        #identofying an attrib to pass to command get-mailbox
        $IDuserMail = Get-ADUser -Identity $user -Properties * | select-object -ExpandProperty mail
        #lookup user to see if it has a mailbox
        $mailboxCheck = get-mailbox $IDuserMail | Select-Object -expandproperty RecipientTypeDetails
        #finds if the user has a mailbox and is specifically a usermailbox then if the users password last set is greater than todays date -30 days
        if ($mailboxCheck -eq 'UserMailbox') {

            if ($user.PasswordExpiry -eq $10day) {
                Write-Output ($user + " 10 days") >> $testlog
            }
            elseif ($user.PasswordExpiry -eq $9day) {
                Write-Output ($user + " 10 days") >> $testlog
            }
            elseif ($user.PasswordExpiry -eq $8day) {
                Write-Output ($user + " 10 days") >> $testlog
            }
            elseif ($user.PasswordExpiry -eq $7day) {
                Write-Output ($user + " 10 days") >> $testlog
            }
            elseif ($user.PasswordExpiry -eq $6day) {
                Write-Output ($user + " 10 days") >> $testlog
            }
            elseif ($user.PasswordExpiry -eq $5day) {
                Write-Output ($user + " 10 days") >> $testlog
            }
            elseif ($user.PasswordExpiry -eq $4day) {
                Write-Output ($user + " 10 days") >> $testlog
            }
            elseif ($user.PasswordExpiry -eq $3day) {
                Write-Output ($user + " 10 days") >> $testlog
            }
            elseif ($user.PasswordExpiry -eq $2day) {
                Write-Output ($user + " 10 days") >> $testlog
            }
            elseif ($user.PasswordExpiry -eq $1day) {
                Write-Output ($user + " 10 days") >> $testlog
            }
            elseif ($user.PasswordExpiry -eq $0day) {
                Write-Output ($user + " 10 days") >> $testlog
            }

            else {}
        }
        else {
            Write-host "No Mailbox attached to " $user
            Write-Output ($user + "no mailbox") >> $testlog
        }


    }







