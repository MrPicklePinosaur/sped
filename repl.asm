
%include "fileutils.S"

extern printf
extern fflush
extern stdout
extern free

global repl

section .data
    prompt_str db `sped > `, 0x00
    invalidcmd_str db `invalid command\n`, 0x00
    invalidaddr_str db `invalid address\n`, 0x00
    charcount_str db `read %i chars\n`, 0x00
    currentline_str db `current line: %i\n`, 0x00
    echo_str db `%s`, 0x00 ; print strings without format exploit

section .bss
    buffer resb 4
    buffer_lines resb 4
    buffer_filename resb 4
    cur_line resb 4

section .text

; prompt for user
; args: buffer, buffer_lines, buffer_filename
repl:

    %define _BUFFER          16
    %define _BUFFER_LINES    12
    %define _BUFFER_FILENAME 8
    %define CMDSTR           4 ; the previous line read from user

    push ebp
    mov ebp, esp

    sub esp, 4
    
    ; set bss vars
    mov eax, [ebp+_BUFFER]
    mov [buffer], eax
    mov eax, [ebp+_BUFFER_LINES]
    mov [buffer_lines], eax
    mov eax, [ebp+_BUFFER_FILENAME]
    mov [buffer_filename], eax
    mov DWORD [cur_line], 0x00

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

    ; q exists program =-=-=-=-=-=-=-=-=-=-=-=-=
    mov eax, DWORD [ebp-CMDSTR]
    cmp BYTE [eax], 'q'
    jne _repl_cmd_quit_end
    jmp _repl_exit
    _repl_cmd_quit_end:

    ; p prints current line =-=-=-=-=-=-=-=-=-=-=
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

    ; n prints the current line number =-=-=-=-=-=-=-=
    mov eax, DWORD [ebp-CMDSTR]
    cmp BYTE [eax], 'n'
    jne _repl_cmd_number_end

    push DWORD [cur_line]
    push currentline_str
    call printf

    jmp _repl_continue
    _repl_cmd_number_end:

    ; - goes to prev line =-=-=-=-=-=-=-=-=-=-=-=-=
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

    ; + goes to next line =-=-=-=-=-=-=-=-=-=-=-=-=
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

    ; g goes to first line =-=-=-=-=-=-=-=-=-=-=-=-=
    mov eax, DWORD [ebp-CMDSTR]
    cmp BYTE [eax], 'g'
    jne _repl_cmd_jumptop_end

    mov DWORD [cur_line], 0x00

    jmp _repl_continue
    _repl_cmd_jumptop_end:

    ; G goes to last line =-=-=-=-=-=-=-=-=-=-=-=-=
    mov eax, DWORD [ebp-CMDSTR]
    cmp BYTE [eax], 'G'
    jne _repl_cmd_jumpbot_end

    mov eax, DWORD [buffer_lines]
    sub eax, 1
    mov DWORD [cur_line], eax

    jmp _repl_continue
    _repl_cmd_jumpbot_end:

    ; c changes the current line =-=-=-=-=-=-=-=-=-=
    mov eax, DWORD [ebp-CMDSTR]
    cmp BYTE [eax], 'c'
    jne _repl_cmd_change_end

    ; read a new line to use
    push 0
    call readLine

    mov esi, eax

    ; free old string
    mov eax, [cur_line]
    mov ecx, 4
    mul ecx
    add eax, [buffer]
    push DWORD [eax]
    call free

    ; insert new string
    mov eax, [cur_line]
    mov ecx, 4
    mul ecx
    add eax, DWORD [buffer]
    mov [eax], esi

    jmp _repl_continue
    _repl_cmd_change_end:

    ; d delete line =-=-=-=-=-=-=-=-=-=-=-=-=
    mov eax, DWORD [ebp-CMDSTR]
    cmp BYTE [eax], 'd'
    jne _repl_cmd_delete_end

    

    jmp _repl_continue
    _repl_cmd_delete_end:

    ; w writes file =-=-=-=-=-=-=-=-=-=-=-=-=
    mov eax, DWORD [ebp-CMDSTR]
    cmp BYTE [eax], 'w'
    jne _repl_cmd_write_end

    push DWORD [buffer_filename]
    push DWORD [buffer]
    push DWORD [buffer_lines]
    call writeFile

    jmp _repl_continue
    _repl_cmd_write_end:


    ; if no commands were matched, it's an error
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

    %undef _BUFFER
    %undef _BUFFER_LINES
    %undef _BUFFER_FILENAME
    %undef CMDSTR

    mov esp, ebp
    pop ebp
    ret
    
