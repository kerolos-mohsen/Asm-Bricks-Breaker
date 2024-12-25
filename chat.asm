.model small
.stack 100h
.data

.code

PUBLIC  INIT_SERIAL
INIT_SERIAL PROC NEAR
	; initinalize COM
	;Set Divisor Latch Access Bit
	mov dx,3fbh 			; Line Control Register
	mov al,10000000b		;Set Divisor Latch Access Bit
	out dx,al				;Out it
	;Set LSB byte of the Baud Rate Divisor Latch register.
	mov dx,3f8h			
	mov al,030h		
	out dx,al

	;Set MSB byte of the Baud Rate Divisor Latch register.
	mov dx,3f9h
	mov al,00h
	out dx,al

	;Set port configuration
	mov dx,3fbh
	mov al,00011111b
	out dx,al
	RET
INIT_SERIAL ENDP 

END