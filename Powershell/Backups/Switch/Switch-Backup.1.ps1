#list of switches
$dell = 'name'
$hp = 'name1'
$cisco = 'name2'
#dell enterprise switches
$dcs = 'name3'


########################################################################################################
#usernames & passwords
$switchu = "username"
$switchuhp = "username"
$switchucisco = "username"
$switchp = "password"
$switchphp = "password"
$switchpcisco = "password"

########################################################################################################
#fixedvariables

#tft server
$tftpserver = 'serverip'

#Service
$TFTP = Get-Service "SolarWinds TFTP Server"

#file age variable
$Hoursold = '-10'
$Hoursback = $CurrentDate.Addhours($Hoursold)

#Log and config age variables for cleanup
$date = Get-Date -Format yyyy-MM-dd-%H-mm
$Daysback = '-30'
$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddDays($Daysback)

#dirs
$ConfigRootDir = 'E:\Backups\Switch-Configs\'
$configLogs = 'E:\Backups\Logs\Switch\'
$connectionOutDIR = "E:\Backups\Logs\Switch\Connection_output\"

#logfiles
$sessionLog = ($configLogs + $date + '-Switch_Backup.log')


#size of folders/dirs
$ConfigBackup = "{0:N2}" -f ((Get-ChildItem $ConfigRootDir -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)
$ConfigLogBackup = "{0:N2}" -f ((Get-ChildItem $ConfigRootDir -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)


########################################################################################################
#Ensure TFTP service is running
if ($TFTP.status -eq 'Running') {
    Write-Output 'TFTP Service is running' >> $sessionLog

}
else {
    Write-Output 'TFTP Service is NOT running attempting to start' >> $sessionLog
    Start-Service "SolarWinds TFTP Server"
    if ($TFTP.status -eq 'Running') {
        Write-Output 'TFTP Service is now running' >> $sessionLog

    }
    else {
        Write-Output 'TFTP Service wont start' >> $sessionLog


        ###EMAIL###

        exit

    }


}
########################################################################################################
####Dell Switches ####

Write-Output "Starting backup of Dell Switches" >> $sessionLog

foreach ($dellswitch in $dell) {
    if (Test-Connection -ComputerName $dellswitch -Quiet) {

        Write-Output ( $dellswitch + ' Connected backup will now be attempted') >> $sessionLog
        $connectionLogDells = ($connectionOutDIR + $dellswitch + '-Switch_startup_output.log')
        $connectionLogDellr = ($connectionOutDIR + $dellswitch + '-Switch_running_output.log')

        #Backup startup Config
        C:\scripts\Orchestration\Daily\Switch-Backup\kitty.exe $dellswitch -ssh -v -l $switchu -pw $switchp -cmd "enable \n Copy startup-Config tftp://$tftpserver/$dellswitch-startup_config \ny \n logout" -log $connectionLogDells

        #wait just in case
        Start-Sleep -Seconds 60

        #Sets location of file
        $startupconfigfile = get-item -path ('E:\Backups\Switch-Configs\' + $dellswitch + '-startup_config') -ErrorAction SilentlyContinue

        #checks backup of startup log
        if ($startupconfigfile -eq $null) {
            { Write-Output ( $dellswitch + ' Backup file not found') >> $sessionLog }
        }
        else {
                    if (Test-Path -Path $startupconfigfile -OlderThan $Hoursback)
        { Write-Output ( $dellswitch + ' startup Config NOT backed up') >> $sessionLog }
        else
        { Write-Output ( $dellswitch + ' startup Config backed up') >> $sessionLog }
        }



        #kill if its left running
        $kitty = Get-Process kitty -ErrorAction SilentlyContinue
        if ($kitty) {
            # try gracefully first
            $kitty.CloseMainWindow()
            # kill after five seconds
            Sleep 5
            if (!$kitty.HasExited) {
                $kitty | Stop-Process -Force
                Write-Output ($dellswitch + ' had to kill the kitty') >> $sessionLog
            }
        }
        Remove-Variable kitty

        #Backup Running config
        C:\scripts\Orchestration\Daily\Switch-Backup\kitty.exe $dellswitch -ssh -v -l svc-switch-backup -pw $switchp -cmd "enable \n Copy running-Config tftp://$tftpserver/$dellswitch-running_config \ny \n logout" -log $connectionLogDellr

        #wait just in case
        Start-Sleep -Seconds 60

        #Sets location of file
        $runningconfigfile = get-item -path ('E:\Backups\Switch-Configs\' + $dellswitch + '-running_config')

        #checks backup of running log
        if ($runningconfigfile -eq $null) {
            { Write-Output ( $dellswitch + ' Backup file not found') >> $sessionLog }
        }
        else {
            if (Test-Path -Path $startupconfigfile -OlderThan $Hoursback)
            { Write-Output ( $dellswitch + ' running Config NOT backed up') >> $sessionLog }
            else
            { Write-Output ( $dellswitch + ' running Config backed up') >> $sessionLog }
        }


        #kill if its left running
        $kitty = Get-Process kitty -ErrorAction SilentlyContinue
        if ($kitty) {
            # try gracefully first
            $kitty.CloseMainWindow()
            # kill after five seconds
            Sleep 5
            if (!$kitty.HasExited) {
                $kitty | Stop-Process -Force
                Write-Output ($dellswitch + ' had to kill the kitty') >> $sessionLog
            }
        }
        Remove-Variable kitty
    }

    else {
        Write-Output ( $dellswitch + ' Cant connect') >> $sessionLog
    }
}

########################################################################################################
####DC Switches ####

Write-Output "Starting backup of DC Switches" >> $sessionLog

foreach ($dcswitch in $dcs) {
    if (Test-Connection -ComputerName $dcswitch -Quiet) {

        Write-Output ( $dcswitch + ' Connected backup will now be attempted') >> $sessionLog
        $connectionLogDells = ($connectionOutDIR + $dcswitch + '-Switch_startup_output.log')
        $connectionLogDellr = ($connectionOutDIR + $dcswitch + '-Switch_running_output.log')

        #Backup startup Config
        C:\scripts\Orchestration\Daily\Switch-Backup\kitty.exe $dcswitch -ssh -v -l $switchu -pw $switchp -cmd "Copy startup-Config tftp://$tftpserver/$dcswitch-startup_config \ny \n logout" -log $connectionLogDells

        #wait just in case
        Start-Sleep -Seconds 60

        #Sets location of file
        $startupconfigfile = get-item -path ('E:\Backups\Switch-Configs\' + $dcswitch + '-startup_config') -ErrorAction SilentlyContinue

        #checks backup of startup log
        if ($startupconfigfile -eq $null) {
            { Write-Output ( $dcswitch + ' Backup file not found') >> $sessionLog }
        }
        else {
            if (Test-Path -Path $startupconfigfile -OlderThan $Hoursback)
            { Write-Output ( $dcswitch + ' startup Config NOT backed up') >> $sessionLog }
            else
            { Write-Output ( $dcswitch + ' startup Config backed up') >> $sessionLog }
        }

        #kill if its left running
        $kitty = Get-Process kitty -ErrorAction SilentlyContinue
        if ($kitty) {
            # try gracefully first
            $kitty.CloseMainWindow()
            # kill after five seconds
            Sleep 5
            if (!$kitty.HasExited) {
                $kitty | Stop-Process -Force
                Write-Output ($dcswitch + ' had to kill the kitty') >> $sessionLog
            }
        }
        Remove-Variable kitty

        #Backup Running config
        C:\scripts\Orchestration\Daily\Switch-Backup\kitty.exe $dcswitch -ssh -v -l svc-switch-backup -pw $switchp -cmd "Copy running-Config tftp://$tftpserver/$dcswitch-running_config \ny \n logout" -log $connectionLogDellr

        #wait just in case
        Start-Sleep -Seconds 60

        #Sets location of file
        $runningconfigfile = get-item -path ('E:\Backups\Switch-Configs\' + $dcswitch + '-running_config') -ErrorAction SilentlyContinue

        #checks backup of running log
        if ($runningconfigfile -eq $null) {
            { Write-Output ( $dellswitch + ' Backup file not found') >> $sessionLog }
        }
        else {
            if (Test-Path -Path $startupconfigfile -OlderThan $Hoursback)
            { Write-Output ( $dcswitch + ' running Config NOT backed up') >> $sessionLog }
            else
            { Write-Output ( $dcswitch + ' running Config backed up') >> $sessionLog }
        }

        #kill if its left running
        $kitty = Get-Process kitty -ErrorAction SilentlyContinue
        if ($kitty) {
            # try gracefully first
            $kitty.CloseMainWindow()
            # kill after five seconds
            Sleep 5
            if (!$kitty.HasExited) {
                $kitty | Stop-Process -Force
                Write-Output ($dcswitch + ' had to kill the kitty') >> $sessionLog
            }
        }
        Remove-Variable kitty
    }

    else {
        Write-Output ( $dcswitch + ' Cant connect') >> $sessionLog
    }
}


########################################################################################################
####HP Switches ####

Write-Output "Starting backup of HP Switches" >> $sessionLog

foreach ($hpswitch in $hp) {
    if (Test-Connection -ComputerName $hpswitch -Quiet) {


        Write-Output ( $hpswitch + ' Connected backup will now be attempted') >> $sessionLog
        $connectionLoghps = ($connectionOutDIR + $hpswitch + '-Switch_startup_output.log')
        $connectionLoghpr = ($connectionOutDIR + $hpswitch + '-Switch_running_output.log')
        #Backup startup Config
        C:\scripts\Orchestration\Daily\Switch-Backup\kitty.exe $hpswitch -ssh -v -l $switchuhp -pw $switchphp -cmd "\n Copy startup-Config tftp $tftpserver $hpswitch-startup_config \n \n logout \ny"  -log $connectionLoghps

        #wait just in case
        Start-Sleep -Seconds 60

        #Sets location of file
        $startupconfigfile = get-item -path ('E:\Backups\Switch-Configs\' + $hpswitch + '-startup_config')

        #checks backup of startup log
        if ($startupconfigfile -eq $null) {
            { Write-Output ( $hpswitch + ' Backup file not found') >> $sessionLog }
        }
        else {
            if (Test-Path -Path $startupconfigfile -OlderThan $Hoursback)
            { Write-Output ( $hpswitch + ' startup Config NOT backed up') >> $sessionLog }
            else
            { Write-Output ( $hpswitch + ' startup Config backed up') >> $sessionLog }
        }


        #kill if its left running
        #kill if its left running
        $kitty = Get-Process kitty -ErrorAction SilentlyContinue
        if ($kitty) {
            # try gracefully first
            $kitty.CloseMainWindow()
            # kill after five seconds
            Sleep 5
            if (!$kitty.HasExited) {
                $kitty | Stop-Process -Force
                Write-Output ($hpswitch+ ' had to kill the kitty') >> $sessionLog
            }
        }
        Remove-Variable kitty

        #Backup Running config
        C:\scripts\Orchestration\Daily\Switch-Backup\kitty.exe $hpswitch -ssh -v -l $switchuhp -pw $switchphp -cmd "\n Copy running-Config tftp $tftpserver $hpswitch-running_config \n \n logout \ny" -log $connectionLoghpr

        #wait just in case
        Start-Sleep -Seconds 60

        #Sets location of file
        $runningconfigfile = get-item -path ('E:\Backups\Switch-Configs\' + $hpswitch + '-running_config')

        #checks backup of running log
        if ($runningconfigfile -eq $null) {
            { Write-Output ( $hpswitch + ' Backup file not found') >> $sessionLog }
        }
        else {
            if (Test-Path -Path $startupconfigfile -OlderThan $Hoursback)
            { Write-Output ( $hpswitch + ' running Config NOT backed up') >> $sessionLog }
            else
            { Write-Output ( $hpswitch + ' running Config backed up') >> $sessionLog }
        }


        #kill if its left running
        $kitty = Get-Process kitty -ErrorAction SilentlyContinue
        if ($kitty) {
            # try gracefully first
            $kitty.CloseMainWindow()
            # kill after five seconds
            Sleep 5
            if (!$kitty.HasExited) {
                $kitty | Stop-Process -Force
                Write-Output ($hpswitch + ' had to kill the kitty') >> $sessionLog
            }
        }
        Remove-Variable kitty
    }

    else {
        Write-Output ( $hpswitch + ' Cant connect') >> $sessionLog
    }
}
<#
########################################################################################################
####Cisco Switches ####

Write-Output "Starting backup of Cisco Switches" >> $sessionLog

foreach ($ciscoswitch in $cisco) {
    if (Test-Connection -ComputerName $ciscoswitch -Quiet) {

        Write-Output ( $ciscoswitch + ' Connected backup will now be attempted') >> $sessionLog

        #Backup startup Config
        C:\scripts\Orchestration\Daily\Switch-Backup\kitty.exe $ciscoswitch -ssh -v -l $switchucisco -pw $switchpcisco -cmd "enable \n Copy startup-Config tftp://$tftpserver/$ciscoswitch-startup_config \ny \n logout"

        #wait just in case
        Start-Sleep -Seconds 60

        #Sets location of file
        $startupconfigfile = get-item -path ('E:\Backups\Switch-Configs\' + $ciscoswitch + '-startup_config')

        #checks backup of startup log
        if ($startupconfigfile.LastWriteTime -lt $Hoursback)
        { Write-Output ( $ciscoswitch + ' startup Config NOT backed up') >> $sessionLog }
        else
        { Write-Output ( $ciscoswitch + ' startup Config backed up') >> $sessionLog }


        #kill if its left running
        if (Get-Process -Name 'kitty') {
            Stop-Process -Name 'kitty'
            Write-Output ($ciscoswitch + ' had to kill the kitty') >> $sessionLog
        }
        else {
            #Write-Host "no"
            Write-Output (' ') >> $sessionLog
        }

        #Backup Running config
        C:\scripts\Orchestration\Daily\Switch-Backup\kitty.exe $ciscoswitch -ssh -v -l $switchucisco -pw $switchpcisco -cmd "enable \n Copy running-Config tftp://$tftpserver/$ciscoswitch-running_config \ny \n logout"

        #wait just in case
        Start-Sleep -Seconds 60

        #Sets location of file
        $runningconfigfile = get-item -path ('E:\Backups\Switch-Configs\' + $ciscoswitch + '-running_config')

        #checks backup of running log
        if ($runningconfigfile.LastWriteTime -lt $Hoursback)
        { Write-Output ( $ciscoswitch + ' running Config NOT backed up') >> $sessionLog }
        else
        { Write-Output ( $ciscoswitch + ' running Config backed up') >> $sessionLog }


        #kill if its left running
        if (Get-Process -Name 'kitty') {
            Stop-Process -Name 'kitty'
            Write-Output ( $ciscoswitch + ' had to kill the kitty') >> $sessionLog
        }
        else {
            #Write-Host "no"
            Write-Output (' ') >> $sessionLog
        }
    }

    else {
        Write-Output ( $ciscoswitch + ' Cant connect') >> $sessionLog
    }
}

########################################################################################################
####Watchguard Firewalls ####
#>

########################################################################################################
#Clean backup folder
if ($Configbackup -gt 1024.0) {
    Get-ChildItem $ConfigRootDir-Recurse -Force -File -PipelineVariable File | % {
        try {
            Remove-Item -Path $File.fullname -Force -Confirm:$false -ErrorAction Stop | Where-Object { $_.LastWriteTime -lt $DatetoDelete }
            "Deleted file: $($File.fullname)" | Out-File $sessionLog -Append
        }
        catch {
            "Failed to delete file: $($File.fullname)" | Out-File $sessionLog -Append
        }
    }
}
else {
    Write-Output ($date + " Config Size is below 1GB") >> $sessionLog

}
########################################################################################################
#clean log folder
if ($ConfigLogBackup -gt 30.0) {
    Get-ChildItem $configLogs -Recurse -Force -File -PipelineVariable File | % {
        try {
            Remove-Item -Path $File.fullname -Force -Confirm:$false -ErrorAction Stop | Where-Object { $_.LastWriteTime -lt $DatetoDelete }
            "Deleted file: $($File.fullname)" | Out-File $sessionLog -Append
        }
        catch {
            "Failed to delete file: $($File.fullname)" | Out-File $sessionLog -Append
        }
    }
}
else {
    Write-Output ($date + " Config Size is below 30MB") >> $sessionLog
    Write-Output ($date + " Service Finished") >> $sessionLog
}