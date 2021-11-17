#ref
#https://github.com/HewlettPackard/PowerShell-ProLiant-SDK/tree/master/HPEiLO/2.2
#https://www.powershellgallery.com/packages/HPEiLOCmdlets/2.2.0.0

$ilo_static = "192.168.0.1"
$original_username = "username"
$original_password = "password"

#testing connection
Find-HPiLO $ilo_static -Verbose

#gettiong snmp
get-HPiLOSNMPIMSetting -Username $original_username -Password $original_password -Server $ilo_static 

#getting power connectionm
get-HPiLOHostPowerSaver -Username $original_username -Password $original_password -Server $ilo_static 

#get hostname for ilo
get-HPiLOServerName -Username $original_username -Password $original_password -Server $ilo_static 

#getting serial
$snilos = Get-HPiLOHostData -Server $ilo_static -Username $original_username -Password $original_password

#loop in the result and output the data.
foreach ($r in $snilos) {
    Write-Host "`nSMBIOS Serial Numbers for $($r.HOSTNAME) at $($r.IP):"
    $recnum=0
    foreach ($record in $r.SMBIOS_RECORD) {
        if ($record.FIELD) {
            foreach ($field in $record.FIELD) {
                if ($field.NAME -eq "Serial Number") {
                    Write-Host $("Record# " +  $recnum + ", " + "SMBIOS Record Type = " + $record.TYPE + ", " + $field.NAME + " = " + $field.VALUE)
                    #Write-Log $("Record# " +  $recnum + ", " + "SMBIOS Record Type = " + $record.TYPE + ", " + $field.NAME + " = " + $field.VALUE)
                
                }
            }
        }
        $recnum++
    }
}

#get ilo license
Get-HPiLOLicense -Username $original_username -Password $original_password -Server $ilo_static -Verbose 
