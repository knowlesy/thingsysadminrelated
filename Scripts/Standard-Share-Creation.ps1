#Refs#
#https://technochat.in/2014/05/set-file-system-auditing-via-powershell/
#https://4sysops.com/archives/create-a-new-folder-and-set-permissions-with-powershell/ 

#Pre-Set Variables#
$AdminGroup = 'Test-FS-AdminGroup' #Set default File Share Admin Group this should be for l2 and above
$SelectedAdminGroup = 'Test-FS-InfraAdminGroup' #The HR Clause this should be for Teamleads only
$DefaultSharelocation = 'C:\Shares' # local reference
$DefaultSharelocationNet = 'c$\Shares' #Network reference for explicit direction
$GeographicLocation = 'UK' #This could be business unit or another reference edit as you wish
$ServerServiceAccount = 'test.local\FileServers' #Audit rights / backups etc typically one per server 
$Company = 'Contoso' # your company / business unit / reference
$ShareGroupOU = "OU=Share-Group,OU=Group,OU=NCL,OU=UK,OU=EMEA,DC=test,DC=local" #OU for Share Groups
$SecurityGrupOU = "OU=Security-Group,OU=Group,OU=NCL,OU=UK,OU=EMEA,DC=test,DC=local" #OU for Security group permissions 
#Log/Event

#Fixed Variables#
$GroupStandard = "$GeographicLocation-$Company-$FileServer-$FolderName" #Naming convention for groups
$ShareGroupR = "$GroupStandard-SH-R" #Read only chare group
$ShareGroupC = "$GroupStandard-SH-C" #Change Share Group
$ShareGroupFC = "$GroupStandard-SH-FC" #Full Control Share Group
$SecurityGroupR = "$GroupStandard-SE-R" #Read only NTFS Permissions
$SecurityGroupM = "$GroupStandard-SE-M" #Modify R/W & Delete Set by standard by default this is a special permission set
$SecurityGroupFC = "$GroupStandard-SE-FC" # Full NTFS Control 
$AuditUser = "Everyone" #Everyone for auditing 
$AuditRules = "Delete,DeleteSubdirectoriesAndFiles,ChangePermissions,Takeownership" #audit actions were looking for 
$InheritType = "ContainerInherit,ObjectInherit" #inherritance 
$AuditType = "Success" #actions yes or no
$AccessRule = New-Object System.Security.AccessControl.FileSystemAuditRule($AuditUser,$AuditRules,$InheritType,"None",$AuditType) #setting the rule 
$FullLocation = "\\$FileServer\$DefaultSharelocationNet\$FolderName" #Full network Server / Disk Folder Location
$RootFolder = "\\$FileServer\$DefaultSharelocationNet\"# Root of Network Server / Disk Location
$ShareLocation = "\\$FileServer\$FolderName" # Share location
$Sourcepath = "$DefaultSharelocation\$FolderName" #on server folder created location
#Log/Event

#User input Variables#
$FileServer = '2016-FS1' #Read-Host -Prompt 'Enter File Server'
$FolderName = 'Test4' #Read-Host -Prompt 'Enter Share Name' 
#HR-Saftey Tag is this for HR if so then reduced Admins 
#Request incident number
#Log/Event

Write-Host "Importing AD Module"
Import-Module -Name ActiveDirectory -ErrorAction Stop
#Log/Event


#Testing Server is online
if(Test-Connection -Count 2 -ComputerName $FileServer -Quiet)
{
    #Log/Event
    Write-Host "Server Responded - Success"
}
else
{
    #Log/Event
    Write-Host "Server Failed to Respond - Script will now close"
    Start-Sleep -Seconds 60
    Exit
}

#Testing Folder is exists
if (Test-Path -Path "$FullLocation")
{
    #Log/Event
    Write-Host "Folder exists - Script will now close"
    Start-Sleep -Seconds 60
    Exit
}
Else
{
    #Log/Event
    Write-Host "Folder does not exist - Success"
}

#Testing Share is exists
if (Test-Path -Path "$ShareLocation")
{
    #Log/Event
    Write-Host "Share exists - Script will now close"
    Start-Sleep -Seconds 60
    Exit
}
Else
{
    #Log/Event
    Write-Host "Share does not exist - Success"
}

#Creating Shares Privalages for that Folder 
#Read Access
New-ADGroup -Name "$ShareGroupR" -Description "$FileServer - $FolderName Share Read Access" -DisplayName "$ShareGroupR" -GroupScope Global -Path $ShareGroupOU
#Ask are authenticated users to be added - check for HR Flag

#Change Access
New-ADGroup -Name "$ShareGroupC" -Description "$FileServer - $FolderName Share Change Access" -DisplayName "$ShareGroupC" -GroupScope Global -Path $ShareGroupOU
#Ask are authenticated users to be added - check for HR Flag

#Full Control
New-ADGroup -Name "$ShareGroupFC" -Description "$FileServer - $FolderName Share Full Control Access" -DisplayName "$ShareGroupFC" -GroupScope Global -Path $ShareGroupOU

#Check for HR Flag
#Add Default Admins / Service Account
Add-ADGroupMember -Identity "$ShareGroupFC" -Members "$AdminGroup", "$ServerServiceAccount" 

#Creating Security Privalages for that Folder 
#Read Access
New-ADGroup -Name "$SecurityGroupR" -Description "$FileServer - $FolderName Security Read Access" -DisplayName "$SecurityGroupR" -GroupScope Global -Path $ShareGroupOU
#Ask are authenticated users to be added - check for HR Flag

#Change Access
New-ADGroup -Name "$SecurityGroupM" -Description "$FileServer - $FolderName Security Modify Access" -DisplayName "$SecurityGroupC" -GroupScope Global -Path $ShareGroupOU
#Ask are authenticated users to be added - check for HR Flag

#Full Control
New-ADGroup -Name "$SecurityGroupFC" -Description "$FileServer - $FolderName Security Full Control Access" -DisplayName "$SecurityGroupFC" -GroupScope Global -Path $ShareGroupOU

#Check for HR Flag
#Add Default Admins / Service Account
Add-ADGroupMember -Identity "$SecurityGroupFC" -Members "$AdminGroup", "$ServerServiceAccount" 
#Log/Event

New-Item -Path $FullLocation -ItemType Directory -Name $RootFolder
#Log/Event


#Set Security PErmissions https://4sysops.com/archives/create-a-new-folder-and-set-permissions-with-powershell/ 


#Set Audit
$ACL = Get-Acl $Sourcepath
$ACL.SetAuditRule($AccessRule)
Write-Host "Processing >",$Sourcepath
$ACL | Set-Acl $Sourcepath
Write-Host "Audit Policy applied successfully."



New-SmbShare -Name $FolderName -cimsession $FileServer -ContinuouslyAvailable 0 -ReadAccess $ShareGroupR -FullAccess $ShareGroupFC -ChangeAccess $ShareGroupC -Path $Sourcepath -ErrorAction SilentlyContinue
#TestSMB Creation
#Log/Event

#Confirm folder types for FSRM
#Confirm quotas
#add to dfs
