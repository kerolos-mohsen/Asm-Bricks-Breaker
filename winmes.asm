.model small
.data
    ; Winning message components
    WIN_TITLE     DB 'Congratulations!$'
    WIN_MESSAGE   DB 'You have successfully completed the challenge!$'
    BORDER_TOP    DB '+-----------------------------------------+$'
    BORDER_SIDE   DB '|                                         |$'
    
.code
PUBLIC DISPLAY_WIN_MESSAGE
DISPLAY_WIN_MESSAGE PROC FAR
    ; Save registers
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    ; Clear screen
    MOV AH, 00h    ; Video mode function
    MOV AL, 03h    ; Text mode (80x25 color)
    INT 10h        ; BIOS video interrupt

    ; Set text color (white text on blue background)
    MOV AH, 09h
    MOV AL, ' '
    MOV BH, 0      ; Page number
    MOV BL, 1Fh   ; Color attribute (Blue background, White text)
    MOV CX, 2000   ; Number of characters to write
    INT 10h

    ; Position cursor for centering
    MOV AH, 02h
    MOV BH, 0      ; Page number
    MOV DH, 10     ; Row (vertical center)
    MOV DL, 20     ; Column (horizontal center)
    INT 10h

    ; Display top border
    MOV AH, 09h
    MOV DX, OFFSET BORDER_TOP
    INT 21h

    ; Move cursor to next line
    CALL NEWLINE

    ; Display side border with title
    MOV AH, 09h
    MOV DX, OFFSET BORDER_SIDE
    INT 21h

    ; Move cursor back slightly to center title
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 11     ; Same row
    MOV DL, 25     ; Adjusted column
    INT 10h

    ; Display title
    MOV AH, 09h
    MOV DX, OFFSET WIN_TITLE
    INT 21h

    ; Move to next lines
    CALL NEWLINE
    
    ; Display another side border
    MOV AH, 09h
    MOV DX, OFFSET BORDER_SIDE
    INT 21h

    ; Move cursor back slightly to center message
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 12     ; Next row
    MOV DL, 22     ; Adjusted column
    INT 10h

    ; Display winning message
    MOV AH, 09h
    MOV DX, OFFSET WIN_MESSAGE
    INT 21h

    ; Move to next lines
    CALL NEWLINE

    ; Display bottom border
    MOV AH, 09h
    MOV DX, OFFSET BORDER_TOP
    INT 21h

    ; Wait for key press
    MOV AH, 00h
    INT 16h

    ; Restore registers
    POP DX
    POP CX
    POP BX
    POP AX
    RET

; Helper procedure to move to next line
NEWLINE PROC NEAR
    PUSH AX
    PUSH DX
    
    ; Display newline
    MOV AH, 02h
    MOV DL, 13     ; Carriage return
    INT 21h
    MOV DL, 10     ; Line feed
    INT 21h
    
    POP DX
    POP AX
    RET
NEWLINE ENDP

DISPLAY_WIN_MESSAGE ENDP
END