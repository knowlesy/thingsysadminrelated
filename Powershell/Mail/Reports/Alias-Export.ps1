#REF https://community.spiceworks.com/topic/2132845-powershell-script-to-export-mailbox-username-and-all-aliases-to-csv
$Mailboxes = Get-Recipient -filter {emailaddresses -like "*@DOMAIN.com"} -ResultSize Unlimited | Sort-Object -Property @{ Expression = { $_.EmailAddresses.Count } } -Descending

$Results = foreach( $Mailbox in $Mailboxes ){
    
    

    $Properties = [ordered]@{
        FirstName          = $Mailbox.FirstName
        LastName           = $Mailbox.LastName
        DisplayName        = $Mailbox.DisplayName
        Type               = $Mailbox.RecipientType
        PrimarySmtpAddress = $Mailbox.PrimarySmtpAddress
        }

    $AltAddresses = $Mailbox.EmailAddresses | Where-Object { $_ -match '^smtp:' -and $_ -match "@DOMAIN.com" -and $_ -ne $Mailbox.PrimarySmtpAddress }

    $i = 1

    foreach( $Address in $AltAddresses ){
        $Properties.Add( "AltAddress$i", $Address -replace '^smtp:' )


        $i++
        }

    [pscustomobject]$Properties
    }

$Results | Export-Csv -Path C:\temp\MailboxReport.csv -NoTypeInformation -NoClobber




