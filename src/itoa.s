.section .text
.code16

.globl itoa

.equ    ITOA_BUFFER_SIZE,   12

# eax - number
# ecx - base
itoa:
    push %bx
    xor %edx, %edx
    mov $numbers, %bx

    mov $(itoa_result + ITOA_BUFFER_SIZE - 1), %di
    std
.div:
    divl %ecx
    or %eax, %eax
    jz .end         # we run out of numbers

    # yep, we're using LUT for number -> character conversion since ASCII is a fuck
    push %eax
    add %bx, %ax
    stosb
    pop %eax

    jmp .div
.end:
    cld

    # we return ptr to string, since we're pushing chars in reverse, therefore
    # beginning of string will change
    mov %di, %ax

    pop %bx
    ret

.section .bss
.comm       itoa_result,        ITOA_BUFFER_SIZE

.section .rodata
numbers:    .ascii "0123456789ABCDEF"