
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

; section .bss

section .text
main:
    push ebp
    mov ebp, esp

    ; read command line args
    mov ecx, [ebp+8]
    cmp ecx, 1
    jg .main_existing
    
    ; display error msg if no file
    push nofile_str
    call printf
    mov eax, 1
    jmp .main_exit

.main_existing:
    mov ebx, DWORD [ebp+12]
    add ebx, 4
    push DWORD [ebx]
    ; push readfile_str
    ; call printf

    call readFile

    mov eax, 0
    jmp .main_exit

.main_exit:
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
    mov edx, 0700
    int 0x80
    mov [ebp-FILE_HANDLE], eax

    ; check if file was open successfully
    cmp eax, 0
    jge .readFile_noerror
    push eax
    push wrongfile_str
    call printf
    jmp .readFile_exit

.readFile_noerror:

    jmp .readFile_exit

.readFile_exit:

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
; return: location to buffer
readLine:
    
    %define _FILE_HANDLE 8

    push ebp
    mov ebp, esp

.readLine_loop:

    ; read a single character
    mov eax, 3
    mov ebx, [ebp+_FILE_HANDLE]
    ; mov ecx, 
    mov edx, 1
    int 0x80

    jmp .readLine_loop

    mov esp, ebp
    pop ebp
    ret

