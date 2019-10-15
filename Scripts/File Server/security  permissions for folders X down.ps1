#how far down
$depth = '0'
#location
$location = 'C:\Temp\test\'
#destination of output
$output = 'C:\Temp\securitoffolders.txt'
#gets the list of folders
$listofFolders = Get-ChildItem -Path $location -Depth $depth 
#runs a command for each item in a list
foreach ($folder in $listofFolders) {
    #gets the ntfs perm for the full location of the item from the list then outputs the information as a list to the output
    Get-Acl -Path $folder.FullName | Format-List >> $output
    }
