ARCH=$(shell uname)

ifeq ($(ARCH),Darwin)
  CC=clang
else ifeq ($(ARCH), Linux)
  CC=gcc
else
  $(error unsupported architecture)
endif

all: avr-sim

avr-sim: avr-sim.c
	$(CC) -I /usr/local/include/simavr -g -o avr-sim avr-sim.c -lsimavr -lelf

clean:
	rm avr-sim

