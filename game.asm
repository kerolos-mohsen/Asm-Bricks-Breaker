.model small
.stack 100h

.data
  AUX_TIME DB 0
.code

;;;;;;;;;		Extrns		;;;;;;;;;

EXTRN EXIT_GAME:FAR
EXTRN DRAWBLOCKS:FAR
EXTRN DISPLAY_HEARTS:FAR
EXTRN DisplayScores:FAR
EXTRN draw_paddles:FAR
EXTRN move_crtPlayer_paddle:FAR
EXTRN send_crtPlayer_pad_pos:FAR
EXTRN read_otherPlayer_pad_pos:FAR
EXTRN DRAW_BALL:FAR
EXTRN MOVE_BALL_BY_VELOCITY:FAR
EXTRN DELETE_BALL:FAR
EXTRN CHECK_FOR_WIN:FAR
EXTRN DELETE_HEARTS:FAR
EXTRN PLAYER_LIVES:Byte
EXTRN RESET_PADDLES:FAR
EXTRN DISPLAY_LOOSE_MESSAGE:FAR
EXTRN CLEAR_WINDOW:FAR
EXTRN SEND_SERIAL_CHARACTER:FAR
EXTRN SPLIT_SCREEN:FAR
EXTRN IS_INGAME:Byte
EXTRN GAME_STATE:Byte
EXTRN CHECK_SERIAL_MESSAGE:FAR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

public START_GAME
START_GAME PROC FAR
    CALL  INIT_GAME
    CALL  DRAWBLOCKS
    CALL  DISPLAY_HEARTS
    ; call  DisplayScores
   
    CHECK_TIME:  
        call  draw_paddles
        mov   ah, 01h             ; check for key press
        int   16h
        jz    NO_INPUT_ACTION     ; check for key press
        
        ; Read the key that was pressed
        mov   ah, 00h             ; Get keystroke
        int   16h
        
        CMP   AL, 27             ; Check if key is ESC
        JE    exit               ; If ESC, exit program
           
        cmp   al, 'c'
        JNE   NOT_C
        
        ; Save registers before changing game state
        push  ax
        push  dx
        
        mov   al, 6              ; Signal code for chat
        CALL  SEND_SERIAL_CHARACTER  
        
        ; Change game state after successful transmission
        cli                      ; Disable interrupts while changing state
        mov   GAME_STATE, 1
        mov   IS_INGAME, 0
        sti                      ; Re-enable interrupts
        
        CALL  CLEAR_WINDOW
        CALL  SPLIT_SCREEN
        
        pop   dx
        pop   ax
        jmp   CHECK_TIME         ; Return to main loop instead of IRET
        
    NOT_C:
        call  move_crtPlayer_paddle
        
    NO_INPUT_ACTION:
        call  CHECK_SERIAL_MESSAGE  
        call  send_crtPlayer_pad_pos
        call  read_otherPlayer_pad_pos
       
        MOV   AH, 2CH
        INT   21H
        CMP   DL, AUX_TIME
        JE    CHECK_TIME
        MOV   AUX_TIME, DL
        
        CALL  DELETE_BALL
        CALL  MOVE_BALL_BY_VELOCITY
        CALL  DRAW_BALL
        call  CHECK_FOR_WIN
       
        JMP   CHECK_TIME
           
    exit:
        call  EXIT_GAME
        
START_GAME ENDP



public TRY_AGAIN
TRY_AGAIN   PROC    FAR
    CALL DELETE_HEARTS
    
    dec PLAYER_LIVES
    JZ DISPLAY_LOOSE_MESSAGE_LABEL

    CALL  DISPLAY_HEARTS
    call RESET_PADDLES
    RET
    
    DISPLAY_LOOSE_MESSAGE_LABEL: 
    call DISPLAY_LOOSE_MESSAGE
    call EXIT_GAME
ENDP TRY_AGAIN

END