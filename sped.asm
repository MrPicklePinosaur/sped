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
    readlines_str db `opened file with %i lines\n`, 0x00
    prompt_str db `sped > `, 0x00
    invalidcmd_str db `invalid command\n`, 0x00
    invalidaddr_str db `invalid address\n`, 0x00
    charcount_str db `read %i chars\n`, 0x00
    currentline_str db `current line: %i\n`, 0x00
    echo_str db `%s`, 0x00 ; print strings without format exploit

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
    mov [buffer_lines], ecx
    mov DWORD [cur_line], 0x00

    push DWORD [buffer_lines]
    push readlines_str
    call printf

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
    jne _repl_invalid_cmd

    ; parse commands
    mov eax, DWORD [ebp-CMDSTR]
    mov eax, [eax]

    ; q exists program
    mov eax, DWORD [ebp-CMDSTR]
    cmp BYTE [eax], 'q'
    jne _repl_cmd_quit_end
    jmp _repl_exit
    _repl_cmd_quit_end:

    ; p prints current line
    mov eax, DWORD [ebp-CMDSTR]
    cmp BYTE [eax], 'p'
    jne _repl_cmd_print_end

    mov eax, DWORD [cur_line]
    mov ecx, 4
    mul ecx
    add eax, [buffer]
    push DWORD [eax]
    push echo_str
    call printf
    jmp _repl_continue
    _repl_cmd_print_end:

    ; n prints the current line number
    mov eax, DWORD [ebp-CMDSTR]
    cmp BYTE [eax], 'n'
    jne _repl_cmd_number_end

    push DWORD [cur_line]
    push currentline_str
    call printf

    jmp _repl_continue
    _repl_cmd_number_end:

    ; - goes to prev line
    mov eax, DWORD [ebp-CMDSTR]
    cmp BYTE [eax], '-'
    jne _repl_cmd_decline_end

    ; make sure we are within bounds
    mov eax, DWORD [cur_line] 
    sub eax, 1
    cmp eax, 0
    jl _repl_invalid_addr
    
    sub DWORD [cur_line], 1

    jmp _repl_continue
    _repl_cmd_decline_end:

    ; + goes to next line
    mov eax, DWORD [ebp-CMDSTR]
    cmp BYTE [eax], '+'
    jne _repl_cmd_incline_end

    ; make sure we are within bounds 
    mov eax, DWORD [cur_line] 
    add eax, 1
    cmp eax, [buffer_lines]
    jge _repl_invalid_addr
    
    add DWORD [cur_line], 1

    jmp _repl_continue
    _repl_cmd_incline_end:


    jmp _repl_invalid_cmd

    ; some error messages
    _repl_invalid_cmd:
    push invalidcmd_str
    call printf
    jmp _repl_continue

    _repl_invalid_addr:
    push invalidaddr_str
    call printf
    jmp _repl_continue

    _repl_continue:
    jmp _repl_loop
    
    _repl_exit:

    %undef CMDSTR

    mov esp, ebp
    pop ebp
    ret
    
