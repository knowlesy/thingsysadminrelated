#REF
#https://serverfault.com/questions/722687/script-for-getting-last-reboot-timestamp-2008r2
$compname = Get-Content -Path C:\computers.txt
foreach ($comp in $compname) {
    Get-WmiObject win32_operatingsystem -ComputerName $comp| select CSName, @{LABEL='LastBootUpTime';EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}

}