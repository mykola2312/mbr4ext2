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
    sub $12, %sp
    # -4(%bp)   dword   LBA
    # -6(%bp)   word    disk_sectors * 2
    # -8(%bp)   word    cylinder
    # -10(%bp)  word    head
    # -12(%bp)  word    sector
    mov %eax, -4(%bp)       # save LBA

    # chs->head = (lba % (conf->num_sectors * 2)) / conf->num_sectors;
    # (conf->num_sectors * 2)
    xor %dx, %dx
    movw disk_sectors, %ax
    mov $2, %bx
    mul %bx
    # ax - num_sectors * 2
    mov %ax, -6(%bp)

    # (lba %
    mov %ax, %bx            # disk_sectors * 2
    mov -4(%bp), %eax       # lba
    div %ebx                # %
    # edx, as remainder, now must be divided by num_sectors
    mov %dx, %ax    # remainder ain't gonna exceed 16 bit value
    xor %dx, %dx    # always clear god damn EDX it can screw your div/mul!
    divw disk_sectors
    # ax - head
    mov %ax, -10(%bp)

    # chs->cylinder = (lba / (conf->num_sectors * 2));
    mov -4(%bp), %eax       # LBA
    mov -6(%bp), %bx        # disk_sectors * 2
    div %ebx                # /
    # ax - cylinder
    mov %ax, -8(%bp)

    # chs->sector = (lba % conf->num_sectors + 1);
    mov -4(%bp), %eax       # LBA
    movw disk_sectors, %bx
    xor %dx, %dx
    div %ebx
    # dx - sector, but needs +1
    inc %dx
    mov %dx, -12(%bp)

    xor %eax, %eax          # flush eax because it loves to screw up itoa

    # convert to BIOS CHS
    # DH - head number
    # CH - cylinder number, lower 8 bits
    # CL - cylinder number 2 high bits, 6 lower bits is sector count
    
    # head
    mov -10(%bp), %dh
    # cylinder
    mov -8(%bp), %ax
    mov %al, %ch            # cylinder 8 low port
    shr $6, %ah             # bump low 2 bits to high 2 bits
    mov %ah, %cl
    # sector
    mov -12(%bp), %ax
    or %al, %cl             # "apply" sector 6 bits to CL lower part
    # we won't waste any byte more for masking, since sector calculation
    # must have clamped value to 63 max

    mov %bp, %sp
    pop %bp
    ret

# eax   - LBA address
# cl    - number of sectors
# es:di - destination
test_disk_read:
    push %cx                # we just have to push it since lba_to_chs will overwrite it
    # convert LBA and encode it in BIOS CHS
    call lba_to_chs

    movb disk_id, %dl
    or $0x80, %dl

    pop %ax                 # now it will have number of sectors
    mov $0x02, %ah
    mov %di, %bx
    int $0x13

    # BUG: something funny about stack at this point
.debug: jmp .debug

    ret

.section .rodata
str_cylinder:   .asciz  "Cylinder: "
str_head:       .asciz  "Head: "
str_sector:     .asciz  "Sector: "
