$HostNames = "host1","host2"
Import-Module Hyper-V


foreach ($HostName in $HostNames)
{
    $VMNames = Get-VM -ComputerName $HostName | where state -eq 'running' | select Name
      
        foreach ($VMName in $VMNames)
        {
        Stop-VM -ComputerName $HostName -Name $VMName.name -Force 
        
        }
}

Start-Sleep -s 60
shutdown -f -s -t 30
