.model small
.stack 100h

.DATA
    AUX_TIME DB 0
    public P1_SCORE
    P1_SCORE DB 0     ; Player 1 score
    public P2_SCORE
    P2_SCORE DB 0     ; Player 2 score
    P1_MSG DB 'P1:$'  ; Player 1 label
    P2_MSG DB 'P2:$'  ; Player 2 label
    T_MSG  DB 'T:$'   ; Total label
    
.code

public DisplayScores
DisplayScores PROC FAR
    push ax
    push bx
    push cx
    push dx

    ; Set bottom right starting position for all scores
    mov ah, 02h    ; Set cursor position
    mov bh, 0      ; Page number
    mov dh, 24     ; Bottom row
    mov dl, 65     ; Far right position for first score
    int 10h

    ; Display P1 label
    mov ah, 09h    
    lea dx, P1_MSG
    int 21h
    
    ; Display P1 score
    xor ax, ax
    mov al, P1_SCORE
    mov bl, 10
    div bl          ; AL = quotient (tens), AH = remainder (ones)
    
    ; Only display tens digit if it's not zero
    cmp al, 0
    je skip_p1_tens
    mov dl, al     
    add dl, 30h
    mov ah, 02h
    int 21h
skip_p1_tens:
    mov dl, ah     ; Display ones digit
    add dl, 30h
    mov ah, 02h
    int 21h

    ; Move cursor for P2
    mov ah, 02h
    mov dl, 70     
    mov dh, 24     
    int 10h

    ; Display P2 label
    mov ah, 09h
    lea dx, P2_MSG
    int 21h
    
    ; Display P2 score
    xor ax, ax
    mov al, P2_SCORE
    mov bl, 10
    div bl         
    
    ; Only display tens digit if it's not zero
    cmp al, 0
    je skip_p2_tens
    mov dl, al     
    add dl, 30h
    mov ah, 02h
    int 21h
skip_p2_tens:
    mov dl, ah     ; Display ones digit
    add dl, 30h
    mov ah, 02h
    int 21h

    ; Move cursor for total
    mov ah, 02h
    mov dl, 75     
    mov dh, 24     
    int 10h

    ; Display total label
    mov ah, 09h
    lea dx, T_MSG
    int 21h
    
    ; Calculate and display total
    xor ax, ax
    mov al, P1_SCORE
    add al, P2_SCORE
    mov bl, 10
    div bl         
    
    ; Only display tens digit if it's not zero
    cmp al, 0
    je skip_total_tens
    mov bl , ah
    mov dl, al     
    add dl, 30h
    mov ah, 02h
    int 21h
    mov ah , bl
skip_total_tens:
    mov dl, ah     ; Display ones digit
    add dl, 30h
    mov ah, 02h
    int 21h

    pop dx
    pop cx
    pop bx
    pop ax
    ret
DisplayScores ENDP

public DELETE_SCORE
DELETE_SCORE PROC FAR
    push ax
    push bx
    push cx
    push dx

    ; Clear the bottom right area where scores are displayed
    mov ah, 02h    
    mov bh, 0      
    mov dh, 24     
    mov dl, 65     
    int 10h

    mov cx, 20     
    mov ah, 02h    
    mov dl, ' '    

clear_loop:
    int 21h
    loop clear_loop

    pop dx
    pop cx
    pop bx
    pop ax
    ret
DELETE_SCORE ENDP
END