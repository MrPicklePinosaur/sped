## SPED - the stupidly pointless editor

**sped** is a line editor written in x86 assembly. Back in the day, before visual editors, line editors like **ed** were used.
This is my own stupid and pointless attempt at writing such line editor.

### INSTALLATION

#### Build from source

with `gcc` and `nasm` installed, you can simply run
```
sudo make install
```
to build the project

### USAGE/COMMANDS

**sped** takes a single command line argument, the file you wish to open.
```
sped [file]
```

**p** - prints the contents of the current line

**n** - prints the current line number

**+/-** - moves up/down a line

**g/G** - jumps to top/bottom of file

**c** - change the contents of the current line

**o/O** - insert line after/before current line

**d** - delete current line

**w** - saves file

**q** - exists the program

### FAQ

**what is the point of this**

obviously, we live in a day and age where we have the comfort of visual editors, so line editors like these have become obsolete. i simply wanted to work on a relatively easy to implement project so i can learn some assembly.

**are you insane**

yes

