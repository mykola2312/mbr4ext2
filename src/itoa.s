.section .text
.code16

.globl itoa

.equ    ITOA_BUFFER_SIZE,   12

# eax - number
# ecx - base
# return - ds:si pointing to string number
itoa:
    push %bx
    xor %edx, %edx
    mov $numbers, %bx

    mov $(itoa_result + ITOA_BUFFER_SIZE - 1), %di
    movb $0, (%di)
    dec %di
    std
.div:
    divl %ecx

    # yep, we're using LUT for number -> character conversion since ASCII is a fuck
    push %eax
    movb (%ebx,%edx,1), %al
    stosb
    pop %eax

    xor %edx, %edx
    
    or %eax, %eax
    jnz .div
.end:
    # we run out of numbers
    cld

    # we return ptr to string, since we're pushing chars in reverse, therefore
    # beginning of string will change
    inc %di
    mov %di, %si

    pop %bx
    ret

.section .bss
.comm       itoa_result,        ITOA_BUFFER_SIZE

.section .rodata
numbers:    .ascii "0123456789ABCDEF"
