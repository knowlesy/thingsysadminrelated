$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

# Check to see if we are currently running “as Administrator”
if ($myWindowsPrincipal.IsInRole($adminRole))
{
# We are running “as Administrator” – so change the title and background colour to indicate this
$Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + “(Elevated)”
$Host.UI.RawUI.BackgroundColor = “DarkBlue”
clear-host
}
else
{
# We are not running “as Administrator” – so relaunch as administrator

# Create a new process object that starts PowerShell
$newProcess = new-object System.Diagnostics.ProcessStartInfo “PowerShell”;

# Specify the current script path and name as a parameter
$newProcess.Arguments = $myInvocation.MyCommand.Definition;

# Indicate that the process should be elevated
$newProcess.Verb = “runas”;

# Start the new process
[System.Diagnostics.Process]::Start($newProcess);

# Exit from the current, unelevated, process
exit
}

mkdir "C:\Program Files (x86)\BGInfo\"
copy "C:\Support\BuildFiles\SysInternals\bginfo.bgi" "C:\Program Files (x86)\BGInfo\"
copy "C:\Support\BuildFiles\SysInternals\bginfo.exe" "C:\Program Files (x86)\BGInfo\"
copy "C:\Support\BuildFiles\SysInternals\bginfo.cmd" "C:\Program Files (x86)\BGInfo\"
copy "C:\Support\BuildFiles\SysInternals\bginfo.lnk" "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\"

mkdir "C:\Program Files (x86)\Sysinternals"

copy "C:\Support\BuildFiles\SysInternals\" "C:\Program Files (x86)\Sysinternals\"