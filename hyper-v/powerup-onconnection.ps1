$vm = 'vm1', 'vm2'
$HostName = "host"
$pingHost = 'san-isci-smb'
Import-Module Hyper-V
$ping = Test-Connection $pingHost -Count 2 -Quiet
If ($ping)
{
    Start-VM -ComputerName $HostName -Name $vm
    Write-EventLog -LogName Application -Source "Scripts" -EntryType Information -EventId 1 -Message "$vm Powered On."
}
else
{
    Write-EventLog -LogName Application -Source "Scripts" -EntryType Warning -EventId 2 -Message "Could not find $pingHost."
}
