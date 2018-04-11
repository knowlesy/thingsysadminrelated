Add-PSSnapin VeeamPSSnapin
###VARIABLE###
$servers = "SERVER1","SERVER2"
$LogLocation = "<LOCATION>"
##############


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
            #Get-VBRJob
        }
        Else
        {
            Write-Line "" >> $LogLocation
            Write-Line "$Server" >> $LogLocation
            Write-Line "Jobs running on $server at the time of this report" >> $LogLocation
            $whatsrunning  >> $LogLocation
            Write-Line "" >> $LogLocation

        }
        
        Disconnect-VBRServer
        Write-Line "Disconnecting from $Server" >> $LogLocation
    }
    Else
    {
        Write-Line "Could not Connect to $server" >> $LogLocation
    }
}
