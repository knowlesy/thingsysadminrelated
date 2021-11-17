    $test = "Abc1!"
    $AUpper = "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
    $ALower = "a", "c", "b", "d", "e", "f", "g", "h", "i", "j", "k", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
    $Num = "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
    $test2 = $test.toarray()

function Write-ColorOutput($ForegroundColor)
{
        # save the current color
        $fc = $host.UI.RawUI.ForegroundColor

        # set the new color
        $host.UI.RawUI.ForegroundColor = $ForegroundColor

        # output
        if ($args) {
                Write-Output $args
        }
        else {
                $input | Write-Output
        }

        # restore the original color
        $host.UI.RawUI.ForegroundColor = $fc
    }


    foreach ($char in $test2)
    {
        if ($AUpper.Contains($char))
        {
            Write-Host $char -NoNewline | Write-ColorOutput red
        }
    }