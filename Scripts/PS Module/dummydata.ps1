function Start-FakeData {

       param(

        [Parameter(Mandatory=$true)][string]$FolderPath,
        [Parameter(Mandatory=$false)] $files = 10,
        [Parameter(Mandatory=$false)] $years = -5,
        [Parameter(Mandatory=$false)] $newdate = (Get-Date).addyears($years)

    )
    
    for ($m = 1; $m -le $files; $m++)
    {
        $random = (Get-Random 100000).tostring()
        $filename = ('TEST-Logfile' + $random + '.log')
        New-Item -Path ($FolderPath + '\' + $filename) -ItemType File
    }

    $modifyfiles = Get-ChildItem $FolderPath -force | Where-Object {! $_.PSIsContainer}
foreach($object in $modifyfiles)
{
$object.CreationTime=($newdate)

$object.LastAccessTime=($newdate)

$object.LastWritetime=($newdate)

}
Get-ChildItem $FolderPath -force | Select-Object Mode, Name, CreationTime, LastAccessTime, LastWriteTime | ft

}