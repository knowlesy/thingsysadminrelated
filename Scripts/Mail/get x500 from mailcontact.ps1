Get-MailContact -Identity "username" | select Name, ExternalEmailAddress, legacyExchangeDN | out-file C:\temp\users-x500.csv -Append