#Ask users for storage report email address
$FileScreenHelpdeskEmail = Read-Host -Prompt 'Input your Helpdesk Email address for File Screen Template'
#Creates Email notification
$FileScreenEmailNotification = New-FsrmAction -Type Email -MailTo "[Admin Email];[Source Io Owner Email];$FileScreenHelpdeskEmail" -Subject “Unauthorized file. Possibile Virus please contact helpdesk immediatly” -Body “User [Source Io Owner] attempted to save [Source File Path] to [File Screen Path] on the [Server] server. This file is in the [Violated File Group] file group, which is not permitted on the server.” 
#Creates Event log notification
$FileScreenEventNotification = New-FsrmAction -Type Event -EventType Warning -Body "User [Source Io Owner] attempted to save [Source File Path] to [File Screen Path] on the [Server] server. This file is in the [Violated File Group] file group, which is not permitted on the server."
#Creates Default File Screen Template for Virus
New-FsrmFileScreenTemplate -Name "Block Virus FileTypes" -IncludeGroup @("Virus FileTypes") -Active -Notification $FileScreenEmailNotification,$FileScreenEventNotification
