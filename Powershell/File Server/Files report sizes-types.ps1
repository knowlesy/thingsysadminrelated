$path = "C:\Temp"
$fileTypes = Get-Childitem $path -Recurse | Select-Object Extension -Unique
$dir200 = Get-Childitem $path -Recurse | select-object fullname
$totalpathSize = Get-ChildItem $path -recurse | Measure-Object -property length -sum
$totalPathSizeGB = "{0:N3} GB" -f (($totalpathSize).sum / 1Gb)
Write-Host "Directory Size is $totalPathSizeGB"
write-host "Extensions in  $path"
foreach ($fileType in $fileTypes) {
    $countType = Get-Childitem $path -Recurse | Where-Object {$_.Extension -eq $fileType.Extension} | Select-Object name,fullname,Length
    $totalofFT = ($countType.name | Measure-Object).Count
    $totalFT = Get-Childitem $path -Recurse | Where-Object {$_.Extension -eq $fileType.Extension} | Select-Object Length | Measure-Object -property length -sum
    $totalFTSizeGB = "{0:N2} GB" -f (($totalFT).sum / 1Gb)
    $totalFTSizeMB = "{0:N2} MB" -f (($totalFT).sum / 1Mb)
    if ($null -eq $fileType.Extension) {
        $fileType = "<BLANK>"
    }
    $FToutput = ($fileType.Extension + ' ,count: ' + $totalofFT + ' ,size(GB): ' + $totalFTSizeGB + ' ,size(MB): ' + $totalFTSizeMB)
    Write-Host $FToutput
}
Write-Host "Sub Folders and Sizes"
$subFolders = Get-ChildItem -Path $path -Recurse -Directory -Force -ErrorAction SilentlyContinue | Select-Object FullName,Length
foreach ($subfolder in $subFolders.fullname) {
    $totalSubFolder = Get-Childitem $subfolder -Recurse | Select-Object Length | Measure-Object -property length -sum
    $totalSFSizeGB = "{0:N2} GB" -f (($totalSubFolder).sum / 1Gb)
    $totalSFSizeMB = "{0:N2} MB" -f (($totalSubFolder).sum / 1Mb)
    $SFoutput = ($subfolder + ' ,size(GB): ' + $totalSFSizeGB + ' ,size(MB): ' + $totalSFSizeMB)
    Write-Host $SFoutput
}
write-host "Checking 200+ charcter limit"
foreach ($item in $dir200)
{

        $200 = Get-ChildItem -file $item.FullName -recurse -ErrorAction SilentlyContinue | Where-Object {$_.name.length -gt 200} | Select-Object fullname #|Select-Object Directory,@{Name="Owner";Expression={ (Get-Acl $_.FullName).Owner }},@{Name="FullLength";Expression={$_.Fullname.length}},Name | Format-Table -Wrap -AutoSize |
        Write-Output $200
        

}
