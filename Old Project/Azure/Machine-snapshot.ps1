#https://arlanblogs.alvarnet.com/create-an-azure-disk-snapshot-posh/
#Assumed Logged into AZ
## Login-AzAccount
## Get-AzSubscription
## Select-AzSubscription "XXX""

##TBC
#Tagging

function Take-Snapshot {
    param (
        [Parameter(Mandatory = $True)] [string] $vmname
    )





    $name = "DC1"
    $date = Get-Date -Format yyyy-MM-dd-%H-mm
    $vm = get-azvm -name $name | select Location, Name, ResourceGroupName, storageprofile

    #OS Type
    #$vm.StorageProfile.OsDisk.OsType
    # $vm.StorageProfile.OsDisk.name
    $OSDisk = Get-AzDisk -DiskName $vm.StorageProfile.OsDisk.name -ResourceGroupName $vm.ResourceGroupName
    $OSSnapshotConfig = New-AzSnapshotConfig -SourceUri $OSDisk.Id -CreateOption Copy -Location $vm.Location

    $Snapshot = New-AzSnapshot -Snapshot $OSSnapshotConfig -SnapshotName ($date + '_OSDisk_ViaScript') -ResourceGroupName $vm.ResourceGroupName

    #datadisks
    #$vm.StorageProfile.DataDisks.name
    }








