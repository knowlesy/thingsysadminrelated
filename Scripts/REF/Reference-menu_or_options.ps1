#REF 
#https://www.petri.com/building-a-powershell-console-menu-revisited-part-1
#https://4sysops.com/archives/how-to-build-an-interactive-menu-with-powershell/
#Testing switch commands in powershell 


$number = Read-Host "Enter a number 1-4 or A for all"
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
    3 {"Three"}
    4 {"Four"}
    3 {"Three Again"}
 }
