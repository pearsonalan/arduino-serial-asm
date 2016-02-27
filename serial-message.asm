;************************************
; serial-message.asm
;
; write a constant message to the serial
; port.
;************************************

.nolist
.include "./m328Pdef.asm"
.list

.def temp = r16
.def overflows = r18

;
; Set up the Interrupt Vector:
;   0x0000 (RESET) => reset
;   0x0020 (TIMER0 OVF) => overflow_handler
;

.org 0x0000
	jmp reset		; PC = 0x0000	RESET

.org 0x0020
	jmp overflow_handler	; PC = 0x0020   TIMER0 OVF


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

	ldi	temp, 5			; set the Clock Selector Bits CS00, CS01, CS02 to 101
	out	TCCR0B, temp		; this puts Timer Counter0, TCNT0 in to FCPU/1024 mode
					; so it ticks at the CPU freq/1024

	ldi	temp, 0b00000001	; set the Timer Overflow Interrupt Enable (TOIE0) bit 
	sts	TIMSK0, temp		; of the Timer Interrupt Mask Register (TIMSK0)

	clr	temp
	out	TCNT0, temp		; initialize the Timer/Counter to 0

	rcall	USART_Init_9600		; initialize the serial communications

	sei				; enable global interrupts

	rjmp	main


;=====================
; timer overflow interrupt handler
overflow_handler: 
	inc	overflows		; add 1 to the overflows variable
	reti				; return from interrupt

;=======================
; Initialize the USART to 9600 Baud
;
USART_Init_9600:
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
	lds	temp, UCSR0A
	sbrs	temp, UDRE0
	rjmp	USART_Transmit

	; Put data (r19) into buffer, sends the data
	sts	UDR0, r19
	ret


;======================
; Main body of program:

main:
	ldi	zl, LOW(message<<1)	; load address of message into zh:zl
	ldi	zh, HIGH(message<<1)	

loop:
	lpm	r19, z+			; load the byte pointed at by Z and increment pointer
	tst	r19			; see if the byte is a 0 byte
	breq	newline			; branch if zero
	rcall	USART_Transmit		; send the character in r19 to the USART
	brne	loop			; if not go back and print again

newline:
	; send cr to the USART
	ldi	r19, $0D
	rcall	USART_Transmit

	; send newline to the USART
	ldi	r19, $0A
	rcall	USART_Transmit

	; wait for a bit
	rcall	delay
	
	rjmp	main			; else go back and to reset the Z pointer



;====================
; simple delay function 
;   delay about 1 second

delay:
	clr	overflows		; set overflows to 0 
sec_count:
	cpi	overflows, 61		; compare number of overflows and 61
	brne	sec_count		; branch to back to sec_count if not equal 
	ret				; if 61 overflows have occured return


.cseg

message:
	.db	"Hello World", 0

