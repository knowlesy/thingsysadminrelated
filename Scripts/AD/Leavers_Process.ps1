#Alpha Testing 

#Ref
#https://gallery.technet.microsoft.com/scriptcenter/Write-Log-PowerShell-999c32d0

#Information for End user
Clear-Host
Write-Host "Logs will be stored in C:\Support\Logs" -ForegroundColor Green
Write-Host "This must be ran as your admin account" -ForegroundColor Green
Write-Host "Remember to be apart of the exclusion rule for sending Emails with AV" -ForegroundColor Green
Start-Sleep -Seconds 2

#Functions
function Write-Log {
    [CmdletBinding()]

    Param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias("LogContent")]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [Alias('LogPath')]
        #[string]$Path = C:\Support\Logs\AD.log
        [string]$Path = $logpath,
        #[switch]$path2,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Error", "Warn", "Info")]
        [string]$Level = "Info",

        [Parameter(Mandatory = $false)]
        [switch]$NoClobber
    )

    Begin {
        # Set VerbosePreference to Continue so that verbose messages are displayed.
        $VerbosePreference = 'Continue'
    }
    Process {

        # If the file already exists and NoClobber was specified, do not write to the log.
        if ((Test-Path $Path) -AND $NoClobber) {
            Write-Error "Log file $Path already exists, and you specified NoClobber. Either delete the file or specify a different name."
            Return
        }

        # If attempting to write to a log file in a folder/path that doesn't exist create the file including the path.
        elseif (!(Test-Path $Path)) {
            Write-Verbose "Creating $Path."
            $NewLogFile = New-Item $Path -Force -ItemType File
        }

        else {
            # Nothing to see here yet.
        }

        # Format Date for our Log File
        $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

        # Write message to error, warning, or verbose pipeline and specify $LevelText
        switch ($Level) {
            'Error' {
                Write-Error $Message
                $LevelText = 'ERROR:'
            }
            'Warn' {
                Write-Warning $Message
                $LevelText = 'WARNING:'
            }
            'Info' {
                Write-Verbose $Message
                $LevelText = 'INFO:'
            }
        }

        # Write log entry to $Path
        "$FormattedDate $LevelText $Message" | Out-File -FilePath $Path -Append
    }
    End {
    }
}

#Static Variables for Function
$logcreated = Get-Date
$logpath = 'C:\Support\logs\AD-Disableuser' + $logcreated.ToString("yyyy-MM-dd_HH-mm-ss") + ".log"
$dateforemail = $logcreated.ToString("yyyy-MM-dd")
$HRnIT = 'internalhr@company.com'
$appowners = 'appowners@company.com'
$mailserver = 'smtp server'



#Manager Email
$ManagerbodyEmail = "Hello " + $manFullName + $fullname + " left the company on " + $dateforemail
$ManagerbodyEmail += "<b>PLEASE RETURN ALL IT HARDWARE</b> to the Infrastructure Team in your local site as soon as possible, if you havent done so already."
$ManagerbodyEmail += "Their Out Of Office message is currently set to:"
$ManagerbodyEmail +=  $fullname + " has left company. "
$ManagerbodyEmail += "Please contact the office directly on 123456."
$ManagerbodyEmail += "If you would like this message changed, please let me know."
$ManagerbodyEmail += "Please also be aware that:"
$ManagerbodyEmail += "IT equipment (incl. laptop) will be scheduled for redeployment after 14 days!"
$ManagerbodyEmail += "Personal folders, emails and any user specific VMs will be removed after 30 days!"
$ManagerbodyEmail += "You are responsible for obtaining any data from their equipment before this time."
$ManagerbodyEmail += "If you require any of the leavers data, reply to this email with the following details:"
$ManagerbodyEmail += "<i>a.	What data is required?</i> "
$ManagerbodyEmail += "<i>b.	For how long?</i>"
$ManagerbodyEmail += "Kind Regards"

#Apps Email
$appbodyEmail = "Hello, "  $fullname + " left the company on " + $dateforemail
$appbodyEmail += "Please remove any user access from related systems any Hardware or Licenses that need to be collected please let us know"
$appbodyEmail += "<i>(E.g. ........)</i> "
$appbodyEmail += "Kind Regards"




