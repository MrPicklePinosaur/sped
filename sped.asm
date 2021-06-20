; sped - the stupidly pointless editor
; written by pinosaur

%include "fileutils.S"
%include "repl.S"

extern printf

global main

; macros
%macro write_str 2
    mov eax, 4
    mov ebx, 1
    mov ecx, %1
    mov edx, %2
    int 0x80
%endmacro

section .data
    banner_str db `SPED - the stupidly pointless editor\n`, 0x00
    nofile_str db `no file provided\n`, 0x00
    readlines_str db `opened file with %i lines\n`, 0x00

section .text
main:
    %define _ARGC 8
    %define _ARGV 12

    %define BUFFER          4
    %define BUFFER_LINES    8
    %define BUFFER_FILENAME 12

    push ebp
    mov ebp, esp

    sub esp, 12

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
    mov ebx, [ebx]
    mov [ebp-BUFFER_FILENAME], ebx

    push DWORD [ebp-BUFFER_FILENAME]
    call readFile

    mov [ebp-BUFFER], eax
    mov [ebp-BUFFER_LINES], ecx

    push DWORD [ebp-BUFFER_LINES]
    push readlines_str
    call printf

    push DWORD [ebp-BUFFER]
    push DWORD [ebp-BUFFER_LINES]
    push DWORD [ebp-BUFFER_FILENAME]
    call repl

    mov eax, 0
    jmp _main_exit

    _main_exit:

    ; free string array

    %undef _ARGC
    %undef _ARGV
    %undef BUFFER
    %undef BUFFER_LINES
    %undef BUFFER_FILENAME

    mov esp, ebp
    pop ebp
    ret

