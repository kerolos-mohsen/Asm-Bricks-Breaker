.MODEL small
.STACK 100h

.DATA
    waiting_msg db "Waiting for connection...$"
    connected_msg db "Connected! Chat session started.$"

.CODE
EXTRN IS_RECIEVER_FOUND:Byte
EXTRN ENTER_USERNAME:FAR
EXTRN username:Byte

PUBLIC ESTABLISH_CONNECTION
ESTABLISH_CONNECTION PROC NEAR
    ; Clear screen first
    mov ax, 0003h
    int 10h
    
    ; Position cursor at center of screen
    mov ah, 02h
    mov bh, 0
    mov dh, 12  ; Row
    mov dl, 25  ; Column
    int 10h
    
    ; Display waiting message
    mov ah, 09h
    mov dx, offset waiting_msg
    int 21h
    
    ; Main handshake loop
CHECK_CONNECTION:
    ; First, try to send our handshake
    mov dx, 3FDH      ; Line Status Register
    in al, dx
    test al, 00100000b  ; Can we transmit?
    jz CHECK_RECEIVE   ; If not, check for incoming
    
    ; Send handshake byte
    mov dx, 03F8H
    mov al, 55h       ; Handshake byte
    out dx, al
    
CHECK_RECEIVE:
    ; Check for received data
    mov dx, 3FDH
    in al, dx
    test al, 1        ; Is there data?
    jz CHECK_CONNECTION  ; If not, continue loop
    
    ; Read the received byte
    mov dx, 03F8H
    in al, dx
    
    ; Is it our handshake byte?
    cmp al, 55h
    jne CHECK_CONNECTION
    
    ; We received the handshake, send confirmation
    mov dx, 3FDH
WAIT_TO_SEND:
    in al, dx
    test al, 00100000b
    jz WAIT_TO_SEND
    
    mov dx, 03F8H
    mov al, 0AAh      ; Confirmation byte
    out dx, al
    
    ; Set connected flag and return
    mov IS_RECIEVER_FOUND, 1
    
    ; Clear screen and show connected message
    mov ax, 0003h
    int 10h
    
    mov ah, 02h
    mov bh, 0
    mov dh, 12
    mov dl, 25
    int 10h
    
    mov ah, 09h
    mov dx, offset connected_msg
    int 21h
    
    ; Small delay
    mov cx, 0FFFFh
DELAY_LOOP:
    loop DELAY_LOOP
    
    ret
ESTABLISH_CONNECTION ENDP

END