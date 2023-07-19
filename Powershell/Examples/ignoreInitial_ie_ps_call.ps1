#REF https://blog.dhampir.no/content/how-to-use-invoke-webrequest-in-powershell-without-having-to-first-open-internet-explorer
#The response content cannot be parsed because the Internet Explorer engine is not available, or Internet Explorer’s 
$keyPath = 'Registry::HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Internet Explorer\Main'
if (!(Test-Path $keyPath)) { New-Item $keyPath -Force | Out-Null }
Set-ItemProperty -Path $keyPath -Name "DisableFirstRunCustomize" -Value 1
