bits 32

kernel_header:
    db "SEPT" ; Magic
    dd kernel_end - kernel_header ; Filesize
    dd kernel_start - kernel_header ; Offset
    dd 0

kernel_start:
    ; Kernel code goes here
    cli
    hlt

kernel_end: