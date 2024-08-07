.section .text
.code16

.globl test_disk_enum

# enumerate all system disks
test_disk_enum:
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
    mov $disk_enum_msg, %si
    call prints_number
.disk_skip:
    decw disk_id
    jns .disk_enum

    ret

.section .rodata
disk_enum_msg:  .asciz  "Disk "

.section .bss
disk_id:        .word
