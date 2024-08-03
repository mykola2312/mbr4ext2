.section .text
.code16

    # we're moving to 0050, 0x7C00 -> 0x0500
    # so, DS is 0x07C0 and ES is 0x0050  
    mov $0x07C0, %ax
    mov %ax, %ds
    mov $0x0050, %ax
    mov %ax, %es

    # set both source and destination pointers to zero, since we using segments
    xor %ax, %ax
    mov %ax, %si
    mov %ax, %di

    # set counter with determined size by linker
    mov $BOOTLOADER_SIZE, %cx
    cld
.copy:
    lodsb
    stosb
    loop .copy

    # far jump to new memory region
    jmp $0x0050,$.bootloader
.bootloader:

    mov $msg, %si
.putc_loop:
    lodsb
    or %al, %al
    jz .halt

    mov $0x0E, %ah
    mov $0x00, %bh
    int $0x10
    jmp .putc_loop
.halt:
    jmp .halt

.section .data
msg:    .asciz "Test MBR hello world\r\n"
