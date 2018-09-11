set-location c:
Start-Transcript -OutputDirectory "C:\Support\Transcripts\" -NoClobber
new-item alias:np -value "C:\Program Files\Notepad++\notepad++.exe"
#Directory where my scripts are stored
$psdir = "C:\Support\Scripts\"  
# load all 'autoload' scripts
Get-ChildItem "${psdir}\*.ps1" | % {.$_} 
#setting root location for powershell window
set-location c:\
#Setting colour (used to identify when running as admin)
#$console = $host.UI.RawUI
#$console.ForegroundColor = "White"
#$console.BackgroundColor = "black"
clear-host