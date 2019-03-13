#connects to exchange
$onpremcred = Get-Credential
$s = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://exchangeserver/PowerShell/  -Credential $onpremcred
Invoke-Command -Session $s -ScriptBlock {

    #imports the AD module
    Import-Module ActiveDirectory
    #$filteredusers = Get-Content -Path "D:\Dump\test\filtered.txt"

    #sets a variable for 30 days previous
    $30days = (Get-Date).AddDays(-30)
    #formats todays date
    $dateformated = get-date $30days -Format "yyyy-MM-dd HH:mm:ss"
    #sets scope of users and filters to enabled users only
    $users = Get-ADUser -SearchBase "DC=domain,DC=LOCAL" -Filter * -Properties * | Where-Object {$_.Enabled -eq "True" }

    foreach ($user in $users) {

        $UserLastPwdSet = Get-ADUser -Identity $user -Properties * | select-object -ExpandProperty PasswordLastSet
        #identofying an attrib to pass to command get-mailbox
        $IDuserMail = Get-ADUser -Identity $user -Properties * | select-object -ExpandProperty mail
        #lookup user to see if it has a mailbox
        $mailboxCheck = get-mailbox $IDuserMail | Select-Object -expandproperty RecipientTypeDetails
        #finds if the user has a mailbox and is specifically a usermailbox then if the users password last set is greater than todays date -30 days
        if ($mailboxCheck -eq 'UserMailbox' -and $UserLastPwdSet -gt $dateformated) {

            #could make several if than greater than here to cater to specific alert and how many days to alert
            Write-host $user + "password will expire shortly"

        }
        else {
             Write-host $user + "password will NOT expire shortly"
        }


    }




} -AsJob


