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
    choice db 1    ; Variable to store user's choice

.code
public menu
menu proc far
    
    ; Clear screen
    mov ax, 0003h
    int 10h
    
menu_loop:
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
    
    ; Get input
get_input:
    mov ah, 01h
    int 21h
    
    ; Convert to uppercase
    cmp al, 'a'
    jb check_input
    cmp al, 'z'
    ja check_input
    sub al, 32
    
check_input:
    cmp al, 'C'
    je chat_selected
    cmp al, 'P'
    je game_selected
    
    ; If invalid, clear screen and loop
    mov ax, 0003h
    int 10h
    jmp menu_loop
    
chat_selected:
    mov [choice], 1
    jmp exit_menu
    
game_selected:
    mov [choice], 2
    
exit_menu:
    ; Clear screen before exiting
    mov ax, 0003h
    int 10h
    
ret
menu endp
end 