.section .text
.code16

    mov $BOOTLOADER_SIZE, %ax

    mov $0x07C0, %ax
    mov %ax, %ds

    mov msg, %si
    cld
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
