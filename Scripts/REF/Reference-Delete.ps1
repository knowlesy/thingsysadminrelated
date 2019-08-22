$Daysback = '-1'
$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddDays($Daysback)

Get-ChildItem $destinationRoot -Recurse -Force -File -PipelineVariable File | % {
    try {
        Remove-Item -Path $File.fullname -Force -Confirm:$false -ErrorAction Stop | Where-Object { $_.LastWriteTime -lt $DatetoDelete }
        "Deleted file: $($File.fullname)" | Out-File $servicelog -Append
    }
    catch {
        "Failed to delete file: $($File.fullname)" | Out-File $servicelog -Append
    }
}
