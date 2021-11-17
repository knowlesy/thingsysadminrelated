$content = Get-Content "C:\Temp\servers.txt" 

foreach ($item in $content) {
    $test = Test-Connection $item -Count 1 -Verbose -Quiet 
    $getip = Resolve-DnsName $item
    if ($test -eq $false) {
        $getip
        Write-Host ('The following server failed to ping: ' + $item + ' ' + $getip.IPAddress) -ForegroundColor Red
    }
    else {
        Write-Host ('The following server responded: ' + $item+ ' ' + $getip.IPAddress) -ForegroundColor Green
    }
}