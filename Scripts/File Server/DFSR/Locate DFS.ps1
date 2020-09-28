(Get-DfsnRoot -Domain $forest).Where( {$_.State -eq 'Online'} ) | Select-Object -ExpandProperty Path 
