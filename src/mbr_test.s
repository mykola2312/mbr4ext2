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

    # enumerate all system disks
    movw $127, disk_id
    #mov $128, %dl # already set bit 7 to 1 for fixed disk type
.disk_enum:
    # set disk id in DL with fixed disk bit on
    movw disk_id, %dx
    or $128, %dx

    mov $0x15, %ah
    int $0x13

    cmp $3, %ah # is fixed disk
    jnz .disk_skip

    # it's working fixed disk, lets print its number
    movw disk_id, %ax
    mov $10, %cx
    call itoa

    mov %ax, %si
    call prints

    mov $'\n', %al
    call serial_putc
.disk_skip:
    decw disk_id
    jns .disk_enum

    nop
.halt:
    jmp .halt

.section .bss
disk_id:   .word
