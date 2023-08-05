$location = "d:\temp\"
$i = 0
$files = Get-ChildItem -Path $location -Recurse
foreach ($file in $files)
{
    $ext = Get-ItemProperty $file -Name extension | Select-Object -ExpandProperty Extension
    Rename-Item $file -NewName $i$ext -ErrorAction Stop
    Write-Host $i
    $i++
    
}