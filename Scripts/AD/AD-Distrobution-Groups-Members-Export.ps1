$Groups = Get-ADGroup -Filter 'groupcategory -eq "distribution"'
ForEach ($Group In $Groups) 
{
    "Group: " + $Group.Name
    $groupname = $Group.Name
    #Appends all groups and their users to one file 
    $groupmail = Get-ADGroup -Identity $group -properties mail| ForEach-Object {$_.mail}
    Get-ADGroupMember -Identity $Group -Recursive | Get-ADUser |select-object samaccountname, enabled, name, UserPrincipalName, @{n = "Group"; e = {"$groupname"}}, @{n = "Group Email"; e = {"$groupmail"}} | Export-Csv -Path c:\temp\group.csv -Append 

}