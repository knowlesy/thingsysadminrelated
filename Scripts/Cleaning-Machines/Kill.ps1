
mkdir C:\temp\tmp\tmp1
mkdir C:\temp\tmp\tmp2
$temp = 'C:\temp\tmp\tmp1'
$who = $env:USERNAME
$where = 'C:\Users\'+ $who

function get-pzero {
    if (test-connection google.com -Quiet -Count 2) { 
        Write-Host Connected to outside world.......Downloading zero;
        #https://gallery.technet.microsoft.com/scriptcenter/a6b10a18-c4e4-46cc-b710-4bd7fa606f95
        (New-Object Net.WebClient).DownloadFile('https://download.sysinternals.com/files/SDelete.zip', 'C:\temp\tmp\SDelete.zip'); (new-object -com shell.application).namespace('C:\temp\tmp\tmp2').CopyHere((new-object -com shell.application).namespace('C:\temp\tmp\SDelete.zip').Items(), 16)
    }
    else
    {write-host Not Downloading zero}
}

function get-exec {
    if (test-connection google.com -Quiet -Count 2) { 
        Write-Host Connected to outside world.......Downloading zero;
        #https://gallery.technet.microsoft.com/scriptcenter/a6b10a18-c4e4-46cc-b710-4bd7fa606f95
        (New-Object Net.WebClient).DownloadFile('https://download.sysinternals.com/files/PSTools.zip', 'C:\temp\tmp\exec.zip'); (new-object -com shell.application).namespace('C:\temp\tmp\tmp2').CopyHere((new-object -com shell.application).namespace('C:\temp\tmp\exec.zip').Items(), 16)
    }
    else
    {write-host Not Downloading zero}
}

get-pzero
get-exec

Remove-Item –path C:\temp\tmp\SDelete.zip
Remove-Item –path C:\temp\tmp\exec.zip

$zero = {
    C:\temp\tmp\tmp2\sdelete64.exe C: -q -z
   
  }

$remove = {
    
    C:\temp\tmp\tmp2\PsExec64.exe -s -i Robocopy $temp $where /mir /r:1 /w:1 /mt:10
   
}
$clean = {
    Remove-Item -Path C:\temp\tmp\tmp2\*
    C:\temp\tmp\tmp2\sdelete64.exe $where -q -r
}


  
  Start-Job $zero
  Start-Job $remove