
.MODEL small
.STACK 100h
.data
.code

; Try sending a character
PUBLIC  SEND_SERIAL_CHARACTER
SEND_SERIAL_CHARACTER PROC  FAR
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


PUBLIC SPLIT_SCREEN
SPLIT_SCREEN PROC NEAR

	; Move cursor to CX=0, DX= 13
	mov dh, 12 ; Row
	mov dl, 0 ; Col
	mov bh, 0
	mov ah, 2
	int 10h
	
	 
	; horizontal line drawing
	mov bx, 00007h    ;
	mov al, 196    ; ASCII character for thin horizontal line (-)
	mov cx, 80      ; Number of times to write (thinner line)
	mov AH , 09h
	int 10h        ; Draw each character
	

	; Return cursor back to CX=0, DX= 00
	mov dh, 0 ; Row
	mov dl, 0 ; Col
	mov bh, 0
	mov ah, 2
	int 10h
	RET
SPLIT_SCREEN ENDP

END