$Csize = Get-Volume -DriveLetter C | select sizeremaining | FT -HideTableHeaders | Out-String
$GB = $Csize/1073741824 # bytes to GB

if ($GB -gt 10) {
     write-output "ERROR: Not enough Space on C:"
     $host.SetShouldExit(111111111)
}
else
{
    Write-Output "READY FOR UPGRADE: $([math]::Round($GB))GB Free space"  # rounds to GB will round up
}
