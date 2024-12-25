.MODEL small
.STACK 100h
.data
receiver_cursor_col db 0
receiver_cursor_row db 13
value db ?, "$"
.code
EXTRN IS_INGAME:byte
EXTRN CRT_PLAYER:byte
EXTRN GAME_STATE:byte
EXTRN CLEAR_WINDOW:FAR

; Check for incoming serial messages
PUBLIC  CHECK_SERIAL_MESSAGE
CHECK_SERIAL_MESSAGE PROC  FAR
    mov dx, 3fDH      
    in al, dx
    AND al, 1
    JNZ MESSAGE_AVAILABLE  ; message available
    RET
    MESSAGE_AVAILABLE:
    mov dx, 03f8H
    in al, dx
    cmp al, 0AAH
    JNE PASS_MESSAGE
    ret
    PASS_MESSAGE:
    mov VALUE, al
   
    cmp IS_INGAME, 1
    je SERIAL_MESSAGE_DONE
    
    cmp al, 5              ; Check for play signal
    JNE IS_GOING_TO_CHAT
    mov GAME_STATE, 2
    mov IS_INGAME, 1
    mov CRT_PLAYER, 2
    JMP SERIAL_MESSAGE_DONE
    
IS_GOING_TO_CHAT:
    cmp al, 6              ; Check for chat signal
    JNE DISPLAY_MESSAGE
    mov GAME_STATE, 1
    CALL CLEAR_WINDOW
    JMP SERIAL_MESSAGE_DONE

DISPLAY_MESSAGE:           ; Regular chat message handling
    cmp al,5
    JNE contine
    cmp al,6
    JNE contine ; escape and send the character if al doesnt match 5 or 6
    ret
    contine:
    mov dh, receiver_cursor_row
    mov dl, receiver_cursor_col
    mov bh, 0
    mov ah, 2
    int 10h
    
    mov ah, 09
    mov dx, offset value
    int 21h
   
    mov ah, 03h
    int 10h
    mov receiver_cursor_row, dh
    mov receiver_cursor_col, dl

    ; Check if at end of line (column 79)
    cmp dl, 79
    jl SERIAL_MESSAGE_DONE

    ; End of line handling
    mov receiver_cursor_col, 0   ; Reset to first column
    inc receiver_cursor_row       ; Move to next row

    ; Check if beyond screen area (row 24)
    cmp receiver_cursor_row, 25
    jl SERIAL_MESSAGE_DONE

    ; Scroll and reset cursor to last valid row
    push dx
    call ScrollUpRecv
    pop dx
    dec receiver_cursor_row
    mov receiver_cursor_col, 0

	
SERIAL_MESSAGE_DONE:
    RET
CHECK_SERIAL_MESSAGE ENDP


ScrollUpRecv PROC FAR
	; Move the cursor one up
	dec dh
	mov ah, 2
	int 10h

	; Scroll window up
	mov ah, 6      ; function 6
	mov al, 1      ; scroll by 1 line
	mov bh, 7      ; normal video attribute
	mov ch, 13      ; upper left Y
	mov cl, 0      ; upper left X
	mov dh, 24     ; lower right Y
	mov dl, 79     ; lower right X
	int 10h

	RET
ScrollUpRecv ENDP
END