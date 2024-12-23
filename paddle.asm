

.model small    
.data
    public paddle_one_x
    paddle_one_x    dw 165    ; X-coordinate for the right-bottom paddle
    INITIAL_paddle_one_x    dw 165    ; X-coordinate for the right-bottom paddle
    
    public paddle_one_y
    paddle_one_y    dw 180    ; Y-coordinate for the right-bottom paddle
    INITIAL_paddle_one_y    dw 180    ; Y-coordinate for the right-bottom paddle
    
    public paddle_two_x
    paddle_two_x    dw 125     ; X-coordinate for the left-bottom paddles
    INITIAL_paddle_two_x    dw 125
    
    public paddle_two_y
    paddle_two_y    dw 180    ; Y-coordinate for the left-bottom paddles
    INITIAL_paddle_two_y    dw 180
    
    paddle_width    dw 30     ; Paddle width
    paddle_height   dw 5      ; Paddle height
    paddle_velocity dw 5      ;paddle move speed

.stack 100h
.code

EXTRN SEND_SERIAL_CHARACTER:FAR
EXTRN CRT_PLAYER:byte

; Modified read_pad_pos procedure
public read_pad_pos
read_pad_pos proc far
    ; Check Line Status Register for first byte
    mov dx, 3fDH       
    in al, dx
    AND al, 1
    JZ NO_MESSAGE  

    ; Read first byte
    mov dx, 03f8H
    in al, dx
    mov bl, al    ; Store first byte

    ; Wait for second byte to be ready
WAIT_SECOND_BYTE:
    mov dx, 3fDH
    in al, dx
    AND al, 1
    JZ WAIT_SECOND_BYTE

    ; Read second byte
    mov dx, 03f8H
    in al, dx
    mov bh, al    ; Store second byte
    
    cmp CRT_PLAYER, 1
    JNE read_player_2
        ; We're player 1
        mov paddle_two_x, bx
        ret

    read_player_2:
        ; We're player 2
        mov paddle_one_x, bx
        ret
    
NO_MESSAGE:
    ret
read_pad_pos endp

; Modified send_pad_pos procedure
public send_pad_pos
send_pad_pos proc far
    ; Wait until transmitter is ready
WAIT_TRANSMITTER:
    mov dx, 3FDH
    in al, dx
    test al, 00100000b
    jz WAIT_TRANSMITTER
   
    cmp CRT_PLAYER, 1
    JNE send_player_2
    
    ; send player one x position
    mov al, byte ptr[paddle_one_x]
    call SEND_SERIAL_CHARACTER
    
    ; Wait for first byte to be sent
WAIT_FIRST_SENT:
    mov dx, 3FDH
    in al, dx
    test al, 00100000b
    jz WAIT_FIRST_SENT
    
    mov al, byte ptr[paddle_one_x+1]
    call SEND_SERIAL_CHARACTER
    ret

send_player_2:
    ; send player two x position
    mov al, byte ptr[paddle_two_x]
    call SEND_SERIAL_CHARACTER
    
    ; Wait for first byte to be sent
WAIT_SECOND_SENT:
    mov dx, 3FDH
    in al, dx
    test al, 00100000b
    jz WAIT_SECOND_SENT
    
    mov al, byte ptr[paddle_two_x+1]
    call SEND_SERIAL_CHARACTER
    ret
send_pad_pos endp

PUBLIC RESET_PADDLES
RESET_PADDLES PROC FAR
    PUSH cx
    
    call clear_paddle1
    call clear_paddle2

    mov cx,INITIAL_paddle_one_x
    mov paddle_one_x,cx

    mov cx,INITIAL_paddle_one_y
    mov paddle_one_y,cx

    mov cx,INITIAL_paddle_two_x
    mov paddle_two_x,cx

    mov cx,INITIAL_paddle_two_y
    mov paddle_two_y,cx
    pop cx

    ret
RESET_PADDLES ENDP

clear_paddle1 proc far

                             mov  cx , paddle_one_x
                             mov  dx , paddle_one_y
    clear_paddle1_horizontal:
                             mov  ah, 0ch                     ; pixel color interrupt
                             mov  al, 00h                     ;pixel color white
                             mov  bh,0h
                             int  10h                         ;call interrupt
                             inc  cx                          ; move to left
                             mov  ax , cx
                             sub  ax , paddle_one_x
                             cmp  ax , paddle_width
                             jl   clear_paddle1_horizontal

                             mov  cx , paddle_one_x
                             inc  dx
                             mov  ax , dx
                             sub  ax , paddle_one_y
                             cmp  ax , paddle_height
                             jl   clear_paddle1_horizontal

                             ret
clear_paddle1 endp

