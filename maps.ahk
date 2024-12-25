#Persistent
SetTitleMatchMode, 2  ; Match partial window titles

; Define the DOSBox windows
p1_window := "P1 - 3000 cycles/ms"
p2_window := "P2 - 3000 cycles/ms"

; Player 1 controls
,::
    ControlSend,, {Left}, %p1_window%
return

.::
    ControlSend,, {Right}, %p1_window%
return

; Player 2 controls
a::
    ControlSend,, a, %p2_window%
return

d::
    ControlSend,, d, %p2_window%
return

; Exit the script with Ctrl+Q
^q::
    ExitApp
