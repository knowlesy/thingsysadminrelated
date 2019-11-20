$content = Get-Content 'c:\temp\maillist.txt'
$OutputPath = 'c:\temp\doesitexist.csv'
foreach ($mail in $content) {

    $Checkmailbox = Get-Mailbox $mail -ErrorAction silentlycontinue
    $CheckContact = Get-mailcontact $mail -ErrorAction silentlycontinue
    $CheckDistG = Get-DistributionGroup $mail -ErrorAction silentlycontinue
    $CheckUser = get-mailuser $mail -ErrorAction silentlycontinue
    
    if (($Checkmailbox | Measure-Object).Count -eq 1) {
        Write-Host ('Mailbox found: ' + $mail) -ForegroundColor Green
        $ExcelMailbox = 'True'
    }
    else {
        Write-Host ('Mailbox NOT found: ' + $mail) -ForegroundColor Yellow
        $ExcelMailbox = 'False'
    }
    if (($Checkcontact | Measure-Object).Count -eq 1) {
        Write-Host ('contactfound: ' + $mail) -ForegroundColor Green
        $Excelcontact = 'True'
    }
    else {
        Write-Host ('contact NOT found: ' + $mail) -ForegroundColor Yellow
        $Excelcontact = 'False'
    }
    if (($CheckDistG | Measure-Object).Count -eq 1) {
        Write-Host ('DistG found: ' + $mail) -ForegroundColor Green
        $ExcelDistG = 'True'
    }
    else {
        Write-Host ('DistG NOT found: ' + $mail) -ForegroundColor Yellow
        $ExcelDistG = 'False'
    }
    if (($CheckUser | Measure-Object).Count -eq 1) {
        Write-Host ('User found: ' + $mail) -ForegroundColor Green
        $ExcelUser = 'True'
    }
    else {
        Write-Host ('User NOT found: ' + $Checkmailbox) -ForegroundColor Yellow
        $ExcelUser = 'False'
    }

    $csvoutput = @(
        [pscustomobject]@{
            Address = $mail
            Mailbox = $ExcelMailbox
            Contact = $Excelcontact
            DistG   = $ExcelDistG
            User    = $ExcelUser

        })

    $csvoutput | Export-Csv $OutputPath -Append -Force

}
