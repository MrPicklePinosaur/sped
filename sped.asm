
%macro write_str 2
    mov eax, 4
    mov ebx, 1
    mov ecx, %1
    mov edx, %2
    int 0x80
%endmacro

section .data
    msg db "SPED - the stupidly pointless editor", 0x0a
    len equ $ - msg

section .text
global _start
_start:
    write_str msg, len

    mov eax, 1
    mov ebx, 42
    int 0x80
