Add-PSSnapin VeeamPSSnapin
###VARIABLE###
$servers = "server1","server2"
$LogLocation = "\\server\Veeam$\VeeamLog.log" #Full Log for diagnostics attched to email
$EmailLog = "\\server\Veeam$\EmailVeeamLog.log"#Final Log for email
$EmailLogTemp = "\\server\Veeam$\EmailVeeamLogTemp.log" #Cutdown Log > will be modified at end to ad html formatting
$timeran = Get-Date

$wherewasthisranfrom = $env:computername

##############
Write-Output "" > $EmailLog
Write-Output "Script is Ran from $wherewasthisranfrom at $timeran" >> $LogLocation
Write-Output "" >> $LogLocation
foreach ($server in $servers)
{
    If (Test-Connection $server -Count 2)
    {
        Connect-VBRServer -Server $server
        Write-Output "Connecting to $Server" >> $LogLocation
        $whatsrunning = Get-VBRJob |Where-Object {$_.IsRunning -eq "True" }|Where-Object {$_.JobType -eq "Backup"}| Format-Table -Property Name -AutoSize
        
        if (($whatsrunning).length -eq "0")
        {
            Write-Output "" >> $LogLocation
            #Write-Output "$Server" >> $LogLocation
            Write-Output "No Jobs running on $server at the time of this report" >> $LogLocation
            Write-Output "" >> $LogLocation
            Write-Output "" >> $EmailLogTemp
            #Write-Output "$Server " >> $EmailLogTemp
            Write-Output "No Jobs running on $server at the time of this report " >> $EmailLogTemp
            Write-Output "" >> $EmailLogTemp
            #Get-VBRJob
        }
        Else
        {
            Write-Output "" >> $LogLocation
            Write-Output "$Server" >> $LogLocation
            Write-Output "Jobs running on $server at the time of this report" >> $LogLocation
            $whatsrunning  >> $LogLocation
            Write-Output "" >> $LogLocation
            Write-Output "" >> $EmailLogTemp
            Write-Output "$Server" >> $EmailLogTemp
            Write-Output "Jobs running on $server at the time of this report" >> $EmailLogTemp
            $whatsrunning  >> $EmailLogTemp
            Write-Output "" >> $EmailLogTemp

        }
        
        Disconnect-VBRServer
        Write-Output "Disconnecting from $Server" >> $LogLocation
    }
    Else
    {
        Write-Output "Could not Connect to $server" >> $LogLocation
        Write-Output "Could not Connect to $server " >> $EmailLogTemp
    }
   # Write-Output "Script is Ran from $wherewasthisranfrom at $timeran " >> $EmailLogTemp
}
Get-Content $EmailLogTemp | foreach {add-content $EmailLog "$_ </BR>"} 

$completetime = Get-Date
Write-Output "" >> $LogLocation
Write-Output "Script Complete $completetime" >> $LogLocation
Remove-Item $EmailLogTemp
