#https://practical365.com/collaboration/groups/office-365-groups-vs-shared-mailboxes/
#https://docs.microsoft.com/en-us/powershell/module/exchange/get-unifiedgroup?view=exchange-ps
#https://vladtalkstech.com/2018/03/find-all-the-office-365-groups-a-user-is-a-member-of-with-powershell.html

$output = 'c:\temp\group.csv'
$input2 = Get-Content 'C:\temp\group.txt'


foreach ($object in $input2) {
    $getmembers = Get-UnifiedGroupLinks $object -linktype Members | Select-Object DisplayName,PrimarySmtpAddress,RecipientType

foreach ($member in $getmembers)
{
$csvoutput = @(
    [pscustomobject]@{
        Group =  $object

        Member = $member.DisplayName

        MemberEmail = $member.PrimarySmtpAddress

        MemberType = $member.RecipientType

    })

    $csvoutput | Export-CSV $output -Append -NoTypeInformation -NoClobber
}
    
}