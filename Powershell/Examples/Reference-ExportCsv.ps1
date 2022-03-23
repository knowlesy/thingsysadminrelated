#testing exporting to CSV via hash table style

#imports list of comp names
$computers = Get-Content 'C:\temp\hostname-list.txt'
#export destination
$report = 'C:\temp\computer-running-services.csv'

#runs through a for each for the list to perfom a function
foreach ($computer in $computers) {

    #confirms computer name
    $computerinfo = Get-WmiObject -ComputerName $computer Win32_Computersystem
    #looks for dhcp service
    $services = Get-service -ComputerName $computer | Where-Object { $_.Name -eq 'Dhcp' } | Select-Object Name, Status

    #Custom object under a variable the hash table that isnt a hash table or is it ?
    $csvoutput = @(
        [PSCustomObject]@{
            #column name then variable
            ComputerName  = $computerinfo.Name
            ServicesName  = $services.Name
            ServiceStatus = $services.Status
        }
    )
    #exporting the custom object / variable for this to a csv it will loop through due to the for each
    $csvoutput | Export-Csv $report -Append -Force

}

#thats it
