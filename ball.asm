.MODEL SMALL
.STACK 100H
.DATA
    BALL_X_INITIAL_POS DW 160
    BALL_Y_INITIAL_POS DW 170
    BALL_X             DW 160
    BALL_Y             DW 170
    BALL_SIZE          DW 04H ; 4x4

    INITIAL_BALL_X_VELOCITY DW 0003H
    BALL_X_VELOCITY DW 0003H
    INITIAL_BALL_Y_VELOCITY DW 0FFFAH
    BALL_Y_VELOCITY DW 0FFFAH

    BLOCK_X_STEP    DW 001Eh ; 30 in decimal --> 20 + 10 (RECTANGLE_WIDTH + GAP_SIZE)
    BLOCK_Y_STEP    DW 000Fh ; 15 in decimal --> 10 + 5 (RECTANGLE_HEIGHT + GAP_SIZE)

    WINDOW_HEIGHT DW 200
    WINDOW_WIDTH  DW 320
    WINDOW_BOUNDS DW 12   ; To Check Boundaries Early

    BALL_CENTER_X DW 110
    BALL_CENTER_Y DW 160

    BLOCK_WIDTH DW  20
    BLOCK_HEIGHT DW  10

.CODE
EXTRN DisplayScores:FAR
EXTRN DELETE_SCORE:FAR
EXTRN CRT_PLAYER:byte
EXTRN TRY_AGAIN:FAR
EXTRN P1_SCORE:byte
EXTRN P2_SCORE:byte
public  RESET_BALL
RESET_BALL PROC NEAR
    push CX
    mov cx,BALL_X_INITIAL_POS
    mov BALL_X,cx

    mov cx,BALL_Y_INITIAL_POS
    mov BALL_Y,cx

    mov cx,INITIAL_BALL_X_VELOCITY
    mov BALL_X_VELOCITY,cx

    
    mov cx,INITIAL_BALL_Y_VELOCITY
    mov BALL_Y_VELOCITY,cx
    pop cx
RESET_BALL  ENDP

PUBLIC    DRAW_BALL
DRAW_BALL PROC
        MOV CX, BALL_X
        MOV DX, BALL_Y
        MOV AL, 0BH    ; WHITE COLOR
        MOV AH, 0CH
        MOV BH, 0

    DRAW_BALL_LOOP:
        INT 10H
        INC CX
        ;SI IS TEMP TO COMPARE WITH BALL_Y + BALL_SIZE
        MOV SI, BALL_X
        ADD SI, BALL_SIZE
        CMP CX, SI
        JNE DRAW_BALL_LOOP

        INC DX
        MOV CX, BALL_X

        MOV SI, BALL_Y
        ADD SI, BALL_SIZE

        CMP DX, SI
        JNE DRAW_BALL_LOOP

        RET
DRAW_BALL             ENDP

PUBLIC DELETE_BALL
DELETE_BALL PROC
    MOV CX, BALL_X        ; Reset X coordinate to initial ball X position
    MOV DX, BALL_Y        ; Reset Y coordinate to initial ball Y position
    MOV AL, 00H           ; BLACK COLOR
    MOV AH, 0CH           ; GRAPHICS PIXEL DRAW INTERRUPT
    MOV BH, 0             ; Page number

DELETE_BALL_LOOP_Y:
    PUSH CX               ; Save X coordinate
    MOV SI, BALL_X
    ADD SI, BALL_SIZE     ; Calculate right boundary of ball

DELETE_BALL_LOOP_X:
    INT 10H               ; Draw pixel
    INC CX                ; Move to next X
    CMP CX, SI            ; Compare with right boundary
    JL DELETE_BALL_LOOP_X ; Continue X loop until boundary reached

    POP CX                ; Restore initial X coordinate
    INC DX                ; Move to next Y
    MOV SI, BALL_Y
    ADD SI, BALL_SIZE     ; Calculate bottom boundary of ball
    CMP DX, SI            ; Compare current Y with bottom boundary
    JL DELETE_BALL_LOOP_Y ; Continue Y loop until boundary reached

    RET
DELETE_BALL ENDP

