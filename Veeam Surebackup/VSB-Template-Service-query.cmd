REM query-service.bat
@ECHO OFF
powershell.exe -noninteractive -noprofile -command "& {C:Tempquery-service.ps1 %1 %2 }"
EXIT /B %errorlevel%