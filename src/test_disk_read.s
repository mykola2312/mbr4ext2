.section .text
.code16

.globl lba_to_chs
.globl test_disk_read

# eax - LBA
# dh - head, ch - cylinder low 8 bits, cl - high 2 cylinder bits, 6 low bits is sector
lba_to_chs:
    # we actually gonna need stack frame for that one lol
    push %bp
    mov %sp, %bp
    sub $10, %sp
    # -4(%bp)   dword   LBA
    # -6(%bp)   word    cylinder
    # -8(%bp)   word    head
    # -10(%bp)  word    sector
    mov %eax, -4(%bp) # save LBA

    # chs->head = lba / (conf->num_heads * conf->num_sectors);
    # (conf->num_heads * conf->num_sectors)
    movw disk_heads, %ax
    mulw disk_sectors
    mov %ax, %bx
    # lba /
    xor %dx, %dx
    mov -4(%bp), %eax
    div %ebx
    # ax - head
    mov %ax, -8(%bp)

    # chs->cylinder = (lba / conf->num_sectors) % conf->num_heads;
    # (lba / conf->num_sectors)
    xor %dx, %dx
    movw disk_sectors, %bx
    mov -4(%bp), %eax
    div %ebx
    # % conf->num_heads
    xor %dx, %dx
    divw disk_heads
    # dx, as remainder, now has cylinder
    mov %dx, -6(%bp)

    # chs->sector = (lba % conf->num_sectors) + 1;
    xor %dx, %dx
    mov -4(%bp), %eax
    divw disk_sectors
    # dx now has sector num, but we need to increment it
    inc %dx
    # dx - sector
    mov %dx, -10(%bp)

    # now lets print C H S values
    mov -6(%bp), %ax
    mov $str_cylinder, %si
    call prints_number

    mov -8(%bp), %ax
    mov $str_head, %si
    call prints_number

    mov -10(%bp), %ax
    mov $str_sector, %si
    call prints_number

    mov %bp, %sp
    pop %bp
    ret

# eax   - LBA address
# cx    - number of sectors
# es:di - destination
test_disk_read:
    # here we need to convert LBA into CHS
    ret

# ds:si - sector
test_disk_taste_sector:
    # test pattern partition - each sector has 32 bit integer in beginning
    # so we read this integer and output it, it must increment as well as LBA address
    mov (%esi), %eax
    mov $str_taste, %si
    call prints_number

    ret

.section .rodata
str_cylinder:   .asciz  "Cylinder: "
str_head:       .asciz  "Head: "
str_sector:     .asciz  "Sector: "
str_taste:      .asciz  "Sector test pattern: "
