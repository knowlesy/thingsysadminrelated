#Refs#
#https://technochat.in/2014/05/set-file-system-auditing-via-powershell/
#https://4sysops.com/archives/create-a-new-folder-and-set-permissions-with-powershell/ 

#Pre-Set Variables#
$AdminGroup = 'Test-FS-AdminGroup'
$SelectedAdminGroup = 'Test-FS-InfraAdminGroup'
$DefaultSharelocation = 'C:\Shares'
$DefaultSharelocationNet = 'c$\Shares'
$GeographicLocation = 'UK'
$ServerServiceAccount = 'test.local\FileServers'
$Company = 'Contoso'
$ShareGroupOU = "OU=Share-Group,OU=Group,OU=NCL,OU=UK,OU=EMEA,DC=test,DC=local"
$SecurityGrupOU = "OU=Security-Group,OU=Group,OU=NCL,OU=UK,OU=EMEA,DC=test,DC=local"
#Log/Event

#Fixed Variables#
$GroupStandard = "$GeographicLocation-$Company-$FileServer-$FolderName"
$ShareGroupR = "$GroupStandard-SH-R"
$ShareGroupC = "$GroupStandard-SH-C"
$ShareGroupFC = "$GroupStandard-SH-FC"
$SecurityGroupR = "$GroupStandard-SE-R"
$SecurityGroupM = "$GroupStandard-SE-M"
$SecurityGroupFC = "$GroupStandard-SE-FC"
$AuditUser = "Everyone"
$AuditRules = "Delete,DeleteSubdirectoriesAndFiles,ChangePermissions,Takeownership"
$InheritType = "ContainerInherit,ObjectInherit"
$AuditType = "Success"
$AccessRule = New-Object System.Security.AccessControl.FileSystemAuditRule($AuditUser,$AuditRules,$InheritType,"None",$AuditType)
$FullLocation = "\\$FileServer\$DefaultSharelocationNet\$FolderName"
$RootFolder = "\\$FileServer\$DefaultSharelocationNet\"
$ShareLocation = "\\$FileServer\$FolderName"
#Log/Event

#User input Variables#
$FileServer = '2016-FS1' #Read-Host -Prompt 'Enter File Server'
$FolderName = 'Test4' #Read-Host -Prompt 'Enter Share Name' 
#HR-Saftey Tag is this for HR if so then reduced Admins 
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
