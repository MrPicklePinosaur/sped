
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

section .text
main:
    push ebp
    mov ebp, esp

    ; read command line args
    mov ecx, [ebp+8]

    cmp ecx, 1
    jg .readFile
    
    ; display error msg if no file
    push nofile_str
    call printf
    mov eax, 1
    jmp .exit

.readFile:

    mov ebx, DWORD [ebp+12]
    add ebx, 4
    push DWORD [ebx]
    push readfile_str
    call printf

    mov eax, 0
    jmp .exit

.exit:
    mov esp, ebp
    pop ebp
    ret

