
$OutputPath = 'C:\temp\distmembers.csv'
$distlist = Get-DistributionGroup 

foreach ($distgroup in $distlist)
{
$groupemail = Get-DistributionGroup $distgroup.DistinguishedName | select DistinguishedName
$distspecifics = Get-DistributionGroup $distgroup.DistinguishedName | Select-Object Name,PrimarySmtpAddress,DisplayName
$getmembers = Get-DistributionGroupMember -Identity $groupemail.DistinguishedName | Select-Object DisplayName,PrimarySmtpAddress,RecipientType

foreach ($member in $getmembers)
{
$csvoutput = @(
    [pscustomobject]@{
        DistGroupNamne =  $distspecifics.Name

        DistGroupEmail = $distspecifics.PrimarySmtpAddress

        DistgroupDisplayName = $distspecifics.DisplayName

        Member = $member.DisplayName

        MemberEmail = $member.PrimarySmtpAddress

        MemberType = $member.RecipientType

        
       

    })

    $csvoutput | Export-CSV $OutputPath -Append -Force -notypeinformation
}
}

#Get-DistributionGroup | Select-Object Name,DisplayName,PrimarySmtpAddress,LegacyExchangeDN | Export-Csv c:\temp\DistGroupInfo.csv -NoTypeInformation


