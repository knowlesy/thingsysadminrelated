############# ADD ADDITIONAL LOCATIONS HERE #############
#used for remote ivanti repo
$locations = '\\server\path'
#set excluded apps, requires explicit name
$excludedapps = 'jre-8u211-windows-i586.exe', 'jre-8u211-windows-x64.exe'
#Days after to exclude
$olderthan = '90'

############################################################# DO NOT MODIFY BELOW ###########################################################################
#############################################################################################################################################################
#############################################################################################################################################################
#############################################################################################################################################################
#############################################################################################################################################################

########Troubleshooting########
#dir for logs
#$loglocation = 'C:\logs\test\'
#session file log
#$logfile = ('C:\logs\test\' + $date + '-session.log')
############END################


#dir for logs
$loglocation = 'E:\Config\Logs\Ivanti\'
#session file log
$logfile = ('E:\Config\Logs\Ivanti\' + $date + '-session.log')
#gets date when ran
$date = Get-Date -Format yyyy-MM-dd-%H-mm
$daysback = ('-' + $olderthan)

#writes date at top of session log file
Write-Output $date >> $logfile

#for each of the locations perform an action
foreach ($location in $locations) {
    #used for tidying up locations for a log file of files to be deleted
    $filemod1 = $location -replace '\\', ''
    $filemod2 = $filemod1 -replace ' ', ''
    $filemod3 = $filemod2 -replace 'Patches', ''


    #Folder Sizes pt1
    $sizebeforedeletion = "{0:N2} GB" -f ((Get-ChildItem $location | Measure-Object Length -Sum).Sum / 1GB)
    $sizetobedeleted = "{0:N2} GB" -f ((Get-ChildItem $location | Where-Object { $excludedapps -notcontains $_.Name -and $_.LastWriteTime -lt (get-date).AddDays(-90) } | Measure-Object Length -Sum).Sum / 1GB)

    #File protection dont delete 30days or older
    $protect = Get-ChildItem $location | Where-Object { $_.LastWriteTime -gt (get-date).AddDays(30) } | select-object Name

    #log location for files deleted in specific location
    $todeletedlogs = ($loglocation + $date + '-' + $filemod3 + '.log')

    Write-Output ("The files below will be excluded from deletion on the following server " + $location ) >> $logfile
    #gets list of files that will be excluded
    Get-ChildItem $location -Filter * | Where-Object { $excludedapps -contains $_.Name } | select-object Name, FullName, LastWriteTime >> $logfile

    #gets list of files that will be deleted
    Get-ChildItem $location | Where-Object { $excludedapps -notcontains $_.Name -and $_.LastWriteTime -lt (get-date).AddDays($daysback) } | select-object Name, LastWriteTime | Out-File $todeletedlogs

    Write-Output ("The files below have been deleted on the following server " + $location ) >> $logfile
    #deletes files outputs any errors to log file
    Get-ChildItem $location | Where-Object { $excludedapps -notcontains $_.Name -or $protect -notcontains $_.Name -and $_.LastWriteTime -lt (get-date).AddDays($daysback) } | Remove-Item -Force -Recurse -WhatIf *>&1 >> $logfile

    #Folder Sizes pt2
    $sizeAfterdeletion = "{0:N2} GB" -f ((Get-ChildItem $location | Measure-Object Length -Sum).Sum / 1GB)

    #logoutput
    Write-Output ("Size before on the following server " + $location + " " + $sizebeforedeletion) >> $logfile
    Write-Output ("Size of files to be deleted " + $location + " " + $sizetobedeleted) >> $logfile
    Write-Output ("Size after on the following server " + $location + " " + $sizeAfterdeletion) >> $logfile

}

#creates an array of files modified in last hour
[array]$attachments = Get-ChildItem $loglocation *.log | Where-Object { $_.LastWriteTime -gt (get-date).AddHours(-1) }


#SMTP
$Email = "emailaddress"
$from = "servername-noreply@domain.com"
$Subject = "Ivanti Cleanup"


$Msg = @{
    to          = $Email
    from        = $from
    Body        = "The following files have been deleted . For confirmation of what should of been deleted please see the servername report"
    subject     = "$Subject"
    smtpserver  = "gbhcas01"
    BodyAsHtml  = $True
    Attachments = $attachments.fullname
}

Send-MailMessage @Msg