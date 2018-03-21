######################################################################################
#References
#http://winpowershell.blogspot.co.uk/2010/01/powershell-choice-yesno-user-input.html
#https://gallery.technet.microsoft.com/scriptcenter/Clean-up-your-C-Drive-bc7bb3ed
#https://github.com/lemtek/Powershell/blob/master/Clear_Browser_Caches
#https://blogs.technet.microsoft.com/heyscriptingguy/2013/04/14/weekend-scripter-use-powershell-to-clean-out-temp-folders/
#https://pureinfotech.com/delete-files-older-than-days-powershell/
#https://support.symantec.com/en_US/article.HOWTO59193.html
#https://gallery.technet.microsoft.com/scriptcenter/Disk-Cleanup-Using-98ad13bc
#https://ss64.com/nt/cleanmgr.html
#https://blogs.technet.microsoft.com/heyscriptingguy/2015/04/02/update-or-add-registry-key-value-with-powershell/
#https://blogs.technet.microsoft.com/heyscriptingguy/2013/03/04/use-powershell-to-find-detailed-windows-profile-information/
######################################################################################

###########Variables###############
$LogsLocation = "C:\Logs\"
$date = get-date -UFormat %y"-"%m"-"%d"-"%T  | foreach {$_ -replace ":", ""}
$Location = "$LogsLocation\Cleanup-$date.log"
$Shell = New-Object -ComObject Shell.Application
$RecBin = $Shell.Namespace(0xA)
$sep = "C:\ProgramData\Symantec\Symantec Endpoint Protection\CurrentVersion\Data\Definitions\VirusDefs"
$Daysback = "-90"
$Tempfolder = "C:\Temp"
##########################

###########Functions###############
function date-time
{ 
   get-date -UFormat %y"-"%m"-"%d"-"%T  | foreach {$_ -replace ":", ""}
}
##########################


If (test-path $LogsLocation)
{
    new-item "$LogsLocation\Cleanup-$date.log"
    date-time | Write-Output >> $Location
    Write-Output "Script Started" >> $Location
}
Else
{
    mkdir $LogsLocation
    new-item "$LogsLocation\Cleanup-$date.log"
    date-time | Write-Output >> $Location
    Write-Output "Script Started" >> $Location
}




clear-host
#Reminder of Logs Location
Write-Host "Ensure this has been ran with an account that is local admin"
Write-Host "############################################################"
Write-Host "            Logs are located in $LogsLocation               "
Write-Host "############################################################"
Write-Host "            Hibernation will be switched off                "

start-sleep -Seconds 10

clear-host

Write-Host "##########################################################"
Write-Host "##########################################################"
Write-Host "###########  Logs are located in $LogsLocation ###########"
Write-Host "##########################################################"
Write-Host "############ Enter Username Shortly  #####################"

start-sleep -Seconds 5

clear-host

date-time | Write-Output >> $Location
Write-Output "Asking For Username" >> $Location

$User = Read-Host -Prompt 'Input the user name'

write-output User for this will be >> $Location
$user | Write-output >> $Location

Write-Host "##########################################################"
Write-Host "##########################################################"
Write-Host "## Pausing for 5 seconds incase of incorrect username  ###"
Write-Host "#############The username you selected is#################"
Write-Host "                        $user                             "
start-sleep -Seconds 5



$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes",""
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No",""
$choices = [System.Management.Automation.Host.ChoiceDescription[]]($yes,$no)
$caption = "Warning!"
$message = "Do you want to proceed"
$result = $Host.UI.PromptForChoice($caption,$message,$choices,0)
if($result -eq 0) 
{ 
Write-Host "You answered YES"
$user | Write-Output >> $Location
write-output "Username Confirmed" >> $Location
} 
if($result -eq 1) 
{ 
Write-Host "You answered NO Application will now Exit"
exit
}

 #Test
 #Write-Host "test"