PUBLIC                MOVE_BALL_BY_VELOCITY
MOVE_BALL_BY_VELOCITY PROC
    MOV AX,     BALL_X_VELOCITY
    ADD BALL_X, AX

    ;ball_x < 0 or ball_x > window_width - BALL_SIZE
    MOV AX,     WINDOW_BOUNDS
    CMP BALL_X, AX
    JL  NEG_VEL_X

    MOV AX,     WINDOW_WIDTH
    SUB AX,     WINDOW_BOUNDS
    CMP BALL_X, AX
    JG  NEG_VEL_X

    MOV AX,     BALL_Y_VELOCITY
    ADD BALL_Y, AX

    MOV AX,     WINDOW_BOUNDS
    CMP BALL_Y, AX
    JL  NEG_VEL_Y

    
    MOV AX,     WINDOW_HEIGHT
    SUB AX,     WINDOW_BOUNDS
    CMP BALL_Y, AX
    JLE skip2
    call RESET_BALL
    call TRY_AGAIN
    
    skip2:

    MOV AH, 0Dh        ; GET COLOR OF PIXEL AT BALL POS
    MOV CX, BALL_X
    MOV DX, BALL_Y

    DRAW_BALL_LOOP2:
        INT 10H

        CMP AL,0BH
        JZ SKIP
        CMP AL, 00h        ; Check If black (no collision)
        JNE BOUNCE

        SKIP:
        INC CX
        ;SI IS TEMP TO COMPARE WITH BALL_Y + BALL_SIZE
        MOV SI, BALL_X
        ADD SI, BALL_SIZE
        CMP CX, SI
        JNE DRAW_BALL_LOOP2

        INC DX
        MOV CX, BALL_X

        MOV SI, BALL_Y
        ADD SI, BALL_SIZE

        CMP DX, SI
        JNE DRAW_BALL_LOOP2
        RET

NEG_VEL_X:
    NEG BALL_X_VELOCITY
    RET

BOUNCE:
    CMP AL, 0Fh     ; Check If white (collision with paddle)
    JE NEG_VEL_Y

    ; Saving X, Y, current location
    push CX
    push DX
    push DX

    SUB CX, 15          ; Subtract 15 for the initial X position of the blocks (inital gap) 
    MOV AX, CX
    MOV SI, BLOCK_X_STEP
    XOR DX, DX          ; Clear DX for division
    DIV SI              ; Divide by 30 (20 + 10) to get the quotient
    MUL SI              ; Multiply by 30 to get the actual X position of the block without the initial gap
    MOV CX, AX
    ADD CX, 15          ; Add 15 to get the actual X position of the block we want to delete

    POP DX              ; Restore the current Y position

    ; same logic as above but for Y
    MOV AX, BLOCK_Y_STEP
    MOV SI, AX
    SUB DX, 10          ; Subtract 10 for the initial Y position of the blocks (inital gap)
    MOV AX, DX
    XOR DX, DX
    DIV SI
    MUL SI
    MOV DX, AX
    ADD DX, 10          ; Add 10 to get the actual Y position of the block we want to delete

    ; now we have the X and Y position of the block we want to delete
    JMP DELETE_BLOCK

NEG_VEL_Y:
    NEG BALL_Y_VELOCITY
    RET
EXIT:
    RET

DELETE_BLOCK:
        call DELETE_SCORE
        cmp CRT_PLAYER , 1
        jne increment_player2
        inc P1_SCORE
        jmp skip_player2
        increment_player2:
        inc P2_SCORE
        skip_player2:
        call DisplayScores
        ;  Delete the block
        MOV BX, BLOCK_HEIGHT
    RowLoop:
        PUSH BX             ; save row counter
        MOV BX, BLOCK_WIDTH
        PUSH CX             ; Save starting X position
    ColumnLoop:
        MOV AH, 0Ch
        MOV AL, 0           ; block coulor
        MOV BH, 0
        INT 10h             ; Draw the pixel, AL = color, BH = page number, CX = X, DX = Y

        INC CX              ; Move to the next pixel in the row
        DEC BX              ; width counter
        JNZ ColumnLoop

        POP CX              ; return X position (starting of the block)
        INC DX              ; Move to the next row
        POP BX              ; Restore row counter
        DEC BX              ; Decrease row counter
        JNZ RowLoop

        ; Restore ball X, Y location and reverse the Y velocity
        POP DX
        POP CX

        NEG BALL_Y_VELOCITY
        RET

MOVE_BALL_BY_VELOCITY ENDP

END