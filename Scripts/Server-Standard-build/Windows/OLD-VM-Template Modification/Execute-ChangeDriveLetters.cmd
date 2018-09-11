powershell -command "& {Set-ExecutionPolicy Unrestricted}"
powershell -file "C:\Support\Scripts\Generic\Script-ChangeDriveLetters.ps1"
powershell -command "& {Set-ExecutionPolicy RemoteSigned}"