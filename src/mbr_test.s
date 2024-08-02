.section .text
.code16

    mov $0x07C0, %ax
    mov %ax, %dx

    mov msg, %si
.putc_loop:
    lodsb
    or %al, %al
    jz .halt

    mov $0x0E, %ah
    mov $0, %al
    int $0x10
    jmp .putc_loop
.halt:
    hlt

.section .data
msg:    .asciz "Test MBR hello world\x0D\x0A" # len 22
