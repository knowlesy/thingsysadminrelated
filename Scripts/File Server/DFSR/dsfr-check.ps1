#REF bwatt
#REF https://www.reddit.com/r/PowerShell/comments/ad0egr/check_dfs_backlog/?utm_source=reddit-android
# List of DFSR Source/Target pairs to monitor
$DFSRPaths = @{
    "server\share" = "server\share";

}

# filename for test file (is created in root of source, and tested for presence in target)
$testFilename = "dfsrcheck.txt"
# email recipients/settings
[string[]]$toRecipients = "noemail@company.com", "noemail1@company.com"
$smtpServer = "smtpserver"
$smtpFrom = "noemail@company.com"
$emailDate = Get-Date -Format "dd/MM/yyyy"

Remove-Item -Path C:\scripts\Orchestration\Daily\DFRS\logcount.txt -Force
$RGGroups = Get-DfsReplicationGroup 
#"Displaying Replication Backlog"
foreach ( $RG in $RGGroups) {
    $RFolders = Get-DfsReplicatedFolder -GroupName $RG.GroupName
    foreach ($RF in $RFolders) {
        $RCons = Get-DfsrConnection -GroupName $RG.GroupName 
        foreach ($RC in $RCons) {
             $date = get-date -f "yyyy-MM-dd HH:mm:ss"
            [double]$count = (Get-DFSRBackLog -groupName $RG.GroupName -folderName $RF.FolderName -DestinationComputerName $RC.DestinationComputerName -SourceComputerName $RC.SourceComputerName -verbose 4>&1).Message.split(":")[2]
            "[{0}] RG: {1} RF: {2} on {3} to {4} Backlog Length: {5}" -f $date,$RG.GroupName,$RF.FolderName,$RC.SourceComputerName, $Rc.DestinationComputerName,$count | Out-File -FilePath "C:\scripts\Orchestration\Daily\DFRS\logcount.txt" -Append
        }
    }
}

# creates a file if it does not already exist
Function Touch-File {
    $file = $args[0]
    if ($file -eq $null) {
        throw "No filename supplied"
    }

    if (Test-Path $file) {
        Write-Host "   Touching $file"
        get-random > $file
    }
    else {
        Write-Host "   Creating $file"
        echo $null > $file
    }
}

# checks presence of files on all target paths and emails results
Function Check-All {
    $textFailureHeading = "Test file stale (possible replication issues)"
    $textFailures = ""
    $textSuccessesHeading = "Replication successful"
    $textSuccesses = ""
    $textbacklog = Get-Content -Path C:\scripts\Orchestration\Daily\DFRS\logcount.txt -Raw
    Write-Host "Checking target files"
    foreach ($key in $DFSRPaths.Keys) { 
        $modTime = (Get-Date).Addhours(-25)
        write-host "   $key" -nonewline
        if ((get-item "$($DFSRPaths[$key])\$testFilename" -Force -EA SilentlyContinue).LastWriteTime -gt $modTime) {
            Write-Host " -> $($DFSRPaths[$key]) OK"
            $textSuccesses += "	$key -> $($DFSRPaths[$key])`r`n" 
        }
        else {
            Write-Host " -> $($DFSRPaths[$key]) STALE"
            $textFailures += "	$key -> $($DFSRPaths[$key])`r`n"
        }
    }

    $messageSubject = "DFS Replication statuses - $emailDate"
    $messageBody = "$textFailureHeading`r`n$textFailures`r`n`r`n$textSuccessesHeading`r`n$textSuccesses`r`n`r $textbacklog `r`n`r"
	
    Send-MailMessage -to $toRecipients -cc $ccRecipients -from $smtpFrom -Subject $messageSubject -body $messageBody -smtpServer $smtpServer
}

# creates test files on all sources
Function Touch-All {
    Write-Host "Refreshing source files"
    foreach ($key in $DFSRPaths.Keys) { 
        Touch-File "$key\$testFilename"
    }
}

Touch-All
Start-Sleep -s 60
Check-All



