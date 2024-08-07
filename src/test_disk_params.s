.section .text
.code16

.globl test_disk_params

# al - drive number
test_disk_params:
    mov %al, %dl
    and $128, %dl

    mov $0x08, %al
    int $0x13

    xor %ax, %ax
    # write slaves
    mov %dl, %al
    movw %ax, disk_slaves
    # write heads
    mov %dh, %al
    movw %ax, disk_heads
    # write cylinders
    # write lower part
    mov %ch, %al
    # write higher part
    mov %cl, %ah
    shr $3, %ah # shift 6 bits to right, because cylinder num's high part is in high 2 bits
    mov %ax, disk_cylinders
    # write sectors per cylinder
    xor %ax, %ax
    mov %cl, %al
    and $0b00111111, %al # 6 lower bits are sector count
    mov %ax, disk_sectors

    # now we can print all this info
    movw disk_slaves, %ax
    mov $str_slaves, %si
    call prints_number

    movw disk_heads, %ax
    mov $str_heads, %si
    call prints_number

    movw disk_cylinders, %ax
    mov $str_cylinders, %si
    call prints_number

    movw disk_sectors, %ax
    mov $str_sectors, %si
    call prints_number

    ret

.section .rodata
str_slaves:     .asciz "Disk slaves: "
str_heads:      .asciz "Disk heads: "
str_cylinders:  .asciz "Disk cylinders: "
str_sectors:    .asciz "Disk sectors per cylinder: "

.section .bss
disk_slaves:    .word   # disk attached slaves
disk_heads:     .word   # number of heads
disk_cylinders: .word   # number of cylinders
disk_sectors:   .word   # sectors in cylinder
