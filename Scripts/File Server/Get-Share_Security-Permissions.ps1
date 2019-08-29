#https://community.spiceworks.com/scripts/show/1070-export-folder-permissions-to-csv-file

$date = Get-Date -Format yyyy-MM-dd-%H-mm
$OutFile = ("C:\Temp\" + $date + "-Permissions.csv")
$Header = "Folder Path,IdentityReference,AccessControlType,IsInherited,InheritanceFlags,PropagationFlags"
#Del $OutFile
Add-Content -Value $Header -Path $OutFile

$location = Get-SmbShare
#shares
$RootPath = $location.Path

#specified folder
#$RootPath = "C:\temp"

$Folders = dir $RootPath -recurse | where {$_.psiscontainer -eq $true}

foreach ($Folder in $Folders){
	$ACLs = get-acl $Folder.fullname | ForEach-Object { $_.Access  }
	Foreach ($ACL in $ACLs){
	$OutInfo = $Folder.Fullname + "," + $ACL.IdentityReference  + "," + $ACL.AccessControlType + "," + $ACL.IsInherited + "," + $ACL.InheritanceFlags + "," + $ACL.PropagationFlags
	Add-Content -Value $OutInfo -Path $OutFile
	}}