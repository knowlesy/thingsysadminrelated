#Ref
#https://gallery.technet.microsoft.com/scriptcenter/Write-Log-PowerShell-999c32d0
#https://www.petenetlive.com/KB/Article/0001238

#Information for End user
Clear-Host
Write-Host "Logs will be stored in C:\Support\Logs" -ForegroundColor Green
Write-Host "This must be ran as your admin account" -ForegroundColor Green
Start-Sleep -Seconds 2

#Functions
function Write-Log {
    [CmdletBinding()]

    param
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

    begin {
        # Set VerbosePreference to Continue so that verbose messages are displayed.
        $VerbosePreference = 'Continue'
    }
    process {

        # If the file already exists and NoClobber was specified, do not write to the log.
        if ((Test-Path $Path) -and $NoClobber) {
            Write-Error "Log file $Path already exists, and you specified NoClobber. Either delete the file or specify a different name."
            return
        }

        # If attempting to write to a log file in a folder/path that doesn't exist create the file including the path.
        elseif (!(Test-Path $Path)) {
            Write-Verbose "Creating $Path."
            $NewLogFile = New-Item $Path -Force -ItemType File
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
    end {
    }
}

#Static Variables for Function
$logcreated = Get-Date
$logpath = 'C:\Support\logs\AD-UPNChange' + $logcreated.ToString("yyyy-MM-dd_HH-mm-ss") + ".log"
$newSuffix = "Domain.com"

#initial log of who is running the script
Write-Log "User running the script is $env:USERNAME" -Level Info

#check to see if its ran as an Admin account
if ($env:USERNAME.StartsWith('!')) {
    Write-Log "Ran with Admin account" -Level INFO
}
else {
    Write-Log "Did not run with an Admin Account terminating" -Level Error
    Start-Sleep -Seconds 2
    exit
}

#Checks if AD Module is on the machine if it fails it stops
if (Get-Module -ListAvailable -Name ActiveDirectory) {
    Write-Log "ADModule exists" -Level INFO
    #trys importing the module
    try {
        Import-Module ActiveDirectory
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Log -Message $ErrorMessage -Level Error
        Write-Log -Message $FailedItem -Level Error
    }

    Write-Log -Message 'AD Module exists and is Importing' -Level INFO
}
else {
    Write-Log "AD Module does not exist on users machine process terminated" -Level Error
    exit
}

$listOfUsers = Read-Host -Prompt "Enter location of Txt file full of usernames"

$txtUsers = Get-Content -Path $listOfUsers

Write-Log "Users imported" -Level Info
foreach ($loggeduser in $textUsers) {
    Write-Log $loggeduser -Level Info
}


foreach ($textUser in $txtUsers) {
    Write-Log "Testing User $textUser exists" -Level Info
    $userExists = Get-ADUser -Identity $textUser
    if ($userExists -eq $null) {
        Write-Log "User: $textUser does not exist" -Level Warn

    }
    else {
        Write-Log "User: $textUser exists!" -Level Info
        $findEmail = get-aduser -Identity $textUser -Properties * | Select-Object -ExpandProperty mail
        Write-Log "Email is: $findEmail" -Level Info
       
        Set-ADUser -UserPrincipalName $findEmail -Identity $textUser
        #Write-Log "Set UPN as $newUPN"

    }
    write-log "Script processing complete" -level Info
}
write-log "Script exiting" -level Info
Exit

