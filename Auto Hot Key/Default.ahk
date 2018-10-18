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


;Paste Text Only
^+v::                            ; Text–only paste from ClipBoard
   Clip0 = %ClipBoardAll%
   ClipBoard = %ClipBoard%       ; Convert to text
   Send ^v                       ; For best compatibility: SendPlay
   Sleep 50                      ; Don't change clipboard while it is pasted! (Sleep > 0)
   ClipBoard = %Clip0%           ; Restore original ClipBoard
   VarSetCapacity(Clip0, 0)      ; Free memory
Return

