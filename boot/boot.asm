bits 16
org 0x7C00 ; tell the assembler to add 0x7C00 offset to labels, segments will be zeroed

start:
    .setup_segments:
        cli

        xor ax, ax
        mov ax, 0
        mov ds, ax
        mov es, ax
        mov fs, ax
        mov gs, ax
        mov ss, ax

    .setup_stack:
        mov sp, 0x7c00
        sti ;stack goes downwards

    .save_boot_device_number:
        mov byte[bootdev], dl ; boot device number is passed in dl by BIOS
    
    .check_lba_extentions:
        mov ah, 0x41
        mov bx, 0x55AA
        mov dl, [bootdev]    
        int 0x13
        jc .hang ; carry flag is set if bios lba extensions don't exist
        cmp bx, 0xAA55
        jne .hang

    .load_next_sector:
        mov eax, 1
        mov bx, next_sector 
        mov cx, 1
        call read_sectors
        jc .hang

        jmp next_sector ; jump to the next sector

    .hang:
        jmp $

read_sectors:

    .save_registers:
        pusha ; registers are preserved

    .build_disk_address_packet:
        mov si, 0x8000             ; disk address packet is at 0x00008000 (ds = 0)
        mov word [ds:si], 0x10     ; size of packet is 16 bytes
        mov word [ds:si + 2], cx   ; sector count is in cx
        mov word [ds:si + 4], bx   ; memory offset is in bx
        mov word [ds:si + 6], fs   ; memory segment is in fs
        mov dword [ds:si + 8], eax ; low starting lba sector is in eax
        mov dword [ds:si + 12], 0
    
    .invoke_disk_int:
        mov ah, 0x42
        mov dl, byte [bootdev]
        int 0x13
    
    .return:
        popa ; restore registers
        ret ; return

variables:
    bootdev db 0

end_boot_sector:

    times 510 - ($ - $$) db 0
    db 0x55
    db 0xAA

%if ($ - $$) != 512
    %error "next_sector is not at byte 512"
%endif

;Next Sector Start
next_sector:

    .load_kernel_header:
        mov ax, 0x1000
        mov fs, ax
        xor bx, bx

        mov eax, 2
        mov cx, 1
        call read_sectors
        jc .hang

    .check_kernel_header:
        mov ax, 0x1000
        mov ds, ax

        cmp dword [0], 0x54504553
        jne .bad_kernel

        mov eax, dword [4]
        add eax, 511
        shr eax, 9

        mov cx, ax

        xor dx, dx
        mov ds, dx

    .load_kernel:
        mov ax, 0x1000
        mov fs, ax
        xor bx, bx

        mov eax, 2
        call read_sectors
        jc .hang
    
    .print_string:
        mov si, message
        cld

    .print_loop:
        lodsb
        cmp al, 0
        je .prepare_protected_mode

        mov ah, 0x0E
        int 0x10

        jmp .print_loop

    .prepare_protected_mode:
        cli

        lgdt [gdt_descriptor]

        mov eax, cr0
        or eax, 1
        mov cr0, eax
        jmp CODE32:protected_mode

    .bad_kernel:
        jmp $

    .hang:
        jmp $

message:
    db "SeptaDisk v0.0.1", 0


%include "boot/kickstart.asm"


bits 32

protected_mode:
    mov ax, DATA32
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov esp, 0x90000
    cld

    mov eax, dword [0x10000 + 8]
    add eax, 0x10000
    jmp eax
.hang:
    cli
    hlt
    jmp .hang


clear_screen:
    mov edi, 0xB8000
    mov ecx, 80 * 25
    mov ax, 0x0F20

.clear:
    mov word [edi], ax
    add edi, 2
    loop .clear

    ret


print_string32:

.loop:
    lodsb
    test al, al
    jz .done

    mov ah, 0x0F
    mov word [edi], ax
    add edi, 2

    jmp .loop

.done:
    ret


message32_title:
    db "SeptaDisk v0.0.1", 0

message32_mode:
    db "Currently in 32bit Mode", 0

bits 16

end_second_sector:

%if ($ - next_sector) > 512
    %error "Second sector is too large"
%endif
   
    times 512 - ($ - next_sector) db 0