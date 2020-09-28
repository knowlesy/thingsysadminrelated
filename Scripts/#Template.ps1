#requires -version 5
<#
.SYNOPSIS
  <Overview of script>
.DESCRIPTION
  <Brief description of script>
.PARAMETER <Parameter_Name>
  <Brief description of parameter input required. Repeat this attribute if required>
.INPUTS
  <Inputs if any, otherwise state None>
.OUTPUTS
  <Outputs if any, otherwise state None>
.NOTES
  Version:        1.0
  Author:         <Name>
  Creation Date:  <Date>
  Purpose/Change: Initial script development
.EXAMPLE
  <Example explanation goes here>
  <Example goes here. Repeat this attribute for more than one example>
.Ref
    https://gallery.technet.microsoft.com/scriptcenter/Write-Log-PowerShell-999c32d0
    https://9to5it.com/powershell-script-template-version-2/
  #>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------
#Import Modules & Snap-ins

#----------------------------------------------------------[Declarations]----------------------------------------------------------
#Any Global Declarations go here

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'
#Static Variables for  Logging Function
$logcreated = Get-Date
$Log_Location = 'C:\Support\logs\'
$logpath = ($Log_Location + $logcreated.ToString("yyyy-MM-dd_HH-mm") + "-AD_Report.log")
$Log_Location_test = Test-Path -Path $Log_Location -ErrorAction $ErrorActionPreference



#-----------------------------------------------------------[Functions]------------------------------------------------------------
#Functions
function Write-Log {
    [CmdletBinding()]

    Param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias("LogContent")]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [Alias('LogPath')]
        #[string]$Path = C:\Support\Logs\AD.log
        [string]$Path = $logpath,
        #[switch]$path2,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Error", "Warn", "Info")]
        [string]$Level = "Info",

        [Parameter(Mandatory = $false)]
        [switch]$NoClobber
    )

    Begin {
        # Set VerbosePreference to Continue so that verbose messages are displayed.
        $VerbosePreference = 'Continue'
    }
    Process {

        # If the file already exists and NoClobber was specified, do not write to the log.
        if ((Test-Path $Path) -AND $NoClobber) {
            Write-Error "Log file $Path already exists, and you specified NoClobber. Either delete the file or specify a different name."
            Return
        }

        # If attempting to write to a log file in a folder/path that doesn't exist create the file including the path.
        elseif (!(Test-Path $Path)) {
            Write-Verbose "Creating $Path."
            $NewLogFile = New-Item $Path -Force -ItemType File
            $NewLogFile 
        }

        else {
            # Nothing to see here yet.
        }

        # Format Date for our Log File
        $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

        # Write message to error, warning, or verbose pipeline and specify $LevelText
        switch ($Level) {
            'Error' {
                Write-Error $Message
                $LevelText = 'ERROR:'
            }
            'Warn' {
                Write-Warning $Message
                $LevelText = 'WARNING:'
            }
            'Info' {
                Write-Verbose $Message
                $LevelText = 'INFO:'
            }
        }

        # Write log entry to $Path
        "$FormattedDate $LevelText $Message" | Out-File -FilePath $Path -Append
    }
    End {
    }
}




#-----------------------------------------------------------[Execution]------------------------------------------------------------

#Script Execution goes here
#Information for End user
Write-Host "Logs will be stored in $Log_Location" -ForegroundColor Green
Write-Host "This must be ran as an admin account" -ForegroundColor Green

if ($Log_Location_test -eq $true) {

    Write-Log "Script Started with Script version $ScriptVersion" -Level Info
    Write-Log "Log Directory already created at $Log_Location" -Level Info
}


else {
    New-Item -Path $Log_Location -ItemType Directory 
    Write-Log "Script Started with Script version $ScriptVersion" -Level Info
    Write-Log "Created Log Directory at $Log_Location" -Level Info
}



Start-Sleep -Seconds 2