#Size
$size = Get-ChildItem C:\Users\$user -Include *.iso, *.vhd -Recurse -ErrorAction SilentlyContinue | Sort Length -Descending |  Select-Object Name,@{Name="Size (GB)";Expression={ "{0:N2}" -f ($_.Length / 1GB) }}, Directory | Format-Table -AutoSize | Out-String 

#Before
$Before = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq "3" } | Select-Object SystemName,@{ Name = "Drive" ; Expression = { ( $_.DeviceID ) } },@{ Name = "Size (GB)" ; Expression = {"{0:N1}" -f( $_.Size / 1gb)}},@{ Name = "FreeSpace (GB)" ; Expression = {"{0:N1}" -f( $_.Freespace / 1gb ) } },@{ Name = "PercentFree" ; Expression = {"{0:P1}" -f( $_.FreeSpace / $_.Size ) } } |Format-Table -AutoSize | Out-String

#Stop Windows update
Write-Host "Stops the windows update service."
Get-Service -Name wuauserv | Stop-Service -Force -Verbose -ErrorAction SilentlyContinue 
Write-Output "Stopping Windows Update" >> $Location
Write-Output "##################################################################################################################" >> $Location
date-time | write-output >> $Location
Write-Output "##################################################################################################################" >> $Location
Write-Host "Windows Update Service has been stopped successfully! "
 
#Software dist
Write-Host "Deletes the contents of windows software distribution. "
date-time | write-output >> $Location
write-Output "Deletes the contents of windows software distribution." >> $Location
Write-Output "##################################################################################################################" >> $Location
Get-ChildItem "C:\Windows\SoftwareDistribution\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | write-output >> $Location
Write-Output "##################################################################################################################" >> $Location
Get-ChildItem "C:\Windows\SoftwareDistribution\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | remove-item -force -Verbose -recurse -ErrorAction SilentlyContinue 
Write-Host "The Contents of Windows SoftwareDistribution have been removed successfully! "


#Switchoff Hibernation
write-output "Switching off Hibernation"
powercfg -h off
write-host "switching off hbernation"

################
#https://blogs.technet.microsoft.com/heyscriptingguy/2013/03/04/use-powershell-to-find-detailed-windows-profile-information/
#Remove old profiles
#Section coming
################
 
#Windows Temp Folder
Write-Host "Deletes the contents of the Windows Temp folder. "
date-time | write-output >> $Location
write-Output "Deletes the contents of the Windows Temp folder." >> $Location
Write-Output "##################################################################################################################" >> $Location
Get-ChildItem "C:\Windows\Temp\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | write-output >> $Location
Write-Output "##################################################################################################################" >> $Location
Get-ChildItem "C:\Windows\Temp\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | Where-Object { ($_.CreationTime -lt $(Get-Date).AddDays(-$DaysToDelete)) } | remove-item -force -Verbose -recurse -ErrorAction SilentlyContinue 
Write-Host "The Contents of Windows Temp have been removed successfully! "
              
#Users Temp Folder
write-host "Delets all files and folders in user's Temp folder.  "
date-time | write-output >> $Location
write-Output "Delets all files and folders in user's Temp folder" >> $Location
Write-Output "##################################################################################################################" >> $Location
Get-ChildItem "C:\users\$user\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue | write-output >> $Location
Write-Output "##################################################################################################################" >> $Location
Get-ChildItem "C:\users\$user\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { ($_.CreationTime -lt $(Get-Date).AddDays(-$DaysToDelete))} | remove-item -force -Verbose -recurse -ErrorAction SilentlyContinue 
write-host "The contents of C:\users\$user\AppData\Local\Temp\ have been removed successfully! "
                     
