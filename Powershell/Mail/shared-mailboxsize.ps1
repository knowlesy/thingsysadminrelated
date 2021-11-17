#ref
#https://gallery.technet.microsoft.com/office/Get-Office-365-Shared-5fb5de24


$OutputFile = 'D:\1sharedsize.csv'


    Out-File -FilePath $OutputFile -InputObject "UserPrincipalName,NumberOfItems,MailboxSize,IssueWarningQuota,ProhibitSendQuota,ProhibitSendReceiveQuota" -Encoding UTF8

    #gather all shared/room/resource mailboxes from Office 365
    $objMailboxes = get-mailbox -ResultSize Unlimited -filter {RecipientTypeDetails -eq "SharedMailbox" -or RecipientTypeDetails -eq "RoomMailbox"} | select UserPrincipalName,IssueWarningQuota,ProhibitSendQuota,ProhibitSendReceiveQuota

    #Iterate through all users
    Foreach ($objMailbox in $objMailboxes)
    {
        #Connect to the users mailbox
        $objMailboxStats = get-mailboxstatistics -Identity $($objMailbox.UserPrincipalName) | Select ItemCount,TotalItemSize

        #Prepare UserPrincipalName variable
        $strUserPrincipalName = $objMailbox.UserPrincipalName

        #Get the size and item count
        $ItemSizeString = $objMailboxStats.TotalItemSize.ToString()
        $strMailboxSize = "{0:N2}" -f ($ItemSizeString.SubString(($ItemSizeString.IndexOf("(") + 1),($itemSizeString.IndexOf(" bytes") - ($ItemSizeString.IndexOf("(") + 1))).Replace(",","")/1024/1024)

        $strItemCount = $objMailboxStats.ItemCount

        #Get the quotas
        $ItemSizeString = $objMailbox.IssueWarningQuota.ToString()
        $strMailboxIssueWarningQuota = "{0:N2}" -f ($ItemSizeString.SubString(($ItemSizeString.IndexOf("(") + 1),($itemSizeString.IndexOf(" bytes") - ($ItemSizeString.IndexOf("(") + 1))).Replace(",","")/1024/1024)
        $ItemSizeString = $objMailbox.ProhibitSendQuota.ToString()
        $strMailboxProhibitSendQuota = "{0:N2}" -f ($ItemSizeString.SubString(($ItemSizeString.IndexOf("(") + 1),($itemSizeString.IndexOf(" bytes") - ($ItemSizeString.IndexOf("(") + 1))).Replace(",","")/1024/1024)
        $ItemSizeString = $objMailbox.ProhibitSendReceiveQuota.ToString()
        $strMailboxProhibitSendReceiveQuota = "{0:N2}" -f ($ItemSizeString.SubString(($ItemSizeString.IndexOf("(") + 1),($itemSizeString.IndexOf(" bytes") - ($ItemSizeString.IndexOf("(") + 1))).Replace(",","")/1024/1024)

        #Output result to screen for debuging (Uncomment to use)
        #write-host "$strUserPrincipalName : $strLastLogonTime"

        #Prepare the user details in CSV format for writing to file
        $strMailboxDetails = ('"'+$strUserPrincipalName+'","'+$strItemCount+'","'+$strMailboxSize+'","'+$strMailboxIssueWarningQuota+'","'+$strMailboxProhibitSendQuota+'","'+$strMailboxProhibitSendReceiveQuota+'"')

        #Append the data to file
        Out-File -FilePath $OutputFile -InputObject $strMailboxDetails -Encoding UTF8 -append
    }