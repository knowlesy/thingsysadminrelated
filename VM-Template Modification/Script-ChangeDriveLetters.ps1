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


#$DriveE=Get-WmiObject -Class win32_volume -Filter "DriveLetter = 'E:'"
#Set-WmiInstance -input $DriveE -Arguments @{DriveLetter='X:'; Label="Swap"}

#$DriveD=Get-WmiObject -Class win32_volume -Filter "DriveLetter = 'D:'"
#Set-WmiInstance -input $DriveD -Arguments @{Label="Server Apps"}

#$DriveC=Get-WmiObject -Class win32_volume -Filter "DriveLetter = 'C:'"
#Set-WmiInstance -input $DriveC -Arguments @{Label="System"}

#$DriveF=Get-WmiObject -Class Win32_volume -Filter "DriveLetter = 'F:'"
#Set-WmiInstance -input $DriveF -Arguments @{DriveLetter='Z:'}