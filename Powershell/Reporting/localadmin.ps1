#https://clintboessen.blogspot.com/2018/08/powershell-list-local-administrators-on.html


$serverlist = Get-Content C:\Support\Scripts\serverlist.txt

foreach ($server in $serverlist)
    {
    $ipAddress = $pingStatus.ProtocolAddress;
    # Ping the computer
    $pingStatus = Get-WmiObject -Class Win32_PingStatus -Filter "Address = '$server'";
    if ($pingStatus.StatusCode -eq 0) {
        Write-Host -ForegroundColor Green "Ping Reply received from $server.";
        $server | Out-File -NoClobber -Append C:\Support\Logs\localadmins.txt
        $admins = Gwmi win32_groupuser –computer $server
        $admins = $admins |? {$_.groupcomponent –like '*"Administrators"'}
        $admins |? {$_.groupcomponent –like '*"Administrators"'} | fl *PartComponent* | Out-File -NoClobber -Append C:\Support\Logs\localadmins.txt
    }
    else {
        Write-Host -ForegroundColor Red "No Ping Reply received from $server.";
    }
    
    }
