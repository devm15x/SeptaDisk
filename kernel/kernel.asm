bits 32

kernel_header:
    db "SEPT"
    dd kernel_end - kernel_header
    dd kernel_start - kernel_header
    dd 0

%include "kernel/drivers/video/vga.asm"

kernel_start:
    call switch_graphics

    mov al, 4
    call cls
    
    mov eax, 160
    mov ebx, 100
    mov cl, 15
    call put_pixel

    .hang:
        cli
        hlt
        jmp .hang
    
second_sector:
    db "READY!"

kernel_end: