Get-MailContact | select displayname,RecipientType,PrimarySmtpAddress,alias,EmailAddresses,name | Export-Csv c:\temp\mailcontacts.csv -NoClobber -NoTypeInformation	
