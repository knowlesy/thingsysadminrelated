#Ref https://blogs.technet.microsoft.com/heyscriptingguy/2018/09/15/using-powershell-to-create-a-folder-of-demo-data/ 
#Ref https://mcpmag.com/articles/2016/04/07/powershell-functions-with-parameters.aspx
# needs to be ran elavated    

function Start-FakeData {

    [CmdletBinding()]

    param(

        [Parameter()]

        [string]$FolderPath

    )

    $DaysToMove = ((Get-Random 120) - 60)
    $HoursToMove = ((Get-Random 48) - 24)
    $MinutesToMove = ((Get-Random 120) - 60)
    $TimeSpan = New-TimeSpan -Days $DaysToMove -Hours $HoursToMove -Minutes $MinutesToMove

    # Now we adjust the Date and Time by the new TimeSpan
    # Needs Admin rights to do this as well!

    Set-Date -Adjust $Timespan | Out-Null

    # Create that file
    Add-Content -Value $a -Path $FolderPath
    # Now we REVERSE the Timespan by the exact same amount
    $TimeSpan = New-TimeSpan -Days (-$DaysToMove) -Hours (-$HoursToMove) -Minutes (-$MinutesToMove)

    Set-Date -Adjust ($Timespan) | Out-Null

}