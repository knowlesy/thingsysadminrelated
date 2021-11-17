#testing
#$paths = "C:\temp\"
#$age = (Get-Date).AddHours(-6)


#actual usage
$paths = Get-Content "c:\temp\paths.txt"
$age = (Get-Date).AddYears(-6)
$log = "c:\temp\oldfiles.log"

$OutputPath = "C:\temp\filesfound.csv"
foreach ($path in $paths) {
    Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.CreationTime -lt $age } | Select-Object Name, Directory, Length, CreationTime, Extension, FullName | ForEach-Object {
        $_size = $_ | Select-Object @{Name = "Length"; Expression = { $_.Length / 1MB } }
        $count = ($_.fullname).Length
        if ($count -gt 255) {
            Write-Host ('ERROR: Path Length ' + $count + " File " + $_.Directory)  -ForegroundColor Red
            Write-Output ('ERROR: Path Length ' + $count + " File " + $_.Directory) >> $log
            $csvoutput = @(
                [pscustomobject]@{
                    Filename           = $_.name

                    File_Location      = $_.Directory

                    Above_Char_limit   = "Yes"

                    File_Path_Length   = $count

                    File_Size_MB       = $_size.Length

                    File_Created       = $_.CreationTime
            
                    File_Last_Accessed = $_.LastAccessTime

                    File_Ext           = $_.Extension

                })
        
        }
        else {
            Write-Host ('FOUND: ' + $_.fullname) -ForegroundColor Yellow
            $csvoutput = @(
                [pscustomobject]@{
                    Filename           = $_.Name

                    File_Location      = $_.FullName

                    Above_Char_limit   = "No"

                    File_Path_Length   = $count

                    File_Size_MB       = $_size.Length

                    File_Created       = $_.CreationTime
            
                    File_Last_Accessed = $_.LastAccessTime

                    File_Ext           = $_.Extension

                })
        
        }
    
        $csvoutput | Export-Csv $OutputPath -Append -Force
       
    }
}
