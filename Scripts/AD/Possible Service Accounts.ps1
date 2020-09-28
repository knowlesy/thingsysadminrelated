#Possible service accounts

$serviceaccountsreport = ('c:\temp\Possible_Service_Accounts.csv')
[array] $serviceAN = "svc","service","Services","lansweeper","build","veeam","vmware","sql","app","application","task","backup","monitor","display","ldap","build","support","symantec","sophos","microsoft","exchange"
foreach ($serviceaccounttext in $serviceAN)
{
Get-ADUser -Filter * -Properties * | Where-Object { $_.SamAccountName -match $serviceaccounttext -or $_.Description -match $serviceaccounttext -or $_.givenname -match $serviceaccounttext -or $_.surname -match $serviceaccounttext -or $_.DisplayName -match $serviceaccounttext} | Select-Object * | Export-Csv -Append -Path $serviceaccountsreport -NoClobber -NoTypeInformation
}