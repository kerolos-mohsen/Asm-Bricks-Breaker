.model small
.stack 100h

.DATA
  
    sender_cursor_row db 0
    sender_cursor_col db 0
    public IS_RECIEVER_FOUND
    IS_RECIEVER_FOUND db 0
    public IS_INGAME
    IS_INGAME db 0
    public CRT_PLAYER
    CRT_PLAYER db 0
    public GAME_STATE
    GAME_STATE db 0    ; Variable to store user's GAME_STATE

.code

;;;;;;;;;		Extrns		;;;;;;;;;

EXTRN CHECK_SERIAL_MESSAGE:FAR
EXTRN SEND_SERIAL_CHARACTER:FAR
EXTRN ENTER_USERNAME:FAR
EXTRN MOVE_CURSOR:FAR
EXTRN menu:FAR
EXTRN INIT_SERIAL:FAR
EXTRN SPLIT_SCREEN:FAR
EXTRN START_GAME:FAR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    CALL INIT_SERIAL
    ; CALL CLEAR_WINDOW
    ; CALL ENTER_USERNAME
    CALL CLEAR_WINDOW
    call menu
    CALL CLEAR_WINDOW
    CALL SPLIT_SCREEN
    
    MAIN_LOOP:
        cmp GAME_STATE,2 ; or GAME_STATE is 2
        jne NOT_IN_GAME
        CALL START_GAME
        
        NOT_IN_GAME:
        CALL HANDLE_KEY_PRESS ; Process any key press
        ; Get current cursor position
        mov ah, 03h
        int 10h
        mov sender_cursor_row, dh
        mov sender_cursor_col, dl
        
        CALL CHECK_SERIAL_MESSAGE ; Check if there is a message to be recieved
        
        mov dh, sender_cursor_row
        mov dl, sender_cursor_col
        mov bh, 0
        mov ah, 2
        int 10h
    JMP MAIN_LOOP
    

    public  EXIT_GAME
    EXIT_GAME PROC FAR           
    ; Clear screen
        MOV   AH, 0
        MOV   AL, 3
        INT   10H

    ; Exit program
        MOV   AH, 4CH
        INT   21H
    EXIT_GAME ENDP
main ENDP

PUBLIC CLEAR_WINDOW
CLEAR_WINDOW PROC FAR
	mov al, 03h
	mov ah, 0
	int 10h
	RET
CLEAR_WINDOW ENDP


PUBLIC HANDLE_KEY_PRESS
HANDLE_KEY_PRESS PROC FAR
    ; Check if key is pressed
    mov ah, 01h
    INT 16h
    JNZ MESSAGE_AVAILABLE  ; No key pressed
    ret
    MESSAGE_AVAILABLE:
    ; read char from buffer
    mov ah, 0h
    INT 16h
    
    ; store al when coming here
    mov si,ax
    CMP GAME_STATE, 1 ; chat
    JNE CHECK_C_P
    
    CMP AH,03Bh ;compare for F1 scan code
    JNE CHECK_FOR_ESC
    mov al, 5               ; Signal code for play
    CALL SEND_SERIAL_CHARACTER  ; Send before changing local state
    mov GAME_STATE, 2
    mov IS_INGAME, 1
    mov CRT_PLAYER, 1
    
    CHECK_C_P:
    ; Restore letter to be written on screen
    mov ax,si
    ; Print Character To Display in blue
    mov ah, 09h
    mov cx, 1
    mov bx, 00001001b
    int 10h
    
    cmp GAME_STATE, 0
    jne CHECK_FOR_ESC
        
    cmp al, 'p'
    JNE NOT_P
    mov al, 5               ; Signal code for play
    CALL SEND_SERIAL_CHARACTER  ; Send before changing local state
    mov GAME_STATE, 2
    mov IS_INGAME, 1
    mov CRT_PLAYER, 1
    RET
    
NOT_P:
    cmp al, 'c'
    JNE NOT_C
    mov al, 6              ; Signal code for chat
    CALL SEND_SERIAL_CHARACTER  ; Send before changing local state
    mov GAME_STATE, 1
    CALL CLEAR_WINDOW
    RET            
    
NOT_C:
CHECK_FOR_ESC:
    CMP al, 27
    JNZ NOT_ESC 
    CALL EXIT_GAME
        
NOT_ESC:
    ; Print Character To Display in blue
    mov ah, 09h
    mov cx, 1
    mov bx, 00001001b
    int 10h
    CALL SEND_SERIAL_CHARACTER  ; Send before changing local state
    cmp IS_INGAME, 1
    JE KEYBOARD_CHECK_DONE
    CALL MOVE_CURSOR

KEYBOARD_CHECK_DONE:
    RET
HANDLE_KEY_PRESS ENDP

END