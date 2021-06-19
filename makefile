CC=gcc
CFLAGS=-m32 -no-pie
ASM=nasm
ASMFLAGS=-f elf32 -g -F dwarf

.PHONY: clean

make: sped

sped.o: sped.asm
	$(ASM) $(ASMFLAGS) -g $^ -o $@

sped: sped.o
	$(CC) $(CFLAGS) $^ -o $@

clean:
	rm sped *.o
