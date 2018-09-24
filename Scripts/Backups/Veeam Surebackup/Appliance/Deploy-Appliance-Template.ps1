#REF
#https://helpcenter.veeam.com/docs/backup/powershell/vmware_vlab.html?ver=95

#Variables
$location = "<locationprefix>"


#Fixed Variables
$esxihost = $location + 'esx01'
$datastore = $location + '-S-PRODT1-01'

Add-VSBVirtualLab -Name "$applianceName" -Server $esxihost -Datastore $datastore