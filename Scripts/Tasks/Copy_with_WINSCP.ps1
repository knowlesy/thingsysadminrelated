Get-ChildItem -Path '<LOCATION>' -Recurse | select name | Out-File c:\temp\list.txt -Encoding ASCII -Width 50

# Load WinSCP .NET assembly
Add-Type -Path "C:\Program Files (x86)\WinSCP\WinSCPnet.dll"

# Set up session options
$sessionOptions = New-Object WinSCP.SessionOptions -Property @{
    Protocol = [WinSCP.Protocol]::Scp
    HostName = "COPYTOSERVER"
    UserName = "username"
    Password = "password"
    SshHostKeyFingerprint = "ssh-rsa 2048 J0ziOAafz+FXeQJfgKt2KR9QRRGGU/HpRFe2A5bsZKw="
}

$session = New-Object WinSCP.Session

try
{
    # Connect
    $session.Open($sessionOptions)

    # Transfer files
    $session.PutFiles("C:\Temp\list.txt", "/tmp/*").Check()
}
finally
{
    $session.Dispose()
}
