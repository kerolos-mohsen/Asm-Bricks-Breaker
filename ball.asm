.MODEL SMALL
.STACK 100H
.DATA
    BALL_X_INITIAL_POS DW 00A0H
    BALL_Y_INITIAL_POS DW 00A0H
    BALL_X             DW 00A0H
    BALL_Y             DW 00A0H
    BALL_SIZE          DW 04H ; 4x4

    BALL_X_VELOCITY DW 0AH
    BALL_Y_VELOCITY DW 03H

    WINDOW_HEIGHT DW 200
    WINDOW_WIDTH  DW 320
    WINDOW_BOUNDS DW 12   ; To Check Boundaries Early

    BALL_CENTER_X DW 110
    BALL_CENTER_Y DW 160

.CODE

PUBLIC    DRAW_BALL
DRAW_BALL PROC
        MOV CX, BALL_X
        MOV DX, BALL_Y
        MOV AL, 0FH    ; WHITE COLOR
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
    JG  NEG_VEL_Y

    MOV AH, 0Dh        ; GET COLOR OF PIXEL AT BALL POS
    MOV CX, BALL_X
    MOV DX, BALL_Y

    DRAW_BALL_LOOP2:
        INT 10H

        
        CMP AL, 00h        ; Check If black (no collision)
        JE EXIT


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

BOUNCE:
    NEG BALL_Y_VELOCITY
    RET

NEG_VEL_X:
    NEG BALL_X_VELOCITY
    RET

NEG_VEL_Y:
    NEG BALL_Y_VELOCITY
    RET
EXIT:
    RET

MOVE_BALL_BY_VELOCITY ENDP
END