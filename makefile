
.PHONY: clean

make: sped

sped.o: sped.asm
	nasm -f elf32 $^ -o $@

sped: sped.o
	ld -m elf_i386 $^ -o $@

clean:
	rm sped *.o
