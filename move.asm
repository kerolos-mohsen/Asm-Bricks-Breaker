.MODEL small
.STACK 100h
.data
.code

PUBLIC MOVE_CURSOR
MOVE_CURSOR PROC FAR
	; Get current cursor position
	mov ah, 03h
	int 10h

	; Check if at end of line (column 79)
	cmp dl, 79
	jl MoveCursorRight

	; End of line, move to next row
	mov dl, 0               ; Reset to first column
	inc dh                     ; Move to next row

	; Check if beyond sender area (row 12)
	cmp dh, 12
	jl UpdateCursor
    push dx

	; Scroll if beyond sender area
	jmp ScrollScreenSender

	validateCursor:
		; Keep cursor in last valid row
		pop dx
		dec dh
		mov dl,0
		mov bx,0

	UpdateCursor:
		; Update cursor position
		mov ah, 2
		int 10h
		ret

	MoveCursorRight:
		; Move cursor to the right
		inc dl
		mov ah, 2
		int 10h
		ret


	ScrollScreenSender:
		; Scroll window up by 1 line
		mov ah, 06h           ; Scroll function
		mov al, 1                ; Scroll by 1 line
		mov bh, 07h           ; Normal video attribute
		mov ch, 0                ; Upper-left corner row
		mov cl, 0                ; Upper-left corner column
		mov dh, 11               ; Lower-right corner row
		mov dl, 79               ; Lower-right corner column
		int 10h
		jmp	validateCursor
MOVE_CURSOR ENDP
END