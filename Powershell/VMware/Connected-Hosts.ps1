Connect-VIServer -Server <server> -User <username> -Password <password>
$Hosts = Get-VMHost | where-object { $_.State -eq "Connected"} | select name |Out-String
