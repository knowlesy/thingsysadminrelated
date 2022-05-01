function get-sysinternals {
    if (test-connection google.com -Quiet -Count 2) { 
        Write-Host Connected to outside world.......Downloading zero;
           (New-Object Net.WebClient).DownloadFile('https://download.sysinternals.com/files/PSTools.zip', 'C:\support\temp\sysinternals.zip')
           (new-object -com shell.application).namespace('C:\support\tools\').CopyHere((new-object -com shell.application).namespace('C:\support\temp\sysinternals.zip').Items(), 16)
    }
    else
    {write-host Not Downloading zero}
}


get-sysinternals

Remove-Item –path C:\support\temp -Include *.zip -Recurse