.model     small
.stack     100h
.DATA
RECTANGLE_WIDTH DW  20
RECTANGLE_HEIGHT DW  10
GAP_SIZE DW 10
INITIAL_X_COORDINATE DW 15
NUMBER_OF_ROWS DW 3
RECT_PER_ROW DW 10

.code
PUBLIC     DRAWBLOCKS
DRAWBLOCKS PROC


    mov       ax, 0A000h ; Video memory segment address
    mov       es, ax     ; ES = video memory
    xor       di, di     ; Starting offset in video memory


    ; Initialize block properties
    mov bx, RECTANGLE_WIDTH ; Rectangle width (20 pixels)
    mov dx, RECTANGLE_HEIGHT ; Rectangle height (10 pixels)
    mov si, GAP_SIZE ; Spacing between rectangles
    mov di, INITIAL_X_COORDINATE ; Initial x-coordinate for first row

    ; Draw 3 rows of rectangles
    mov bp, NUMBER_OF_ROWS  ; Number of rows
    xor ah, ah ; Color index (used to cycle through colors)
row_loop:
    push bp     ; Save BP (row counter)
    mov  cx, RECT_PER_ROW ; Number of rectangles per row
    push di     ; Save DI (current row's starting position)

rectangles_loop:
    push cx ; Save CX (rectangle counter)
    push di ; Save DI (current position)

    ; Cycle through colors (IDK how it works but it does)
    mov al, ah  ; Set current color based on AH
    and al, 07h
    add al, 20h

    ; Draw one rectangle row by row
    mov cx, dx ; Set height counter (RECT_PER_ROW rectangles per row)
draw_height:
    push      cx          ; Save CX (height counter)
    mov       cx, bx      ; Set width counter (20 pixels)
    rep stosb             ; Draw one row of the rectangle
    mov       cx,320
    neg       cx
    add       cx,GAP_SIZE
    add       cx,GAP_SIZE
    neg       cx
    add       di, cx     ; Move to the next row (320 - GAP_SIZE*2)
    pop       cx          ; Restore CX (height counter)
    loop      draw_height

    pop  di              ; Restore DI (position)
    add  di, bx          ; Move DI to next rectangle start
    add  di, si          ; Add spacing
    inc  ah              ; Increment color index for the next rectangle
    pop  cx              ; Restore CX (rectangle counter)
    loop rectangles_loop

    pop di       ; Restore DI (starting x-coordinate for row)
    add di, 4800 ; Move DI to next row (320 * HEIGHT_RECT + 320 * 5 (spacing between rows of rect))
    pop bp       ; Restore BP (row counter)
    dec bp       ; Decrement row counter
    jnz row_loop ; Repeat for next row

	RET
DRAWBLOCKS ENDP
END