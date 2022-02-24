function Get-Password {
    param (
        [Parameter(Mandatory = $false)] [int] $Length = 20,
        [Parameter(Mandatory = $false)] [switch] $NoSymbol = $false,
        [Parameter(Mandatory = $false)] [switch] $Change = $false,
        [Parameter(Mandatory = $false)] [int]$times = 1,
        [Parameter(Mandatory = $false)] [switch] $Multiple = $false
    )
    #sets how many passwords and length 
    if ($Multiple -eq $True) {
        Write-Host "Multiple was selected, times and length WILL be overided" -ForegroundColor Red
        Write-Host ""
        $length = 14
        $times = 10
    }
    #if false only outputs 1 

    #if change is set goes lets you set an easier password for the user aka password reset 
    if ($change -eq $True) {
        #reduces lenth 
        if ($Length -eq '20') {
            $length = '6'
        }
        #inputs a default string 
        [string] $password = "ChangeMeNow"
        #sets symbol 
        $changesymbol = $true

    }
    else {
        #if the flag isnt true dont make an easy password 
        [string] $password = ""
        $changesymbol = $false
    }
    #for X times passwords 
    for ($m = 1; $m -le $times; $m++) {
        #sets length of passwords 
        for ($i = 1; $i -le $Length; $i++) {
            #char sets 
            $AUpper = "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
            $ALower = "a", "c", "b", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
            $Num = "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
            #gets random of each char array 
            $randomupper = Get-Random $AUpper
            $randomlower = Get-Random $ALower
            $randomnumber = Get-Random $Num
            #wether to get a random of the symbol array subject to flag used 
            if ($NoSymbol -eq $false) {
                #complex or password reset 
                if ($changesymbol -eq $True) {
                    $Symbol = '?', '!', '#'
                }
                else {
                    $Symbol = '<', '>', '[', ']', '{', '}', '?', '!', '&', '(', ')', '%', '#', '-', '_'
                }
                #gets random of symbol 
                $randomsymbol = Get-Random $Symbol
                #creates a new array called all 
                $all = $randomupper, $randomlower, $randomnumber, $randomsymbol
       
            }
            else {
                #no symbol random array 
                $all = $randomupper, $randomlower, $randomnumber
            }
            #gets random out of the array 
            $randomall = Get-Random $all
            #appends or writes line per char from the length 
            $password += $randomall

            if ($NoSymbol -eq $false) {
                Clear-Variable -Name randomsymbol
                
            }
            #clears variables 
            Clear-Variable -Name all
            Clear-Variable -Name randomall
    
        }
        
        #Write-Host $password
        #turns password variable into a char array 

        $chars = $password.ToCharArray()
        #cycling through each of the chars in the array 
        foreach ($char in $chars) {
            #sets exit ppoint of the for 

            #uppercase
            foreach ($au in $AUpper) {
                if ($char -ceq $au) {
                    write-host $char -ForegroundColor DarkGreen -NoNewline
 
                }
            }
            #lowercase

            foreach ($al in $ALower) {
                if ($char -ceq $al) {
                    write-host $char -ForegroundColor Yellow -NoNewline

                }
            }

            #num

            foreach ($n in $Num) {
                if ($char -eq $n) {
                    write-host $char -ForegroundColor Magenta -NoNewline

                }
            }

            #symbol

            foreach ($sym in $Symbol) {

                if ($char -eq $sym) {
                    write-host $char -ForegroundColor Blue -NoNewline
                        
                }
            }

        }
        write-host ""

        Clear-Variable -Name password
        Clear-Variable -Name AUpper -ErrorAction SilentlyContinue
        Clear-Variable -Name ALower -ErrorAction SilentlyContinue
        Clear-Variable -Name Num -ErrorAction SilentlyContinue
        Clear-Variable -Name randomupper -ErrorAction SilentlyContinue
        Clear-Variable -Name randomlower -ErrorAction SilentlyContinue
        Clear-Variable -Name Symbol -ErrorAction SilentlyContinue
    }

}

