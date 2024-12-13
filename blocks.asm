.model     small
.stack     100h

.code
PUBLIC     DRAWBLOCKS
DRAWBLOCKS PROC
    ; Set video mode 13h (320x200, 256 colors)
    mov ax, 0013h ; Set video mode 13h
    int 10h       ; Call BIOS interrupt

    ; Clear the screen (fill video memory with 0)
    mov       ax, 0A000h ; Video memory segment address
    mov       es, ax     ; ES = video memory
    xor       di, di     ; Starting offset in video memory
    mov       cx, 32000  ; 320x200 pixels, 1 byte per pixel
    mov       al, 00h    ; Black color (0)
    rep stosb            ; Clear the screen

    ; Initialize block properties
    mov bx, 20 ; Rectangle width (20 pixels)
    mov dx, 10 ; Rectangle height (10 pixels)
    mov si, 10 ; Spacing between rectangles
    mov di, 20 ; Initial x-coordinate for first row

    ; Draw 3 rows of rectangles
    mov bp, 3  ; Number of rows
    xor ah, ah ; Color index (used to cycle through colors)
row_loop:
    push bp     ; Save BP (row counter)
    mov  cx, 10 ; Number of rectangles per row
    push di     ; Save DI (current row's starting position)

rectangles_loop:
    push cx ; Save CX (rectangle counter)
    push di ; Save DI (current position)

    ; Cycle through colors (IDK how it works but it does)
    mov al, ah  ; Set current color based on AH
    and al, 07h
    add al, 20h

    ; Draw one rectangle row by row
    mov cx, dx ; Set height counter (10 rows)
draw_height:
    push      cx          ; Save CX (height counter)
    mov       cx, bx      ; Set width counter (20 pixels)
    rep stosb             ; Draw one row of the rectangle
    add       di, 300     ; Move to the next row (320 - 20)
    pop       cx          ; Restore CX (height counter)
    loop      draw_height

    pop  di              ; Restore DI (position)
    add  di, bx          ; Move DI to next rectangle start
    add  di, si          ; Add spacing
    inc  ah              ; Increment color index for the next rectangle
    pop  cx              ; Restore CX (rectangle counter)
    loop rectangles_loop

    pop di       ; Restore DI (starting x-coordinate for row)
    add di, 4800 ; Move DI to next row (320 * 10 + 320 * spacing)
    pop bp       ; Restore BP (row counter)
    dec bp       ; Decrement row counter
    jnz row_loop ; Repeat for next row

	RET
DRAWBLOCKS ENDP
END