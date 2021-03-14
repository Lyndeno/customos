global start

section .text
bits 32
start:
    mov esp, stack_top ; move stack pointer to top of stack

    call check_multiboot
    call check_cpuid
    call check_long_mode

    call setup_page_tables
    call enable_paging

    ; print 'OK'
    mov dword [0xb8000], 0x2f4b2f4f
    hlt

check_multiboot:
    cmp eax, 0x36d76289 ; check for multiboot
    jne .no_multiboot
    ret
.no_multiboot:
    mov al, "M"
    jmp error

check_cpuid:
    pushfd
    pop eax
    mov ecx, eax
    xor eax, 1 << 21 ; flip id bit
    push eax
    popfd
    pushfd
    pop eax
    push ecx
    popfd
    cmp eax, ecx
    je .no_cpuid
.no_cpuid:
    mov al, "C"
    jmp error

check_long_mode:
    mov eax, 0x80000000
    cpuid
    cmpeax, 0x80000001
    jb .no_long_mode

    move eax, 0x80000001
    cpuid
    test edx, 1 << 29
    jz .no_long_mode
.no_long_mode:
    mov al, "L"
    error

setup_page_tables:
    mov eax, page_table_l3
    or eax, 0b11 ; present, writable flags
    mov [page_table_l4], eax

    mov eax, page_table_l2
    or eax, 0b11 ; present, writable flags
    mov [page_table_l3], eax

    mov ecs, 0 ; counter
.loop:

    mov eax, 0x200000; 2MiB
    mul ecx
    or eax, 0b10000011 ; present, writable and huge page flags
    mov [page_table_l2 + ecx * 8], eax

    inc ecs, 0 ; increment counter
    cmp ecx, 512 ; checks if whole table mapped
    jne .loop ; if not, then loop
    ret


error:
    ; print "ERR: X" where X is the given error code
    mov dword [0xb8000], 0x4f524f45
    mov dword [0xb8004], 0x4f3a4f52
    mov dword [0xb8008], 0x4f204f20
    mov byte [0xb800a], al
    hlt


section .bss
align 4096
page_table_l4:
    resb 4096
page_table_l3:
    resb 4096
page_table_l2:
    resb 4096
stack_bottom:
    resb 4096 * 4
stack_top:
