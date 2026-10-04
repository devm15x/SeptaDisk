bits 32

switch_graphics:
    ;MISC
    cli
    mov dx, 0x03C2
    mov al, 01100011b
    out dx, al

    ; CRTC
    mov dx, 0x03D4

    mov ax, 0x0E11
    out dx, ax
    mov ax, 0x5F00
    out dx, ax
    mov ax, 0x4F01
    out dx, ax
    mov ax, 0x5002
    out dx, ax
    mov ax, 0x8203
    out dx, ax
    mov ax, 0x5404
    out dx, ax
    mov ax, 0x8005
    out dx, ax
    mov ax, 0x2813
    out dx, ax
    mov ax, 0xBF06
    out dx, ax
    mov ax, 0x1F07
    out dx, ax
    mov ax, 0x4109
    out dx, ax
    mov ax, 0x9C10
    out dx, ax
    mov ax, 0x8E11
    out dx, ax
    mov ax, 0x8F12
    out dx, ax
    mov ax, 0x9615
    out dx, ax
    mov ax, 0xB916
    out dx, ax
    mov ax, 0x0008
    out dx, ax
    mov ax, 0x4014
    out dx, ax
    mov ax, 0xA317
    out dx, ax

    ; Sequencer
    mov dx, 0x03C4

    mov ax, 0x0100
    out dx, ax
    mov ax, 0x0101
    out dx, ax
    mov ax, 0x0F02
    out dx, ax
    mov ax, 0x0003
    out dx, ax
    mov ax, 0x0E04
    out dx, ax
    mov ax, 0x0300
    out dx, ax
    mov ax, 0x0301
    out dx, ax

    ; Graphics Controller
    mov dx, 0x03CE

    mov ax, 0x0000
    out dx, ax
    mov ax, 0x0001
    out dx, ax
    mov ax, 0x0002
    out dx, ax
    mov ax, 0x0003
    out dx, ax
    mov ax, 0x0004
    out dx, ax
    mov ax, 0x4005
    out dx, ax
    mov ax, 0x0506
    out dx, ax
    mov ax, 0x0F07
    out dx, ax
    mov ax, 0xFF08
    out dx, ax

    ; Attribute Controller
    mov dx, 0x03DA
    in al, dx

    mov dx, 0x03C0

    mov al, 0x30
    out dx, al
    mov al, 0x41
    out dx, al

    mov al, 0x31
    out dx, al
    mov al, 0x00
    out dx, al

    mov al, 0x32
    out dx, al
    mov al, 0x0F
    out dx, al

    mov al, 0x33
    out dx, al
    mov al, 0x00
    out dx, al

    mov al, 0x34
    out dx, al
    mov al, 0x00
    out dx, al

    mov al, 0x20
    out dx, al

    xor esi, esi

.palette_loop:
    cmp esi, 15
    jge .palette_done

    mov eax, esi
    shl eax, 4 ; eax = 16 * i

    ; BLACK
    mov bl, 0
    mov cl, 0
    mov ch, 0
    call g_set_color

    ; BLUE
    inc al
    mov bl, 0
    mov cl, 0
    mov ch, 168
    call g_set_color

    ; GREEN
    inc al
    mov bl, 0
    mov cl, 168
    mov ch, 0
    call g_set_color

    ; CYAN
    inc al
    mov bl, 0
    mov cl, 168
    mov ch, 168
    call g_set_color

    ; RED
    inc al
    mov bl, 168
    mov cl, 0
    mov ch, 0
    call g_set_color

    ; PURPLE
    inc al
    mov bl, 168
    mov cl, 0
    mov ch, 168
    call g_set_color

    ; BROWN
    inc al
    mov bl, 168
    mov cl, 84
    mov ch, 0
    call g_set_color

    ; GRAY
    inc al
    mov bl, 168
    mov cl, 168
    mov ch, 168
    call g_set_color

    ; DARK GRAY
    inc al
    mov bl, 84
    mov cl, 84
    mov ch, 84
    call g_set_color

    ; LIGHT BLUE
    inc al
    mov bl, 84
    mov cl, 84
    mov ch, 252
    call g_set_color

    ; LIGHT GREEN
    inc al
    mov bl, 84
    mov cl, 252
    mov ch, 84
    call g_set_color

    ; LIGHT CYAN
    inc al
    mov bl, 84
    mov cl, 252
    mov ch, 252
    call g_set_color

    ; LIGHT RED
    inc al
    mov bl, 252
    mov cl, 84
    mov ch, 84
    call g_set_color

    ; LIGHT PURPLE
    inc al
    mov bl, 252
    mov cl, 84
    mov ch, 252
    call g_set_color

    ; YELLOW
    inc al
    mov bl, 252
    mov cl, 168
    mov ch, 84
    call g_set_color

    ; WHITE
    inc al
    mov bl, 252
    mov cl, 252
    mov ch, 252
    call g_set_color

    inc esi
    jmp .palette_loop

.palette_done:
    sti
    ret

; AL = palette index
; BL = red
; CL = green
; CH = blue

g_set_color:
    push ax
    push dx

    mov dx, 0x03C8
    out dx, al

    mov dx, 0x03C9

    mov al, bl
    shr al, 2
    out dx, al

    mov al, cl
    shr al, 2
    out dx, al

    mov al, ch
    shr al, 2
    out dx, al

    pop dx
    pop ax
    ret

put_pixel:
    push edi

    mov edi, ebx
    imul edi, 320
    add edi, eax
    add edi, 0xA0000

    mov byte [edi], cl

    pop edi
    ret

; AL = color
cls:
    push edi
    push ecx

    mov edi, 0xA0000
    mov ecx, 320 * 200
    rep stosb

    pop ecx
    pop edi
    ret