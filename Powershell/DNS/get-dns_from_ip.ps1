#$content = "192.168.1.1"
$content = Get-Content C:\temp\list.txt
$results = foreach ($item in $content) {

  $what =  [System.Net.Dns]::GetHostbyAddress($item) | Select-Object Hostname,Addresslist 

  $Properties = [ordered]@{
    DNS          =  $what.Hostname
    IP           =  $item

    }
    [pscustomobject]$Properties
}

$Results | Export-Csv -Path C:\temp\DNS.csv -NoTypeInformation -Append
