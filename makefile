CC=gcc
CFLAGS=-m32 -no-pie
ASM=nasm
ASMFLAGS=-f elf32 -g

.PHONY: clean

make: sped

%.o: %.asm
	$(ASM) $(ASMFLAGS) -o $@ $^

sped: sped.o fileutils.o repl.o
	$(CC) $(CFLAGS) -o $@ $^

clean:
	rm sped *.o
