
mkdir C:\temp\tmp\tmp1
mkdir C:\temp\tmp\tmp2


$final = 'C:\temp\tmp\tmp2'
$temp = 'C:\temp\tmp\tmp1'
#$who = $env:USERNAME
#$where = 'C:\Users\'+ $who
$where = 'C:\Temp\Test'


function get-pzero {
    if (test-connection google.com -Quiet -Count 2) { 
        Write-Host Connected to outside world.......Downloading zero;
        (New-Object Net.WebClient).DownloadFile('https://download.sysinternals.com/files/SDelete.zip', 'C:\temp\tmp\temp1.zip'); (new-object -com shell.application).namespace('C:\temp\tmp\tmp2').CopyHere((new-object -com shell.application).namespace('C:\temp\tmp\temp1.zip').Items(), 16)
        (New-Object Net.WebClient).DownloadFile('https://download.sysinternals.com/files/PSTools.zip', 'C:\temp\tmp\temp2.zip'); (new-object -com shell.application).namespace('C:\temp\tmp\tmp2').CopyHere((new-object -com shell.application).namespace('C:\temp\tmp\temp2.zip').Items(), 16)
    }
    else
    {write-host Not Downloading zero}
}


get-pzero


Remove-Item –path C:\temp\tmp -Include *.zip -Recurse


$zero = {
    wevtutil el | Foreach-Object {wevtutil cl “$_”}
    C:\temp\tmp\tmp2\sdelete64.exe -q -s $where
    C:\temp\tmp\tmp2\sdelete64.exe -q -s C:\Support
    C:\temp\tmp\tmp2\PsExec64.exe -s Robocopy $temp $where /mir /r:1 /w:1 /mt:10

     }


$clean = {
    C:\temp\tmp\tmp2\sdelete64.exe -z -q -c -p 3 c:
    Robocopy $final $temp /mir /r:1 /w:1 /mt:10 
    Remove-Item –path C:\Support -Recurse
    wevtutil el | Foreach-Object {wevtutil cl “$_”}
}


  
  Start-Job $zero


  wait-job -name zero -timeout 300

  start-job $clean