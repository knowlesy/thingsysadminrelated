###########What It's For###############
#Intention is to be ran as an admin for a local users of a MAchine
#To be Ran on Win 7/8/8.1/10
#Script Execution will need to be bypassed
#######################################

###########What It Does############### 
#Clears Event Log
#Set Eventlog size to 20MB / 30days
#Cleans C:\Windows\SoftwareDistribution\
#Cleans Error Reporting C:\ProgramData\Microsoft\Windows\WER
#Cleans C:\Windows\Temp\
#Disables Hibernation
#Cleans C:\Temp
#Cleans SEP
#SCCM Cache Cleanup
#Remove Old User Profiles 
#Clean Remaining user Profiles
##Cleans Firefox 
##Cleans Chrome
##Cleans IE
##Cleans C:\users\$user\AppData\Local\Temp\*
##Cleans Domino for DMP in logs
#Cleans Reg User *.bak Temp user Keys
#Cleans Recycle Bin  
#Runs Clmgr
#Sets SCCM Cache Size
###################################


######################################################################################
#References
#This is based off a combination of scripts from a variety of locations
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
#https://gallery.technet.microsoft.com/Script-to-delete-bak-2ebd222f
#https://gallery.technet.microsoft.com/scriptcenter/Deleting-the-SCCM-Cache-da03e4c7
#https://social.technet.microsoft.com/wiki/contents/articles/31380.increase-sccm-client-cache-size.aspx
#https://gallery.technet.microsoft.com/Clean-the-SCCM-configMrg-b72f0b96
######################################################################################


###########Variables###############
$LogsLocation = "C:\Logs\"
$date = get-date -UFormat %y"-"%m"-"%d"-"%T  | foreach {$_ -replace ":", ""}
$Location = "$LogsLocation\Cleanup-$date.log"
$Shell = New-Object -ComObject Shell.Application
$RecBin = $Shell.Namespace(0xA)
$sep = "C:\ProgramData\Symantec\Symantec Endpoint Protection\CurrentVersion\Data\Definitions\VirusDefs"
$Daysback = "-90" #Days
$Tempfolder = "C:\Temp"
$DeleteDaysback = "-180" #Days
$Domino2 = "$user\AppData\Local\Lotus\Notes\Data\workspace\logs"
$sccmCache = '51200' #MB
$sccmlastUsed = 30  #Days
##########################

###########Functions###############
function date-time
{ 
   get-date -UFormat %y"-"%m"-"%d"-"%T  | foreach {$_ -replace ":", ""}
}
##########################


##Create Location

If (test-path $LogsLocation)
{
    new-item "$LogsLocation\Cleanup-$date.log" -ItemType file
    date-time | Write-Output >> $Location
    Write-Output "Script Started" >> $Location
}
Else
{
    mkdir $LogsLocation
    new-item "$LogsLocation\Cleanup-$date.log"  -ItemType file
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

start-sleep -Seconds 5
clear-host

Write-Host "####This script will take up to 30 minutes or more!#######"
Write-Host "##########################################################"
Write-Host "###########  Logs are located in $LogsLocation ###########"
Write-Host "##########################################################"

start-sleep -Seconds 5
date-time | Write-Output >> $Location

##Getting Before Size
Before = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq "3" } | Select-Object SystemName,@{ Name = "Drive" ; Expression = { ( $_.DeviceID ) } },@{ Name = "Size (GB)" ; Expression = {"{0:N1}" -f( $_.Size / 1gb)}},@{ Name = "FreeSpace (GB)" ; Expression = {"{0:N1}" -f( $_.Freespace / 1gb ) } },@{ Name = "PercentFree" ; Expression = {"{0:P1}" -f( $_.FreeSpace / $_.Size ) } } |Format-Table -AutoSize | Out-String

##Clear Event Log
wevtutil el | Foreach-Object {wevtutil cl "$_"}

