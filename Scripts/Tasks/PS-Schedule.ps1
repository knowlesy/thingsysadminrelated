#REF https://4sysops.com/archives/create-powershell-scheduled-jobs/


#Define the interval to repeat the job
$trigger = New-JobTrigger -Once -At 9:00AM -RepetitionInterval (New-TimeSpan -Hours 12) -RepeatIndefinitely
 
#Get user credential so that the job has access to the network
$cred = Get-Credential -UserName bigfirm.biz\someuser
 
#Set job options
$opt = New-ScheduledJobOption -RunElevated -RequireNetwork
 
Register-ScheduledJob -Name Get-DCDiskSpace -Trigger $trigger -Credential $cred `
 -FilePath c:\scripts\Get-DCDiskSpace.ps1 -MaxResultCount 10  ScheduledJobOption $opt