clear_paddle2 proc far

                             mov  cx , paddle_two_x
                             mov  dx , paddle_two_y

    clear_paddle2_horizontal:
                             mov  ah, 0ch                     ; pixel color interrupt
                             mov  al, 00h                     ;pixel color white
                             mov  bh,0h
                             int  10h                         ;call interrupt
                             inc  cx                          ; move to left
                             mov  ax , cx
                             sub  ax , paddle_two_x
                             cmp  ax , paddle_width
                             jl   clear_paddle2_horizontal

                             mov  cx , paddle_two_x
                             inc  dx

                             mov  ax , dx
                             sub  ax , paddle_two_y
                             cmp  ax , paddle_height
                             jl   clear_paddle2_horizontal



                             ret
clear_paddle2 endp



PUBLIC draw_paddles
draw_paddles proc far

                             mov  cx , paddle_one_x
                             mov  dx , paddle_one_y
    paddle1_horizontal:      
                             mov  ah, 0ch                     ; pixel color interrupt
                             mov  al, 0Fh                     ;pixel color white
                             mov  bh,0h
                             int  10h                         ;call interrupt
                             inc  cx                          ; move to left
                             mov  ax , cx
                             sub  ax , paddle_one_x
                             cmp  ax , paddle_width
                             jl   paddle1_horizontal

                             mov  cx , paddle_one_x
                             inc  dx

                             mov  ax , dx
                             sub  ax , paddle_one_y
                             cmp  ax , paddle_height
                             jl   paddle1_horizontal

                             mov  cx , paddle_two_x
                             mov  dx , paddle_two_y

    paddle2_horizontal:      
                             mov  ah, 0ch                     ; pixel color interrupt
                             mov  al, 0Fh                     ;pixel color white
                             mov  bh,0h
                             int  10h                         ;call interrupt
                             inc  cx                          ; move to left
                             mov  ax , cx
                             sub  ax , paddle_two_x
                             cmp  ax , paddle_width
                             jl   paddle2_horizontal

                             mov  cx , paddle_two_x
                             inc  dx

                             mov  ax , dx
                             sub  ax , paddle_two_y
                             cmp  ax , paddle_height
                             jl   paddle2_horizontal



                             ret

draw_paddles endp

PUBLIC move_paddles
move_paddles proc far


    ;check which key is pressed
    mov  ah , 00h
    int  16h                         ; al = ASCII , ah = scan code

    cmp CRT_PLAYER,2
    JNE check_paddle2_movement
    ;if up arrow move up

    cmp  ah , 4dh
    je   move_paddle1_right
    ;if down arrow move down
    cmp  ah , 4bh
    je   move_paddle1_left
    ret
    ; jmp  check_paddle2_movement

    move_paddle1_right:      
        call clear_paddle1
        mov  ax , paddle_velocity
    ; Boundary check for the right edge of the screen
        mov  bx, paddle_one_x
        add  bx, ax
        add  bx, paddle_width
        cmp  bx, 320                     ; Assuming screen width is 320 pixels
        jg   paddle1_skip_right          ; If beyond right boundary, skip update

        add  paddle_one_x , ax
    paddle1_skip_right:      
        ; jmp  check_paddle2_movement
        ret

    move_paddle1_left:       
        call clear_paddle1
        mov  ax , paddle_velocity
    ; Boundary check for the left edge of the screen
        mov  bx, paddle_one_x
        sub  bx, ax
        cmp  bx, 0                       ; Ensure it doesn't go below 0
        jl   paddle1_skip_left           ; If beyond left boundary, skip update
        sub  paddle_one_x , ax
    paddle1_skip_left:       
        ; jmp  check_paddle2_movement
    ret
    
    ; paddle2_movement
    check_paddle2_movement:  

    ; D | d to right
        cmp  al , 64h
        je   move_paddle2_right
        cmp  al , 44h
        je   move_paddle2_right
    ; A | a to left
        cmp  al , 61h
        je   move_paddle2_left
        cmp  al , 41h
        je   move_paddle2_left
        
        ; jmp  exit_paddle_movement
        ret
    move_paddle2_right:      
        call clear_paddle2
        mov  ax , paddle_velocity
    ; Boundary check for the right edge of the screen
        mov  bx, paddle_two_x
        add  bx, ax
        add  bx, paddle_width
        cmp  bx, 320                     ; Assuming screen width is 320 pixels
        jg   paddle2_skip_right          ; If beyond right boundary, skip update

        add  paddle_two_x , ax
    paddle2_skip_right:      
        ; jmp  exit_paddle_movement
    ret

    move_paddle2_left:       
        call clear_paddle2
        mov  ax , paddle_velocity
    ; Boundary check for the left edge of the screen
        mov  bx, paddle_two_x
        sub  bx, ax
        cmp  bx, 0                       ; Ensure it doesn't go below 0
        jl   exit_paddle_movement        ; If beyond left boundary, skip update
        sub  paddle_two_x , ax
exit_paddle_movement:    
        ret

move_paddles endp


END