# Set Eventlog Size to 20mb and retention to 30 days
Limit-EventLog -LogName Application -MaximumSize 20MB -OverflowAction OverwriteOlder -RetentionDays 30
Limit-EventLog -LogName System -MaximumSize 20MB -OverflowAction OverwriteOlder -RetentionDays 30
Limit-EventLog -LogName Security -MaximumSize 20MB -OverflowAction OverwriteOlder -RetentionDays 30


##Stop Windows update
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

#windows error reporting
Write-Host "Deletes the contents of windows error reporting. "
date-time | write-output >> $Location
write-Output "Deletes the contents of windows error reporting." >> $Location
Write-Output "##################################################################################################################" >> $Location
Get-ChildItem "C:\ProgramData\Microsoft\Windows\WER\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | write-output >> $Location
Write-Output "##################################################################################################################" >> $Location
Get-ChildItem "C:\ProgramData\Microsoft\Windows\WER\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | remove-item -force -Verbose -recurse -ErrorAction SilentlyContinue 
Write-Host "The Contents of error reporting have been removed successfully! "

#Windows Temp Folder
Write-Host "Deletes the contents of the Windows Temp folder. "
date-time | write-output >> $Location
write-Output "Deletes the contents of the Windows Temp folder." >> $Location
Write-Output "##################################################################################################################" >> $Location
Get-ChildItem "C:\Windows\Temp\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | write-output >> $Location
Write-Output "##################################################################################################################" >> $Location
Get-ChildItem "C:\Windows\Temp\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | Where-Object { ($_.CreationTime -lt $(Get-Date).AddDays(-$DaysToDelete)) } | remove-item -force -Verbose -recurse -ErrorAction SilentlyContinue 
Write-Host "The Contents of Windows Temp have been removed successfully! "

#Switchoff Hibernation
write-output "Switching off Hibernation"
powercfg -h off
write-host "Switched off hbernation"

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
    Write-Output "Registry Exports" >> $Location
    Reg  export "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches" C:\Temp\clnmgr.reg
    Reg  export "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" C:\Temp\Profile.reg
    Write-Output "Clnmg Reg & Profile Key backed up" >> $Location
}
Else
{
    mkdir $Tempfolder
    date-time | Write-Output >> $Location
    Write-Output "Temp Folder Created" >> $Location
    Write-Output "Registry Exports" >> $Location
    Reg  export "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches" C:\Temp\clnmgr.reg
    Reg  export "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" C:\Temp\Profile.reg
    Write-Output "Clnmg Reg & Profile Key backed up" >> $Location
}



#SEP
if (test-path $sep)
{
Write-Host "Clearing Sep"
Get-ChildItem –Path $sep -Recurse  -Force -ErrorAction SilentlyContinue | Where-Object {($_.LastWriteTime -lt (Get-Date).AddDays($Daysback))} | Where-object {$_.localpath -like "C:\ProgramData\Symantec\Symantec Endpoint Protection\CurrentVersion\Data\Definitions\VirusDefs\20"} | write-output >> $Location
Get-ChildItem –Path $sep -Recurse  -Force -ErrorAction SilentlyContinue | Where-Object {($_.LastWriteTime -lt (Get-Date).AddDays($Daysback))} | Where-object {$_.localpath -like "C:\ProgramData\Symantec\Symantec Endpoint Protection\CurrentVersion\Data\Definitions\VirusDefs\20"} | Remove-Item -Force -ErrorAction SilentlyContinue 
}

#SCCM Cache Clearout
$CMObject = new-object -com "UIResource.UIResourceMgr" #Create CM object 
$cacheInfo = $CMObject.GetCacheInfo() # get CCM cache info

$objects = $cacheinfo.GetCacheElements() | select-object location , LastReferenceTime, ContentSize

$StartDate=(GET-DATE)

$i=0

out-file -append  -filepath C:\Logs\cacheremoval.log "Clean CccmCache"  # write all things on log


