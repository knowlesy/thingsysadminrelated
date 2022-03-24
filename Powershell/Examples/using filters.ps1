
get-aduser -Properties * -filter {Displayname -like '<DISPLAYNAME>'} | Select-Object displayname,samaccountname,DistinguishedName,mail 