#Temp Internet Files
write-host "Remove all files and folders in user's Temporary Internet Files.  "
date-time | write-output >> $Location
write-Output "Remove all files and folders in user's Temporary Internet Files" >> $Location
Write-Output "##################################################################################################################" >> $Location
Get-ChildItem "C:\users\$user\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue |  write-output >> $Location
Write-Output "##################################################################################################################" >> $Location
Get-ChildItem "C:\users\$user\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | Where-Object {($_.CreationTime -le $(Get-Date).AddDays(-$DaysToDelete))} | remove-item -force -recurse -ErrorAction SilentlyContinue 
write-host "All Temporary Internet Files have been removed successfully! "
                     
#Recycle Bin                  
Write-host "Deletes the contents of the recycling Bin. "
date-time | write-output >> $Location
write-Output "The Recycling Bin is now being emptied!" >> $Location
Write-Output "##################################################################################################################" >> $Location
$RecBin.Items() | write-output >> $location
Write-Output "##################################################################################################################" >> $Location
$RecBin.Items() | %{Remove-Item $_.Path -Recurse -Confirm:$false}
Write-Host "The Recycling Bin has been emptied! "

#SEP
Write-Host "Clearing Sep"
Get-ChildItem –Path $sep -Recurse | Where-Object {($_.LastWriteTime -lt (Get-Date).AddDays($Daysback))} | write-output >> $Location
Get-ChildItem –Path $sep -Recurse | Where-Object {($_.LastWriteTime -lt (Get-Date).AddDays($Daysback))} | Remove-Item



#Firefox
if (test-path "C:\Users\$user\AppData\Local\Mozilla\Firefox\Profiles")
{
Write-Host -ForegroundColor yellow "Clearing Mozilla caches"
Write-Output "Stopping Firefox" >> $Location
taskkill /f /im firefox.exe /T >> $Location
Remove-Item -path C:\Users\$user\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache\* -Recurse -Force -EA SilentlyContinue -Verbose
Remove-Item -path C:\Users\$user\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache\*.* -Recurse -Force -EA SilentlyContinue -Verbose
Remove-Item -path C:\Users\$user\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache2\entries\*.* -Recurse -Force -EA SilentlyContinue -Verbose
Remove-Item -path C:\Users\$user\AppData\Local\Mozilla\Firefox\Profiles\*.default\thumbnails\* -Recurse -Force -EA SilentlyContinue -Verbose
Remove-Item -path C:\Users\$user\AppData\Local\Mozilla\Firefox\Profiles\*.default\cookies.sqlite -Recurse -Force -EA SilentlyContinue -Verbose
Remove-Item -path C:\Users\$user\AppData\Local\Mozilla\Firefox\Profiles\*.default\webappsstore.sqlite -Recurse -Force -EA SilentlyContinue -Verbose
Remove-Item -path C:\Users\$user\AppData\Local\Mozilla\Firefox\Profiles\*.default\chromeappsstore.sqlite -Recurse -Force -EA SilentlyContinue -Verbose
Write-Host -ForegroundColor yellow "Done..."
Write-Output "Cleared Firefox Profile...." >> $Location
}

#Chrome
if (test-path "C:\Users\$user\AppData\Local\Google\Chrome\User Data\Defaults")
{
Write-Host -ForegroundColor yellow "Clearing Google caches"
Write-Output "Stopping Chrome" >> $Location
taskkill /f /im chrome.exe /T >> $Location
Remove-Item -path "C:\Users\$user\AppData\Local\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -EA SilentlyContinue -Verbose
Remove-Item -path "C:\Users\$user\AppData\Local\Google\Chrome\User Data\Default\Cache2\entries\*" -Recurse -Force -EA SilentlyContinue -Verbose
Remove-Item -path "C:\Users\$user\AppData\Local\Google\Chrome\User Data\Default\Cookies" -Recurse -Force -EA SilentlyContinue -Verbose
Remove-Item -path "C:\Users\$user\AppData\Local\Google\Chrome\User Data\Default\Media Cache" -Recurse -Force -EA SilentlyContinue -Verbose
Remove-Item -path "C:\Users\$user\AppData\Local\Google\Chrome\User Data\Default\Cookies-Journal" -Recurse -Force -EA SilentlyContinue -Verbose
Write-Host -ForegroundColor yellow "Done..."
Write-Output "Cleared Google Profile...." >> $Location
}