####Pre Flight Checks###

#initial log of who is running the script
Write-Log "User running the script is $env:USERNAME" -Level Info

#check to see if its ran as an Admin account
if ($env:USERNAME.StartsWith('!')) {
        Write-Log "Ran with Admin account" -Level INFO
}
else {
      Write-Log "Did not run with an Admin Account terminating" -Level Error
    start-sleep -Seconds 2
    exit
}

#Checks if AD Module is on the machine if it fails it stops
if (Get-Module -ListAvailable -Name ActiveDirectory) {
    Write-Log "ADModule exists" -level INFO
    #trys importing the module
    Try {
        Import-Module ActiveDirectory
    }
    Catch {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Log -Message $ErrorMessage -Level Error
        Write-Log -Message $FailedItem -Level Error
    }

    Write-Log -Message 'AD Module exists and is Importing' -Level INFO
}
else {
    Write-Log "AD Module does not exist on users machine process terminated" -Level Error
    exit
}

#Trys to import exch 2010 ps snapin if it fails it stops
add-pssnapin Microsoft.Exchange.Management.PowerShell.E2010
$exchimported = Get-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010 | Select-Object -ExcludeProperty Name
$exchimportedworks = $exchimported.ToString()
if ($exchimportedworks -ccontains "Microsoft.Exchange.Management.PowerShell.E2010")
    {
    Write-Log "Exchange Module Imported" -level INFO

    }
else {
    Write-Log "Exchange Module Did not import" -Level Error
    exit
}




###Script Gore ###

 #ask for credentials of normal user to send email
    $email = Read-Host -Prompt 'Input YOUR none admin email address'
    Write-Log "email address entered to send emails $email" -Level Info
    $credentials = Get-Credential -UserName $email -Message "Enter your NONE admin email address"



#Checks if user exists
$lookupAD = Read-Host -Prompt 'Input username'
Write-Log 'User input $lookupAD' -Level INFO

