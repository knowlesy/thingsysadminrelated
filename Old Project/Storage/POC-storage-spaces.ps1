s#Install-WindowsFeature RSAT-Clustering-PowerShell
$Servers = "poc1","poc2","poc3"
$ServerRoles = "Hyper-V","Data-Center-Bridging","Failover-Clustering","RSAT-Clustering-PowerShell","Hyper-V-PowerShell","FS-FileServer"

foreach ($server in $servers){
    Install-WindowsFeature –Computername $server –Name $ServerRoles
}





Test-Cluster –Node $Servers –Include "Storage Spaces Direct", "Inventory", "Network", "System Configuration"

New-Cluster –Name testcluster –Node "poc1","poc2","poc3" –NoStorage

icm (Get-Cluster -Name testcluster | Get-ClusterNode) {

Update-StorageProviderCache

Get-StoragePool | ? IsPrimordial -eq $false | Set-StoragePool -IsReadOnly:$false -ErrorAction SilentlyContinue

Get-StoragePool | ? IsPrimordial -eq $false | Get-VirtualDisk | Remove-VirtualDisk -Confirm:$false -ErrorAction SilentlyContinue

Get-StoragePool | ? IsPrimordial -eq $false | Remove-StoragePool -Confirm:$false -ErrorAction SilentlyContinue

Get-PhysicalDisk | Reset-PhysicalDisk -ErrorAction SilentlyContinue

Get-Disk | ? Number -ne $null | ? IsBoot -ne $true | ? IsSystem -ne $true | ? PartitionStyle -ne RAW | % {

$_ | Set-Disk -isoffline:$false

$_ | Set-Disk -isreadonly:$false

$_ | Clear-Disk -RemoveData -RemoveOEM -Confirm:$false

$_ | Set-Disk -isreadonly:$true

$_ | Set-Disk -isoffline:$true

}

Get-Disk |? Number -ne $null |? IsBoot -ne $true |? IsSystem -ne $true |? PartitionStyle -eq RAW | Group -NoElement -Property FriendlyName

} | Sort -Property PsComputerName,Count

Enable-ClusterStorageSpacesDirect –CimSession testcluster


New-StoragePool -StorageSubSystemName testcluster -FriendlyName NanoS2D -ProvisioningTypeDefault Fixed -ResiliencySettingNameDefault Parity -Physicaldisks (Get-PhysicalDisk -CanPool $true -CimSession $Servers[0]) -CimSession $Servers[0]

New-Volume -StoragePoolFriendlyName *test* -FriendlyName vDisk1 -FileSystem CSVFS_ReFS -UseMaximumSize -CimSession $Servers[0]
