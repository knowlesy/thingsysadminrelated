set-location c:
Start-Transcript -OutputDirectory "C:\Support\Transcripts\" -NoClobber
new-item alias:np -value "C:\Program Files\Notepad++\notepad++.exe"
$psISE.CurrentPowerShellTab.AddOnsMenu.SubMenus.Add(
    "Connect to Exchange ", {
        $onpremcred = Get-Credential
        $ExSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://<SERVER>/PowerShell/  -Credential $onpremcred
        Import-PSSession $ExSession
    },
    "Control+Alt+1"
)

$psISE.CurrentPowerShellTab.AddOnsMenu.SubMenus.Add(
    "Connect to Exchange Online", {
        $o365Cred = Get-Credential
        $o365Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $o365Cred -Authentication Basic -AllowRedirection
        Import-PSSession $o365Session
    },
    "Control+Alt+3"
)

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