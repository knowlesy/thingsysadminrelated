$path = "C:\"
$Exclude = @("DfsrPrivate", "$recycle.bin") #To be added 
$loglocation = "C:\Logs\Share-255CharPlus.log" 
$errorloglocation = "C:\LogsShare-255CharPlus-Error.log"

foreach ($item in $path)
{

        Get-ChildItem $item -file -recurse -ErrorAction SilentlyContinue | where {$_.name.length -gt 200} |Select Directory,@{Name="Owner";Expression={ (Get-Acl $_.FullName).Owner }},@{Name="FullLength";Expression={$_.Fullname.length}},Name | Format-Table -Wrap -AutoSize | write-output >> $loglocation
        Write-output "$($Error[0])" >> $errorloglocation

}
