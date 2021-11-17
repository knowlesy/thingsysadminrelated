function Get-MoreIPinfo {
    param (
        [Parameter(Mandatory=$true)] $IP = ""

    )
    $doesitping = Test-Connection $IP -Count 2 -Quiet
    $DNS = Resolve-DnsName $IP -ErrorAction SilentlyContinue | select name
    
    if ($doesitping -eq "True") {
        Write-Host ("Ping Result: " + $doesitping) -ForegroundColor Green
    }
    else {
        Write-Host ("Ping Result: " + $doesitping) -ForegroundColor Red
    }
   
    
    if ($DNS.count -eq 0)
    {
        Write-Host ("DNS: Did not resolve") -ForegroundColor Red
    }
    else {
        Write-Host ("DNS: " + $dns.name) -ForegroundColor Green
    }
    try {
        $AD = Get-ADComputer -Properties IPv4Address -Filter {IPv4Address -eq $IP} -ErrorAction SilentlyContinue | select Name
    }
    catch {
        $ADtest = "1"
    }
    if ($ADtest -eq 1)
    {
        Write-Host ("AD: No account for " + $IP) -ForegroundColor Red
        $ADtest = "0"
    }
    else {
        Write-Host ("AD Name: " + $AD.Name) -ForegroundColor Green
        $ADtest = "0"
    }
    

}




