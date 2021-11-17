$FileScreenDrives = @()
while ($FileScreendrive = Read-Host "Enter Drives letter you wish to apply the ""Block Virus File Screen Template"" to") 
{
	$FileScreenDrives += "$FileScreenDrive"
} 
#Create a File Screen Per drive on the standard 
foreach ($FileScreenDrive in $FileScreenDrives) 
{
    #Applys a file Screen template "Virus" Per Drive
    New-FsrmFileScreen -Path ("$($FileScreendrive)`:\") –Template "Block Virus File Types"
    
}
