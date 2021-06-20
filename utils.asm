
extern memmove

global shiftLeft
global shiftRight

section .text

shiftLeft:
    push ebp
    mov ebp, esp
    
    
    
    mov esp, ebp
    pop ebp
    ret

shiftRight:
    push ebp
    mov ebp, esp

    
    
    mov esp, ebp
    pop ebp
    ret
