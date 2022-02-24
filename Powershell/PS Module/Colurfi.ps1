
function Get-textcolour {
    param (
        [Parameter(Mandatory = $false)] [string] $text = ""

    )
    $AUpper = "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
    $ALower = "a", "c", "b", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
    $Num = "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
    $chars = $text.ToCharArray()
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
}