#IE 2
if (test-path "C:\Users\$user\AppData\Local\Microsoft\Windows\Temporary Internet Files\")
{
Write-Host -ForegroundColor yellow "Clearing IE caches"
Write-Output "Stopping IE" >> $Location
taskkill /f /im iexplore.exe /T >> $Location
Remove-Item -path "C:\Users\$user\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" -Recurse -Force -EA SilentlyContinue -Verbose
Write-Host -ForegroundColor yellow "Done..."
Write-Output "Cleared IE Profile...." >> $Location
}


#C:\Temp Folder Clean
#Imports Profile 12 for clnmgr
If (test-path $Tempfolder)
{
    
    date-time | Write-Output >> $Location
    Write-Output "Temp Folder already there...." >> $Location
    Write-Host "Deletes the contents of Local Temp C:\Temp. "
    date-time | write-output >> $Location
    write-Output "Deletes the contents of C:\Temp." >> $Location
    Write-Output "##################################################################################################################" >> $Location
    Get-ChildItem "C:\Temp\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | write-output >> $Location
    Write-Output "##################################################################################################################" >> $Location
    Get-ChildItem "C:\Temp\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | remove-item -force -Verbose -recurse -ErrorAction SilentlyContinue 
    Write-Host "c:\Temp cleared "
    Reg  export "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches" C:\Temp\clnmgr.reg
    Write-Output "Clnmg Reg Key backed up" >> $Location
}
Else
{
    mkdir $Tempfolder
    date-time | Write-Output >> $Location
    Write-Output "Temp Folder Created" >> $Location
    Reg  export "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches" C:\Temp\clnmgr.reg
    Write-Output "Clnmg Reg Key backed up" >> $Location
}



#ClnMgr runs profile 12 C: only
Execute-Process -FilePath “reg.exe” -Parameters “import .\clnmgr.reg” -PassThru
Write-Output "Running Cleanup Manager" >> $Location
clear-host
CLEANMGR /sagerun:12 /d c:\
Write-Host "###########################################################"
Write-Host "###########################################################"
Write-Host "                                                           "
Write-Host "Cleanup Manager Running System will be paused for 5 minutes"
Write-Host "                   Do not Close this box!                  "
Write-Host "           Reg backup is in C:\Temp\Clnmgr.reg             "
Write-Host "                                                           "
Write-Host "###########################################################"
Write-Host "###########################################################"
start-sleep -Seconds 300
 
# Starts the Windows Update Service 
Get-Service -Name wuauserv | Start-Service -Verbose 
Write-Host "Starting Windows Update Service"
Write-Output "Starting Windows Update Service" >> $Location

#Grab how much free data 
$After =  Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq "3" } | Select-Object SystemName,@{ Name = "Drive" ; Expression = { ( $_.DeviceID ) } }, @{ Name = "Size (GB)" ; Expression = {"{0:N1}" -f( $_.Size / 1gb)}}, @{ Name = "FreeSpace (GB)" ; Expression = {"{0:N1}" -f( $_.Freespace / 1gb ) } }, @{ Name = "PercentFree" ; Expression = {"{0:P1}" -f( $_.FreeSpace / $_.Size ) } } | Format-Table -AutoSize | Out-String 
 
# Sends some before and after info for ticketing purposes 
 
Hostname ; Get-Date | Select-Object DateTime 
Write-Output "Before: $Before" >> $Location 
Write-Output "After: $After" >> $Location
Write-Output $size >> $Location

Write-Host "Before: $Before"
Write-Host "After: $After"
Write-Host $size


Write-Host "Completed Successfully! "
