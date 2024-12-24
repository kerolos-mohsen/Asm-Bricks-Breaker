.model small
.stack 100h

.DATA
    AUX_TIME DB 0
    public PLAYER_LIVES
    PLAYER_LIVES DB 10
.code
public DISPLAY_HEARTS
DISPLAY_HEARTS PROC FAR
    push ax
    push bx
    push cx
    push dx

    mov bx, 190        ; Base Y coordinate
    mov cx, 10         ; Starting X coordinate
    mov al, 4          ; Red color
    mov ah, PLAYER_LIVES

draw_heart_loop:
    push cx
    push ax
    
    ; Draw heart shape
    mov ah, 0Ch        ; Function for pixel drawing
    
    ; Center pixels
    mov dx, bx
    int 10h           ; Top center
    
    dec cx
    int 10h           ; Top left
    
    add cx, 2
    int 10h           ; Top right
    
    sub cx, 1
    inc dx
    int 10h           ; Middle
    
    dec cx
    int 10h           ; Middle left
    
    add cx, 2
    int 10h           ; Middle right
    
    sub cx, 1
    inc dx
    int 10h           ; Bottom
    
    pop ax
    pop cx
    add cx, 12        ; Space between hearts
    dec ah
    jnz draw_heart_loop
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
ENDP DISPLAY_HEARTS

public DELETE_HEARTS
DELETE_HEARTS PROC FAR
    push ax
    push bx
    push cx
    push dx

    mov bx, 190        ; Base Y coordinate
    mov cx, 10         ; Starting X coordinate
    mov al, 0          ; Red color
    mov ah, PLAYER_LIVES

DELETE_heart_loop:
    push cx
    push ax
    
    ; Draw heart shape
    mov ah, 0Ch        ; Function for pixel drawing
    
    ; Center pixels
    mov dx, bx
    int 10h           ; Top center
    
    dec cx
    int 10h           ; Top left
    
    add cx, 2
    int 10h           ; Top right
    
    sub cx, 1
    inc dx
    int 10h           ; Middle
    
    dec cx
    int 10h           ; Middle left
    
    add cx, 2
    int 10h           ; Middle right
    
    sub cx, 1
    inc dx
    int 10h           ; Bottom
    
    pop ax
    pop cx
    add cx, 12        ; Space between hearts
    dec ah
    jnz DELETE_heart_loop
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
ENDP DELETE_HEARTS
END