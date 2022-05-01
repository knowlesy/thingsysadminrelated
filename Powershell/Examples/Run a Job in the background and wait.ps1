Start-Job -ScriptBlock { C:\support\tools\sdelete64.exe -accepteula -nobanner -z c:}
Start-Sleep -Seconds 10
$wait = Get-Process "sdelete64" -ErrorAction SilentlyContinue| select-object *
$z = 0
$zmax = 40 
if ($wait.Responding -eq "True")
{
    Write-Host "SDELETE is running this wil ltake some time"
    while ($wait.Responding -eq "True") {
        if ($z -eq $zmax) {
            write-host "Zeroing ran for over 20 mintes terminating process"
            stop-process $wait.Id -force
        }
        else {
            write-host "Zeroing C Drive ($z/$zmax)"
            start-sleep -seconds 30
            $wait = Get-Process "sdelete64" -ErrorAction SilentlyContinue | select-object *
            $z++
        }
    }
}
else
{ 
    Write-Host "SDELETE failed to run"
    #stop-process $wait.Id -force -ErrorAction SilentlyContinue
}
