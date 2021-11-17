#Refs#
#https://technochat.in/2014/05/set-file-system-auditing-via-powershell/
#https://4sysops.com/archives/create-a-new-folder-and-set-permissions-with-powershell/ 

#Logging
Import-Module C:\Temp\PSMultiLog.psm1
Start-FileLog -FilePath c:\Logs\FilServer.log -LogLevel Information # Log everything.
Start-EventLogLog -Source "Share-Creation" 
Start-HostLog -LogLevel Information


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
Write-Log -EntryType Information -Message "Admin grop used, $AdminGroup"
Write-Log -EntryType Information -Message "Restricted Admins, $SelectedAdminGroup"
Write-Log -EntryType Information -Message "Default Share location, $DefaultSharelocation"
Write-Log -EntryType Information -Message "Network reference location, $DefaultSharelocationNet"
Write-Log -EntryType Information -Message "Geographic location, $GeographicLocation"
Write-Log -EntryType Information -Message "Service account, $ServerServiceAccount"
Write-Log -EntryType Information -Message "Entity is, $Company"
Write-Log -EntryType Information -Message "Share group is, $ShareGroupOU"
Write-Log -EntryType Information -Message "Security Group is, $SecurityGrupOU"

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
Write-Log -EntryType Information -Message "Server Entered $FileServer"
$FolderName = 'Test4' #Read-Host -Prompt 'Enter Share Name'
Write-Log -EntryType Information -Message "Sharename Entered $FolderName" 
$Secureconfirm = Read-Host "n" #"Confirm is this a secure Share? Y/N"
If(($confirm) -eq "y")
{
   Write-Log -EntryType Information -Message "Secure Share selected" 
   $SecureShare = "True"
}
Else
{
   Write-Log -EntryType Information -Message "Secure Share Not Selected"  
   $SecureShare = "False"
}
$IncidentRef = 'INC12345' #Read-Host -Prompt 'Enter Incident Ref'
Write-Log -EntryType Information -Message "Incident Ref is $IncidentRef"


Write-Host "Importing AD Module"
Import-Module -Name ActiveDirectory -ErrorVariable ErrorAD -ErrorAction SilentlyContinue
If ($ErrorAD) {

   Write-Log -EntryType Error -Message "AD Module could not be imported"
   Exit 

}
Else
{
Write-Log -EntryType Error -Message "AD Module imported"
}



#Testing Server is online
if(Test-Connection -Count 2 -ComputerName $FileServer -Quiet)
{
    Write-Log -EntryType Information -Message "Server Responded Success" 
    Write-Host "Server Responded - Success"
}
else
{
    Write-Log -EntryType Error -Message "Server Failed to Respond - Script will now close" 
    Write-Host "Server Failed to Respond - Script will now close"
    Start-Sleep -Seconds 60
    Exit
}

#Testing Folder is exists
if (Test-Path -Path "$FullLocation")
{
    Write-Log -EntryType Warning -Message "Folder exists - Script will now close"
    Start-Sleep -Seconds 60
    Exit
}
Else
{
    Write-Log -EntryType Information -Message "$FullLocation does not exist Script will continue - Success" 
    
}

#Testing Share is exists
if (Test-Path -Path "$ShareLocation")
{
    Write-Log -EntryType Error -Message "ShareName Exists Script will now end"
    Start-Sleep -Seconds 60
    Exit
}
Else
{
    Write-Log -EntryType Information -Message "Share does not exist - Success" 
    
}

#Creating Shares Privalages for that Folder 
#Read Access
New-ADGroup -Name "$ShareGroupR" -Description "$FileServer - $FolderName Share Read Access" -DisplayName "$ShareGroupR" -GroupScope Global -Path $ShareGroupOU -ErrorVariable TEST -ErrorAction SilentlyContinue
If ($TEST) {

   Write-Log -EntryType Error -Message ""
   Exit 

}
Else
{
    Write-Log -EntryType Error -Message ""
}
#Request to add users

#Change Access
New-ADGroup -Name "$ShareGroupC" -Description "$FileServer - $FolderName Share Change Access" -DisplayName "$ShareGroupC" -GroupScope Global -Path $ShareGroupOU -ErrorVariable TEST -ErrorAction SilentlyContinue
If ($TEST) {

   Write-Log -EntryType Error -Message ""
   Exit 

}
Else
{
    Write-Log -EntryType Error -Message ""
}
#Request to add users

