.section .text
.code16

    # initialize stack
    mov $RAM_SEGMENT, %ax
    mov %ax, %ss
    mov $STACK_END, %sp

    # we're moving to 0x7C00 -> 0x7E00
    push $0x07C0
    pop %ds
    push %ss
    pop %es

    # set both source and destination pointers to zero, since we using segments
    xor %si, %si
    xor %di, %di

    # set counter with determined size by linker
    mov $BOOTLOADER_SIZE, %cx
    cld
.copy:
    lodsb
    stosb
    loop .copy

    # far jump to new memory region
    jmp $RAM_SEGMENT,$.bootloader
.bootloader:
    # set DS segment
    push %es
    pop %ds

.entry:
    call serial_init

    mov $msg, %si
    call prints

    mov $12345678, %eax
    mov $10, %ecx
    call itoa

    mov %ax, %si
    call prints

    mov $'\n', %al
    call serial_putc

    mov $0xCAFEBABE, %eax
    mov $16, %ecx
    call itoa

    mov %ax, %si
    call prints
.halt:
    jmp .halt

.section .rodata
msg:    .asciz "Test MBR hello world\r\n"
