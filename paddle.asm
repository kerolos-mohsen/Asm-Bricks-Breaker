.model small    
.data
    ; Paddle positions
    public paddle_one_x, paddle_one_y
    paddle_one_x    dw 165    ; X-coordinate for right paddle
    paddle_one_y    dw 180    ; Y-coordinate for right paddle
    
    public paddle_two_x, paddle_two_y
    paddle_two_x    dw 125    ; X-coordinate for left paddle
    paddle_two_y    dw 180    ; Y-coordinate for left paddle
    
    ; Paddle properties
    paddle_width    dw 30     ; Paddle width
    paddle_height   dw 5      ; Paddle height
    paddle_velocity dw 1      ; Paddle move speed

    ; Screen boundaries
    SCREEN_RIGHT    dw 320    ; Right screen boundary
    SCREEN_LEFT     dw 0      ; Left screen boundary

     PADDLE_SYNC_CHAR db 'P'
.code

EXTRN CRT_PLAYER:byte

PUBLIC clear_paddle1
clear_paddle1 proc far
    mov cx, paddle_one_x    ; Starting X coordinate
    mov dx, paddle_one_y    ; Starting Y coordinate
    
clear_paddle1_horizontal:
    mov ah, 0ch            ; Set pixel
    mov al, 00h            ; Black color (effectively erasing)
    mov bh, 0h             ; Page number
    int 10h                ; Draw pixel
    
    inc cx                 ; Move right
    mov ax, cx
    sub ax, paddle_one_x
    cmp ax, paddle_width
    jl clear_paddle1_horizontal
    
    mov cx, paddle_one_x   ; Reset X to start
    inc dx                 ; Move down one row
    
    mov ax, dx
    sub ax, paddle_one_y
    cmp ax, paddle_height
    jl clear_paddle1_horizontal
    
    ret
clear_paddle1 endp

PUBLIC clear_paddle2
clear_paddle2 proc far
    mov cx, paddle_two_x    ; Starting X coordinate
    mov dx, paddle_two_y    ; Starting Y coordinate
    
clear_paddle2_horizontal:
    mov ah, 0ch            ; Set pixel
    mov al, 00h            ; Black color (effectively erasing)
    mov bh, 0h             ; Page number
    int 10h                ; Draw pixel
    
    inc cx                 ; Move right
    mov ax, cx
    sub ax, paddle_two_x
    cmp ax, paddle_width
    jl clear_paddle2_horizontal
    
    mov cx, paddle_two_x   ; Reset X to start
    inc dx                 ; Move down one row
    
    mov ax, dx
    sub ax, paddle_two_y
    cmp ax, paddle_height
    jl clear_paddle2_horizontal
    
    ret
clear_paddle2 endp

; First paddle movement (Arrow keys)
PUBLIC move_paddle1
move_paddle1 proc far
    ; Check which arrow key is pressed
    mov ah, 00h
    int 16h                     ; al = ASCII, ah = scan code

    ; Right arrow (4Dh)
    cmp ah, 4dh
    je move_paddle1_right
    
    ; Left arrow (4Bh)
    cmp ah, 4bh
    je move_paddle1_left
    
    ret

move_paddle1_right:
    ; Clear old paddle position
    call clear_paddle1
    
    ; Calculate new position
    mov ax, paddle_velocity
    mov bx, paddle_one_x
    add bx, ax                  ; Add velocity
    add bx, paddle_width        ; Account for paddle width
    
    ; Check right boundary
    cmp bx, SCREEN_RIGHT
    jg paddle1_skip_right       ; If beyond boundary, skip update
    
    ; Update position
    add paddle_one_x, ax
    
paddle1_skip_right:
    ret

move_paddle1_left:
    ; Clear old paddle position
    call clear_paddle1
    
    ; Calculate new position
    mov ax, paddle_velocity
    mov bx, paddle_one_x
    sub bx, ax                  ; Subtract velocity
    
    ; Check left boundary
    cmp bx, SCREEN_LEFT
    jl paddle1_skip_left        ; If beyond boundary, skip update
    
    ; Update position
    sub paddle_one_x, ax
    
paddle1_skip_left:
    ret
move_paddle1 endp

