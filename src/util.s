.section .text
.code16

.globl prints_number
.globl empty_string

# eax - number, ds:si - header string
prints_number:
    # header
    push %eax
    call prints
    pop %eax

    mov $10, %cx
    call itoa
    call prints

    # newline
    mov $'\n', %al
    call serial_putc

    ret

.section .rodata
empty_string: .byte 0
