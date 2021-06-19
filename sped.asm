; sped - the stupidly pointless editor
; written by pinosaur

global main
extern printf
extern malloc
extern realloc
extern free
extern memset

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

    push eax
    call printf

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
;   eax: location to buffer
;   ebx: contains eof
readLine:
    %define _FILE_HANDLE 8
    %define CHAR_COUNT   4   ; count number of characters read
    %define BLOCK_COUNT  8   ; number of 64 blocks we've read
    %define STR_PTR      12  ; malloced buffer to store read string

    push ebp
    mov ebp, esp
    
    ; allocate vars
    sub esp, 8
    mov DWORD [ebp-CHAR_COUNT], 0x00
    mov DWORD [ebp-BLOCK_COUNT], 0x00

    push 64
    call malloc
    mov [ebp-STR_PTR], eax

    push DWORD [ebp-STR_PTR]
    push 0x00
    push 64

    _readLine_loop:
    ; if buffer is full
    cmp BYTE [ebp-CHAR_COUNT], 63 ; leave one byte for null byte
    jne _readLine_notfull
    jmp _readLine_exit

    _readLine_notfull:
    ; read a single character
    mov eax, 3
    mov ebx, [ebp+_FILE_HANDLE]
    mov ecx, [ebp-STR_PTR]
    add ecx, [ebp-CHAR_COUNT]
    mov edx, 1
    int 0x80

    ; mov eax, 4
    ; mov ebx, 1
    ; mov ecx, [ebp-STR_PTR]
    ; add ecx, [ebp-CHAR_COUNT]
    ; mov edx, 1
    ; int 0x80

    ; check for newline
    mov eax, [ebp-STR_PTR]
    add eax, [ebp-CHAR_COUNT]
    cmp DWORD [eax], 0x0a
    jne _readLine_not_newline
    mov ebx, 0
    jmp _readLine_exit
    _readLine_not_newline:
    
    ; check for eof
    mov eax, [ebp-STR_PTR]
    add eax, [ebp-CHAR_COUNT]
    cmp DWORD [eax], 0x05
    jne _readLine_not_eof
    mov ebx, 1
    jmp _readLine_exit 
    _readLine_not_eof:

    add DWORD [ebp-CHAR_COUNT], 1
    jmp _readLine_loop

    _readLine_exit:

    mov eax, DWORD [ebp-STR_PTR]

    %undef _FILE_HANDLE
    %undef CHAR_COUNT
    %undef BLOCK_COUNT 
    %undef STR_PTR

    mov esp, ebp
    pop ebp
    ret

