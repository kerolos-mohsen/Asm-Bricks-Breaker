.model small
.stack 100h

.data
.code

PUBLIC INIT_GAME
INIT_GAME PROC FAR
    ; Set video mode 13h (320x200, 256 colors)
    mov   ax, 0013h                    ; Set video mode 13h
    int   10h                          ; Call BIOS interrupt

    ; Clear the screen (fill video memory with 0)
    mov   ax, 0A000h                   ; Video memory segment address
    mov   es, ax                       ; ES = video memory
    xor   di, di                       ; Starting offset in video memory
    mov   cx, 32000                    ; 320x200 pixels, 1 byte per pixel
    mov   al, 00h                      ; Black color (0)
    rep   stosb                        ; Clear the screen

    RET
ENDP  INIT_GAME


END