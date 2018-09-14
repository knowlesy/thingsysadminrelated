#outputs a lot of mess then process this in notepad++ and excel
Get-ChildItem C:\temp\MailLists -I *.txt -R | Select-String -SimpleMatch "@" | Out-File C:\temp\distrobutionlist.txt