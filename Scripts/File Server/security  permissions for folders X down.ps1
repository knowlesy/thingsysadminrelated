####subject to which PS version comment out the sections


#################FOR PS VERSION 5#################################

#how far down PS5+
#$depth = '0'

#location
#$location = 'F:\Shares\OfficeFiles'

#gets the list of folders version 5+
#$listofFolders = Get-ChildItem -Path $location -Depth $depth 


#################FOR PS VERSION 2#################################
#olderversion of PS where \* is X amount of sub dir
$location2 = 'F:\Shares\OfficeFiles\*'
$listofFolders = Get-ChildItem -Path $location2 


##################################
#destination of output
$output = 'C:\Temp\securitoffolders.txt'

#runs a command for each item in a list
foreach ($folder in $listofFolders) {
    #gets the ntfs perm for the full location of the item from the list then outputs the information as a list to the output
    Get-Acl -Path $folder.FullName | Format-List >> $output
    }



