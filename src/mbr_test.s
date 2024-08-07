.section .text
.code16

.globl entry

entry:
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

    # set DS segment
    push %es
    pop %ds

    # far jump to new memory region
    jmp $RAM_SEGMENT,$.bootloader
.bootloader:
    call serial_init

    mov $2342424, %eax
    call lba_to_chs
.halt:
    jmp .halt
