ifndef PORT
  PORT := /dev/ttyUSB0
endif

ifndef BAUD
  BAUD := 115200
endif

.PHONY: all upload

all: serial-alpha.hex serial-message.hex serial-interrupt.hex

serial-alpha.hex: serial-alpha.asm
	avra -l serial-alpha.lst serial-alpha.asm

serial-message.hex: serial-message.asm
	avra -l serial-message.lst serial-message.asm

serial-interrupt.hex: serial-interrupt.asm
	avra -l serial-interrupt.lst serial-interrupt.asm

upload-serial-alpha:
	avrdude -v -p m328p -c arduino -b $(BAUD) -P $(PORT) -U flash:w:serial-alpha.hex
	
upload-serial-message:
	avrdude -v -p m328p -c arduino -b $(BAUD) -P $(PORT) -U flash:w:serial-message.hex
	
upload-serial-interrupt:
	avrdude -v -p m328p -c arduino -b $(BAUD) -P $(PORT) -U flash:w:serial-interrupt.hex
	
clean:
	-rm serial-alpha.lst serial-alpha.cof serial-alpha.eep.hex serial-alpha.hex serial-alpha.obj
	-rm serial-message.lst serial-message.cof serial-message.eep.hex serial-message.hex serial-message.obj
	-rm serial-interrupt.lst serial-interrupt.cof serial-interrupt.eep.hex serial-interrupt.hex serial-interrupt.obj
