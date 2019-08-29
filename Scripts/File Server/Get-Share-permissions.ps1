 $date = Get-Date -Format yyyy-MM-dd-%H-mm
 $export = ("C:\Temp\" + $date + "-Share_Permissions.csv")
 $ShareList = Get-SmbShare
 $ShareNames = $ShareList.Name
 $PermissionsList = Get-SmbShareAccess -Name $ShareNames
 $PermissionsList | Export-Csv $export