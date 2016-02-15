all: avr-sim

avr-sim: avr-sim.c
	clang -I /usr/local/include/simavr -g -o avr-sim avr-sim.c -lsimavr -lelf

clean:
	rm avr-sim

