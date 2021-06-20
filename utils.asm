
%include "macros.S"

extern memmove
extern free
extern realloc

global shiftLeft
global shiftRight

section .text

; shrinks array (4byte) by shifting blocks left
; args: buffer, buffer_len, shift_pos (index that gets destroyed)
; return:
;   eax: location of new buffer
; issues: 
shiftLeft:
    %define _BUFFER      16
    %define _BUFFER_LEN  12
    %define _SHIFT_POS   8
    %define SHIFT_LEN    4
    %define BLOCK_OFFSET 8 ; mem location of block to be destroyed
    %define NEW_BUFFER   12

    push ebp
    mov ebp, esp

    sub esp, 12

    ; set vars
    mov eax, DWORD [ebp+_BUFFER_LEN]
    sub eax, [ebp+_SHIFT_POS]
    sub eax, 1
    mov [ebp-SHIFT_LEN], eax

    str_offset [ebp+_BUFFER], [ebp+_SHIFT_POS]
    mov [ebp-BLOCK_OFFSET], eax
    
    ; free string to be destoryed first
    mov eax, DWORD [ebp-BLOCK_OFFSET]
    mov eax, [eax]
    push eax
    call free

    ; move the memory
    mov eax, DWORD [ebp-SHIFT_LEN]
    mov ecx, 4
    mul ecx
    push eax
    mov eax, DWORD [ebp-BLOCK_OFFSET]
    add eax, 4
    push eax
    push DWORD [ebp-BLOCK_OFFSET]
    call memmove
    
    ; realloc to shrink the array
    mov eax, DWORD [ebp+_BUFFER_LEN]
    sub eax, 1 
    mov ecx, 4
    mul ecx
    push eax
    push DWORD [ebp+_BUFFER]
    call realloc
    mov [ebp-NEW_BUFFER], eax

    %undef _BUFFER
    %undef _BUFFER_LEN
    %undef _SHIFT_POS

    mov eax, [ebp-NEW_BUFFER]
    
    mov esp, ebp
    pop ebp
    ret

; grows array by shifting blocks right
; args: buffer, buffer_len, shift_pos (new uninitalized index)
; return:
;   eax: location of new buffer
shiftRight:
    %define _BUFFER      16
    %define _BUFFER_LEN  12
    %define _SHIFT_POS   8
    %define SHIFT_LEN    4
    %define BLOCK_OFFSET 8 ; mem location of block to be destroyed
    %define NEW_BUFFER   12

    push ebp
    mov ebp, esp

    sub esp, 12

    ; realloc to make memory bigger first
    mov eax, DWORD [ebp+_BUFFER_LEN]
    add eax, 1
    mov ecx, 4
    mul ecx
    push eax
    push DWORD [ebp+_BUFFER]
    call realloc
    mov [ebp-NEW_BUFFER], eax

    ; set vars
    mov eax, DWORD [ebp+_BUFFER_LEN]
    sub eax, [ebp+_SHIFT_POS]
    mov [ebp-SHIFT_LEN], eax

    str_offset [ebp-NEW_BUFFER], [ebp+_SHIFT_POS]
    mov [ebp-BLOCK_OFFSET], eax

    ; move the memory
    mov eax, DWORD [ebp-SHIFT_LEN]
    mov ecx, 4
    mul ecx
    push eax
    push DWORD [ebp-BLOCK_OFFSET]
    mov eax, DWORD [ebp-BLOCK_OFFSET]
    add eax, 4
    push eax
    call memmove

    %undef _BUFFER
    %undef _BUFFER_LEN
    %undef _SHIFT_POS

    mov eax, [ebp-NEW_BUFFER]
    
    mov esp, ebp
    pop ebp
    ret

