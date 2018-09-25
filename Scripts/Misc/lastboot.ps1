#REF
#https://serverfault.com/questions/722687/script-for-getting-last-reboot-timestamp-2008r2
$compname = Get-Content -Path C:\Support\info\Servers.txt
foreach ($comp in $compname) {
    $errorwithpc = $comp + ' Can not connect'
    $logoutput = 'C:\Support\Logs\lastboot.log'
    Get-WmiObject win32_operatingsystem -ComputerName $comp| select CSName, @{LABEL = 'LastBootUpTime'; EXPRESSION = {$_.ConverttoDateTime($_.lastbootuptime)}} -ErrorVariable $errorwithpc | Out-File -FilePath $logoutput -Append

}