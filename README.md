# arduino-serial-asm

This repository contains code which communicates with a host PC from an
Arduino (or other ATmega 328 device) using the USART.  

I have been experimenting with programming the Arduino using assembly
language of late and found it interesting. When writing C/C++ code for 
the arduino, a debugging technique I have used is to write information
back to the PC using the `Serial` library of the Arduino/Wiring platform.

Three programs in this repo implement serial communications of different
types:

## serial-alpha.asm

Repeatedly write the alphabet to the USART.

## serial-message.asm

Write a message to the serial port which is stored in the code segment.
In this case, the message is "Hello World". (original, huh?)

## serial-intterupt.asm

Both of the above programs use blocking mode, polling on the UDRE0 (USART
Data Register Empty 0) bit of the UCSR0A register (USART Control and Status
Register 0 A) to determine when UDR (the USART Data Register) is empty and
ready for a new byte to be sent. The `serial-interrupt.asm` program enables
the UDRE0 interrupt and has an interrupt handler to send the next byte 
of the message.

* For a great introduction to AVR Assembly programming see [Command Line
Assembly Language AVR Tutorials](http://www.instructables.com/id/Command-Line-AVR-Tutorials/)
on Instructables.
