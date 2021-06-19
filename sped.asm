; sped - the stupidly pointless editor
; written by pinosaur

%include "fileutils.S"

global main
extern printf
extern fflush
extern stdout

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
    prompt_str db `sped > `, 0x00
    invalidcommand_str db `invalid command\n`, 0x00
    charcount_str db `read %i chars\n`, 0x00

section .bss
    buffer resb 4
    buffer_lines resb 4
    cur_line resb 4

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

    mov [buffer], eax
    mov [buffer_lines], ebx
    mov DWORD [cur_line], 0x00

    call repl

    mov eax, 0
    jmp _main_exit

    _main_exit:
    %undef _ARGC
    %undef _ARGV

    mov esp, ebp
    pop ebp
    ret

; prompt for user
; no args - reads from globals
repl:

    %define CMDSTR 4 ; the previous line read from user

    push ebp
    mov ebp, esp

    sub esp, 4

    _repl_loop:
    
    ; print the prompt
    push prompt_str
    call printf
    push DWORD [stdout]
    call fflush

    ; read line from stdin
    push 0
    call readLine

    mov DWORD [ebp-CMDSTR], eax

    ; commands are single char for now
    cmp ecx, 1 
    jne _repl_invalid

    ; parse commands
    mov eax, DWORD [ebp-CMDSTR]
    mov eax, [eax]

    ; q exists program
    mov eax, DWORD [ebp-CMDSTR]
    cmp BYTE [eax], 'q'
    jne _repl_cmd_quit_end
    jmp _repl_exit
    _repl_cmd_quit_end:


    _repl_invalid:
    push invalidcommand_str
    call printf

    _repl_continue:
    jmp _repl_loop
    
    _repl_exit:

    %undef CMDSTR

    mov esp, ebp
    pop ebp
    ret
    