# delete all folder unused on ccm cache
foreach ( $item in $objects )
{
   
  $diffDate = $StartDate - $item.LastReferenceTime

   if ( $diffDate.Days -gt $sccmlastUsed  )
    {
        $i++
        remove-item -path $item.location
       
    }

 }

#Delete Old User Profiles which havent logged in +XXX Days
#$DeleteDaysback = "-9000"
write-Output "Remove Old User Profiles" >> $Location
Write-Output "##################################################################################################################" >> $Location
write-Output "Usernames to be Deleted" >> $Location
get-ciminstance win32_userprofile | where-object {$_.localpath -like "C:\Users\*"} | Where-object {$_.localpath -ne "C:\Users\defaultuser0"} | Where-object {$_.localpath -ne "C:\Users\Public"} | ? lastusetime | select lastusetime, localpath | Where-Object {($_.lastusetime -lt (Get-Date).AddDays($DeleteDaysback))} | Write-Output >> $location
$olderprofiles = get-ciminstance win32_userprofile | where-object {$_.localpath -like "C:\Users\*"} | Where-object {$_.localpath -ne "C:\Users\defaultuser0"} | ? lastusetime | select lastusetime, localpath | Where-Object {($_.lastusetime -lt (Get-Date).AddDays($DeleteDaysback))}
$filteredolderprofiles = $olderprofiles | select -expandproperty localpath 
foreach ($filter in $filteredolderprofiles)
{
$string = ($filter | Out-String).Trim()
#$String
Get-ChildItem –Path $string -Recurse  -Force -ErrorAction SilentlyContinue | write-output >> $location
Get-ChildItem –Path $string -Recurse  -Force -ErrorAction SilentlyContinue | Remove-Item -recurse -Verbose -recurse -ErrorAction SilentlyContinue
}
Write-Output "##################################################################################################################" >> $Location
write-Output "Profiles Removed" >> $Location

