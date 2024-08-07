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

    mov $2048, %eax         # LBA
    mov $1, %cl             # number of sectors
    mov $test_sector, %di   # buffer destination
    call test_disk_read

    // mov test_sector, %eax
    // mov $str_test_pattern, %si
    // call prints_number
.halt:
    jmp .halt

.section .rodata
str_test_pattern:   .asciz  "Test pattern: "

.section .bss
.comm test_sector, 512
