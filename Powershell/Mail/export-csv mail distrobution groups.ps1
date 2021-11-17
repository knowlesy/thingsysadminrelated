$Outputfile = 'D:\o365dlmembers.csv'
$arrDLMembers = @{}

#Prepare Output file with headers
Out-File -FilePath $OutputFile -InputObject "Distribution Group DisplayName,Distribution Group Email,Member DisplayName, Member Email, Member Type" -Encoding UTF8

#Get all Distribution Groups from Office 365
$objDistributionGroups = Get-DistributionGroup -ResultSize Unlimited

#Iterate through all groups, one at a time
Foreach ($objDistributionGroup in $objDistributionGroups)
{

    write-host "Processing $($objDistributionGroup.DisplayName)..."

    #Get members of this group
    $objDGMembers = Get-DistributionGroupMember -Identity $($objDistributionGroup.PrimarySmtpAddress)

    write-host "Found $($objDGMembers.Count) members..."

    #Iterate through each member
    Foreach ($objMember in $objDGMembers)
    {
        Out-File -FilePath $OutputFile -InputObject "$($objDistributionGroup.DisplayName),$($objDistributionGroup.PrimarySMTPAddress),$($objMember.DisplayName),$($objMember.PrimarySMTPAddress),$($objMember.RecipientType)" -Encoding UTF8 -append
        write-host "`t$($objDistributionGroup.DisplayName),$($objDistributionGroup.PrimarySMTPAddress),$($objMember.DisplayName),$($objMember.PrimarySMTPAddress),$($objMember.RecipientType)"
    }
}