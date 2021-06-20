
%ifndef __UTILS_S__
%define __UTILS_S__

; gets the nth string ptr in a str array
; of the form: str_offset buffer, n
; result is in eax
%macro str_offset 2
    mov eax, %2
    mov ecx, 4
    mul ecx
    add eax, DWORD %1
%endmacro

extern shiftLeft
extern shiftRight

%endif
