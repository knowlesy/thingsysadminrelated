$vm = 'vm1','vm2'
$HostName = "hyperv-host"
$pingHost = "iscsi-or-smbshare-or-whatevs"
Import-Module Hyper-V
$ping = Test-Connection $pingHost -Count 2
If ($pingHost)
{
    Start-VM -ComputerName $HostName -Name $vm
}
