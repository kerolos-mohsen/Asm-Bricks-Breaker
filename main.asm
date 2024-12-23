.model small
.stack 100h

.DATA
    AUX_TIME DB 0
    sender_cursor_row db 0
    sender_cursor_col db 0
    public IS_RECIEVER_FOUND
    IS_RECIEVER_FOUND db 0
    public IS_INGAME
    IS_INGAME db 0
    public CRT_PLAYER
    CRT_PLAYER db 0
.code

;;;;;;;;;		Extrns		;;;;;;;;;


EXTRN DRAWBLOCKS:FAR
EXTRN DRAW_BALL:FAR
EXTRN MOVE_BALL_BY_VELOCITY:FAR
EXTRN DELETE_BALL:FAR
EXTRN move_paddles:FAR
EXTRN draw_paddles:FAR
EXTRN CHECK_SCREEN_PIXELS:FAR
EXTRN DISPLAY_WIN_MESSAGE:FAR
EXTRN RESET_PADDLES:FAR
EXTRN DISPLAY_LOOSE_MESSAGE:FAR
EXTRN DISPLAY_HEARTS:FAR
EXTRN DELETE_HEARTS:FAR
EXTRN PLAYER_LIVES:Byte
EXTRN CHECK_SERIAL_MESSAGE:FAR
EXTRN SEND_SERIAL_CHARACTER:FAR
EXTRN ENTER_USERNAME:FAR
EXTRN paddle_one_x:word
EXTRN paddle_one_y:word
EXTRN paddle_two_x:word
EXTRN paddle_two_y:word
EXTRN MOVE_CURSOR:FAR
EXTRN read_pad_pos:FAR
EXTRN send_pad_pos:FAR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    CALL INIT_SERIAL
    CALL CLEAR_WINDOW
    CALL ENTER_USERNAME
    CALL CLEAR_WINDOW
    CALL SPLIT_SCREEN
    
    ; Add handshake routine
    ; CALL ESTABLISH_CONNECTION
    
    MAIN_LOOP:
        cmp IS_INGAME,1
        JE START_GAME
        CALL CHECK_KEYBOARD
        ; Get current cursor position
        mov ah, 03h
        int 10h
        mov sender_cursor_row, dh
        mov sender_cursor_col, dl
        
        CALL CHECK_SERIAL_MESSAGE
        
        mov dh, sender_cursor_row
        mov dl, sender_cursor_col
        mov bh, 0
        mov ah, 2
        int 10h
    JMP MAIN_LOOP

public START_GAME
START_GAME PROC FAR
    CALL  INIT_GAME
    CALL  DRAWBLOCKS
    CALL  DISPLAY_HEARTS

    ; GET TIME CH Hours, CL Minutes, DH Seconds, DL Hundreths of a second
    CHECK_TIME:     

    call read_pad_pos

    ; PADDLE STUFF
        call  draw_paddles
        mov   ah , 01h
        int   16h
        jz    NO_INPUT_ACTION

        CMP   AL, 27                       ; Check if key is ESC
        JE    exit                         ; If ESC, exit program
        
        call move_paddles
        call  send_pad_pos
        call  read_pad_pos

    NO_INPUT_ACTION:
        MOV   AH, 2CH
        INT   21H

        CMP   DL, AUX_TIME
        JE    CHECK_TIME

        MOV   AUX_TIME, DL


    ; BALL MOVEMENT
        CALL  DELETE_BALL
        CALL  MOVE_BALL_BY_VELOCITY
        CALL  DRAW_BALL

    ; check win condition
        call  CHECK_SCREEN_PIXELS
        cmp   al , 1
        je    GAME_WON
        JMP   CHECK_TIME
    GAME_WON:       
    call DISPLAY_WIN_MESSAGE
    exit:           
    ; Clear screen
        MOV   AH, 0
        MOV   AL, 3
        INT   10H

    ; Exit program
        MOV   AH, 4CH
        INT   21H
ENDP START_GAME
main ENDP


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

ESTABLISH_CONNECTION PROC FAR
    ; Send initial handshake byte
WAIT_FOR_CONNECTION:
    mov dx, 3FDH      ; Line Status Register
    in al, dx
    test al, 00100000b  ; Test if transmitter is ready
    jz WAIT_FOR_CONNECTION
    
    mov dx, 03F8H
    mov al, 0AAh      ; Handshake byte
    out dx, al
    
    ; Wait for response
    mov cx, 1000      ; Timeout counter
WAIT_RESPONSE:
    mov dx, 3FDH
    in al, dx
    test al, 1        ; Test if received data is ready
    jnz CONNECTED
    loop WAIT_RESPONSE
    jmp WAIT_FOR_CONNECTION
    
CONNECTED:
    mov IS_RECIEVER_FOUND, 1
    RET
ESTABLISH_CONNECTION ENDP

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

CHECK_KEYBOARD PROC
    ; Check for keystroke without waiting
    mov ah, 01h
    INT 16h
    JZ KEYBOARD_CHECK_DONE  ; No key pressed, return

	; Read key from buffer
    mov ah, 0h
    INT 16h
    
    cmp AH, 59
    JNE NOT_F1
    mov al,5
    mov IS_INGAME,1
    mov CRT_PLAYER,1
    NOT_F1:
    ; Check for ESC key to exit
    CMP al, 27
    JNZ NOT_ESC 
    jmp exit
    
    NOT_ESC:
    ; Send character to serial port
    CALL SEND_SERIAL_CHARACTER
    cmp IS_INGAME,1
    JE reciever_found
    SKIP_START_GAME:
    ; Move cursor after sending
    CALL MOVE_CURSOR

KEYBOARD_CHECK_DONE:
;     CMP IS_RECIEVER_FOUND, 1
;     JE reciever_found
    
;     ; Small delay to allow character to be received
;     mov bx, 1000
;     delay_loop:
;         dec bx
;     jnz delay_loop
    
;     call SEND_SERIAL_CHARACTER
reciever_found:
    RET
CHECK_KEYBOARD ENDP

public TRY_AGAIN
TRY_AGAIN   PROC    FAR
    CALL DELETE_HEARTS
    
    dec PLAYER_LIVES
    JZ DISPLAY_LOOSE_MESSAGE_LABEL

    CALL  DISPLAY_HEARTS
    call RESET_PADDLES
    RET
    
    DISPLAY_LOOSE_MESSAGE_LABEL: 
    call DISPLAY_LOOSE_MESSAGE
    jmp exit
ENDP TRY_AGAIN


INIT_GAME PROC NEAR
    ; Set video mode 13h (320x200, 256 colors)
                    mov   ax, 0013h                    ; Set video mode 13h
                    int   10h                          ; Call BIOS interrupt

    ; Clear the screen (fill video memory with 0)
                    mov   ax, 0A000h                   ; Video memory segment address
                    mov   es, ax                       ; ES = video memory
                    xor   di, di                       ; Starting offset in video memory
                    mov   cx, 32000                    ; 320x200 pixels, 1 byte per pixel
                    mov   al, 00h                      ; Black color (0)
                    rep   stosb                        ; Clear the screen
    
                    RET
ENDP  INIT_GAME


END