#Full Control
New-ADGroup -Name "$ShareGroupFC" -Description "$FileServer - $FolderName Share Full Control Access" -DisplayName "$ShareGroupFC" -GroupScope Global -Path $ShareGroupOU -ErrorVariable TEST -ErrorAction SilentlyContinue
If ($TEST) {

   Write-Log -EntryType Error -Message ""
   Exit 

}
Else
{
    Write-Log -EntryType Error -Message ""
}
If ($SecureShare -eq "True")
{
    #Request to add users
    Write-Log -EntryType Warning -Message "" 
    Add-ADGroupMember -Identity "$ShareGroupFC" -Members "$SelectedAdminGroup","$ServerServiceAccount"
}
Else
{
    #Request to add users
    Write-Log -EntryType Information -Message "" 
    Add-ADGroupMember -Identity "$ShareGroupFC" -Members "$AdminGroup", "$ServerServiceAccount" 
}


#Creating Security Privalages for that Folder 
#Read Access
New-ADGroup -Name "$SecurityGroupR" -Description "$FileServer - $FolderName Security Read Access" -DisplayName "$SecurityGroupR" -GroupScope Global -Path $ShareGroupOU -ErrorVariable TEST -ErrorAction SilentlyContinue
If ($TEST) {

   Write-Log -EntryType Error -Message ""
   Exit 

}
Else
{
    Write-Log -EntryType Error -Message ""
} 
#Request to add users

#Change Access
New-ADGroup -Name "$SecurityGroupM" -Description "$FileServer - $FolderName Security Modify Access" -DisplayName "$SecurityGroupC" -GroupScope Global -Path $ShareGroupOU -ErrorVariable TEST -ErrorAction SilentlyContinue
If ($TEST) {

   Write-Log -EntryType Error -Message ""
   Exit 

}
Else
{
    Write-Log -EntryType Error -Message ""
}
#Request to add users

#Full Control
New-ADGroup -Name "$SecurityGroupFC" -Description "$FileServer - $FolderName Security Full Control Access" -DisplayName "$SecurityGroupFC" -GroupScope Global -Path $ShareGroupOU -ErrorVariable TEST -ErrorAction SilentlyContinue
If ($TEST) {

   Write-Log -EntryType Error -Message ""
   Exit 

}
Else
{
    Write-Log -EntryType Error -Message ""
}
If ($SecureShare -eq "True")
{
    #Request to add users
    Write-Log -EntryType Warning -Message "" 
    Add-ADGroupMember -Identity "$SecurityGroupFC" -Members "$SelectedAdminGroup","$ServerServiceAccount"
}
Else
{
    #Request to add users
    Write-Log -EntryType Information -Message "" 
    Add-ADGroupMember -Identity "$SecurityGroupFC" -Members "$AdminGroup", "$ServerServiceAccount" 
}


New-Item -Path $FullLocation -ItemType Directory -Name $RootFolder -ErrorVariable TEST -ErrorAction SilentlyContinue
If ($TEST) {

   Write-Log -EntryType Error -Message ""
   Exit 

}
Else
{
    Write-Log -EntryType Error -Message ""
}



#Set Security PErmissions https://4sysops.com/archives/create-a-new-folder-and-set-permissions-with-powershell/ 


#Set Audit
$ACL = Get-Acl $Sourcepath
$ACL.SetAuditRule($AccessRule)
Write-Host "Processing >",$Sourcepath
$ACL | Set-Acl $Sourcepath
Write-Log -EntryType Information -Message "Audit Policy applied successfully."



New-SmbShare -Name $FolderName -cimsession $FileServer -ContinuouslyAvailable 0 -ReadAccess $ShareGroupR -FullAccess $ShareGroupFC -ChangeAccess $ShareGroupC -Path $Sourcepath-ErrorVariable ErrorAD -ErrorAction SilentlyContinue
If ($ErrorAD) {

   Write-Log -EntryType Error -Message "AD Module could not be imported"
   Exit 

}
Else
{
Write-Log -EntryType Error -Message "AD Module imported"
}
#TestSMB Creation


#Confirm folder types for FSRM
#Confirm quotas
#add to dfs


Stop-FileLog
Stop-EventLogLog
Stop-HostLog
