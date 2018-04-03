$Dir = get-childitem D:\Test -recurse
$dir2 = "D:\Test"
# $Dir |get-member
$List = $Dir | where {$_.extension -eq ".txt"} 
$List | format-table name | ft -hidetableheaders
foreach ($item in $List)
{
 $location = "$dir2\$item"
 Remove-item $location -Force -ErrorAction SilentlyContinue 
}
