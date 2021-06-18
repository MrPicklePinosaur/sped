CC=gcc
CFLAGS=-m32 -no-pie -g

.PHONY: clean

make: sped

sped.o: sped.asm
	nasm -f elf32 $^ -o $@

sped: sped.o
	$(CC) $(CFLAGS) $^ -o $@

clean:
	rm sped *.o
