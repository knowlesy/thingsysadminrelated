function Get-MeetingPeople {
    param (
        [Parameter(Mandatory=$false)] $Speaker = "",
        [Parameter(Mandatory=$false)] $Note = ""
    )
    $people = "A","B","C"
    $randomhost = Get-Random $People
    if ($randomhost -eq $speaker)
    {
        #for testing do until
        #Write-Host "Host / host remove Both Match - ERROR" -ForegroundColor Red
        do{ 
            Remove-Variable $randomhost -ErrorAction SilentlyContinue
            $randomhost = Get-Random $People
            
        }
        until ($randomhost -ne $speaker)
    }
    Write-Host ("Host: " + $randomhost) -ForegroundColor Magenta
    $randomnote = Get-Random $People
    if (($randomnote -eq $randomhost) -or ($randomnote -eq $note))
    {
        #for testing do until
        #Write-Host "Both Match - ERROR" -ForegroundColor Red
        do{ 
            Remove-Variable $randomnote -ErrorAction SilentlyContinue
            $randomnote = Get-Random $People
            
        }
        until (($randomnote -ne $randomhost) -and ($randomnote -ne $note))
    }
    
    Write-Host ("Note Taker: " + $randomnote) -ForegroundColor Green
}




