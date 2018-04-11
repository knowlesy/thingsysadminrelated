Add-PSSnapin VeeamPSSnapin
###VARIABLE###
$servers = "SERVER1","SERVER2"
##############

foreach ($server in $servers)
{
    If (Test-Connection $server -Count 2)
    {
        Connect-VBRServer -Server $server
        $whatsrunning = Get-VBRJob |Where-Object {$_.IsRunning -eq "True" }|Where-Object {$_.JobType -eq "Backup"}| Format-Table -Property Name,JobType,IsRunning -AutoSize
        
        if (($whatsrunning).length -eq "0")
        {
            Write-Host ""
            write-host "No Jobs running on $server at the time of this report"
            Write-Host ""
            #Get-VBRJob
        }
        Else
        {
            Write-Host ""
            write-host "Jobs running on $server at the time of this report"
            $whatsrunning
            Write-Host ""

        }
        
        Disconnect-VBRServer
    }
    Else
    {
        Write-Host "Could not Connect to $server"
    }
}
