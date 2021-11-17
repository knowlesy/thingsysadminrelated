$users = Import-Csv -Path D:\name.csv
foreach ($user in $users) {

    Get-Mailbox -Identity $user.users | select Name, legacyExchangeDN | Export-Csv -Append -path D:\users-x500.csv
}
