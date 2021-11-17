powershell -command "& {Set-ExecutionPolicy Unrestricted}"
powershell -file "C:\Support\Scripts\Generic\Script-StandardCustomisations.ps1"
powershell -command "& {Set-ExecutionPolicy RemoteSigned}"
reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CrashControl /v CrashDumpEnabled /t REG_DWORD /d 0x2 /f