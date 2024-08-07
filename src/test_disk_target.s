# template file for disk parameters
# this will target disk 1

.globl disk_id
.globl disk_heads
.globl disk_cylinders
.globl disk_sectors

.section .rodata
disk_id:        .word 1
disk_heads:     .word 16
disk_cylinders: .word 519
disk_sectors:   .word 64
