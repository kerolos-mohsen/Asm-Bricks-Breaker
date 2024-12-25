.model small    
.stack 100h

.data
    ; Winning message components
    WIN_TITLE     DB 'Congratulations!$'
    WIN_MESSAGE   DB 'You have successfully completed the challenge!$'
    BORDER_TOP    DB '+-----------------------------------------+$'
    BORDER_SIDE   DB '|                                         |$'
    NUMBER_OF_ROWS DW 3
    
.code
EXTRN EXIT_GAME:FAR

PUBLIC CHECK_FOR_WIN
CHECK_FOR_WIN PROC FAR
    ; Video memory starts at segment A000h
    MOV     AX, 0A000h      ; Video memory segment
    MOV     ES, AX          ; ES = A000h
    XOR     DI, DI          ; Start from offset 0
    MOV     DI, 3200

    ; Calculate the total number of pixels to check
    MOV     AX, NUMBER_OF_ROWS ; Load the number of rows
    MOV     BX, 320           ; Number of pixels per row
    MUL     BX                ; AX = NUMBER_OF_ROWS * 320
    MOV     CX, AX            ; CX = Total pixels to check

CHECK_PIXEL:
    MOV     AL, ES:[DI]       ; Load pixel color directly from video memory
    CMP     AL, 0             ; Is the pixel black (0)?
    JE      NEXT_PIXEL        ; If yes, continue to next pixel
    CMP     AL, 15            ; Is the pixel white (15)?
    JE      NEXT_PIXEL        ; If yes, continue to next pixel

    ; If pixel is neither black nor white, exit with no win
    MOV     AL, 0             ; Set AL to indicate not all pixels are black or white
    RET

NEXT_PIXEL:
    INC     DI                ; Move to next pixel
    LOOP    CHECK_PIXEL       ; Continue checking all pixels

    ; If all pixels are black or white, return success
    call DISPLAY_WIN_MESSAGE
    call EXIT_GAME
    RET
CHECK_FOR_WIN ENDP


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
DISPLAY_WIN_MESSAGE ENDP

; Helper procedure to move to next line
PUBLIC NEWLINE
NEWLINE PROC FAR
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

END