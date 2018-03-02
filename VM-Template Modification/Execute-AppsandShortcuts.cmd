powershell -command "& {Set-ExecutionPolicy Unrestricted}"
powershell -file "C:\Support\Scripts\Generic\Script-AppsandShortcuts.ps1"
powershell -command "& {Set-ExecutionPolicy RemoteSigned}"
"c:\Support\BuildFiles\windirstat.exe" /S
