

.model small    
.data
    paddle_one_x    dw 165    ; X-coordinate for the right-bottom paddle
    INITIAL_paddle_one_x    dw 165    ; X-coordinate for the right-bottom paddle
    
    paddle_one_y    dw 180    ; Y-coordinate for the right-bottom paddle
    INITIAL_paddle_one_y    dw 180    ; Y-coordinate for the right-bottom paddle
    
    paddle_two_x    dw 125     ; X-coordinate for the left-bottom paddles
    INITIAL_paddle_two_x    dw 125
    
    paddle_two_y    dw 180    ; Y-coordinate for the left-bottom paddles
    INITIAL_paddle_two_y    dw 180
    
    paddle_width    dw 30     ; Paddle width
    paddle_height   dw 5      ; Paddle height
    paddle_velocity dw 5      ;paddle move speed

.stack 100h
.code
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

    ;if up arrow move up

                             cmp  ah , 4dh
                             je   move_paddle1_right
    ;if down arrow move down
                             cmp  ah , 4bh
                             je   move_paddle1_left

                             jmp  check_paddle2_movement

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
                             jmp  check_paddle2_movement


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
                             jmp  check_paddle2_movement

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

                             jmp  exit_paddle_movement
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
                             jmp  exit_paddle_movement


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