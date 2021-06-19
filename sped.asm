; sped - the stupidly pointless editor
; written by pinosaur

%include "fileutils.S"

global main
extern printf

section .data
    banner_str db `SPED - the stupidly pointless editor\n`, 0x00
    nofile_str db `no file provided\n`, 0x00

section .text
main:
    %define _ARGC 8
    %define _ARGV 12

    push ebp
    mov ebp, esp

    ; read command line args
    mov ecx, [ebp+_ARGC]
    cmp ecx, 1
    jg _main_existing
    
    ; display error msg if no file
    push nofile_str
    call printf
    mov eax, 1
    jmp _main_exit

    _main_existing:
    mov ebx, DWORD [ebp+_ARGV]
    add ebx, 4 ; first user arg is filename
    push DWORD [ebx]
    call readFile

    mov eax, 0
    jmp _main_exit

    _main_exit:
    %undef _ARGC
    %undef _ARGV

    mov esp, ebp
    pop ebp
    ret

