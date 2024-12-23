.MODEL small
.STACK 100h
.data
sender_cursor_row db 0
sender_cursor_col db 0
.code

;;;;;;;;;		Extrns		;;;;;;;;;

EXTRN CHECK_SERIAL_MESSAGE:FAR
EXTRN SEND_SERIAL_CHARACTER:FAR
EXTRN MOVE_CURSOR:FAR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;		Main		;;;;;;;;;
Main PROC
    mov ax, @data
    mov ds, ax

    CALL INIT_SERIAL
    CALL CLEAR_WINDOW
    CALL SPLIT_SCREEN

MAIN_LOOP:
    CALL CHECK_KEYBOARD


	; Get current cursor position to return back to
    mov ah, 03h
    int 10h
    mov sender_cursor_row,  dh ; Use tracked row
    mov sender_cursor_col,  dl ; Use tracked column
    
	; Check for incoming serial message
    CALL CHECK_SERIAL_MESSAGE
    
	mov dh, sender_cursor_row  ; Use tracked row
    mov dl, sender_cursor_col  ; Use tracked column
    mov bh, 0
    mov ah, 2
    int 10h
    ; Continue loop
    JMP MAIN_LOOP

EXIT_PROGRAM:
	CALL CLEAR_WINDOW
    mov ah, 4Ch
    int 21h
Main ENDP

;;;;;;;;;		END MAIN		;;;;;;;;;


CHECK_KEYBOARD PROC
    ; Check for keystroke without waiting
    mov ah, 01h
    INT 16h
    JZ KEYBOARD_CHECK_DONE  ; No key pressed, return
    
	; Read key from buffer
    mov ah, 0h
    INT 16h
    
    ; Check for ESC key to exit
    CMP al, 27
    JZ EXIT_PROGRAM
    
    ; Send character to serial port
    CALL SEND_SERIAL_CHARACTER
    
    ; Move cursor after sending
    CALL MOVE_CURSOR

KEYBOARD_CHECK_DONE:
    RET
CHECK_KEYBOARD ENDP

CLEAR_WINDOW PROC NEAR
	mov al, 03h
	mov ah, 0
	int 10h
	RET
CLEAR_WINDOW ENDP

INIT_SERIAL PROC NEAR
	; initinalize COM
	
	;Set Divisor Latch Access Bit
	mov dx,3fbh 			; Line Control Register
	mov al,10000000b		;Set Divisor Latch Access Bit
	out dx,al				;Out it
	;Set LSB byte of the Baud Rate Divisor Latch register.
	mov dx,3f8h			
	mov al,0ch			
	out dx,al

	;Set MSB byte of the Baud Rate Divisor Latch register.
	mov dx,3f9h
	mov al,00h
	out dx,al

	;Set port configuration
	mov dx,3fbh
	mov al,00011011b
	out dx,al
	RET
INIT_SERIAL ENDP 


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