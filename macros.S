
%ifndef __UTILS_S__
%define __UTILS_S__

%macro write_str 2
    mov eax, 4
    mov ebx, 1
    mov ecx, %1
    mov edx, %2
    int 0x80
%endmacro

; gets the nth string ptr in a str array
; of the form: str_offset buffer, n
; result is in eax
%macro str_offset 2
    mov eax, %2
    mov ecx, 4
    mul ecx
    add eax, DWORD %1
%endmacro

%endif
