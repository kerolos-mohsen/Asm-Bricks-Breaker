.MODEL small
.STACK 100h
.data
receiver_cursor_col db 0
receiver_cursor_row db 13
value db ?, "$"
.code
EXTRN IS_INGAME:byte
EXTRN START_GAME:FAR
; Check for incoming serial messages
PUBLIC  CHECK_SERIAL_MESSAGE
CHECK_SERIAL_MESSAGE PROC  FAR
    ; Check Line Status Register
    mov dx, 3fDH       
    in al, dx
    AND al, 1
    JZ SERIAL_MESSAGE_DONE  ; No message available

    ; Move to receiver area using tracked cursor position
    mov dh, receiver_cursor_row  ; Use tracked row
    mov dl, receiver_cursor_col  ; Use tracked column
    mov bh, 0
    mov ah, 2
    int 10h

    ; Read incoming message
    mov dx, 03f8H
    in al, dx
    cmp al,0AAH
    JE SERIAL_MESSAGE_DONE
    mov VALUE, al
    
    cmp al,5
    JNE SKIP_START_GAME
    mov IS_INGAME,1
    JMP SERIAL_MESSAGE_DONE
    
    SKIP_START_GAME:
    ; Display received message
    mov ah, 09
    mov dx, offset value
    int 21h
    
    ; Get current cursor position after displaying
    mov ah, 03h
    int 10h

    ; Update tracked cursor position
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