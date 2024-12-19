.model small    
.data
NUMBER_OF_ROWS DW 3

.stack 100h
.code
PUBLIC CHECK_SCREEN_PIXELS
CHECK_SCREEN_PIXELS PROC far
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
    MOV     AL, 1             ; Set AL to indicate win condition
    RET
CHECK_SCREEN_PIXELS ENDP

END