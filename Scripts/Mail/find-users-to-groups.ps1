#$included-domains = "domain.com", "domain.co.za", "domain.co.uk"

#gets a list of user@domain
$useremails = get-content "C:\temp\useremail.txt"


#for every line in list
foreach ($user in $useremails) 
{
   #setting variable 
    $userinlist = Get-ChildItem C:\temp\MailLists -I *.txt -R | Select-String  $user

    #if user 
    if ($userinlist) {
        $user | out-File -FilePath "C:\temp\user-distrobution.txt" -Append
        Get-ChildItem C:\temp\MailLists -I *.txt -R | Select-String  $user | out-File -FilePath "C:\temp\user-distrobution.txt" -Append
    }

    
}