#if user exists is TRUE
if (Get-ADUser -Identity $lookupAD) {
    Write-Log "User exists in AD" -Level INFO

    #gets fullname variable as AD is set backwards
    $firstName = Get-ADUser -Identity $lookupAD -Properties * | Select-Object -ExpandProperty givenname
    $surname = Get-ADUser -Identity $lookupAD | Select-Object -ExpandProperty Surname
    $fullname = $firstName.ToString() + " " + $surname.ToString()


    #log all info on user
    $userinfo = Get-ADUser -Identity $lookupAD -Properties * | Select *
    foreach ($useritem in $userinfo)
    {
        write-log $useritem -Level Info
    }

    #log all mail info on user
    $mailuserinfo = Get-mailbox -Identity $lookupAD | Select *
    foreach ($mailuseritem in $mailuserinfo)
    {
        write-log $mailuseritem -Level Info
    }


    #new variable as AD user confirmed
    $lookupAD = $ADconfirmed
    write-log 'Disabling Account' -Level Info

    #disable account
    Disable-ADAccount -Identity $ADconfirmed
    start-sleep -Seconds 2

    #check for account disabled
    $accountenabledcheck = Get-ADUser -Identity $ADconfirmed | select-object -ExpandProperty Enabled
    $accountstatus = $accountenabledcheck.ToString()
        if ($accountstatus -ccontains 'True')
            {
            write-log "Account still enabled" -Level Error
            sleep -Seconds 2
            Exit
            }
        else
            {
            write-log "Account disabled" -Level Info
            }

    #Get user description
    $currentuserdesc = Get-ADUser -Identity $ADconfirmed -Properties Description | select -ExpandProperty Description
    write-log "Current Description for User: $currentuserdesc" -Level Info
    #Update user description
    Set-ADUser -Identity $ADconfirmed -Description "User has left, account disabled as of" + $logcreated.ToString("yyyy-MM-dd_HH-mm-ss")
    write-log "updated user has left" -Level Info

    #output groups their a member of
    write-log "User is a member of" -Level Info
    $memberof = Get-ADPrincipalGroupMembership $ADconfirmed | select-object -ExpandProperty name
    foreach ($memberingroup in $memberof)
    {
         write-log "$memberingroup" -Level Info
    }


    #remove all groups
    Write-Log "Removing user from groups" -Level Info
    foreach( $removeuserfrom in $memberof | Where-Object {$_.identity -ne "Domain Users"})
    {
        write-log "Removed from $removeuserfrom" -Level Info
        Remove-ADGroupMember -Identity $removeuserfrom -Member $ADconfirmed
        #Add-ADGroupMember -Identity "Domain Users" -Members $ADconfirmed
    }

    #get out of office if set
    $currentooo = Get-MailboxAutoReplyConfiguration -Identity $ADconfirmed
    Write-Log "Getting current out of office" -Level Info
    foreach ($ooofItem in $currentooo)
    {
    Write-Log "$ooofItem" -Level Info
    }

    #set out of office
    Write-Log "Setting current out of office" -Level Info
    Set-MailboxAutoReplyConfiguration -Identity $ADconfirmed -AutoReplyState Enabled -ExternalAudience All -ExternalMessage $fullname + "has left the company. Please contact the office directly on +44(0) 1488 662000." -InternalMessage $fullname + "has left the company. Please contact the office directly on +44(0) 1488 662000."
    $newooo = Get-MailboxAutoReplyConfiguration -Identity $ADconfirmed
    Write-Log "Getting new out of office" -Level Info
    foreach ($newooofItem in $newooo)
    {
    Write-Log "$newooofItem" -Level Info
    }


    #hide from addressbook
    Write-Log "Removing from addressbook" -Level Info
    Set-Mailbox -Identity $ADconfirmed -HiddenFromAddressListsEnabled $true

    $addressbookstatus = Get-Mailbox -Identity $ADconfirmed | select PrimarySmtpAddress,HiddenFromAddressListsEnabled | Format-List
    foreach ($addressstatusitem in $addressbookstatus)
    {
        write-log $addressstatusitem -Level Info
    }



    #check if they have a manager
    $manager = Get-ADUser -Identity $ADconfirmed -Properties * | select-object -ExpandProperty Manager

    if ($manager -eq $null)
    {
        ###email IT and HR
        Send-MailMessage -Credential $credentials -From $email -To $HRnIT -Subject $fullname + "has no Manager" -SmtpServer $mailserver -Body 'This is an automated message, the user' + $fullname + 'has no manager set, please respond to this email with a manager'
        Write-Log "Manager is not sent email sent to IT / HR" -Level Warn
    }
    else
    {
        #gets managers email
        $getmanemail = Get-ADUser -Identity $manager -Properties *  | Select-Object -ExpandProperty mail
        $manfirstName = Get-ADUser -Identity $manager -Properties *  | Select-Object -ExpandProperty fivenname
        $mansurName = Get-ADUser -Identity $manager -Properties *  | Select-Object -ExpandProperty Surname
        $manFullName = $manfirstName.ToString() + $mansurName.ToString()


        Write-Log "Manager attribute is populated" -Level Info
        Write-Log $manager -Level Info

            #trys emailing manager
    Try {
            #Email Managers
         Send-MailMessage -Credential $credentials -From $email -To $getmanemail -Subject $fullname + "has left the orginisation" -SmtpServer $mailserver -Body $ManagerbodyEmail -BodyAsHtml
        write-log "Email sent to manager" -level info
    }
    Catch {
        Write-Log "Failed to send email to Manager" -Level Error
        Write-log "Check you are allowed to send outbound emails in AV or you entered the correct credentials" -level Error
        Write-log "You will have to manually email the Manager / app owner now" -level Error
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName

        Write-Log $ErrorMessage -Level Error
        Write-Log $FailedItem -Level Error
    }


    #trys emailing app owners
    Try {
        #Email apps team
         Send-MailMessage -Credential $credentials -From $email -To $getmanemail -Subject $fullname + "has left the orginisation" -SmtpServer $mailserver -Body $appbodyEmail -BodyAsHtml
        write-log "Email sent to app owners" -level info
    }
    Catch {
        Write-Log "Failed to send email to Manager" -Level Error
        Write-log "Check you are allowed to send outbound emails in AV or you entered the correct credentials" -level Error
        Write-log "You will have to manually email the Manager / app owner now" -level Error
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName

        Write-Log $ErrorMessage -Level Error
        Write-Log $FailedItem -Level Error
    }


    }

    #confirm if they have anyone underneith them
    $Directreports = Get-ADUser -Identity $ADconfirmed -Properties *  | Select-Object -ExpandProperty directReports
    if ($Directreports -eq $null)
    {
        Write-Log "No Direct Reports" -Level Info

    }
    else
    {

        Write-Log "User is a manager" -Level Info
        foreach ($directreportuser in $Directreports)
        {
        Write-Log $directreportuser -Level Info
        }

        #reassign direct reportees
        Write-Log "Redirecting USers to new manager" -Level Info
        $newManager = Read-Host -Prompt "Enter Username of New Manager"
        if (get-aduser -Identity $newManager)
        {
            Write-Log "Manager Exists proceeding to redirect users" -Level Info
            foreach ($directreportuser in $Directreports)
            {
                Write-Log "User: $directreportuser set to under $newManager Mgmt" -Level Info
                Set-ADUser -Identity $directreportuser -Manager $newManager
            }
        }
        else
        {
        Write-Log "New manager does not exist you will have to do this manually" -Level Error
        }

    }






    ###move account to left OU

	### set local admin password on machine



    # check if they have an admin account
    Write-Log "Checking if user has an admin account" -Level Info

    $adminaccount = "!" + $lookupAD
if (Get-ADUser -Identity $adminaccount)
 {
    Write-Log "Admin exists in AD: $adminaccount" -Level INFO

    #log all info on user
    $adminuserinfo = Get-ADUser -Identity $adminaccount -Properties * | Select *
    foreach ($adminuseritem in $adminuserinfo)
    {
        write-log $adminuseritem -Level Info
    }


    #new variable as AD user confirmed
    $adminaccount = $AdminADconfirmed
    write-log 'Disabling Account' -Level Info

    #disable account
    Disable-ADAccount -Identity $AdminADconfirmed
    start-sleep -Seconds 2

    #check for account disabled
    $Adminaccountenabledcheck = Get-ADUser -Identity $AdminADconfirmed | select-object -ExpandProperty Enabled
    $Adminaccountstatus = $Adminaccountenabledcheck.ToString()
        if ($Adminaccountstatus -ccontains 'True')
            {
            write-log "Admin Account still enabled" -Level Error
            sleep -Seconds 2
            Exit
            }
        else
            {
            write-log "Admin Account disabled" -Level Info
            }

    #Get admin user description
    $admincurrentuserdesc = Get-ADUser -Identity $AdminADconfirmed -Properties Description | select -ExpandProperty Description
    write-log "Current Description for User: $qdmincurrentuserdesc" -Level Info
    #Update user description
    Set-ADUser -Identity $AdminADconfirmed -Description "User has left, account disabled as of" + $logcreated.ToString("yyyy-MM-dd_HH-mm-ss")
    write-log "updated user has left" -Level Info

    #output groups their a member of
    write-log "User is a member of" -Level Info
    $Adminmemberof = Get-ADPrincipalGroupMembership $AdminADconfirmed | select-object -ExpandProperty name
    foreach ($Adminmemberingroup in $Adminmemberof)
    {
         write-log "$Adminmemberingroup" -Level Info
    }


    #remove all groups
    Write-Log "Removing Admin user from groups" -Level Info
    foreach( $Adminremoveuserfrom in $Adminmemberof | Where-Object {$_.identity -ne "Domain Users"})
    {
        write-log "Removed from $Adminremoveuserfrom" -Level Info
        Remove-ADGroupMember -Identity $Adminremoveuserfrom -Member $AdminADconfirmed
        #Add-ADGroupMember -Identity "Domain Users" -Members $AdminADconfirmed
    }



    }
    else
    {
        write-log "No admin account for this user" -level info
    }


}
else {
    Write-Log 'User did not exist' -Level Error
    start-sleep -seconds 2
    exit
}
