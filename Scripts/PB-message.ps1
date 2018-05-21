$pbapi = "PB-api-key"
$cred = New-Object System.Management.Automation.PSCredential ($pbapi,(ConvertTo-SecureString $pbapi -AsPlainText -Force))
 
$body = @{
  type = "note"
  title = "hey"
  body = "ho3"
  }
    
  Invoke-WebRequest -Uri "https://api.pushbullet.com/v2/pushes" -Credential $cred -Method Post -Body $body -ErrorAction SilentlyContinue

   
