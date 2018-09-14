$exclude = "domain.com", "domain.co.za", "domain.co.uk"
Get-ChildItem C:\temp\MailLists -I *.txt -R | Select-String -notmatch $exclude | out-File -FilePath "C:\temp\usersnotindomain.txt" -Append