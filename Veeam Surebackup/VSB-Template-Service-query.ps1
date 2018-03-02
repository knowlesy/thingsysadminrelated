#query-service.ps1
param(
[string] $ip, #IP address of checked server
[string] $service ) #Service name
$result = (get-Service -ComputerName $ip -Name $service -ErrorAction SilentlyContinue)
if($result.status -eq "Running")
{
exit
}
else
{
write-host ("Error 1, Service '" + $service + "' not running or not found.") #if service not found or not running, then echo
$host.SetShouldExit(1)
exit
}