; Second paddle movement (A/D keys)
PUBLIC move_paddle2
move_paddle2 proc far
    ; Check which key is pressed
    mov ah, 00h
    int 16h                     ; al = ASCII, ah = scan code
    
    ; D or d (64h/44h)
    cmp al, 64h                 ; 'd'
    je move_paddle2_right
    cmp al, 44h                 ; 'D'
    je move_paddle2_right
    
    ; A or a (61h/41h)
    cmp al, 61h                 ; 'a'
    je move_paddle2_left
    cmp al, 41h                 ; 'A'
    je move_paddle2_left
    
    ret

move_paddle2_right:
    ; Clear old paddle position
    call clear_paddle2
    
    ; Calculate new position
    mov ax, paddle_velocity
    mov bx, paddle_two_x
    add bx, ax                  ; Add velocity
    add bx, paddle_width        ; Account for paddle width
    
    ; Check right boundary
    cmp bx, SCREEN_RIGHT
    jg paddle2_skip_right       ; If beyond boundary, skip update
    
    ; Update position
    add paddle_two_x, ax
    
paddle2_skip_right:
    ret

move_paddle2_left:
    ; Clear old paddle position
    call clear_paddle2
    
    ; Calculate new position
    mov ax, paddle_velocity
    mov bx, paddle_two_x
    sub bx, ax                  ; Subtract velocity
    
    ; Check left boundary
    cmp bx, SCREEN_LEFT
    jl paddle2_skip_left        ; If beyond boundary, skip update
    
    ; Update position
    sub paddle_two_x, ax
    
paddle2_skip_left:
    ret
move_paddle2 endp

; Main paddle movement handler
PUBLIC move_crtPlayer_paddle
move_crtPlayer_paddle proc far
    ; Check which player is current
    cmp CRT_PLAYER, 1
    jne handle_paddle2
    
    ; Handle paddle 1 movement
    call move_paddle1
    ret
    
handle_paddle2:
    ; Handle paddle 2 movement
    call move_paddle2
    ret
move_crtPlayer_paddle endp



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

PUBLIC send_crtPlayer_pad_pos
send_crtPlayer_pad_pos proc far
    ; First check if transmitter holding register is empty
    mov dx, 3FDH
    in al, dx
    test al, 20h
    jz send_done    ; If not empty, skip sending
    
    ; Send paddle sync character
    mov dx, 3F8H
    mov al, PADDLE_SYNC_CHAR
    out dx, al
    
    ; Wait for transmitter to be ready again
    mov dx, 3FDH
wait_transmit1:
    in al, dx
    test al, 20h
    jz wait_transmit1
    
    ; Send X position (high byte)
    mov dx, 3F8H
    mov bx, paddle_one_x    ; Use paddle_one_x if CRT_PLAYER is 1, else use paddle_two_x
    cmp CRT_PLAYER, 1
    je send_p1
    mov bx, paddle_two_x
send_p1:
    mov al, bh
    out dx, al
    
    ; Wait and send X position (low byte)
    mov dx, 3FDH
wait_transmit2:
    in al, dx
    test al, 20h
    jz wait_transmit2
    
    mov dx, 3F8H
    mov al, bl
    out dx, al
    
send_done:
    ret
send_crtPlayer_pad_pos endp

PUBLIC read_otherPlayer_pad_pos
read_otherPlayer_pad_pos proc far
    ; Check if data is available
    mov dx, 3FDH
    in al, dx
    test al, 1
    jz read_done    ; If no data, skip reading
    
    ; Read first byte
    mov dx, 3F8H
    in al, dx
    
    ; Check if it's a paddle sync message
    cmp al, PADDLE_SYNC_CHAR
    jne read_done
    
    ; Wait for high byte of position
wait_data1:
    mov dx, 3FDH
    in al, dx
    test al, 1
    jz wait_data1
    
    ; Read high byte
    mov dx, 3F8H
    in al, dx
    mov bh, al
    
    ; Wait for low byte of position
wait_data2:
    mov dx, 3FDH
    in al, dx
    test al, 1
    jz wait_data2
    
    ; Read low byte
    mov dx, 3F8H
    in al, dx
    mov bl, al
    
    ; Update appropriate paddle position
    cmp CRT_PLAYER, 1
    je update_p2    ; If we're player 1, update paddle 2
    push bx
    call clear_paddle1
    pop bx
    mov paddle_one_x, bx
    jmp read_done
update_p2:
    push bx
    call clear_paddle2
    pop bx
    mov paddle_two_x, bx
    
read_done:
    ret
read_otherPlayer_pad_pos endp

END