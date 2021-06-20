
%include "macros.S"

extern printf
extern malloc
extern realloc
extern free
extern memset
extern strlen

global readFile
global readLine
global writeFile

section .data
    wrongfile_str db `unable to open file, error code: %i\n`, 0x00
    returnvalue_str db `system call return was %i\n`, 0x00

section .text

; reads file line by line
; args: filename
; return:
;    eax - pointer to mem
;    ecx - lines read
readFile:
    %define _FILE_NAME  8
    %define FILE_HANDLE 4
    %define IS_EOF      8
    %define LINES_READ  12
    %define BUF_PTR     16 ; malloced array of strings

    push ebp
    mov ebp, esp
    
    ; allocate vars
    sub esp, 16
    mov DWORD [ebp-FILE_HANDLE], 0x00
    mov DWORD [ebp-IS_EOF], 0x00
    mov DWORD [ebp-LINES_READ], 0x00

    push 0
    call malloc 
    mov [ebp-BUF_PTR], eax

    ; open existing file
    mov eax, 5
    mov ebx, [ebp+_FILE_NAME]
    mov ecx, 0
    mov edx, 0777
    int 0x80
    mov [ebp-FILE_HANDLE], eax

    ; check if file was open successfully
    cmp eax, 0
    jge _readFile_loop
    push eax
    push wrongfile_str
    call printf
    jmp _readFile_exit

    _readFile_loop:

    push DWORD [ebp-FILE_HANDLE]
    call readLine 
    mov esi, eax
    mov [ebp-IS_EOF], ebx

    ; check if eof was reached
    cmp DWORD [ebp-IS_EOF], 1
    je _readFile_exit

    
    ; push esi
    ; call printf

    ; make string buffer bigger
    mov eax, DWORD [ebp-LINES_READ]
    add eax, 1
    mov ecx, 4
    mul ecx
    push eax
    push DWORD [ebp-BUF_PTR]
    call realloc
    mov DWORD [ebp-BUF_PTR], eax

    ; write string to buffer
    mov eax, [ebp-LINES_READ]
    mov ecx, 4
    mul ecx
    add eax, DWORD [ebp-BUF_PTR]
    mov [eax], esi

    ; push DWORD [eax]
    ; call printf

    add DWORD [ebp-LINES_READ], 1

    jmp _readFile_loop

    _readFile_exit:
    ; close file
    mov eax, 6
    mov ebx, [ebp-FILE_HANDLE]
    int 0x80

    mov eax, [ebp-BUF_PTR]
    mov ecx, [ebp-LINES_READ]

    %undef _FILE_NAME
    %undef FILE_HANDLE
    %undef IS_EOF
    %undef LINES_READ
    %undef BUF_PTR

    mov esp, ebp
    pop ebp
    ret


; reads a line until newline character is reached
; args: file_handle
; return:
;   eax: location to buffer
;   ebx: contains eof
;   ecx: number of chars read
readLine:
    %define _FILE_HANDLE 8
    %define CHAR_COUNT   4   ; count number of characters read
    %define BLOCK_COUNT  8   ; number of 64 blocks we've read
    %define STR_PTR      12  ; malloced buffer to store read string

    push ebp
    mov ebp, esp
    
    ; allocate vars
    sub esp, 12
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
    
    ; check for eof
    cmp eax, 0 ; eax has zero on eof
    jne _readLine_not_eof
    mov ebx, 1
    jmp _readLine_exit 
    _readLine_not_eof:

    ; check for newline
    mov eax, [ebp-STR_PTR]
    add eax, [ebp-CHAR_COUNT]
    cmp DWORD [eax], 0x0a
    jne _readLine_not_newline
    mov ebx, 0
    jmp _readLine_exit
    _readLine_not_newline:

    add DWORD [ebp-CHAR_COUNT], 1
    jmp _readLine_loop

    _readLine_exit:

    mov eax, [ebp-BLOCK_COUNT]
    mov ecx, 63
    mul ecx
    add eax, [ebp-CHAR_COUNT]
    mov ecx,eax

    mov eax, DWORD [ebp-STR_PTR]

    %undef _FILE_HANDLE
    %undef CHAR_COUNT
    %undef BLOCK_COUNT 
    %undef STR_PTR

    mov esp, ebp
    pop ebp
    ret

; writes contents of string array into file
; arg: filename, string array, number of lines
writeFile:

    %define _FILE_NAME    16
    %define _STR_ARR      12
    %define _STR_ARR_LEN  8
    %define FILE_HANDLE   4
    %define LINES_WRITTEN 8

    push ebp
    mov ebp, esp

    ; allocate vars
    sub esp, 8
    mov DWORD [ebp-FILE_HANDLE], 0x00
    mov DWORD [ebp-LINES_WRITTEN], 0x00

    ; open existing file
    mov eax, 5
    mov ebx, [ebp+_FILE_NAME]
    mov ecx, 2
    mov edx, 0777
    int 0x80
    mov [ebp-FILE_HANDLE], eax

    ; check if file was open successfully
    cmp eax, 0
    jl _writeFile_error

    ; truncate file
    mov eax, 93
    mov ebx, [ebp-FILE_HANDLE]
    mov ecx, 1
    int 0x80
    
    _writeFile_loop:

    ; check if we are done writing
    mov eax, [ebp+_STR_ARR_LEN]
    cmp eax, [ebp-LINES_WRITTEN]
    je _writeFile_exit

    ; get length of string to write
    str_offset [ebp+_STR_ARR], [ebp-LINES_WRITTEN]
    mov esi, eax
    push DWORD [esi]
    call strlen

    mov edx, eax
    mov eax, 4
    mov ebx, [ebp-FILE_HANDLE]    
    mov ecx, [esi]
    int 0x80

    add DWORD [ebp-LINES_WRITTEN], 1

    jmp _writeFile_loop

    _writeFile_error:
    push eax
    push wrongfile_str
    call printf
    jmp _writeFile_exit

    _writeFile_exit:

    ; close file
    mov eax, 6
    mov ebx, [ebp-FILE_HANDLE]
    int 0x80
    
    %undef _FILE_NAME
    %undef _STR_ARR
    %undef _STR_ARR_LEN
    %undef FILE_HANDLE
    
    mov esp, ebp
    pop ebp
    ret

