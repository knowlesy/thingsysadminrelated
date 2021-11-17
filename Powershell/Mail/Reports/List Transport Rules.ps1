Get-TransportRule | select name,state,mode,description | export-csv c:\temp\mailflowrulesdiscovery.csv -NoClobber -NoTypeInformation
