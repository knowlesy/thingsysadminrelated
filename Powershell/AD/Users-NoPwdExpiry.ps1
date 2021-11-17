Import-Module ActiveDirectory
$date = Get-Date -Format yyyy-MM-dd-%H-mm
$path = ("C:\Support\Files\" + $date + "-users.csv")
$filteredusers = Get-Content -Path "C:\Support\Scripts\Users-NoPwdExpiry-Users-toignore.txt"
Get-ADUser -SearchBase "DC=Domain,DC=LOCAL" -Filter * -Properties * |
Where-Object { $filteredusers -notcontains $_.SamAccountName -and $_.PasswordNeverExpires -eq 'True' -and $_.Enabled -eq "True" -and $_.SamAccountName -notmatch "svc" -and $_.msExchRecipientTypeDetails -ne "4" } | Select-Object SamAccountName, PasswordNeverExpires, PasswordLastSet, @{N = 'LastLogon'; E = { [DateTime]::FromFileTime($_.LastLogon) } }, CanonicalName, Description, msExchRecipientTypeDetails | Export-Csv -Append -Path $path

#msExchRecipientTypeDetails is exchange shared mailbox or not
#User Mailbox 1
#Linked Mailbox 2
#Shared Mailbox 4
#Legacy Mailbox 8
#Room Mailbox 16
#Equipment Mailbox 32
#Mail Contact 64
#Mail User 128
#http://techgenix.com/msexchangerecipienttypedetails-active-directory-values/

