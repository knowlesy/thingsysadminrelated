$servers = get-Content "C:\Temp\serverlist.txt"

$OutputPath = 'C:\temp\AD-Port-export.csv'
foreach ($server in $servers) {
    
    $dns = Test-NetConnection $server -Port 53 -InformationLevel Quiet
    $smtp = Test-NetConnection $server -Port 25 -InformationLevel Quiet
    $rdp = Test-NetConnection $server -Port 3389 -InformationLevel Quiet
    $ftp = Test-NetConnection $server -Port 21 -InformationLevel Quiet
    $secureweb = Test-NetConnection $server -Port 443 -InformationLevel Quiet
    $web = Test-NetConnection $server -Port 80 -InformationLevel Quiet
    #$pop = Test-NetConnection $server -Port 110 -InformationLevel Quiet
    #$imap = Test-NetConnection $server -Port 143 -InformationLevel Quiet
    $iscsi = Test-NetConnection $server -Port 860 -InformationLevel Quiet
    $telnet = Test-NetConnection $server -Port 23 -InformationLevel Quiet
    $ssh = Test-NetConnection $server -Port 22 -InformationLevel Quiet
    
    $csvoutput = @(
    [pscustomobject]@{
        Name =  $server

        DNS = $dns

        SMTP = $smtp

        RDP = $rdp

        FTP = $ftp

        Web = $web

        SecureWeb = $secureweb

        ISCSI = $iscsi

        Telnet = $telnet

        SSH = $ssh

    })



 

$csvoutput | Export-CSV $OutputPath -Append -Force -NoClobber -NoTypeInformation

}
