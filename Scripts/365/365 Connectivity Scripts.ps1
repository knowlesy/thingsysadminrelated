#365 connect
#https://docs.microsoft.com/en-us/office365/enterprise/powershell/connect-to-office-365-powershell
Connect-MsolService
#username password of the 365 site your wanting to connect to


#teams connect
Connect-MicrosoftTeams
#username password of the teams site your wanting to connect to


#sharepoint connect
#https://docs.microsoft.com/en-us/powershell/sharepoint/sharepoint-online/connect-sharepoint-online?view=sharepoint-ps
$adminUPN = "<the full email address of a SharePoint administrator account, example: jdoe@contosotoycompany.onmicrosoft.com>"
$orgName = "<name of your Office 365 organization, example: contosotoycompany>"
$userCredential = Get-Credential -UserName $adminUPN -Message "Type the password."
Connect-SPOService -Url https://$orgName-admin.sharepoint.com -Credential $userCredential


#Exchange
$UserCredential = Get-Credential
$ProxyOptions = New-PSSessionOption -ProxyAccessType ieconfig
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic –AllowRedirection –SessionOption $proxyOptions
Import-PSSession $Session –DisableNameChecking