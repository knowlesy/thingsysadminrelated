;Sound
^+Left::SoundSet,-5
^+Right::SoundSet,+5
^+Up::SoundSet,+50
^+Down::SoundSet,Mute

;Open Command Promt 
#IfWinActive ahk_class CabinetWClass ; for use in explorer.
^+C::
ClipSaved := ClipboardAll
Send !d
Sleep 10
Send ^c
Run, cmd /K "cd `"%clipboard%`""
Clipboard := ClipSaved
ClipSaved =
return
#IfWinActive

;Open Powershell
^+P::
    Run, PowerShell
Return