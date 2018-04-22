$Trigger= New-ScheduledTaskTrigger -At 03:00am -Daily
$User= "NT AUTHORITY\SYSTEM"
$Action= New-ScheduledTaskAction -Execute "cmd" -Argument "shutdown -s -f"
Register-ScheduledTask -TaskName "Daily Shutdown" -Trigger $Trigger -User $User -Action $Action -RunLevel Highest –Force
