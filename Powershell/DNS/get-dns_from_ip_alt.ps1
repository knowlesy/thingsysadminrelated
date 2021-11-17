$content = Get-Content C:\temp\list.txt
foreach ($item in $content) {
try{
$dns = [System.Net.Dns]::GetHostEntry($item).HostName
Write-Host ($item + "," + $dns) -ForegroundColor Green
 }
 catch
 {
 Write-Host ($item + " unknown") -ForegroundColor Red
 }
 }