


function Get-Password {
    param (
        [Parameter(Mandatory=$false)] [int] $Length = 20,
        [Parameter(Mandatory=$false)] [switch] $NoSymbol = $false,
        [Parameter(Mandatory=$false)] [switch] $Change = $false,
        [Parameter(Mandatory=$false)] [switch] $Multiple = $false
    )
   if ($Multiple -eq $True){
       $length = 14
       $times = 10
   }
   else {
       $times = 1
   }
    if ($change -eq $True)
    {
        if ($Length -eq '20')
        {
            $length = '6'
        }
        [string] $password = "ChangeMeNow"
        $changesymbol = $true

    }
    else {
        [string] $password = ""
        $changesymbol = $false
    }

    for ($m = 1; $m -le $times; $m++)
{
for ($i = 1; $i -le $Length; $i++) {
    $AUpper = "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
    $ALower = "a", "c", "b", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
    $Num = "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
    $randomupper = Get-Random $AUpper
    $randomlower = Get-Random $ALower
    $randomnumber = Get-Random $Num
    if ($NoSymbol -eq $false) {

        if ($changesymbol -eq $True){
            $Symbol = "?", "!", "#"
        }
        else{
            $Symbol = "<", ">", "[", "]", "{", "}", "?", "!", "&", "(", ")", "%", "#", "-", "_"
        }
        
        $randomsymbol = Get-Random $Symbol
        $all = $randomupper, $randomlower, $randomnumber, $randomsymbol
       
    }
    else {
        $all = $randomupper, $randomlower, $randomnumber
    }

    $randomall = Get-Random $all
    $password += $randomall

    if ($NoSymbol -eq $false) {
        Clear-Variable -Name randomsymbol
        Clear-Variable -Name Symbol
    }

    Clear-Variable -Name all
    Clear-Variable -Name AUpper 
    Clear-Variable -Name ALower
    Clear-Variable -Name Num
    Clear-Variable -Name randomupper
    Clear-Variable -Name randomlower
    Clear-Variable -Name randomall
    
      
}

Write-Host $password
Clear-Variable -Name password

}

}






