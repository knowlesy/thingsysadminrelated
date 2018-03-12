#Create Directory
$Directory = "C:\VMWARE\$((Get-Date).ToString('yyyy-MM-dd'))"
New-Item -ItemType Directory -Path $Directory
#Set Directory Location

Set-PowerCLIConfiguration -InvalidCertificateAction ignore -confirm:$false
#Connect to VSphere
Connect-VIServer -Server <vcenter-server> -User <username> -Password <password>

#$Hosts = Get-VMHost | where-object { $_.State -eq "Connected"} | select name |Out-String 
$Hosts = "<host>"
$myCol = @()
 ForEach ($vmhost in $Hosts)
        {
         #write $vmhost 
         Get-VMHostFirmware -VMHost $vmhost -BackupConfiguration -DestinationPath $Directory
         $ConfigFileTest="$Directory\configBundle-$vmhost.tgz"
         If (Test-Path $ConfigFileTest)
            {
            # // Backup File exists
            Write-Output "$vmhost successfully backed up configuration" | Out-File $Directory\Log.Log -Append
            } 
         Else
            {
            # // File does not exist
            Write-Output "$vmhost failed to back up configuration"  | Out-File $Directory\Log.Log -Append
            }
        }
$myCol #| out-gridview
