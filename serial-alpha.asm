;************************************
; serial.asm
;************************************

.nolist
.include "./m328Pdef.asm"
.list


.cseg

;
; Set up the Interrupt Vector at 0x0000
;
; We only use 1 interrupt in this program, the RESET
; interrupt.
;

.org 0x0000
	jmp reset		; PC = 0x0000	RESET


;======================
; initialization

.org 0x0034
reset: 
	clr	r1			; set the SREG to 0
	out	SREG, r1

	ldi	r28, LOW(RAMEND)	; init the stack pointer to point to RAMEND
	ldi	r29, HIGH(RAMEND)
	out	SPL, r28
	out	SPH, r29

	rcall	USART_Init		; initialize the serial communications
	sei				; enable global interrupts
	rjmp	main

;=======================
; Initialize the USART
;
USART_Init:
	; these values are for 9600 Baud with a 16MHz clock
	ldi	r16, 103
	clr	r17

	; Set baud rate
	sts	UBRR0H, r17
	sts	UBRR0L, r16

	; Enable receiver and transmitter
	ldi	r16, (1<<RXEN0)|(1<<TXEN0)
	sts	UCSR0B, r16

	; Set frame format: Async, no parity, 8 data bits, 1 stop bit
	ldi	r16, 0b00001110
	sts	UCSR0C, r16
	ret

;=======================
; send a byte over the serial wire
; byte to send is in r19

USART_Transmit:
	; wait for empty transmit buffer
	lds	r16, UCSR0A
	sbrs	r16, UDRE0
	rjmp	USART_Transmit

	; Put data (r19) into buffer, sends the data
	sts	UDR0, r19
	ret


;======================
; Main body of program:

main:
	ldi	r19, $41		; load 'A' into r19
loop:
	rcall	USART_Transmit		; send the character in r19 to the USART
	inc	r19			; increment to the next character
	cpi	r19, $5B		; see if we are now at ascii 91 ('[' or the first letter past 'Z')
	brne	loop			; if not go back and print again

	; send cr to the USART
	ldi	r19, $0D
	rcall	USART_Transmit

	; send newline to the USART
	ldi	r19, $0A
	rcall	USART_Transmit
	
	rjmp	main			; else go back and to reset the value in r19

