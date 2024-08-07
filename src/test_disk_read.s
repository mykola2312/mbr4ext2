.section .text
.code16

.globl test_disk_read

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
    lodsd # load 32 bit into eax
    mov $str_taste, %si
    call prints_number

    ret

.section .rodata
str_taste:  .asciz  "Sector test pattern: "
