global start

section .text
bits 32
start:
    mov esp, stack_top ; move stack pointer to top of stack
    ; print 'OK'
    mov dword [0xb8000], 0x2f4b2f4f
    hlt

section .bss
stack_bottom:
    resb 4096 * 4
stack_top:
