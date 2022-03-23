#REF 
#https://www.petri.com/building-a-powershell-console-menu-revisited-part-1
#https://4sysops.com/archives/how-to-build-an-interactive-menu-with-powershell/
#https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_switch?view=powershell-6
#Testing switch commands in powershell 


$number = Read-Host "Enter a number 1-4 or A for all or Q for quit"
write-host ("Variable entered " + $number)
#if it matches a then run all of the switches
if ($number -eq "A")
{
    write-host ("if statement matches so Variable contains " + $number)
    Clear-Variable -Name number
    write-host ("Variable cleared currently it is " + $number)
    $number = 1,2,3,4
    write-host ("Variable updated now contains " + $number)

}

switch($number){
    1 {"One"}
    2 {"Two"}
    #below will stop looking after it is found break causes an end
    #3 {"Three" ; Break}
    3 {"Three"}
    4 {"Four"}
    3 {"Three Again"}
    1 {"One"}
    'q' {write-host "quitting"
        exit}
 }
