CC=gcc
CFLAGS=-m32 -no-pie
ASM=nasm
ASMFLAGS=-f elf32 -g
PREFIX=/usr/bin

.PHONY: clean install uninstall

make: sped

%.o: %.asm
	$(ASM) $(ASMFLAGS) -o $@ $^

sped: sped.o fileutils.o repl.o utils.o
	$(CC) $(CFLAGS) -o $@ $^

install: sped
	mkdir -p $(PREFIX)
	cp -f sped $(PREFIX)
	chmod 775 $(PREFIX)/sped

uninstall:
	rm -f $(PREFIX)/sped

clean:
	rm sped *.o
