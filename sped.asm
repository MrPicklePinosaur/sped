; sped - the stupidly pointless editor
; written by pinosaur

global main
extern printf

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
    readfile_str db `reading file %s\n`, 0x00
    nofile_str db `no file provided\n`, 0x00
    argcount_str db `there are %d args\n`, 0x00
    wrongfile_str db `unable to open file, error code: %i\n`, 0x00
    char_str db `read this char: %i\n`, 0x00
    printfint_str db `int: %i\n`, 0x00

section .bss
    read_buf resb 64

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
    add ebx, 4
    push DWORD [ebx]
    ; push readfile_str
    ; call printf

    call readFile

    mov eax, 0
    jmp _main_exit

    _main_exit:
    %undef _ARGC
    %undef _ARGV

    mov esp, ebp
    pop ebp
    ret


; reads file line by line
; args: filename
; return:
;    eax - pointer to mem
;    ecx - lines read
readFile:
    %define _FILE_NAME 8
    %define FILE_HANDLE 4

    push ebp
    mov ebp, esp
    
    ; allocate vars
    sub esp, 4
    mov DWORD [ebp-FILE_HANDLE], 0x00

    ; open existing file
    mov eax, 5
    mov ebx, [ebp+_FILE_NAME]
    mov ecx, 0
    mov edx, 0777
    int 0x80
    mov [ebp-FILE_HANDLE], eax

    ; check if file was open successfully
    cmp eax, 0
    jge _readFile_noerror
    push eax
    push wrongfile_str
    call printf
    jmp _readFile_exit

    _readFile_noerror:
    push DWORD [ebp-FILE_HANDLE]
    call readLine 

    jmp _readFile_exit

    _readFile_exit:
    ; close file
    mov eax, 6
    mov ebx, [ebp-FILE_HANDLE]
    int 0x80

    %undef _FILE_NAME
    %undef FILE_HANDLE

    mov esp, ebp
    pop ebp
    ret


; reads a line until newline character is reached
; args: file_handle
; return:
;   location to buffer
;   contains eof
readLine:
    %define _FILE_HANDLE 8
    %define CHAR_PTR 4

    push ebp
    mov ebp, esp

    sub esp, 4
    mov DWORD [ebp-CHAR_PTR], 0x00

    _readLine_loop:
    ; if buffer is full
    cmp BYTE [ebp-CHAR_PTR], 64
    jne _readLine_notfull
    jmp _readLine_exit

    _readLine_notfull:
    ; read a single character
    mov eax, 3
    mov ebx, [ebp+_FILE_HANDLE]
    mov ecx, read_buf
    add ecx, [ebp-CHAR_PTR]
    mov edx, 1
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, read_buf
    add ecx, [ebp-CHAR_PTR]
    mov edx, 1
    int 0x80

    ; check for newline
    mov eax, read_buf
    add eax, [ebp-CHAR_PTR]
    cmp DWORD [eax], 0x0a
    je _readLine_exit
    
    ; check for eof
    mov eax, read_buf
    add eax, [ebp-CHAR_PTR]
    cmp DWORD [eax], 0x05
    je _readLine_exit

    add DWORD [ebp-CHAR_PTR], 1

    jmp _readLine_loop

    _readLine_exit:

    %undef _FILE_HANDLE
    %undef CHAR_PTR

    mov esp, ebp
    pop ebp
    ret

