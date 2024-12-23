
.MODEL small
.STACK 100h
.data
.code

; Try sending a character
PUBLIC  SEND_SERIAL_CHARACTER
SEND_SERIAL_CHARACTER PROC  FAR
    ; Prepare character display
    mov ah, 09h
    mov cx, 1
    mov bx, 00001001b
    int 10h
    
    ; Wait until serial port is ready to transmit
    mov dx, 03F8H
    out dx, al
    
    ; Wait until character is fully sent
    CALL WAIT_TILL_SEND
    RET
SEND_SERIAL_CHARACTER ENDP


; Wait until serial transmitter is ready
WAIT_TILL_SEND PROC
    tryAgain:
    ; Check Transmitter Holding Register status
    mov dx, 3FDH       ; Line Status Register
    In al, dx          ; Read Line Status
    AND al, 00100000b
    JZ tryAgain  ; Wait if not empty
    RET
WAIT_TILL_SEND ENDP


END