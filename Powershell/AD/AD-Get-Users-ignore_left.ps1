import-module activedirectory
Get-ADUser -SearchBase "DC=DOMAIN,DC=LOCAL" -Filter * -Properties * | Where-Object {$_.distinguishedName -match "OU=Users" -and $_.distinguishedName -notmatch "OU=Left"} | Select-Object SAMaccountname, description, distinguishedName, telephoneNumber, Mobile | Export-Csv -Path c:\temp\excel.csv -Append

