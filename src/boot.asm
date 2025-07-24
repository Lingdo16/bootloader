[BITS 16]
[ORG 0x7c00]


CODE_OFFSET equ 0x8
DATA_OFFSET equ 0x10


KERNEL_LOAD_SEG equ 0x1000
KERNEL_START_ADDR equ 0x100000

start:
    cli
    mov ax, 0x00
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti 

     
;Load kernel
mov bx, KERNEL_LOAD_SEG
mov dh, 0x00
mov dl, 0x80
mov cl, 0x02
mov ch, 0x00
mov ah, 0x02
mov al, 8
int 0x13


jc disk_read_error



load_PM:
    cli
    lgdt[gdt_descriptor]
    mov eax, cr0
    or al, 1
    mov cr0, eax
    jmp CODE_OFFSET:PModeMain


disk_read_error:
    hlt


gdt_start:
    dd 0x00000000
    dd 0x00000000

    ;code segment descriptor
    dw 0xFFFF       ;limit
    dw 0x0000       ;base
    db 0x00         ;base
    db 10011010b    ;access byte
    db 11001111b    ;flag
    db 0x00         ;base

    ;Data segment descriptor
    dw 0xFFFF       ;limit
    dw 0x0000       ;base
    db 0x00         ;base
    db 10010010b    ;access byte
    db 11001111b    ;flag
    db 0x00         ;base

gdt_end:
    

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start


PModeMain:
    mov ax, DATA_OFFSET
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov ss, ax
    mov gs, ax
    mov ebp, 0x9C00
    mov esp, ebp


    in al, 0x92
    or al, 2
    out 0x92, al

    jmp CODE_OFFSET:KERNEL_START_ADDR




times 510 - ($ - $$) db 0


dw 0xAA55


