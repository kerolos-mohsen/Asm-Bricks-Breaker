.model small
.stack 100h

.DATA
    public username
    username db 20 dup('$')        ; Buffer for username with $ terminator
    prompt_msg db 'Enter username: $'
    max_length db 19              ; Maximum username length (leaving room for $)
    actual_length db 0            ; Track actual length of entered username

.code
public ENTER_USERNAME
ENTER_USERNAME PROC FAR
    ; Save registers
    push ax
    push bx
    push cx
    push dx
    
    ; Display prompt
    mov ah, 09h
    lea dx, prompt_msg
    int 21h
    
    ; Initialize variables
    mov cx, 0                      ; Character counter
    lea di, username              ; Point to username buffer
    
input_loop:
    ; Read character
    mov ah, 01h                   ; Read character with echo
    int 21h
    
    ; Check for Enter key
    cmp al, 13                    ; Compare with carriage return
    je input_done
    
    ; Check for backspace
    cmp al, 8                     ; Compare with backspace
    je handle_backspace
    
    ; Check if maximum length reached
    cmp cl, max_length
    je input_loop                 ; If max length reached, ignore new characters
    
    ; Store character and increment counter
    mov [di], al
    inc di
    inc cl
    jmp input_loop

handle_backspace:
    ; Check if there are characters to delete
    cmp cl, 0
    je input_loop                 ; If no characters, ignore backspace
    
    ; Move cursor back and clear character
    mov ah, 02h
    mov dl, 20h                   ; Space character
    int 21h
    
    mov ah, 02h
    mov dl, 8                     ; Move cursor back
    int 21h
    
    ; Update buffer and counter
    dec di
    dec cl
    mov byte ptr [di], '$'        ; Clear the character in buffer
    jmp input_loop

input_done:
    ; Store actual length
    mov actual_length, cl
    
    ; Ensure string is properly terminated
    mov byte ptr [di], '$'
    
    ; Add newline
    mov ah, 02h
    mov dl, 13                    ; Carriage return
    int 21h
    mov dl, 10                    ; Line feed
    int 21h
    
    ; Restore registers
    pop dx
    pop cx
    pop bx
    pop ax
    
    ret
ENTER_USERNAME ENDP

END