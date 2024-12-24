.model small
.stack 100h
.data
    line        db '========================================$'
    welcome_msg db 13,10,'               WELCOME',13,10,'$'
    box_top     db '    +--------------------------------+',13,10,'$'
    box_side    db '    |$'
    box_bottom  db '    +--------------------------------+$'
    option1     db '        Press C to Enter Chat        $'
    option2     db '        Press P to Play Game         $'
    prompt      db 13,10,'          Your choice [C/P]: $'
    newline     db 13,10,'$'
    public choice
    choice db 0    ; Variable to store user's choice

.code


EXTRN CHECK_KEYBOARD:FAR
EXTRN CLEAR_WINDOW:FAR
EXTRN CHECK_SERIAL_MESSAGE:FAR
public menu
menu proc far
    ; Print first line
    mov ah, 09h
    lea dx, line
    int 21h
    
    ; Print welcome
    mov ah, 09h
    lea dx, welcome_msg
    int 21h
    
    ; Print second line
    mov ah, 09h
    lea dx, line
    int 21h
    
    ; Add spacing
    mov ah, 09h
    lea dx, newline
    int 21h
    int 21h
    
    ; Print box top
    mov ah, 09h
    lea dx, box_top
    int 21h
    
    ; Print first option
    mov ah, 09h
    lea dx, box_side
    int 21h
    mov ah, 09h
    lea dx, option1
    int 21h
    mov ah, 09h
    lea dx, box_side
    int 21h
    mov ah, 09h
    lea dx, newline
    int 21h
    
    ; Print second option
    mov ah, 09h
    lea dx, box_side
    int 21h
    mov ah, 09h
    lea dx, option2
    int 21h
    mov ah, 09h
    lea dx, box_side
    int 21h
    mov ah, 09h
    lea dx, newline
    int 21h
    
    ; Print box bottom
    mov ah, 09h
    lea dx, box_bottom
    int 21h
    
    ; Print prompt
    mov ah, 09h
    lea dx, prompt
    int 21h
wait_for_input:
    call CHECK_KEYBOARD        ; Check for local input
    call CHECK_SERIAL_MESSAGE  ; Check for remote input
    cmp choice, 0
    je wait_for_input         ; Keep waiting if no choice made
ret
menu endp
end 