#Clean all User Profiles 
$users = Get-ChildItem -Path C:\users\ -Directory -Force -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName 
foreach ($user in $users)
{

#Firefox
if (test-path "C:\Users\$user\AppData\Local\Mozilla\Firefox\Profiles")
{
Write-Host -ForegroundColor yellow "Clearing Mozilla caches"
Write-Output "Stopping Firefox" >> $Location
taskkill /f /im firefox.exe /T >> $Location
Remove-Item -path $user\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache\* -Recurse -Force -EA SilentlyContinue -Verbose
Remove-Item -path $user\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache\*.* -Recurse -Force -EA SilentlyContinue -Verbose
Remove-Item -path $user\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache2\entries\*.* -Recurse -Force -EA SilentlyContinue -Verbose
Remove-Item -path $user\AppData\Local\Mozilla\Firefox\Profiles\*.default\thumbnails\* -Recurse -Force -EA SilentlyContinue -Verbose
Remove-Item -path $user\AppData\Local\Mozilla\Firefox\Profiles\*.default\cookies.sqlite -Recurse -Force -EA SilentlyContinue -Verbose
Remove-Item -path $user\AppData\Local\Mozilla\Firefox\Profiles\*.default\webappsstore.sqlite -Recurse -Force -EA SilentlyContinue -Verbose
Remove-Item -path $user\AppData\Local\Mozilla\Firefox\Profiles\*.default\chromeappsstore.sqlite -Recurse -Force -EA SilentlyContinue -Verbose
Write-Host -ForegroundColor yellow "Done..."
Write-Output "Cleared Firefox Profile...." >> $Location
}

#Chrome
if (test-path "$user\AppData\Local\Google\Chrome\User Data\Defaults")
{
Write-Host -ForegroundColor yellow "Clearing Google caches"
Write-Output "Stopping Chrome" >> $Location
taskkill /f /im chrome.exe /T >> $Location
Remove-Item -path "$user\AppData\Local\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -EA SilentlyContinue -Verbose
Remove-Item -path "$user\AppData\Local\Google\Chrome\User Data\Default\Cache2\entries\*" -Recurse -Force -EA SilentlyContinue -Verbose
Remove-Item -path "$user\AppData\Local\Google\Chrome\User Data\Default\Cookies" -Recurse -Force -EA SilentlyContinue -Verbose
Remove-Item -path "$user\AppData\Local\Google\Chrome\User Data\Default\Media Cache" -Recurse -Force -EA SilentlyContinue -Verbose
Remove-Item -path "$user\AppData\Local\Google\Chrome\User Data\Default\Cookies-Journal" -Recurse -Force -EA SilentlyContinue -Verbose
Write-Host -ForegroundColor yellow "Done..."
Write-Output "Cleared Google Profile...." >> $Location
}


#IE 2
if (test-path "$user\AppData\Local\Microsoft\Windows\Temporary Internet Files\")
{
Write-Host -ForegroundColor yellow "Clearing IE caches"
Write-Output "Stopping IE" >> $Location
taskkill /f /im iexplore.exe /T >> $Location
Remove-Item -path "$user\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" -Recurse -Force -EA SilentlyContinue -Verbose
Write-Host -ForegroundColor yellow "Done..."
Write-Output "Cleared IE Profile...." >> $Location
}

#Users Temp Folder
write-host "Delets all files and folders in user's Temp folder.  "
date-time | write-output >> $Location
write-Output "Deletes all files and folders in user's Temp folder" >> $Location
Write-Output "##################################################################################################################" >> $Location
Get-ChildItem "$user\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue | write-output >> $Location
Write-Output "##################################################################################################################" >> $Location
Get-ChildItem "$user\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { ($_.CreationTime -lt $(Get-Date).AddDays(-$DaysToDelete))} | remove-item -force -Verbose -recurse -ErrorAction SilentlyContinue 
write-host "The contents of $user\AppData\Local\Temp\ have been removed successfully! "


#Remove Domino Dump files
date-time | write-output >> $Location
write-Output "Deletes all dmp files in user's Domino Log folder" >> $Location
if (test-path $user\AppData\Local\Lotus\Notes\Data\workspace\logs)
{
Write-Output "##################################################################################################################" >> $Location
$Domino = get-childitem $user\AppData\Local\Lotus\Notes\Data\workspace\logs -recurse
$DominoList = $Domino | where {$_.extension -eq ".dmp"} 
$DominoList | format-table name | ft -hidetableheaders
foreach ($DominoItem in $DominoList)
{
 $DominoLocation = "$Domino2\$DominoItem"
 $DominoLocation | write-output >> $Location
 Remove-item $location -Force -ErrorAction SilentlyContinue 
}
Write-Output "##################################################################################################################" >> $Location
write-host "The contents of $user\AppData\Local\Lotus\Notes\Data\workspace\logs have been removed successfully! "

}

}

Write-Host "Searching for Temp Profiles in Reg"
    date-time | write-output >> $Location
    write-Output "Searching for Temp Profiles in Reg" >> $Location
    Write-Output "##################################################################################################################" >> $Location

	##connect with registry of remote machine
	$baseKey = Get-Item -Path Registry::HKEY_LOCAL_MACHINE

	##set registry path
	$key = $baseKey.OpenSubKey("Software\Microsoft\Windows NT\CurrentVersion\ProfileList",$true)

	## get all profile name
	$profilereg = $key.GetSubKeyNames()
	$profileregcount = $profilereg.count

		foreach($profilereg as $profile)
		{
    			if($profile -like "*.bak")
    		{
        		$bakname = $profile


			$baknamefinal = $bakname.Split(".")[0]

			## Delete bak profile
			$key.DeleteSubKeyTree("$bakname")


			##connect with profileGuid
			$keyGuid = $baseKey.OpenSubKey("Software\Microsoft\Windows NT\CurrentVersion\ProfileGuid",$true)

			## get all profile Guid
			$Guidreg = $keyGuid.GetSubKeyNames()
			$Guidregcount = $Guidreg.count
		
			while($Guidregcount -ne 0)
			{
				$bakname1 = $Guidreg[$Guidregcount-1]
		
				$keyGuidTest = $baseKey.OpenSubKey("Software\Microsoft\Windows NT\CurrentVersion\ProfileGuid\$bakname1",$true)
				$KeyGuidSidValue = $keyGuidTest.GetValue("sidstring")
				$KeyGuidSidValue
			
				if($baknamefinal -eq $KeyGuidSidValue)
				{
					## Delete Guid profile
					$keyGuid.DeleteSubKeyTree("$bakname1") >> $Location
				}
				$Guidregcount = $Guidregcount-1
			}


		}
		$profileregcount = $profileregcount-1
	}

    Write-Host "Completed searching for Temp Profiles in Reg"
    date-time | write-output >> $Location
    write-Output "Completed searching for Temp Profiles in Reg" >> $Location
    Write-Output "##################################################################################################################" >> $Location


#Recycle Bin                  
Write-host "Deletes the contents of the recycling Bin. "
date-time | write-output >> $Location
write-Output "The Recycling Bin is now being emptied!" >> $Location
Write-Output "##################################################################################################################" >> $Location
$RecBin.Items() | write-output >> $location
Write-Output "##################################################################################################################" >> $Location
$RecBin.Items() | %{Remove-Item $_.Path -Recurse -Confirm:$false}
Write-Host "The Recycling Bin has been emptied! "


#Cleanup 
ClnMgr runs profile 12 C: only
Execute-Process -FilePath “reg.exe” -Parameters “import .\clnmgr.reg” -PassThru
Write-Output "Running Cleanup Manager" >> $Location
clear-host
CLEANMGR /sagerun:12 /d c:\
Write-Host "###########################################################"
Write-Host "###########################################################"
Write-Host "                                                           "
Write-Host "    Cleanup Manager Running System will be paused          "
Write-Host "                   Do not Close this box!                  "
Write-Host "           Reg backup is in C:\Temp\Clnmgr.reg             "
Write-Host "                                                           "
Write-Host "###########################################################"
Write-Host "###########################################################"
wait-process -name cleanmgr
 
# Starts the Windows Update Service 
Get-Service -Name wuauserv | Start-Service -Verbose 
Write-Host "Starting Windows Update Service"
Write-Output "Starting Windows Update Service" >> $Location

#Sets SCCM Cache Size
$Cache = Get-WmiObject -Namespace 'ROOT\CCM\SoftMgmtAgent' -Class CacheConfig
$Cache.Size = $sccmCache
$Cache.Put()
Restart-Service -Name CcmExec

#Grab how much free data 
$After =  Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq "3" } | Select-Object SystemName,@{ Name = "Drive" ; Expression = { ( $_.DeviceID ) } }, @{ Name = "Size (GB)" ; Expression = {"{0:N1}" -f( $_.Size / 1gb)}}, @{ Name = "FreeSpace (GB)" ; Expression = {"{0:N1}" -f( $_.Freespace / 1gb ) } }, @{ Name = "PercentFree" ; Expression = {"{0:P1}" -f( $_.FreeSpace / $_.Size ) } } | Format-Table -AutoSize | Out-String 
 
# Sends some before and after info for ticketing purposes 
Hostname ; Get-Date | Select-Object DateTime 
Write-Output "Before: $Before" >> $Location 
Write-Output "After: $After" >> $Location
Write-Output "SCCM Cache is now $sccmCache MB"
Write-Host "Before: $Before"
Write-Host "After: $After"
Write-Host "SCCM Cache is now $sccmCache MB"
Write-Host "Completed Successfully! "
Write-Host "Logs are in C:\Logs\ "
Write-Host "You Should now restart your machine "
start-sleep -Seconds 120
exit
