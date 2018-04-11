Add-PSSnapin VeeamPSSnapin
###VARIABLE###
$servers = "server1","server2"
$LogLocation = "\\Server\Veeam$\VeeamLog.log" #Full Log for diagnostics attched to email
$EmailLog = "\\Server\Veeam\EmailVeeamLog.log" #Cutdown Log > Data improted to a seperate Script as Email
$timeran = Get-Date
$wherewasthisranfrom = $env:computername

##############

write-line "Script is Ran from $wherewasthisranfrom at $timeran" >> $LogLocation
foreach ($server in $servers)
{
    If (Test-Connection $server -Count 2)
    {
        Connect-VBRServer -Server $server
        Write-Line "Connecting to $Server" >> $LogLocation
        $whatsrunning = Get-VBRJob |Where-Object {$_.IsRunning -eq "True" }|Where-Object {$_.JobType -eq "Backup"}| Format-Table -Property Name,JobType,IsRunning -AutoSize
        
        if (($whatsrunning).length -eq "0")
        {
            Write-Line "" >> $LogLocation
            Write-Line "$Server" >> $LogLocation
            Write-Line "No Jobs running on $server at the time of this report" >> $LogLocation
            Write-Line "" >> $LogLocation
            Write-Line "" >> $EmailLog
            Write-Line "$Server" >> $EmailLog
            Write-Line "No Jobs running on $server at the time of this report" >> $EmailLog
            Write-Line "" >> $EmailLog
            #Get-VBRJob
        }
        Else
        {
            Write-Line "" >> $LogLocation
            Write-Line "$Server" >> $LogLocation
            Write-Line "Jobs running on $server at the time of this report" >> $LogLocation
            $whatsrunning  >> $LogLocation
            Write-Line "" >> $LogLocation
            Write-Line "" >> $EmailLog
            Write-Line "$Server" >> $EmailLog
            Write-Line "Jobs running on $server at the time of this report" >> $EmailLog
            $whatsrunning  >> $EmailLog
            Write-Line "" >> $EmailLog

        }
        
        Disconnect-VBRServer
        Write-Line "Disconnecting from $Server" >> $LogLocation
    }
    Else
    {
        Write-Line "Could not Connect to $server" >> $LogLocation
        Write-Line "Could not Connect to $server" >> $EmailLog
    }
    write-line "Script is Ran from $wherewasthisranfrom at $timeran" >> $EmailLog
}
