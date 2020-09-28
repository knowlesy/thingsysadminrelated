$teams = get-team
$OutputPath = 'C:\temp\Teams-Report.csv'

foreach ($team in $teams)
{
    $teamowner = Get-TeamUser -GroupId $team.groupid | where-object {$_.role -eq "Owner"}
    $teamguest = Get-TeamUser -GroupId $team.groupid | where-object {$_.role -ne "Owner"}
    $teamchannels = Get-TeamChannel -GroupId $team.groupid
    foreach ($teamchannel in $teamchannels)
    {

    $csvoutput = @(
        [pscustomobject]@{
           TeamName = $team.displayname
           TeamDescription = $team.Description
            TeamVisibility = $team.Visibility
            TeamArchieved = $team.Archived
            TeamMailNickname = $team.MailNickName
           TeamChannel = $teamchannel.displayname
            TeamChannelDescription = $teamchannel.description
           TeamOwnerMail = ($teamowner.user -join ";")
           TeamOwnerName = ($teamowner.name -join ";")
           TeamNotOwnerMail = ($teamguest.mail -join ";")
           TeamNotOwnerName = ($teamguest.name -join ";")
        })

     $csvoutput | Export-CSV $OutputPath -Append -Force -notypeinformation -noclobber




    }


    }