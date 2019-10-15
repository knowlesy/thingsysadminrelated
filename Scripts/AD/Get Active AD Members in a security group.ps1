#list of groups could be pulled from ad / text file or stated as per below 
$groups = 'Group 1','Group 2','Group 3'
#output location
$output = 'c:\temp\ADGroupMember.txt'
#imp[orts ad module to call ps commands in ad
Import-Module ActiveDirectory
#performs a fopr each item in the list of groups
foreach ($group in $groups) {
    #output group to text file
    Write-Output $group >> $output
    #outpout group to host
    Write-Host $group -ForegroundColor Yellow
    #exports users direct to list and text file old code
    #Get-ADGroupMember -Identity $group | Select-Object Name | Format-List >> $output

    #gets list of users in ad group
    $membersofthegroup = Get-ADGroupMember -Identity $group | Select-Object samaccountname,name

    #goes through each member in the list
    foreach ($member in $membersofthegroup) {
        #looks up user in ad
        $IsUserEnabled = Get-ADUser $member.samaccountname -Properties * | Select-Object Name,Enabled
        #if based on there enabled 
        if ($IsUserEnabled.enabled -eq $true) {
            #output to host user is enabled
            write-host ($member.Name + " is active") -ForegroundColor Green
            #output to text file user is enabled
            Write-Output ("Name: " + $member.Name) >> $output
            
        }
        else {
             #states user in group isnt enabled and wont be outputted 
            write-host ("The user " + $member.Name + " in group " + $group + "Is not enabled and will not be listed in the exported members of groups" ) -ForegroundColor Red
        }
    }
    #spaciong for formatting 
    Write-Output " " >> $output
    Write-Output " " >> $output
}
